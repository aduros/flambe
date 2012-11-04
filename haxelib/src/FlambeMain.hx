//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

import haxe.Template;

using StringTools;

typedef Command = {
    var name :String;
    var handler :Void -> Void;
    var description :String;
};

class FlambeMain
{
    public function new (libDir :String, args :Array<String>)
    {
        _libDir = libDir;
        _args = args;
        _commands = [];

        addCommand("new", create, "Create a new project template");
        addCommand("setup", setup, "Setup Flambe");
        addCommand("help", help, "Print this help message");
    }

    public function run ()
    {
        if (_args.length > 0) {
            var cmd = _args[0];
            for (command in _commands) {
                if (command.name == cmd) {
                    Reflect.callMethod(this, command.handler, []);
                    return;
                }
            }
            Sys.println("Unknown command, \"" + cmd + "\"");
        }

        help();
    }

    public function setup ()
    {
        var dest;
        if (WINDOWS) {
            var haxeDir = Sys.getEnv("HAXEPATH");
            if (haxeDir == null) {
                Sys.println("%HAXEPATH% environment variable not set, " +
                    "did you install Haxe properly?");
                Sys.exit(1);
            }
            File.copy(_libDir + "/bin/wafl", haxeDir + "/wafl.py");
            File.copy(_libDir + "/bin/wafl.bat", haxeDir + "/wafl.bat");
            dest = haxeDir + "/wafl";

        } else {
            dest = "/usr/bin/wafl";
            try {
                File.copy(_libDir + "/bin/wafl", dest);
                Sys.command("chmod", ["755", dest]);
            } catch (e :Dynamic) {
                Sys.println("Couldn't create " + dest + ", did you sudo?");
                Sys.exit(1);
            }
        }

        Sys.println("Installed wafl to " + cleanPath(dest));

        if (hasFlashDevelop()) {
            switch (read("Install Flambe support in FlashDevelop?", "Y").toLowerCase()) {
            case "y", "yes":
                try {
                    // Deliberately wacky quoting, cmd.exe was designed by loons
                    new Process("cmd", ["/s /k\" \"" + _libDir + "\\flambe-FlashDevelop.fdz\""]);
                } catch (err :Dynamic) {
                    Sys.println("Err, something went wrong. You can try getting the FDZ manually" +
                        " from https://github.com/aduros/flambe/downloads");
                }
            default:
                Sys.println("Ok, you can install it later by running setup again");
            }
        }

        if (!hasPython()) {
            Sys.println(" ┌────────────────────────────────────────────────┐");
            Sys.println(" │ It looks you don't have Python, you'll need to │");
            Sys.println(" │ install it to build Flambe apps:               │");
            Sys.println(" │           http://python.org/download           │");
            Sys.println(" └────────────────────────────────────────────────┘");
        }
    }

    public function create ()
    {
        var name;
        do {
            name = read("Project identifier, one word please");
        } while (!~/^[a-z0-9]+$/i.match(name));

        var capitalName = name.charAt(0).toUpperCase() + name.substr(1);

        Sys.println("");
        Sys.println("-- Press enter to use the defaults --");

        var outputDir = read("Project directory", cleanPath(Sys.getCwd() + "/" + name));

        var mainClassFull;
        do {
            mainClassFull = read("Main class, including package", capitalName + "Main");
        } while(!~/^([a-z][a-z0-9]*\.)*[A-Z][A-Za-z0-9]*$/.match(mainClassFull));

        var idx = mainClassFull.lastIndexOf(".");
        var hasPackage = (idx >= 0);
        var mainClass = hasPackage ? mainClassFull.substr(idx+1) : mainClassFull;
        var mainClassPackage = hasPackage ? mainClassFull.substr(0, idx) : "";

        try {
            FileSystem.createDirectory(outputDir);
        } catch (error :Dynamic) {
            // The directory probably already exists, press on
        }
        FileSystem.createDirectory(outputDir + "/etc");
        FileSystem.createDirectory(outputDir + "/assets");
        FileSystem.createDirectory(outputDir + "/assets/bootstrap");

        var srcDir = outputDir;
        for (dir in ["src"].concat(hasPackage ? mainClassPackage.split(".") : [])) {
            srcDir += "/" + dir;
            FileSystem.createDirectory(srcDir);
        }

        var templateDir = _libDir + "/template";
        var ctx = {
            name: name,
            capitalName: capitalName,
            mainClassFull: mainClassFull,
            mainClass: mainClass,
            hasPackage: hasPackage,
            mainClassPackage: mainClassPackage,
        };
        copyTemplate(ctx, templateDir + "/wscript.tmpl", outputDir + "/wscript");
        copyTemplate(ctx, templateDir + "/AppMain.hx.tmpl", srcDir + "/" + mainClass + ".hx");

        // For AIR
        copyTemplate(ctx, templateDir + "/air-desc.xml.tmpl", outputDir + "/etc/air-desc.xml");
        File.copy(templateDir + "/air-cert.pfx", outputDir + "/etc/air-cert.pfx");

        // For FlashDevelop
        copyTemplate(ctx, templateDir + "/app.hxproj.tmpl", outputDir + "/" + name + ".hxproj");
    }

    public function help ()
    {
        Sys.println("Usage: haxelib run flambe [command]");
        Sys.println("Commands:");

        for (command in _commands) {
            Sys.println("  " + command.name + ": " + command.description);
        }
    }

    private function read (prompt :String, ?def :String) :String
    {
        Sys.print(prompt);
        if (def != null) {
            Sys.print(" [" + def + "]");
        }
        Sys.print(": ");

        var line = Sys.stdin().readLine().trim();
        return (line.length > 0 || def == null) ? line : def;
    }

    private function addCommand (name :String, handler :Void -> Void, description :String)
    {
        _commands.push({name: name, handler: handler, description: description});
    }

    private static function copyTemplate (ctx :Dynamic, from :String, to :String)
    {
        var template = new Template(File.getContent(from));
        File.saveContent(to, template.execute(ctx));
    }

    private static function cleanPath (path :String) :String
    {
        if (WINDOWS) {
            path = path.replace("/", DIR_SEP);
        }
        // Remove duplicate slashes
        path = new EReg("\\" + DIR_SEP + "+", "g").replace(path, DIR_SEP);
        // Remove trailing slashes
        path = new EReg("\\" + DIR_SEP + "$", "").replace(path, "");

        return path;
    }

    private static function hasFlashDevelop () :Bool
    {
        if (WINDOWS) {
            try {
                // Deliberately wacky quoting
                var p = new Process("cmd", ["/s /k\" assoc .fdz"]);
                return p.stdout.readLine().indexOf("FlashDevelop") >= 0;
            } catch (error :Dynamic) {
                // Fall through
            }
        }
        return false;
    }

    private static function hasPython () :Bool
    {
        if (WINDOWS) {
            // Look for the Python .py file association first
            try {
                // Deliberately wacky quoting
                var p = new Process("cmd", ["/s /k\" assoc .py"]);
                return p.stdout.readLine().indexOf("Python") >= 0;
            } catch (error :Dynamic) {
                // Fall through
            }
        }
        try {
            new Process("python", ["--version"]);
            return true;
        } catch (error :Dynamic) {
            // Fall through
        }
        return false;
    }

    private static function main ()
    {
        var args = Sys.args();
        if (args.length < 1) {
            // When run using haxelib, a path will be added to the last argument
            Sys.println("No path argument, are you running this with haxelib run?");
            Sys.exit(1);
        }

        var libDir = cleanPath(Sys.getCwd());
        var cwd = cleanPath(args[args.length-1]);
        Sys.setCwd(cwd);

        var app = new FlambeMain(libDir, args.slice(0, args.length-1));
        app.run();
    }

    private static var WINDOWS = Sys.systemName() == "Windows";
    private static var DIR_SEP = WINDOWS ? "\\" : "/";

    private var _libDir :String;
    private var _args :Array<String>;
    private var _commands :Array<Command>;
}
