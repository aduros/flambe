from waflib import *
from waflib.TaskGen import *
import os
import optparse

FLAMBE_ROOT = os.path.dirname(__file__) + "/../.."
SERVER_CONFIG = "/tmp/flambe-server.py"

def options(ctx):
    group = ctx.add_option_group("flambe options")
    group.add_option("--debug", action="store_true", help="Build a debug version for development")
    group.add_option("--no-flash", action="store_true", help="Skip all Flash builds")
    group.add_option("--no-html", action="store_true", help="Skip all HTML builds")
    group.add_option("--no-android", action="store_true", help="Skip all Android builds")
    group.add_option("--no-ios", action="store_true", help="Skip all iOS builds")
    group.add_option("--flashdevelop", action="store", help=optparse.SUPPRESS_HELP)

def configure(ctx):
    ctx.load("haxe")
    ctx.load("closure")
    ctx.find_program("adt", var="ADT", mandatory=False)
    ctx.find_program("npm", var="NPM", mandatory=False)

    ctx.env.debug = ctx.options.debug or ctx.options.flashdevelop == "debug"
    ctx.env.has_flash = (not ctx.options.no_flash)
    ctx.env.has_html = (not ctx.options.no_html)
    ctx.env.has_android = (not ctx.options.no_android) and bool(ctx.env.ADT)

    import platform
    system = platform.system()
    ctx.env.has_ios = (not ctx.options.no_ios) and bool(ctx.env.ADT) and \
        (system == "Windows" or system == "Darwin")

@feature("flambe")
def apply_flambe(ctx):
    Utils.def_attrs(ctx, platforms="flash html",
        classpath="", flags="", libs="", asset_base=None, flash_version="11", main=None,
        dead_code_elimination=True, air_cert="etc/air-cert.pfx", air_desc="etc/air-desc.xml",
        air_password=None, ios_profile="etc/ios.mobileprovision")

    hxproj = load_hxproj(ctx)

    # The classpath option should be a list of waf nodes
    classpath = [flambe_src(ctx)] + Utils.to_list(ctx.classpath)

    if hxproj:
        classpath += infer_classpaths(ctx, hxproj)
    else:
        # If no hxproj, assume a src directory
        classpath.append(ctx.path.find_dir("src"))

    main = ctx.main
    if not main:
        if hxproj:
            main = infer_main(hxproj)
        if not main:
            ctx.bld.fatal("You must specify a main class in your wscript or hxproj")

    flags = ["-main", main]
    if ctx.dead_code_elimination:
        flags += ["-dce", "full"]
    flags += Utils.to_list(ctx.flags)

    libs = ["hxsl"] + Utils.to_list(ctx.libs)
    if hxproj:
        libs += infer_haxelibs(hxproj)

    platforms = Utils.to_list(ctx.platforms)
    flash_version = ctx.flash_version
    debug = ctx.env.debug

    # Figure out what should be built
    build_flash = "flash" in platforms and ctx.env.has_flash
    build_html = "html" in platforms and ctx.env.has_html
    build_android = "android" in platforms and ctx.env.has_android
    build_ios = "ios" in platforms and ctx.env.has_ios

    asset_dir = ctx.path.find_dir("assets")
    asset_list = [] if asset_dir is None else asset_dir.ant_glob("**/*")

    install_prefix = "deploy/"
    build_prefix = (ctx.name if ctx.name else "main") + "-"

    # The files that are built and should be installed
    outputs = []

    if debug:
        flags += "-debug --no-opt --no-inline -D fdb -D advanced-telemetry".split()
    else:
        flags += "--no-traces".split()

    if ctx.asset_base != None:
        ctx.bld.fatal("asset_base has been removed, set Manifest.externalBasePath instead.");

    if build_flash:
        flash_flags = ["-swf-version", flash_version]

        swf = build_prefix + "flash.swf"
        outputs.append(swf)

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + flash_flags,
            libs=libs,
            target=swf)
        ctx.bld.install_files(install_prefix + "web/targets", swf)

    if build_html:
        html_flags = "-D html".split()

        uncompressed = build_prefix + "html.uncompressed.js"
        js = build_prefix + "html.js"
        outputs.append(js)

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + html_flags,
            libs=libs,
            target=js if debug else uncompressed)
        if not debug:
            ctx.bld(features="closure", source=uncompressed, target=js,
                flags="--warning_level QUIET --language_in ES5_STRICT")
        else:
            ctx.bld.install_files(install_prefix + "web/targets", js + ".map")
        ctx.bld.install_files(install_prefix + "web/targets", js)

    if build_android or build_ios:
        # Since the captive runtime is used for apps, we can always use the latest swf version
        air_flags = "-D flambe_air -swf-version 11.2".split()
        air_libs = "air3".split()

        swf = build_prefix + "air.swf"

        ctx.bld(features="haxe", classpath=classpath,
            flags=flags + air_flags,
            libs=libs + air_libs,
            target=swf)

        adt = ctx.env.ADT
        if not adt:
            ctx.bld.fatal("adt from the AIR SDK is required, " + \
                "ensure it's in your $PATH and re-run waf configure.")

        air_cert = ctx.path.find_resource(ctx.air_cert)
        if not air_cert:
            ctx.bld.fatal("Could not find AIR certificate at %s." % ctx.air_cert)

        air_desc = ctx.path.find_resource(ctx.air_desc)
        if not air_desc:
            ctx.bld.fatal("Could not find AIR descriptor at %s." % ctx.air_desc)

        air_password = ctx.air_password
        if not air_password:
            ctx.bld.fatal("You must specify the air_password to your certificate.")

        app_id = infer_app_id(ctx, air_desc)
        air_apps = []

        # Installs and launches an AIR app on the device
        def air_install(ctx, platform, package):
            ctx.to_log("Installing %s to %s device...\n" % (app_id, platform))

            from subprocess import PIPE # Squelch some noisy errors
            platform = platform.lower()
            ctx.exec_command([ adt, "-uninstallApp", "-platform", platform, "-appid", app_id ],
                stderr=PIPE)
            ctx.exec_command([ adt, "-installApp", "-platform", platform, "-package", package ])
            ctx.exec_command([ adt, "-launchApp", "-platform", platform, "-appid", app_id ],
                stderr=PIPE)

        if build_android:
            apk_type = "apk-debug" if debug else "apk-captive-runtime"
            rule = ("%s -package -target %s " +
                "-storetype pkcs12 -keystore %s -storepass %s " +
                "\"${TGT}\" %s ") % (
                    quote(adt), apk_type, quote(air_cert.abspath()), quote(air_password),
                    quote(air_desc.abspath()))

            if ctx.bld.cmd == "install":
                def install_apk(ctx):
                    air_install(ctx, "Android",
                        install_prefix + "packages/" + build_prefix + "android.apk")
                ctx.bld.add_post_fun(install_apk)

            air_apps.append((build_prefix + "android.apk", rule))

        if build_ios:
            ios_profile = ctx.path.find_resource(ctx.ios_profile)
            if not ios_profile:
                ctx.bld.fatal("Could not find iOS provisioning profile at %s." % ctx.ios_profile)

            # TODO(bruno): Add -connect [host] for debug builds, if fdb is present
            # TODO(bruno): Handle final app store packaging
            ipa_type = "ipa-debug" if debug else "ipa-ad-hoc"
            rule = ("%s -package -target %s -provisioning-profile %s " +
                "-storetype pkcs12 -keystore %s -storepass %s " +
                "\"${TGT}\" %s ") % (
                    quote(adt), ipa_type, quote(ios_profile.abspath()),
                    quote(air_cert.abspath()), quote(air_password), quote(air_desc.abspath()))

            if ctx.bld.cmd == "install":
                def install_ipa(ctx):
                    air_install(ctx, "iOS",
                        install_prefix + "packages/" + build_prefix + "ios.ipa")
                ctx.bld.add_post_fun(install_ipa)

            air_apps.append((build_prefix + "ios.ipa", rule))

        # Build all our AIR apps, appending common configuration
        for target, rule in air_apps:
            outputs.append(target)

            # Include the swf
            rule += swf

            # Include the assets
            if asset_dir is not None:
                # Exclude assets Flash will never use
                air_assets = asset_dir.ant_glob("**/*", excl="**/*.(ogg|wav|m4a)")
                rule += " -C %s %s" % (
                    quote(ctx.path.abspath()),
                    " ".join([ quote(asset.nice_path()) for asset in air_assets ]))

            ctx.bld(rule=rule, target=target, source=swf)
            ctx.bld.add_manual_dependency(target, air_cert);
            ctx.bld.add_manual_dependency(target, air_desc);
            ctx.bld.install_files(install_prefix + "packages", target)

    # Common web stuff
    if build_flash or build_html:
        # Compile the embedder script
        embedder = "flambe.js"
        scripts = ctx.bld.root.find_dir(FLAMBE_ROOT+"/tools/embedder").ant_glob("*.js")

        ctx.bld(features="closure", source=scripts, target=embedder,
            flags="-D flambe.FLASH_VERSION='%s'" % flash_version)
        ctx.bld.install_files(install_prefix + "web", embedder)

        # Install the default embedder page if necessary
        if ctx.bld.path.find_dir("web") == None:
            ctx.bld.install_files(install_prefix + "web", [
                ctx.bld.root.find_resource(FLAMBE_ROOT+"/tools/embedder/index.html"),
                ctx.bld.root.find_resource(FLAMBE_ROOT+"/tools/embedder/logo.png"),
            ])

        # Install the assets
        if asset_dir is not None:
            ctx.bld.install_files(install_prefix + "web/assets", asset_list,
                cwd=asset_dir, relative_trick=True)

        # Also install any other files in /web
        ctx.bld.install_files(install_prefix, ctx.path.ant_glob("web/**/*"), relative_trick=True)

    # Force a rebuild when anything in the asset directory has been updated
    for asset in asset_list:
        for output in outputs:
            ctx.bld.add_manual_dependency(output, asset)

@feature("flambe-server")
def apply_flambe_server(ctx):
    Utils.def_attrs(ctx, main=None, classpath="", flags="", libs="", npm_libs="", include="")
    if ctx.target == "":
        ctx.target = "server.js"

    classpath = [ ctx.path.find_dir("src"), flambe_src(ctx) ] + \
        Utils.to_list(ctx.classpath) # The classpath option should be a list of nodes

    if not ctx.main:
        ctx.bld.fatal("You must specify a main class in your wscript")

    target = ctx.target
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = Utils.to_list(ctx.libs)
    npm_libs = Utils.to_list(ctx.npm_libs)
    include = Utils.to_list(ctx.include)
    build_prefix = (ctx.name if ctx.name else "main") + "-server/"
    install_prefix = "deploy/" + build_prefix;

    cwd = ctx.path.get_bld().make_node(build_prefix)
    cwd.mkdir()

    if npm_libs:
        if not ctx.env.NPM:
            ctx.bld.fatal("npm is required to specify node libraries, " + \
                "ensure it's in your $PATH and re-run waf configure.")

        for npm_lib in npm_libs:
            ctx.bld(rule="%s install %s" % (quote(ctx.env.NPM), npm_lib), cwd=cwd.abspath())

        if ctx.bld.cmd == "install":
            # Find files to install only after npm has downloaded them
            def install_modules(ctx):
                dir = ctx.bldnode.find_dir(build_prefix)
                for file in dir.ant_glob("node_modules/**/*"):
                    ctx.do_install(file.abspath(), install_prefix + file.path_from(dir))
            ctx.bld.add_post_fun(install_modules)

    # TODO(bruno): Use the node externs in haxelib
    flags += "-D server".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
    else:
        flags += "--no-traces -D flambe_keep_logs".split()

    ctx.bld(features="haxe", classpath=classpath, flags=flags, libs=libs,
        target=build_prefix + target)
    ctx.bld.install_files(install_prefix, build_prefix + target)

    # Mark any other custom files for installation
    if include:
        ctx.bld.install_files(install_prefix, include, relative_trick=True)

    if target == "server.js":
        file = SERVER_CONFIG
        conf = ConfigSet.ConfigSet()
        try:
            conf.load(file)
        except (IOError):
            pass
        conf.script = install_prefix + target
        conf.store(file)

        # Restart the development server when installing
        if ctx.bld.cmd == "install":
            ctx.bld.add_post_fun(restart_server)

# Spawns a development server for testing
def server(ctx):
    from subprocess import Popen
    print("Restart the server using `wafl restart_server`.")
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
            os.kill(conf.pid, signal.SIGHUP)
    except (IOError, OSError):
        pass
Context.g_module.__dict__["restart_server"] = restart_server

# Surround a string in quotes
def quote(string):
    return '"' + string + '"';

# Locate flambe's source code directory
def flambe_src(ctx):
    root = ctx.bld.root
    dir = root.find_dir(FLAMBE_ROOT + "/src")
    return dir if dir is not None else root.find_dir(FLAMBE_ROOT)

def load_hxproj(ctx):
    from xml.dom.minidom import parse
    projs = ctx.path.ant_glob("*.hxproj")
    if projs:
        proj = projs[0]
        try:
            return parse(proj.abspath())
        except Exception as e:
            ctx.bld.fatal("Could not parse %s: %s" % (proj.nice_path(), e))
    return None

def infer_classpaths(ctx, hxproj):
    classpaths = []
    for node in hxproj.getElementsByTagName("classpaths"):
        for node in node.getElementsByTagName("class"):
            path = node.getAttribute("path")
            if path:
                classpaths.append(ctx.path.find_dir(str(path)))
    return classpaths

def infer_main(hxproj):
    for node in hxproj.getElementsByTagName("build"):
        for node in node.getElementsByTagName("option"):
            main = node.getAttribute("mainClass")
            if main:
                return str(main)
    return None

def infer_haxelibs(hxproj):
    libs = []
    for node in hxproj.getElementsByTagName("haxelib"):
        for node in node.getElementsByTagName("library"):
            lib = node.getAttribute("name")
            # Flambe itself is already included specially
            if lib and lib != "flambe":
                libs.append(str(lib))
    return libs

def infer_app_id(ctx, air_desc):
    from xml.dom.minidom import parse
    try:
        xml = parse(air_desc.abspath())
        id = xml.getElementsByTagName("id")[0]
        return id.childNodes[0].nodeValue
    except Exception as e:
        ctx.bld.fatal("Could not parse %s: %s" % (air_desc.nice_path(), e))
