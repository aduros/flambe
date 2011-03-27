#!/usr/bin/env python

import os

def options(ctx):
    ctx.add_option("--debug", action="store_true", default=False, help="Build a development version")

def configure(ctx):
    ctx.load("haxe", tooldir="tools")
    ctx.env.debug = ctx.options.debug

def build(ctx):
    flags = "-main test.Main".split()
    hasBootstrap = os.path.isdir("res/bootstrap")

    if ctx.env.debug:
        flags += "-debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx(features="haxe", classpath="src",
        flags=flags,
        libs="format",
        swflib="bootstrap.swf" if hasBootstrap else None,
        target="app.swf")

    ctx(features="haxe", classpath="src",
        flags=flags + "-D amity --macro flambe.macro.AmityJSGenerator.use()".split(),
        target="app.js")

    # Create asset swfs from the directories in /res
    ctx(features="haxe", classpath="tools",
        flags="-main AssetPackager",
        libs="format",
        target="packager.n")
    ctx(rule="neko -interp ${SRC} ../res .", # -interp because neko JIT segfaults
        source="packager.n", target= "bootstrap.swf" if hasBootstrap else None, always=True)

def android_test(ctx):
    os.system("adb push res/bootstrap /sdcard/amity-dev")
    os.system("adb push build/app.js /sdcard/amity-dev")
    # TODO: Close the app if it's already running
    os.system("adb shell am start -a android.intent.action.MAIN " +
        "-n com.threerings.amity/.AmityActivity")

def android_log(ctx):
    os.system("adb logcat -v tag amity:V SDL:V *:W")
