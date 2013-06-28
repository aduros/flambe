import errno
import logging
import os
import shutil
import subprocess

logger = logging.getLogger("flambe")

data_dir = os.path.join(os.path.dirname(__file__), "data")
cache_dir = ".flambe-cache"

class FlambeException (Exception): pass

def new (path):
    shutil.copytree(data_dir+"/scaffold", path)

def build (config, platforms=[], debug=False):
    common_flags = ["-lib", "flambe", "-cp", "src"]

    common_flags += ["-main", get(config, "main")]
    common_flags += ["-dce", "full"]
    if debug: common_flags += ["-debug", "--no-opt", "--no-inline"]
    else: common_flags += ["--no-traces"]

    common_flags += to_list(get(config, "haxe_flags", []))

    mkdir_p(cache_dir)
    shutil.rmtree("build", ignore_errors=True)
    shutil.copytree("web", "build/web")
    shutil.copytree("assets", "build/web/assets")
    mkdir_p("build/web/targets")
    shutil.copy(data_dir+"/flambe.js", "build/web")

    def build_html ():
        html_flags = ["-D", "html"]
        unminified = cache_dir+"/main-html.unminified.js"
        minified = "build/web/targets/main-html.js"

        if debug:
            haxe(common_flags + html_flags + ["-js", minified])
        else:
            haxe(common_flags + html_flags + ["-js", unminified])
            minify_js([unminified], minified, strict=True)

    def build_flash ():
        flash_flags = ["-swf", "build/web/targets/main-flash.swf",
            "--flash-strict", "-D", "native_trace",
            "-swf-header", "640:480:60:000000", "-swf-version", "11", "-lib", "hxsl"]
        if debug: flash_flags += ["-D", "fdb", "-D", "advanced-telemetry"]
        haxe(common_flags + flash_flags)

    builders = {
        "html": build_html,
        "flash": build_flash,
    }
    for platform in platforms:
        builders[platform]()

def clean ():
    shutil.rmtree("build", ignore_errors=True)
    shutil.rmtree(cache_dir, ignore_errors=True)

def haxe (flags):
    run_command(["haxe"] + flags)

def minify_js (inputs, output, strict=False):
    from textwrap import dedent
    command=["java", "-jar", data_dir+"/closure.jar",
        "--warning_level", "QUIET",
        "--js_output_file", output,
        "--output_wrapper", dedent("""\
            /**
             * Cooked with Flambe
             * https://github.com/aduros/flambe
             */
            %output%""")]
    for input in inputs: command += ["--js", input]
    if strict: command += ["--language_in", "ES5_STRICT"]
    run_command(command, verbose=False)

def run_command (command, verbose=True):
    if verbose: logger.info(" ".join(command))
    if subprocess.call(command) != 0: raise FlambeException()

def to_list (o):
    if isinstance(o, list): return o
    if isinstance(o, str): return o.split()
    return [o]

def get (config, name, default=None):
    if name in config:
        return config[name]
    elif default is not None:
        return default
    else:
        raise FlambeException("Missing required entry in config file: %s" % name)

def mkdir_p (path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

from twisted.internet import reactor
from twisted.web import static, server
from datetime import datetime, timedelta
class Server ():
    http_port = 5000

    def run (self):
        logger.info("Serving on http://localhost:%s" % self.http_port)

        class CacheableFile(static.File):
            def render (self, request):
                # Set perma-cache headers on asset requests
                if "v" in request.args:
                    expires = datetime.utcnow() + timedelta(days=(25 * 365))
                    request.setHeader("Expires", expires.strftime("%a, %d %b %Y %H:%M:%S GMT"))
                    request.setHeader("Cache-Control", "max-age=315360000")
                return super(CacheableFile, self).render(request)

        root = CacheableFile("build/web")
        reactor.listenTCP(self.http_port, server.Site(root))
        reactor.run()
