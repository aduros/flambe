#!/usr/bin/env python

from waflib import *
from waflib.TaskGen import *
import os

# Waf hates absolute paths for some reason
FLAMBE_ROOT = os.path.dirname(__file__) + "/.."

SERVER_CONFIG = "/tmp/flambe-server.py"

def options(ctx):
    ctx.add_option("--debug", action="store_true", default=False,
        help="Build a development version")

def configure(ctx):
    ctx.load("haxe", tooldir=FLAMBE_ROOT+"/tools")
    ctx.find_program("java", var="JAVA")
    ctx.find_program("npm", var="NPM", mandatory=False)
    ctx.find_program("adt", var="ADT", mandatory=False)
    ctx.find_program("adb", var="ADB", mandatory=False)
    ctx.env.debug = ctx.options.debug
    ctx.env.has_android = bool(ctx.env.ADT and ctx.env.ADB)

@feature("flambe")
def apply_flambe(ctx):
    Utils.def_attrs(ctx, platforms="flash html", app="default",
        classpath="", flags="", libs="", assetBase=None,
        airCert="etc/air-cert.pfx", airDesc="etc/air-desc.xml", airPassword=None)

    classpath=["src", FLAMBE_ROOT+"/src"] + Utils.to_list(ctx.classpath)
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = ["hxJson2"] + Utils.to_list(ctx.libs)
    platforms = Utils.to_list(ctx.platforms)
    debug = ctx.env.debug

    assetDir = ctx.path.find_dir("assets")
    assetList = [] if assetDir is None else assetDir.ant_glob("**/*")

    installPrefix = "deploy/" + ctx.app + "/"
    buildPrefix = ctx.app + "/"

    closure = ctx.bld.path.find_resource(FLAMBE_ROOT+"/tools/closure.jar")

    # Don't forget to change flambe.js when changing -swf-version!
    flash_flags = "-swf-version 10 -swf-header 640:480:60:ffffff".split()
    html_flags = "-D html".split()

    # The files that are built and should be installed
    outputs = []

    if debug:
        flags += "-D debug --no-opt --no-inline".split()
        # Only generate line numbers for Flash. The stack -debug creates for JS isn't too useful
        flash_flags += ["-debug"]
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    # Inject a custom asset base URL if provided
    if ctx.assetBase != None:
        flags += [
            "--macro",
            "addMetadata(\"@assetBase('%s')\", \"flambe.asset.Manifest\")" % ctx.assetBase,
        ]

    if "flash" in platforms:
        swf = buildPrefix + "app-flash.swf"
        outputs.append(swf)
        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + flash_flags,
            libs=libs,
            target=swf)
        ctx.bld.install_files(installPrefix + "web", swf)

    if "html" in platforms:
        uncompressed = buildPrefix + "app-html.uncompressed.js"
        js = buildPrefix + "app-html.js"
        outputs.append(js)
        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + html_flags,
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
            ctx.bld(rule=("%s -jar '%s' --js ${SRC} --js_output_file ${TGT} " +
                "--output_wrapper '%s' --warning_level QUIET") %
                    (ctx.env.JAVA, closure.abspath(), wrapper),
                source=uncompressed, target=js)
        ctx.bld.install_files(installPrefix + "web", js)

    if "android" in platforms:
        swf = buildPrefix + "app-air.swf"
        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + flash_flags + "-D air".split(),
            libs=libs,
            target=swf)
        apk = buildPrefix + "app-android.apk"
        outputs.append(apk)

        adb = ctx.env.ADB
        if not adb:
            ctx.bld.fatal("adb from the Android SDK is required, " + \
                "ensure it's in your $PATH and re-run waf configure.")

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

        # Derive the location of the Android SDK from adb's path
        androidRoot = adb[0:adb.rindex("/platform-tools/adb")]

        apkType = "apk-debug" if debug else "apk-captive-runtime"
        rule = ("'%s' -package -target %s " +
            "-storetype pkcs12 -keystore '%s' -storepass '%s' " +
            "'${TGT}' '%s' " +
            "-platformsdk '%s' ") % (
                adt, apkType, airCert.abspath(), airPassword, airDesc.abspath(), androidRoot)

        # Include the swf in the APK
        rule += "-C '%s' '%s' " % (buildPrefix, "app-air.swf")

        # Include the assets in the APK
        if assetDir is not None:
            # Exclude assets Flash will never use
            airAssets = assetDir.ant_glob("**/*", excl="**/*.(ogg|wav|m4a)")
            rule += "-C '%s' %s " % (
                ctx.path.abspath(),
                " ".join([ "'" + asset.nice_path() + "'" for asset in airAssets ]))

        ctx.bld(rule=rule, target=apk, source=swf)
        ctx.bld.add_manual_dependency(apk, airCert);
        ctx.bld.add_manual_dependency(apk, airDesc);
        ctx.bld.install_files(installPrefix + "apps", apk)

        if ctx.bld.cmd == "install":
            # Install the APK if there's a device plugged in
            def install_apk(ctx):
                state = ctx.cmd_and_log("'%s' get-state" % adb, quiet=Context.STDOUT)
                if state == "device\n":
                    ctx.to_log("Installing APK to device...\n")
                    ctx.exec_command("'%s' install -rs '%s'" %
                        (adb, installPrefix + "apps/app-android.apk"))
            ctx.bld.add_post_fun(install_apk)

    # Common web stuff
    if "flash" in platforms or "html" in platforms:
        # Compile the embedder script
        embedder = buildPrefix + "flambe.js"
        scripts = ctx.bld.path.find_dir(FLAMBE_ROOT+"/tools/embedder").ant_glob("*.js")
        ctx.bld(rule="%s -jar '%s' %s --js_output_file ${TGT}" %
            (ctx.env.JAVA, closure.abspath(),
            " ".join(["--js '" + script.abspath() + "'" for script in scripts]),
            ), target=embedder)
        for script in scripts:
            ctx.bld.add_manual_dependency(embedder, script)
        ctx.bld.install_files(installPrefix + "web", embedder)

        # Install the default index.html if necessary
        if ctx.bld.path.find_dir("web") == None:
            ctx.bld.install_files(installPrefix + "web",
                ctx.bld.path.find_resource(FLAMBE_ROOT+"/tools/embedder/index.html"))

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

    classpath=["src", FLAMBE_ROOT+"/src"] + Utils.to_list(ctx.classpath)
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = Utils.to_list(ctx.libs)
    npmLibs = Utils.to_list(ctx.npmLibs)
    include = Utils.to_list(ctx.include)
    installPrefix = "deploy/" + ctx.app + "/server/"
    buildPrefix = ctx.app + "/"

    if True:
        if not ctx.env.NPM:
            ctx.bld.fatal("npm is required to specify node libraries, " + \
                "ensure it's in your $PATH and re-run waf configure.")

        cwd = ctx.path.get_bld().make_node(buildPrefix)
        for npmLib in npmLibs:
            ctx.bld(rule="'%s' install '%s'" % (ctx.env.NPM, npmLib), cwd=cwd.abspath())

        # Find files to install only after npm has downloaded them
        def installModules(ctx):
            dir = ctx.bldnode.find_dir(buildPrefix)
            for node in dir.ant_glob("node_modules/**/*"):
                ctx.do_install(node.abspath(), installPrefix + node.path_from(dir))
        ctx.bld.add_post_fun(installModules)

    # TODO(bruno): Use the node externs in haxelib
    flags += "-D server".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
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
    print("Restart the server using 'waf restart_server'.")
    while True:
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
