import distutils.core
import errno
import logging
import os
import re
import shutil
import subprocess

log = logging.getLogger("flambe")

data_dir = os.path.join(os.path.dirname(__file__), "data")
cache_dir = ".flambe-cache"

class FlambeException (Exception): pass

def new (path):
    shutil.copytree(data_dir+"/scaffold", path)

def run (config, platform, debug=False):
    build(config, [platform], debug)
    id = get(config, "id")
    if platform == "android":
        log.info("")
        apk = "build/main-android.apk"
        log.info("Installing: " + apk)
        adt(["-uninstallApp", "-platform", "android", "-appid", id], verbose=False, output=False, check=False)
        adt(["-installApp", "-platform", "android", "-package", apk], verbose=False)
        adt(["-launchApp", "-platform", "android", "-appid", id], verbose=False)
        if debug:
            log.info("")
            # Clear the log, then start tailing it
            adb(["logcat", "-c"], verbose=False)
            adb(["logcat", "-v", "raw", "-s", "air.%s:V" % id], verbose=False)

def build (config, platforms=[], debug=False):
    common_flags = ["-lib", "flambe", "-cp", "src"]

    common_flags += ["-main", get(config, "main")]
    common_flags += ["-dce", "full"]
    if debug: common_flags += ["-debug", "--no-opt", "--no-inline"]
    else: common_flags += ["--no-traces"]

    common_flags += to_list(get(config, "haxe_flags", []))

    mkdir_p(cache_dir)
    mkdir_p("build/web/targets")
    distutils.dir_util.copy_tree("web", "build/web")
    shutil.copy(data_dir+"/flambe.js", "build/web")

    shutil.rmtree("build/web/assets", ignore_errors=True)
    shutil.copytree("assets", "build/web/assets")

    # Flags common to all swf-based targets (flash, android, ios)
    swf_flags = ["--flash-strict", "-D", "native_trace",
        "-swf-header", "640:480:60:000000", "-lib", "hxsl"]
    if debug: swf_flags += ["-D", "fdb", "-D", "advanced-telemetry"]

    def build_html ():
        html_flags = ["-D", "html"]
        unminified = cache_dir+"/main-html.unminified.js"
        js = "build/web/targets/main-html.js"
        log.info("Building: " + js)
        if debug:
            haxe(common_flags + html_flags + ["-js", js])
        else:
            # Minify release builds
            haxe(common_flags + html_flags + ["-js", unminified])
            minify_js([unminified], js, strict=True)

    def build_flash ():
        swf = "build/web/targets/main-flash.swf"
        flash_flags = swf_flags + ["-swf-version", "11", "-swf", swf]
        log.info("Building: " + swf)
        haxe(common_flags + flash_flags)

    def build_air (flags):
        # Prepare the assets directory
        mkdir_p(cache_dir+"/air")
        shutil.rmtree(cache_dir+"/air/assets", ignore_errors=True)
        shutil.copytree("assets", cache_dir+"/air/assets",
            ignore=shutil.ignore_patterns("*.ogg", "*.wav", "*.m4a"))

        # Build the swf
        air_flags = swf_flags + ["-lib", "air3", "-swf-version", "11.2", "-D", "flambe_air"]
        haxe(common_flags + air_flags + flags)

    def generate_air_xml (swf, output):
        from xml.dom.minidom import parseString
        from textwrap import dedent
        doc = parseString(dedent("""
            <application xmlns="http://ns.adobe.com/air/application/3.7">
              <id>"""+get(config, "id")+"""</id>
              <versionNumber>"""+str(get(config, "version"))+"""</versionNumber>
              <filename>"""+get(config, "name")+"""</filename>
              <initialWindow>
                <content>"""+swf+"""</content>
                <renderMode>direct</renderMode>
              </initialWindow>
            </application>"""))
        icons = doc.createElement("icon")
        for icon in os.listdir("icons"):
            # Only include properly named square icons
            if re.match("(\d+)x\\1.png", icon):
                size = os.path.splitext(icon)[0]
                image = doc.createElement("image"+size)
                image.appendChild(doc.createTextNode("icons/"+icon))
                icons.appendChild(image)
        doc.firstChild.appendChild(icons)
        with open(output, "w") as file:
            doc.writexml(file)

    def build_android ():
        apk = "build/main-android.apk"
        log.info("Building: " + apk)

        swf = "main-android.swf"
        build_air(["-swf", cache_dir+"/air/"+swf])

        # Generate a dummy certificate if it doesn't exist
        cert = cache_dir+"/air/certificate-android.p12"
        try:
            with open(cert): pass
        except IOError:
            adt(["-certificate", "-cn", "SelfSign", "-validityPeriod", "25", "2048-RSA", cert, "password"])

        xml = cache_dir+"/air/config-android.xml"
        generate_air_xml(swf, xml)

        apk_type = "apk-debug" if debug else "apk-captive-runtime"
        adt(["-package", "-target", apk_type, "-storetype", "pkcs12",
            "-keystore", cert, "-storepass", "password", apk, xml, "icons",
            "-C", cache_dir+"/air", swf, "assets"])

    def build_ios ():
        ipa = "build/main-ios.ipa"
        log.info("Building: " + ipa)

        swf = "main-ios.swf"
        build_air(["-swf", cache_dir+"/air/"+swf])

        xml = cache_dir+"/air/config-ios.xml"
        generate_air_xml(swf, xml)

        ipa_type = "ipa-debug" if debug else "ipa-ad-hoc" # or maybe ipa-test?
        adt(["-package", "-target", ipa_type,
            "-provisioning-profile", "ios/development.mobileprovision",
            "-storetype", "pkcs12", "-keystore", "ios/development.p12", "-storepass", "password",
            ipa, xml, "icons", "-C", cache_dir+"/air", swf, "assets"])

    builders = {
        "html": build_html,
        "flash": build_flash,
        "ios": build_ios,
        "android": build_android,
    }
    for ii, platform in enumerate(platforms):
        if ii != 0: log.info("")
        builders[platform]()

def clean ():
    shutil.rmtree("build", ignore_errors=True)
    shutil.rmtree(cache_dir, ignore_errors=True)

def haxe (flags, **kwargs):
    run_command(["haxe"] + flags, **kwargs)

def adt (flags, **kwargs):
    run_command(["adt"] + flags, **kwargs)

def adb (flags, **kwargs):
    run_command(["adb"] + flags, **kwargs)

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

def run_command (command, verbose=True, output=True, check=True):
    if verbose: log.info(" ".join(command))
    stream = None if output else subprocess.PIPE
    code = subprocess.call(command, stdout=stream, stderr=stream)
    if check and code != 0: raise FlambeException()

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
        log.info("Serving on http://localhost:%s" % self.http_port)

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
