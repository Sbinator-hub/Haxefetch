package utils;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class Configuration {
    public static var modules:Array<String> = [
        "hostname", "host", "os", "kernel", "de", "wm",
        "ram", "swap", "cpu", "gpu", "disk", "packages",
        "haxe", "opengl", "vulkan", "uptime",
        "birthday", "birth", "colors"
    ];

    public static var separator:String = ":";

    public static var logo:String = "";
    // public static var customLogo:String = "";
    public static var logoSize:String = "normal";
    public static var logoColor = "";

    public static var showHostname:Bool = true;

    public static var showHost:Bool = true;
    public static var hostString:String = "Host";
    public static var vendor:Bool = true;
    public static var productName:Bool = true;

    public static var showDistro:Bool = true;
    public static var distroString:String = "OS";
    public static var architecture:Bool = true;
    public static var init:Bool = true;

    public static var showKernel:Bool = true;
    public static var kernelString:String = "Kernel";

    public static var showDesktop:Bool = true;
    public static var desktopString:String = "DE";

    public static var showSession:Bool = true;
    public static var sessionString:String = "WM";
    public static var protocol:Bool = true;

    public static var showRAM:Bool = true;
    public static var ramString:String = "RAM";
    public static var ramPercent:Bool = true;

    public static var showSWAP:Bool = true;
    public static var swapString:String = "SWAP";
    public static var swapPercent:Bool = true;

    public static var showCPU:Bool = true;
    public static var cpuString:String = "CPU";
    public static var cpuFreq:Bool = true;
    public static var cpuCAT:Bool = true;

    public static var showGPU:Bool = true;
    public static var gpuString:String = "GPU";
    public static var gpuType:Bool = true;

    public static var showDisk:Bool = true;
    public static var diskString:String = "Disk";

    public static var showPackages:Bool = true;
    public static var packageString:String = "Packages";
    public static var packageManager:Bool = true;

    public static var showShell:Bool = true;
    public static var shellString:String = "Shell";

    public static var showUptime:Bool = true;
    public static var uptimeString:String = "Uptime";

    public static var showBirthday:Bool = true;
    public static var birthdayString:String = "OS Birthday";

    public static var showBirth:Bool = true;
    public static var birthString:String = "OS Birth";

    public static var showBlock:Bool = true;

    public static function loadConfig():Void {
        var main = Sys.getEnv("HOME");
        if (main == null || main == "") return;

        var configDirectory = Path.join([main, ".config", "haxefetch"]);
        var configFile = Path.join([configDirectory, "config.conf"]);

        if (!FileSystem.exists(configFile)) {
            createConfiguration(configDirectory, configFile, false);
            return;
        }

        try {
            var configContent = File.getContent(configFile);
            var line = configContent.split("\n");

            for (i in 0...line.length) {
                var lineNumber = i + 1;
                var lines = line[i];
                var trims = StringTools.trim(lines);

                if (trims == "" || StringTools.startsWith(trims, "#") || StringTools.startsWith(trims, ";") || StringTools.startsWith(trims, "[") && StringTools.endsWith(trims, "]")) continue;
                if (trims.indexOf("=") == -1) {
                    Sys.println('${Colors.colorize("Error in configuration of Haxefetch!", Colors.RED)} ${Colors.colorize('[Line ${lineNumber}]:', Colors.YELLOW)} ${Colors.colorize('Invalid config syntax. Missing "=" for', Colors.RED)} -> ${Colors.colorize('"${trims}"', Colors.YELLOW)} <-');
                    Sys.exit(1);
                }
                
                var part = trims.split("=");
                var keyValue = StringTools.trim(part[0]);
                var value = StringTools.trim(part.slice(1).join("="));

                if (keyValue == "") {
                    Sys.println('${Colors.colorize("Error in configuration of Haxefetch!", Colors.RED)} ${Colors.colorize('[Line ${lineNumber}]:', Colors.YELLOW)} ${Colors.colorize('Missing module key option before "="', Colors.RED)}');
                    Sys.exit(1);
                }

                try {
                    parseConfigOptions(keyValue, value, lineNumber);
                } catch (e:Dynamic) {
                    Sys.println('${Colors.colorize("Error in configuration of Haxefetch!", Colors.RED)} ${Colors.colorize('[Line ${lineNumber}]:', Colors.YELLOW)} ${Colors.colorize('Failed to parse option module', Colors.RED)} ${Colors.colorize('"${keyValue}"', Colors.YELLOW)} -> ${Colors.colorize('${e}', Colors.RED)}');
                    Sys.exit(1);
                }
            }
        } catch (e:Dynamic) {
            Sys.println('${Colors.colorize("Fatal error appeared:", Colors.RED)} ${Colors.colorize('Cannot read config file: ${e}. Is directory and configuration correct?', Colors.RED)}');
            Sys.exit(1);
        }
    }

    public static function generateConfiguration():Void {
        var home = Sys.getEnv("HOME");
        if (home == null || home == "") {
            Sys.println('Haxefetch error: Could not determine user directory? Does home directory exist?');
            Sys.exit(1);
        }

        var configDirectory = Path.join([home, ".config", "haxefetch"]);
        var configFile = Path.join([configDirectory, "config.conf"]);
        createConfiguration(configDirectory, configFile, true);
    }

    private static function parseConfigOptions(key:String, value:String, lineNumber:Int):Void {
        switch (key) {
            case "modules":
                var raw = value.split(",");
                modules = [for (item in raw) StringTools.trim(item)];  
            case "separator": separator = parseString(value);
    
            case "logo": logo = parseString(value);
            // case "custom_logo": customLogo = parseString(value);
            case "logo_type": logoSize = parseString(value);
            case "logo_color": logoColor = parseString(value);

            case "show_hostname": showHostname = parseBool(value);

            case "show_host": showHost = parseBool(value);
            case "machine_vendor": vendor = parseBool(value);
            case "machine_product": productName = parseBool(value);
            case "host": hostString = parseString(value);

            case "show_distro": showDistro = parseBool(value);
            case "distro": distroString = parseString(value);
            case "cpu_architecture": architecture = parseBool(value);
            case "init": init = parseBool(value);

            case "show_kernel": showKernel = parseBool(value);
            case "kernel": kernelString = parseString(value);

            case "show_desktop_environment": showDesktop = parseBool(value);
            case "desktop": desktopString = parseString(value);

            case "show_window_manager": showSession = parseBool(value);
            case "session": sessionString = parseString(value);
            case "display_protocol": protocol = parseBool(value);

            case "show_ram": showRAM = parseBool(value);
            case "ram": ramString = parseString(value);
            case "ram_percentage": ramPercent = parseBool(value);

            case "show_swap": showSWAP = parseBool(value);
            case "swap": swapString = parseString(value);
            case "swap_percentage": swapPercent = parseBool(value);

            case "show_cpu": showCPU = parseBool(value);
            case "cpu": cpuString = parseString(value);
            case "cpu_frequency": cpuFreq = parseBool(value);
            case "cores_threads": cpuCAT = parseBool(value);

            case "show_gpu": showGPU = parseBool(value);
            case "gpu": gpuString = parseString(value);
            case "gpu_type": gpuType = parseBool(value);
 
            case "show_disk_usage": showDisk = parseBool(value);
            case "disk": diskString = parseString(value);

            case "show_package": showPackages = parseBool(value);
            case "package": packageString = parseString(value);
            case "package_manager": packageManager = parseBool(value);

            case "show_shell": showShell = parseBool(value);
            case "shell": shellString = parseString(value);

            case "show_uptime": showUptime = parseBool(value);
            case "uptime": uptimeString = parseString(value);

            case "show_birthday": showBirthday = parseBool(value);
            case "birthday": birthdayString = parseString(value);

            case "show_birth": showBirth = parseBool(value);
            case "birth": birthString = parseString(value);

            case "show_color_block": showBlock = parseBool(value);
            default:
                Sys.println('${Colors.colorize("Error in configuration of Haxefetch!", Colors.RED)} ${Colors.colorize('[Line ${lineNumber}]:', Colors.YELLOW)} ${Colors.colorize('Unknown option key', Colors.RED)} -> ${Colors.colorize('"${key}"', Colors.YELLOW)} <-');
                Sys.exit(1);
        }
    }

    private static function parseBool(value:String):Bool {
        var low = value.toLowerCase();
        if (low == "true") return true;
        if (low == "false") return false;

        throw '${Colors.colorize('Invalid bool options', Colors.RED)} ${Colors.colorize('"${value}"', Colors.YELLOW)} ${Colors.colorize('(expected only true or false)', Colors.RED)}';
    }

    private static function parseString(value:String):String {
        if ((StringTools.startsWith(value, "\"") && StringTools.endsWith(value, "\"")) || (StringTools.startsWith(value, "'") && StringTools.endsWith(value, "'"))) {
            return value.substring(1, value.length - 1);
        }
        return value;
    }

    private static function createConfiguration(directory:String, path:String, creation:Bool):Void {
        try {
            if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);

            var defaults =
                "# Haxefetch configuration\n\n" +
                "modules=hostname, host, os, kernel, de, wm, ram, swap, cpu, gpu, disk, packages, shell, uptime, birthday, birth, colors\n" +
                "separator=':'\n\n" +

                "logo=''\n" +
                // "custom_logo=''\n" + IT IS BROKEN AND NOT WORKING
                "logo_type='normal'\n" +
                "logo_color=''\n\n" +

                "show_hostname=true\n" +
                "show_host=true\n" +
                "machine_vendor=true\n" +
                "machine_product=true\n" +
                "host='Host'\n\n" +

                "show_distro=true\n" +
                "distro='OS'\n" +
                "cpu_architecture=true\n" +
                "init=true\n\n" +

                "show_kernel=true\n" +
                "kernel='Kernel'\n\n" +

                "show_desktop_environment=true\n" +
                "desktop='DE'\n\n" +

                "show_window_manager=true\n" +
                "session='WM'\n" +
                "display_protocol=true\n\n" +

                "show_ram=true\n" +
                "ram='RAM'\n" +
                "ram_percentage=true\n\n" +

                "show_swap=true\n" +
                "swap='SWAP'\n"+
                "swap_percentage=true\n\n" +

                "show_cpu=true\n" +
                "cpu='CPU'\n" +
                "cpu_frequency=true\n" +
                "cores_threads=true\n\n" +

                "show_gpu=true\n" +
                "gpu='GPU'\n" +
                "gpu_type=true\n\n" +

                "show_disk_usage=true\n" +
                "disk='Disk'\n\n" +

                "show_package=true\n" +
                "package='Packages'\n" +
                "package_manager=true\n\n" +

                "show_shell=true\n" +
                "shell='Shell'\n\n" +

                "show_uptime=true\n" +
                "uptime='Uptime'\n\n" +

                "show_birthday=true\n" +
                "birthday='OS Birthday'\n\n" +

                "show_birth=true\n" +
                "birth='OS Birth'\n\n" +

                "show_color_block=true\n";

            File.saveContent(path, defaults);

            if (creation) {
                Sys.println('${Colors.colorize('Configuration is now generated in', Colors.YELLOW)} ${Colors.colorize(':', Colors.WHITE)} ${Colors.colorize('"${directory}"', Colors.GREEN)}');
                Sys.exit(1);
            }
        } catch (e:Dynamic) {
            Sys.println('${Colors.colorize('Genereting config failed:', Colors.RED)}) ${Colors.colorize('${e}', Colors.WHITE)}');
            if (creation) Sys.exit(1);
        }
    }
}
