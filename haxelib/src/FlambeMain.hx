//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

import sys.FileSystem;
import sys.io.File;

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
        if (Sys.systemName() == "Windows") {
            var haxeDir = Sys.getEnv("HAXEPATH");
            if (haxeDir == null) {
                Sys.println("%HAXEPATH% environment variable not set, " +
                    "did you install Haxe properly?");
                Sys.exit(1);
            }
            File.copy(_libDir + "/bin/flambe-waf", haxeDir + "/flambe-waf.py");
            File.copy(_libDir + "/bin/flambe-waf.bat", haxeDir + "/flambe-waf.bat");

        } else {
            var dest = "/usr/bin/flambe-waf";
            try {
                File.copy(_libDir + "/bin/flambe-waf", dest);
            } catch (e :Dynamic) {
                Sys.println("Couldn't create " + dest + ", did you sudo?");
            }
        }
    }

    public function create ()
    {
        var name;
        do {
            name = read("Project identifier, one word please");
        } while (!~/^[a-z0-9]+$/i.match(name));

        var capitalName = name.charAt(0).toUpperCase() + name.substr(1);

        var outputDir = read("Project directory", Sys.getCwd() + "/" + name);
        var mainClassFull;
        do {
            mainClassFull = read("Main class, including package", capitalName + "Main");
        } while(!~/^([a-z][a-z0-9]*\.)*[A-Z][A-Za-z0-9]*/.match(mainClassFull));

        var idx = mainClassFull.lastIndexOf(".");
        var hasPackage = (idx >= 0);
        var mainClass = hasPackage ? mainClassFull.substr(idx+1) : mainClassFull;
        var mainClassPackage = hasPackage ? mainClassFull.substr(0, idx) : "";

        FileSystem.createDirectory(outputDir);
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
        copyTemplate(ctx, templateDir + "/air-desc.xml.tmpl", outputDir + "/etc/air-desc.xml");
        copyTemplate(ctx, templateDir + "/AppMain.hx.tmpl", srcDir + "/" + mainClass + ".hx");
        File.copy(templateDir + "/air-cert.pfx", outputDir + "/etc/air-cert.pfx");
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

    private static function main ()
    {
        var args = Sys.args();
        if (args.length < 1) {
            // When run using haxelib, a path will be added to the last argument
            Sys.print("No path argument, are you running this with haxelib run?");
            Sys.exit(1);
        }

        var app = new FlambeMain(args[args.length-1], args.slice(0, args.length-1));
        app.run();
    }

    private var _libDir :String;
    private var _args :Array<String>;
    private var _commands :Array<Command>;
}
