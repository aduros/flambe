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
    ctx.env.debug = ctx.options.debug

@feature("flambe")
def apply_flambe(ctx):
    flags = ["-main", ctx.main]
    hasBootstrap = ctx.path.find_dir("res/bootstrap")

    flash_flags = "-swf-header 640:480:30:ffffff".split()
    amity_flags = "-D amity --macro flambe.macro.AmityJSGenerator.use()".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
        # Only generate line numbers for Flash. The stack -debug creates for JS is unused in Amity
        flash_flags += ["-debug"]
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx.bld(features="haxe", classpath=["src", FLAMBE_ROOT+"/src"],
        flags=flags + flash_flags,
        swflib="bootstrap.swf" if hasBootstrap else None,
        target="app.swf")

    ctx.bld(features="haxe", classpath=["src", FLAMBE_ROOT+"/src"],
        flags=flags + amity_flags,
        target="app.js")

    res = ctx.path.find_dir("res")
    if res is not None:
        # Create asset swfs from the directories in /res
        ctx.bld(features="haxe", classpath=FLAMBE_ROOT+"/tools",
            flags="-main AssetPackager",
            libs="format",
            target="packager.n")
        # -interp because neko JIT is unstable...
        ctx.bld(rule="neko -interp ${SRC} " + res.abspath() + " .",
            source="packager.n", target= "bootstrap.swf" if hasBootstrap else None, always=True)

@feature("flambe-server")
def apply_flambe_server(ctx):
    flags = ["-main", ctx.main]
    # TODO(bruno): Use the node externs in haxelib
    flags += "-D server --macro flambe.macro.AmityJSGenerator.use()".split()

    if ctx.env.debug:
        flags += "-D debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx.bld(features="haxe", classpath=["src", FLAMBE_ROOT+"/src"],
        flags=flags, target="server.js")

# Upload and run the app on Android
def android_test(ctx):
    os.system("adb push res /sdcard/amity-dev")
    os.system("adb push build/app.js /sdcard/amity-dev")
    os.system("adb shell am start -a android.intent.action.MAIN " +
        "-c android.intent.category.HOME")
    os.system("adb shell am start -a android.intent.action.MAIN " +
        "-n com.threerings.amity/.AmityActivity")
Context.g_module.__dict__["android_test"] = android_test

# View the app's log on Android
def android_log(ctx):
    os.system("adb logcat -v tag amity:V SDL:V *:W")
Context.g_module.__dict__["android_log"] = android_log

# Run the app in a Flash player
def flash_test(ctx):
    os.system("flashplayer build/app.swf")
Context.g_module.__dict__["flash_test"] = flash_test

# View the app's log in Flash
def flash_log(ctx):
    os.system("tail -F $HOME/.macromedia/Flash_Player/Logs/flashlog.txt")
Context.g_module.__dict__["flash_log"] = flash_log

# Upload and run the app on webOS
def webos_test(ctx):
    # If the process documented at https://developer.palm.com/content/resources/develop/pdk_app_debugging.html
    # worked on Linux, this would be less hacky (we would just use scp). Until Linux is officially
    # supported by the PDK, a zip is instead created and pushed, then unzipped on the device.
    from zipfile import ZipFile
    assets = ZipFile("build/assets.zip", "w")
    res = ctx.path.find_node("res")
    for node in res.ant_glob("**"):
        relpath = str(node.abspath())[len(res.abspath())+1:]
        assets.write(node.abspath(), relpath)
    assets.write("build/app.js", "app.js")
    assets.close()

    staging = "/tmp/amity-dev"
    os.system("novacom run 'file:///bin/rm -rf " + staging + "'")
    os.system("novacom run 'file:///bin/mkdir -p " + staging + "'")
    os.system("novacom put 'file:///tmp/assets.zip' < build/assets.zip")
    os.system("novacom run 'file:///usr/bin/unzip /tmp/assets.zip -d " + staging + "'")
    os.system("novacom run 'file:///bin/rm -rf /tmp/assets.zip'")

    os.system("novacom run 'file:///usr/bin/killall amity'")
    os.system("palm-launch com.threerings.amity")
Context.g_module.__dict__["webos_test"] = webos_test

# View the app's log on webOS
def webos_log(ctx):
    os.system("novacom run 'file:///usr/bin/tail -f /var/log/messages' | grep com.threerings.amity")
Context.g_module.__dict__["webos_log"] = webos_log

SERVER_PID = "/tmp/flambe-server.pid"

# Spawns a development server for testing
def server(ctx):
    from subprocess import Popen
    print("Restart the server using 'waf restart_server' or 'kill `cat %s`." % SERVER_PID);
    while True:
        p = Popen(["node", "build/server.js"]);
        with open(SERVER_PID, "w") as file:
            file.write(str(p.pid))
        p.wait()
        os.remove(SERVER_PID)
Context.g_module.__dict__["server"] = server

# Restart the local dev server
def restart_server(ctx):
    import signal
    with open(SERVER_PID, "r") as file:
        os.kill(int(file.read()), signal.SIGTERM)
Context.g_module.__dict__["restart_server"] = restart_server
