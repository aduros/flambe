"""
Basic Closure compiler support for Waf
"""

import os
from waflib import *
from waflib.TaskGen import extension, feature

def configure(ctx):
    path = ctx.environ["PATH"].split(os.pathsep)
    if "JAVA_HOME" in ctx.environ:
        path = [ctx.environ["JAVA_HOME"]] + path
        ctx.env["JAVA_HOME"] = [ctx.environ["JAVA_HOME"]]
    ctx.find_program("java", var="JAVA", path_list=path)

    ctx.env.CLOSURE_JAR = ctx.find_file("closure.jar", path_list=[os.path.dirname(__file__)])

class closure(Task.Task):
    color = "BLUE"
    vars = [ "flags" ] # Depend on these env var as inputs

    def run(self):
        env = self.env
        gen = self.generator
        bld = gen.bld
        wd = bld.bldnode.abspath()
        self.last_cmd = lst = [ env.JAVA, "-jar", env.CLOSURE_JAR,
            "--js_output_file", self.outputs[0].abspath() ]

        from textwrap import dedent
        lst.extend([ "--output_wrapper", dedent("""\
            /**
             * Cooked with Flambe
             * https://github.com/aduros/flambe
             */
            %output%""") ])

        for input in self.inputs:
            lst.extend(["--js", input.abspath()])

        lst.extend(env.flags)
        return self.generator.bld.exec_command(lst, cwd=wd, env=env.env or None)

@extension(".js")
def js_file(ctx, node):
    pass

@feature("closure")
def apply_closure(ctx):
    Utils.def_attrs(ctx, flags="");

    flags = Utils.to_list(ctx.flags)
    target = ctx.target;

    inputs = ctx.source
    outputs = [ ctx.path.get_bld().make_node(target) ]

    task = ctx.create_task("closure", inputs, outputs)
    task.env.flags = flags
    ctx.closure_task = task
