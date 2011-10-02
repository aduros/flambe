#!/usr/bin/env python

from waflib import *
from waflib.TaskGen import *
import os

# Waf hates absolute paths for some reason
FLAMBE_ROOT = os.path.dirname(__file__) + "/.."

def options(ctx):
    ctx.add_option("--debug", action="store_true", default=False, help="Build a development version")

def configure(ctx):
    ctx.load("haxe", tooldir=FLAMBE_ROOT+"/tools")
    ctx.find_program("java", var="JAVA")
    ctx.find_program("neko", var="NEKO")
    ctx.env.debug = ctx.options.debug

@feature("flambe")
def apply_flambe(ctx):
    Utils.def_attrs(ctx, classpath="", flags="", libs="")
    classpath=["src", FLAMBE_ROOT+"/src"] + Utils.to_list(ctx.classpath)
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = ["hxJson2"] + Utils.to_list(ctx.libs)

    debug = ctx.env.debug
    hasBootstrap = ctx.path.find_dir("res/bootstrap")
    closure = ctx.bld.path.find_resource(FLAMBE_ROOT+"/tools/closure.jar")

    flash_flags = "-swf-header 640:480:60:ffffff".split()
    html_flags = "-D html --macro flambe.macro.BrowserJSGenerator.use()".split()

    if debug:
        flags += "-D debug --no-opt --no-inline".split()
        # Only generate line numbers for Flash. The stack -debug creates for JS isn't too useful
        flash_flags += ["-debug"]
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx.bld(features="haxe", classpath=classpath,
        flags=flags + flash_flags,
        swflib="bootstrap.swf" if hasBootstrap else None,
        libs=libs,
        target="app.swf")
    ctx.bld.install_files("deploy/web", "app.swf")

    ctx.bld(features="haxe", classpath=classpath,
        flags=flags + html_flags,
        libs=libs,
        target="app-html.js" if debug else "app-html.uncompressed.js")
    if not debug:
        import textwrap
        wrapper = textwrap.dedent("""\
            /**
             * Cooked with Flambe
             * https://github.com/aduros/flambe
             */
            %%output%%""")
        # TODO(bruno): Higher compilation levels break the app because haXe uses eval in places.
        # Submit an issue/patch upstream.
        ctx.bld(rule=("%s -jar '%s' --js ${SRC} --js_output_file ${TGT} " +
            "--output_wrapper  '%s' --compilation_level WHITESPACE_ONLY --warning_level QUIET") %
                (ctx.env.JAVA, closure.abspath(), wrapper),
            source="app-html.uncompressed.js", target="app-html.js")
    ctx.bld.install_files("deploy/web", "app-html.js")

    res = ctx.path.find_dir("res")
    if res is not None:
        # Create asset swfs from the directories in /res
        ctx.bld(features="haxe", classpath=FLAMBE_ROOT+"/tools/packager/src",
            flags="-main AssetPackager",
            libs="format",
            target="packager.n")
        # -interp because neko JIT is unstable...
        ctx.bld(rule="%s -interp ${SRC} %s ." % (ctx.env.NEKO, res.abspath()),
            source="packager.n", target= "bootstrap.swf" if hasBootstrap else None)

        # Force a rebuild when anything in res/ has been updated
        assets = res.ant_glob("**/*")
        for asset in assets:
            ctx.bld.add_manual_dependency("app-html.js", asset)
            ctx.bld.add_manual_dependency("bootstrap.swf", asset)

        ctx.bld.install_files("deploy/web", assets, cwd=res, relative_trick=True)

    # Compile the embedder script
    scripts = ctx.bld.path.find_dir(FLAMBE_ROOT+"/tools/embedder").ant_glob("*.js")
    ctx.bld(rule="%s -jar '%s' %s --js_output_file ${TGT}" %
        (ctx.env.JAVA, closure.abspath(),
        " ".join(["--js '" + script.abspath() + "'" for script in scripts]),
        ), target="flambe.js")
    for script in scripts:
        ctx.bld.add_manual_dependency("flambe.js", script)
    ctx.bld.install_files("deploy/web", "flambe.js")

    # Install the default index.html if necessary
    if ctx.bld.path.find_dir("web") == None:
        ctx.bld.install_files("deploy/web",
            ctx.bld.path.find_resource(FLAMBE_ROOT+"/tools/embedder/index.html"))

    # Also install any other files in /web
    ctx.bld.install_files("deploy", ctx.path.ant_glob("web/**/*"), relative_trick=True)

@feature("flambe-server")
def apply_flambe_server(ctx):
    Utils.def_attrs(ctx, classpath="", flags="", libs="")
    classpath=["src", FLAMBE_ROOT+"/src"] + Utils.to_list(ctx.classpath)
    flags = ["-main", ctx.main] + Utils.to_list(ctx.flags)
    libs = Utils.to_list(ctx.libs)

    # TODO(bruno): Use the node externs in haxelib
    flags += "-D server --macro flambe.macro.AmityJSGenerator.use()".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx.bld(features="haxe", classpath=classpath, flags=flags, libs=libs, target="server.js")
    ctx.bld.install_files("deploy", "server.js")
    ctx.bld.install_files("deploy", ctx.path.ant_glob("data/**/*"), relative_trick=True)
    if ctx.bld.cmd == "install":
        ctx.bld.add_post_fun(restart_server)

# Run the app in a Flash player
def flash_test(ctx):
    os.system("flashplayer deploy/web/app.swf")
Context.g_module.__dict__["flash_test"] = flash_test

# View the app's log in Flash
def flash_log(ctx):
    os.system("tail -F $HOME/.macromedia/Flash_Player/Logs/flashlog.txt")
Context.g_module.__dict__["flash_log"] = flash_log

SERVER_PID = "/tmp/flambe-server.pid"

# Spawns a development server for testing
def server(ctx):
    from subprocess import Popen
    print("Restart the server using 'waf restart_server' or 'kill `cat %s`." % SERVER_PID)
    while True:
        p = Popen(["node", "deploy/server.js"])
        with open(SERVER_PID, "w") as file:
            file.write(str(p.pid))
        p.wait()
        os.remove(SERVER_PID)
Context.g_module.__dict__["server"] = server

# Restart the local dev server
def restart_server(ctx):
    import signal
    try:
        with open(SERVER_PID, "r") as file:
            os.kill(int(file.read()), signal.SIGTERM)
    except (IOError, OSError):
        pass
Context.g_module.__dict__["restart_server"] = restart_server
