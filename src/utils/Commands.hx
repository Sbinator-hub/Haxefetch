package utils;

import haxe.macro.Compiler;

class Commands {
    public static final HAXEFETCH_VERSION:String = "1.1.0";
    public static var commit:String = "";

    public static function parse(argument:Array<String>):Void {
        if (commit == "") commit = SystemUtils.fetchGithubCommit();
        for (args in argument) {
            switch (args) {
                case "-h" | "--help":
                    fetchHelp();
                    Sys.exit(0);
                
                case "-v" | "--version":
                    Sys.println('Haxefetch ${HAXEFETCH_VERSION} (Built on Haxe ${Compiler.getDefine("haxe")}) [Commit ${commit}]');
                    Sys.exit(0);

                case "-c" | "--config":
                    Configuration.generateConfiguration();

                case "-t" | "--tutorial":
                    fetchInstructions();
                    Sys.exit(0);
                
                case "-s" | "--supported":
                    checkIfSupported();
                    Sys.exit(0);

                default:
                    Sys.println('Unknown command ${args}');
                    Sys.println("Try -h or --help for current commands");
                    Sys.exit(0);
            }
        }
    }

    private static function fetchHelp():Void {
        Sys.println("   Haxefetch: a fetch program inspired by other fetches written in Haxe.\n");
        Sys.println("   Usage: haxefetch [OPTIONS]");
        Sys.println("   -h | --help " + " " + "        Show help");
        Sys.println("   -v | --version " + " " + "     Show version of Haxefetch.");
        Sys.println("   -c | --config " + " " + "      Generate new config of Haxefetch.");
        Sys.println("   -t | --tutorial " + " " + "    Show how to customize Haxefetch.");
        Sys.println("   -s | --supported " + " " + "   Check if Haxefetch is supported.");
    } 

    private static function fetchInstructions():Void {
        Sys.println('In order to customise this:\n');
        Sys.println('Generate configuration with "haxefetch --config | -c" (it is located into /home/${Sys.getEnv("USER")}/.config/haxefetch directory).\nYou can see there is some options to customise this fetch program, so enjoy :)');
    }

    private static function checkIfSupported():Void {
        #if (windows || macos || android || bsd)
        Sys.println('Your platform ${SystemUtils.osPlatform()} does not supports Haxefetch!');
        #else
        Sys.println('Detected ${SystemUtils.fetchDistro()}! Supported.');
        #end
    }
}
