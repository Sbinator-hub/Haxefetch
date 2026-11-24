package utils;

import haxe.macro.Compiler;

class Commands {
    public static var commit:String = "";
    public static var overrideLogo:String = "";

    public static function parse(arguments:Array<String>):Void {
        if (commit == "") commit = SystemUtils.fetchGithubCommit();

        var i = 0;
        while (i < arguments.length) {
            var arg = arguments[i];
            switch (arg) {
                case "-h" | "--help":
                    fetchHelp();
                    Sys.exit(0);

                case "-v" | "--version":
                    Sys.println('Haxefetch ${Haxefetch.HAXEFETCH_VERSION} (Built on Haxe ${Compiler.getDefine("haxe")}) [Commit ${commit}]');
                    Sys.exit(0);

                case "-c" | "--config":
                    Configuration.generateConfiguration();
                    Sys.exit(0);

                case "-t" | "--tutorial":
                    fetchInstructions();
                    Sys.exit(0);

                case "-s" | "--supported":
                    checkIfSupported();
                    Sys.exit(0);

                case "-l" | "--logo":
                    if (i + 1 >= arguments.length) {
                        Sys.println('${Colors.colorize("Error:", Colors.RED)} ${Colors.colorize('${arg}', Colors.YELLOW)} ${Colors.colorize('requires either a distro name', Colors.RED)} ${Colors.colorize('or', Colors.YELLOW)} ${Colors.colorize('file path name with .txt', Colors.RED)}');
                        Sys.exit(1);
                    }
                    overrideLogo = arguments[i + 1];
                    i++;

                default:
                    Sys.println('Unknown command ${arg}');
                    Sys.println("Try -h or --help for current commands");
                    Sys.exit(0);
            }
            i++;
        }
    }

    private static function fetchHelp():Void {
        Sys.println("   Haxefetch: a fetch program inspired by other fetches written in Haxe.\n");
        Sys.println("   Usage: haxefetch [OPTIONS]");
        Sys.println("   -h | --help                 Show help");
        Sys.println("   -v | --version              Show version of Haxefetch.");
        Sys.println("   -c | --config               Generate new config of Haxefetch.");
        Sys.println("   -t | --tutorial             Show how to customize Haxefetch.");
        Sys.println("   -s | --supported            Check if Haxefetch is supported.");
        Sys.println("   -l | --logo <name|path>     Override logo with a distro, custom file, or 'none'.");
    }

    private static function fetchInstructions():Void {
        Sys.println('In order to customise this:\n');
        Sys.println('Generate configuration with "haxefetch --config | -c" (it is located into /home/${Sys.getEnv("USER")}/.config/haxefetch directory).\nYou can see there is some options to customise this fetch program, so enjoy :)');
    }

    private static function checkIfSupported():Void {
        #if (windows || macos || bsd)
        Sys.println('Your platform ${SystemUtils.osPlatform()} does not supports Haxefetch!');
        #else
        Sys.println('Detected ${SystemUtils.getRawDistro()}! Supported.');
        #end
    }
}