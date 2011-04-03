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

    if ctx.env.debug:
        flags += "-debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx.bld(features="haxe", classpath=["src", FLAMBE_ROOT+"/src"],
        flags=flags,
        swflib="bootstrap.swf" if hasBootstrap else None,
        target="app.swf")

    ctx.bld(features="haxe", classpath=["src", FLAMBE_ROOT+"/src"],
        flags=flags + "-D amity --macro flambe.macro.AmityJSGenerator.use()".split(),
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

# TODO: How can we expose these handy commands to the main wscript?
def android_test(ctx):
    os.system("adb push res /sdcard/amity-dev")
    os.system("adb push build/app.js /sdcard/amity-dev")
    os.system("adb shell am start -a android.intent.action.MAIN " +
        "-c android.intent.category.HOME")
    os.system("adb shell am start -a android.intent.action.MAIN " +
        "-n com.threerings.amity/.AmityActivity")

def flash_test(ctx):
    os.system("flashplayer build/app.swf")

def android_log(ctx):
    os.system("adb logcat -v tag amity:V SDL:V *:W")
