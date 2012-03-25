#!/usr/bin/env python

from waflib import *
from waflib.TaskGen import *
import os

FLAMBE_ROOT = os.path.dirname(__file__) + "/.."
SERVER_CONFIG = "/tmp/flambe-server.py"

def options(ctx):
    group = ctx.add_option_group("flambe options")
    group.add_option("--debug", action="store_true", help="Build a debug version for development")
    group.add_option("--no-flash", action="store_true", help="Skip all Flash builds")
    group.add_option("--no-html", action="store_true", help="Skip all HTML builds")
    group.add_option("--no-android", action="store_true", help="Skip all Android builds")
    group.add_option("--no-ios", action="store_true", help="Skip all iOS builds")

def configure(ctx):
    ctx.load("haxe", tooldir=FLAMBE_ROOT+"/tools")
    ctx.find_program("java", var="JAVA")
    ctx.find_program("npm", var="NPM", mandatory=False)
    ctx.find_program("adt", var="ADT", mandatory=False)
    ctx.find_program("adb", var="ADB", mandatory=False)

    ctx.env.debug = ctx.options.debug
    ctx.env.has_flash = (not ctx.options.no_flash)
    ctx.env.has_html = (not ctx.options.no_html)
    ctx.env.has_android = (not ctx.options.no_android) and bool(ctx.env.ADT and ctx.env.ADB)
    ctx.env.has_ios = False # (not ctx.options.no_ios) and bool(ctx.env.ADT)

@feature("flambe")
def apply_flambe(ctx):
    Utils.def_attrs(ctx, platforms="flash html", app="default",
        classpath="", flags="", libs="", assetBase=None,
        airCert="etc/air-cert.pfx", airDesc="etc/air-desc.xml", airPassword=None,
        iosProfile="etc/ios.mobileprovision")

    classpath = [ ctx.path.find_dir("src"), ctx.bld.root.find_dir(FLAMBE_ROOT+"/src") ] + \
        Utils.to_list(ctx.classpath) # The classpath option should be a list of nodes
    flags = ["-main", ctx.main, "--dead-code-elimination"] + Utils.to_list(ctx.flags)
    libs = ["format"] + Utils.to_list(ctx.libs)
    platforms = Utils.to_list(ctx.platforms)
    debug = ctx.env.debug

    # Figure out what should be built
    buildFlash = "flash" in platforms and ctx.env.has_flash
    buildHtml = "html" in platforms and ctx.env.has_html
    buildAndroid = "android" in platforms and ctx.env.has_android
    buildIOS = "ios" in platforms and ctx.env.has_ios

    assetDir = ctx.path.find_dir("assets")
    assetList = [] if assetDir is None else assetDir.ant_glob("**/*")

    installPrefix = "deploy/" + ctx.app + "/"
    buildPrefix = ctx.app + "/"

    closure = ctx.bld.root.find_resource(FLAMBE_ROOT+"/tools/closure.jar")

    flashVersion = "10.1"

    # The files that are built and should be installed
    outputs = []

    if debug:
        flags += "-debug --no-opt --no-inline".split()
    else:
        flags += "--no-traces -D flambe_disable_logging".split()

    # Inject a custom asset base URL if provided
    if ctx.assetBase != None:
        flags += [
            "--macro",
            "addMetadata(\"@assetBase('%s')\", \"flambe.asset.Manifest\")" % ctx.assetBase,
        ]

    if buildFlash:
        flashFlags = ["-swf-version", flashVersion]

        swf = buildPrefix + "app-flash.swf"
        outputs.append(swf)

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + flashFlags,
            libs=libs,
            target=swf)
        ctx.bld.install_files(installPrefix + "web", swf)

    if buildHtml:
        htmlFlags = "-D html --js-modern".split()

        uncompressed = buildPrefix + "app-html.uncompressed.js"
        js = buildPrefix + "app-html.js"
        outputs.append(js)

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + htmlFlags,
            libs=libs,
            target=js if debug else uncompressed)
        if not debug:
            import textwrap
            wrapper = textwrap.dedent("""\
                /**
                 * Cooked with Flambe
                 * https://github.com/aduros/flambe
                 */
                %%output%%""")
            ctx.bld(rule=("%s -jar %s --js \"${SRC}\" --js_output_file \"${TGT}\" " +
                "--output_wrapper %s --warning_level QUIET --language_in ES5_STRICT") %
                    (quote(ctx.env.JAVA), quote(closure.abspath()), quote(wrapper)),
                source=uncompressed, target=js)
        else:
            ctx.bld.install_files(installPrefix + "web", js + ".map")
        ctx.bld.install_files(installPrefix + "web", js)

    if buildAndroid or buildIOS:
        # Since the captive runtime is used for apps, we can always use the latest swf version
        airFlags = "-D air -swf-version 11.2".split()

        swf = buildPrefix + "app-air.swf"

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + airFlags,
            libs=libs,
            target=swf)

        adt = ctx.env.ADT
        if not adt:
            ctx.bld.fatal("adt from the AIR SDK is required, " + \
                "ensure it's in your $PATH and re-run waf configure.")

        airCert = ctx.path.find_resource(ctx.airCert)
        if not airCert:
            ctx.bld.fatal("Could not find AIR certificate at %s." % ctx.airCert)

        airDesc = ctx.path.find_resource(ctx.airDesc)
        if not airCert:
            ctx.bld.fatal("Could not find AIR descriptor at %s." % ctx.airDesc)

        airPassword = ctx.airPassword
        if not airPassword:
            ctx.bld.fatal("You must specify the airPassword to your certificate.")

        airApps = []

        if buildAndroid:
            adb = ctx.env.ADB
            if not adb:
                ctx.bld.fatal("adb from the Android SDK is required, " + \
                    "ensure it's in your $PATH and re-run waf configure.")

            # Derive the location of the Android SDK from adb's path
            androidRoot = adb[0:adb.rindex("/platform-tools/adb")]

            apkType = "apk-debug" if debug else "apk-captive-runtime"
            rule = ("%s -package -target %s " +
                "-storetype pkcs12 -keystore %s -storepass %s " +
                "\"${TGT}\" %s " +
                "-platformsdk %s ") % (
                    quote(adt), apkType, quote(airCert.abspath()), quote(airPassword),
                    quote(airDesc.abspath()), quote(androidRoot))

            if ctx.bld.cmd == "install":
                # Install the APK if there's a device plugged in
                def install_apk(ctx):
                    state = ctx.cmd_and_log("%s get-state" % quote(adb), quiet=Context.STDOUT)
                    if state == "device\n":
                        ctx.to_log("Installing APK to device...\n")
                        ctx.exec_command("%s install -rs %s" %
                            (quote(adb), quote(installPrefix + "apps/app-android.apk")))
                ctx.bld.add_post_fun(install_apk)

            airApps.append((buildPrefix + "app-android.apk", rule))

        if buildIOS:
            iosProfile = ctx.path.find_resource(ctx.iosProfile)
            if not iosProfile:
                ctx.bld.fatal("Could not find iOS provisioning profile at %s." % ctx.iosProfile)

            # TODO(bruno): Add -connect [host] for debug builds, if fdb is present
            # TODO(bruno): Handle final app store packaging
            # TODO(bruno): Is there a way to install an IPA from the command line? (sans jailbreak)
            ipaType = "ipa-debug" if debug else "ipa-ad-hoc"
            rule = ("%s -package -target %s -provisioning-profile %s " +
                "-storetype pkcs12 -keystore %s -storepass %s " +
                "\"${TGT}\" %s ") % (
                    quote(adt), ipaType, quote(iosProfile.abspath()),
                    quote(airCert.abspath()), quote(airPassword), quote(airDesc.abspath()))

            airApps.append((buildPrefix + "app-ios.ipa", rule))

        # Build all our AIR apps, appending common configuration
        for target, rule in airApps:
            outputs.append(target)

            # Include the swf
            rule += "-C %s %s " % (quote(buildPrefix), "app-air.swf")

            # Include the assets
            if assetDir is not None:
                # Exclude assets Flash will never use
                airAssets = assetDir.ant_glob("**/*", excl="**/*.(ogg|wav|m4a)")
                rule += "-C %s %s " % (
                    quote(ctx.path.abspath()),
                    " ".join([ quote(asset.nice_path()) for asset in airAssets ]))

            ctx.bld(rule=rule, target=target, source=swf)
            ctx.bld.add_manual_dependency(target, airCert);
            ctx.bld.add_manual_dependency(target, airDesc);
            ctx.bld.install_files(installPrefix + "apps", target)

    # Common web stuff
    if buildFlash or buildHtml:
        # Compile the embedder script
        embedder = buildPrefix + "flambe.js"
        scripts = ctx.bld.root.find_dir(FLAMBE_ROOT+"/tools/embedder").ant_glob("*.js")
        ctx.bld(rule="%s -jar %s -D flambe.FLASH_VERSION=\\'%s\\' --js_output_file \"${TGT}\" %s" %
            (quote(ctx.env.JAVA), quote(closure.abspath()), flashVersion,
            " ".join(["--js " + quote(script.abspath()) for script in scripts]),
            ), target=embedder)
        for script in scripts:
            ctx.bld.add_manual_dependency(embedder, script)
        ctx.bld.install_files(installPrefix + "web", embedder)

        # Install the default embedder page if necessary
        if ctx.bld.path.find_dir("web") == None:
            ctx.bld.install_files(installPrefix + "web", [
                ctx.bld.root.find_resource(FLAMBE_ROOT+"/tools/embedder/index.html"),
                ctx.bld.root.find_resource(FLAMBE_ROOT+"/tools/embedder/logo.png"),
            ])

        # Install the assets
        if assetDir is not None:
            ctx.bld.install_files(installPrefix + "web/assets", assetList,
                cwd=assetDir, relative_trick=True)

        # Also install any other files in /web
        ctx.bld.install_files(installPrefix, ctx.path.ant_glob("web/**/*"), relative_trick=True)

    # Force a rebuild when anything in the asset directory has been updated
    for asset in assetList:
        for output in outputs:
            ctx.bld.add_manual_dependency(output, asset)

@feature("flambe-server")
def apply_flambe_server(ctx):
    Utils.def_attrs(ctx, app="default", classpath="", flags="", libs="", npmLibs="", include="")

    classpath = [ ctx.path.find_dir("src"), ctx.bld.root.find_dir(FLAMBE_ROOT+"/src") ] + \
        Utils.to_list(ctx.classpath) # The classpath option should be a list of nodes
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = Utils.to_list(ctx.libs)
    npmLibs = Utils.to_list(ctx.npmLibs)
    include = Utils.to_list(ctx.include)
    installPrefix = "deploy/" + ctx.app + "/server/"
    buildPrefix = ctx.app + "/"

    if npmLibs:
        if not ctx.env.NPM:
            ctx.bld.fatal("npm is required to specify node libraries, " + \
                "ensure it's in your $PATH and re-run waf configure.")

        cwd = ctx.path.get_bld().make_node(buildPrefix)
        for npmLib in npmLibs:
            ctx.bld(rule="%s install %s" % (quote(ctx.env.NPM), npmLib), cwd=cwd.abspath())

        if ctx.bld.cmd == "install":
            # Find files to install only after npm has downloaded them
            def installModules(ctx):
                dir = ctx.bldnode.find_dir(buildPrefix)
                for file in dir.ant_glob("node_modules/**/*"):
                    ctx.do_install(file.abspath(), installPrefix + file.path_from(dir))
            ctx.bld.add_post_fun(installModules)

    # TODO(bruno): Use the node externs in haxelib
    flags += "-D server".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
    else:
        flags += "--no-traces".split()

    server = buildPrefix + "server.js"
    ctx.bld(features="haxe", classpath=classpath, flags=flags, libs=libs, target=server)
    ctx.bld.install_files(installPrefix, server)

    # Mark any other custom files for installation
    if include:
        ctx.bld.install_files(installPrefix, include, relative_trick=True)

    file = SERVER_CONFIG
    conf = ConfigSet.ConfigSet()
    try:
        conf.load(file)
    except (IOError):
        pass
    conf.script = installPrefix + "server.js"
    conf.store(file)

    # Restart the development server when installing
    if ctx.bld.cmd == "install":
        ctx.bld.add_post_fun(restart_server)

# Spawns a development server for testing
def server(ctx):
    from subprocess import Popen
    print("Restart the server using `waf restart_server`.")
    while True:
        print("")
        conf = ConfigSet.ConfigSet(SERVER_CONFIG)
        p = Popen(["node", conf.script])
        conf.pid = p.pid
        conf.store(SERVER_CONFIG)
        p.wait()
Context.g_module.__dict__["server"] = server

# Restart the local dev server
def restart_server(ctx):
    import signal
    try:
        conf = ConfigSet.ConfigSet(SERVER_CONFIG)
        if "pid" in conf:
            os.kill(conf.pid, signal.SIGTERM)
    except (IOError, OSError):
        pass
Context.g_module.__dict__["restart_server"] = restart_server

# Surround a string in quotes
def quote(string):
    return '"' + string + '"';
