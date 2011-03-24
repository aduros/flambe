#!/usr/bin/env python

def options(ctx):
    ctx.add_option("--debug", action="store_true", default=False, help="Build a development version")

def configure(ctx):
    ctx.load("haxe", tooldir="tools")
    ctx.env.debug = ctx.options.debug

def build(ctx):
    flags = "-main test.Main".split()
    if ctx.env.debug:
        flags += "-debug --no-opt --no-inline".split()
    else:
        #flags += "--dead-code-elimination --no-traces".split()
        flags += "--no-traces".split()

    ctx(features="haxe", classpath="src",
        flags = flags,
        target="app.swf")

    ctx(features="haxe", classpath="src",
        flags = flags + "-D amity --macro flambe.macro.AmityJSGenerator.use()".split(),
        target="app.js")
