package utils;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

#if hscript
import hscript.Interp;
import hscript.Parser;
import hscript.Printer;
#end

class Configuration {
    public static var modules:Array<String> = [
        "hostname", "host", "os", "kernel", "de", "wm",
        "ram", "swap", "cpu", "gpu", "disk", "packages",
        "uptime", "birthday", "birth", "colors"
    ];

    public static var separator:String = ":";

    public static var logo:String = "";
    public static var logoX:Int = 2;
    public static var logoY:Int = 1;
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
    public static var systemKernel:Bool = true;
    public static var kernelString:String = "Kernel";
    public static var systemKernelString:String = "Linux";

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
    public static var packageSeparator:String = ",";

    public static var showShell:Bool = true;
    public static var shellString:String = "Shell";

    public static var showUptime:Bool = true;
    public static var uptimeString:String = "Uptime";
    public static var daysString:String = "d";
    public static var hoursString:String = "h";
    public static var minutesString:String = "m";

    public static var showBirthday:Bool = true;
    public static var birthdayString:String = "OS Birthday";

    public static var showBirth:Bool = true;
    public static var birthString:String = "OS Birth";

    public static var showBlock:Bool = true;
    public static var showBlock2:Bool = true;

    public static function loadConfig():Void {
        var main = Sys.getEnv("HOME");
        if (main == null || main == "") return;

        var configDirectory = Path.join([main, ".config", "haxefetch"]);
        var hxFile = Path.join([configDirectory, "config.hx"]);
        var confFile = Path.join([configDirectory, "config.conf"]);

        if (FileSystem.exists(hxFile)) {
            loadHaxeConfig(hxFile);
        } else if (FileSystem.exists(confFile)) {
            loadConfConfig(confFile);
        } else {
            createConfiguration(configDirectory, confFile, false, false);
        }

    }

    public static function generateConfiguration():Void {
        var home = Sys.getEnv("HOME");
        if (home == null || home == "") {
            Sys.println('Haxefetch error: Could not determine user directory? Does home directory exist?');
            Sys.exit(1);
        }

        var configDirectory = Path.join([home, ".config", "haxefetch"]);

        Sys.println('There are ${Colors.colorize("2", Colors.GREEN)} types of configuration support. Which you\'re choosing?');
        Sys.println('${Colors.colorize(".conf", Colors.GREEN)} (default)');
        Sys.println('${Colors.colorize(".hx", Colors.fg(208))} (new)');
        Sys.stdout().writeString('[1-2]: ');
        Sys.stdout().flush();

        var choice = StringTools.trim(Sys.stdin().readLine());
        var isHaxe = (choice == "2" || choice.toLowerCase() == "hx");

        var fileName = isHaxe ? "config.hx" : "config.conf";
        var oldFileName = isHaxe ? "config.conf" : "config.hx";

        var configFile = Path.join([configDirectory, fileName]);
        var oldConfigFile = Path.join([configDirectory, oldFileName]);

        if (FileSystem.exists(oldConfigFile)) {
            FileSystem.deleteFile(oldConfigFile);
        }

        createConfiguration(configDirectory, configFile, true, isHaxe);
    }

    private static function loadConfConfig(path:String):Void {
        try {
            var configContent = File.getContent(path);
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

    #if hscript
    private static function loadHaxeConfig(path:String) {
        var parser = new Parser();
        var interp = new Interp();

        try {            
            parser.line = 1;

            interp.variables.set("modules", modules);
            interp.variables.set("separator", separator);

            interp.variables.set("logo", logo);
            interp.variables.set("logo_x", logoX);
            interp.variables.set("logo_y", logoY);
            interp.variables.set("logo_type", logoSize);
            interp.variables.set("logo_color", modules);

            interp.variables.set("show_hostname", showHostname);

            interp.variables.set("show_host", showHost);
            interp.variables.set("machine_vendor", vendor);
            interp.variables.set("machine_product", productName);
            interp.variables.set("host", hostString);

            interp.variables.set("show_distro", showDistro);
            interp.variables.set("distro", distroString);
            interp.variables.set("cpu_architecture", architecture);
            interp.variables.set("init", init);

            interp.variables.set("show_kernel", showKernel);
            interp.variables.set("kernel", kernelString);
            interp.variables.set("show_system_kernel", systemKernel);
            interp.variables.set("system_kernel", systemKernelString);

            interp.variables.set("show_desktop_environment", showDesktop);
            interp.variables.set("desktop", desktopString);

            interp.variables.set("show_window_manager", showSession);
            interp.variables.set("session", sessionString);
            interp.variables.set("display_protocol", protocol);

            interp.variables.set("show_ram", showRAM);
            interp.variables.set("ram", ramString);
            interp.variables.set("ram_percentage", ramPercent);

            interp.variables.set("show_swap", showSWAP);
            interp.variables.set("swap", swapString);
            interp.variables.set("swap_percentage", swapPercent);

            interp.variables.set("show_cpu", showCPU);
            interp.variables.set("cpu", cpuString);
            interp.variables.set("cpu_frequency", cpuFreq);
            interp.variables.set("cores_threads", cpuCAT);

            interp.variables.set("show_gpu", showGPU);
            interp.variables.set("gpu", gpuString);
            interp.variables.set("gpu_type", gpuType);

            interp.variables.set("show_disk_usage", showDisk);
            interp.variables.set("disk", diskString);

            interp.variables.set("show_package", showPackages);
            interp.variables.set("package", packageString);
            interp.variables.set("package_manager", packageManager);
            interp.variables.set("package_separator", packageSeparator);

            interp.variables.set("show_shell", showShell);
            interp.variables.set("shell", shellString);

            interp.variables.set("show_uptime", showUptime);
            interp.variables.set("uptime", uptimeString);
            interp.variables.set("days", daysString);
            interp.variables.set("hours", hoursString);
            interp.variables.set("minutes", minutesString);

            interp.variables.set("show_birthday", showBirthday);
            interp.variables.set("birthday", birthdayString);

            interp.variables.set("show_birth", showBirth);
            interp.variables.set("birth", birthString);

            interp.variables.set("show_color_block", showBlock);
            interp.variables.set("show_bright_color_block", showBlock2);

            var program = parser.parseString(File.getContent(path));
            interp.execute(program);

            if (interp.variables.exists("modules")) modules = interp.variables.get("modules");
            if (interp.variables.exists("separator")) separator = interp.variables.get("separator");

            if (interp.variables.exists("logo")) logo = interp.variables.get("logo");
            if (interp.variables.exists("logo_x")) logoX = interp.variables.get("logo_x");
            if (interp.variables.exists("logo_y")) logoY = interp.variables.get("logo_y");
            if (interp.variables.exists("logo_type")) logoSize = interp.variables.get("logo_type");
            if (interp.variables.exists("logo_color")) logoColor = interp.variables.get("logo_color");

            if (interp.variables.exists("show_hostname")) showHostname = interp.variables.get("show_hostname");

            if (interp.variables.exists("show_host")) showHost = interp.variables.get("show_host");
            if (interp.variables.exists("machine_vendor")) vendor = interp.variables.get("machine_vendor");
            if (interp.variables.exists("machine_product")) productName = interp.variables.get("machine_product");
            if (interp.variables.exists("host")) hostString = interp.variables.get("host");

            if (interp.variables.exists("show_distro")) showDistro = interp.variables.get("show_distro");
            if (interp.variables.exists("distro")) distroString = interp.variables.get("distro");
            if (interp.variables.exists("cpu_architecture")) architecture = interp.variables.get("cpu_architecture");
            if (interp.variables.exists("init")) init = interp.variables.get("init");

            if (interp.variables.exists("show_kernel")) showKernel = interp.variables.get("show_kernel");
            if (interp.variables.exists("kernel")) kernelString = interp.variables.get("kernel");
            if (interp.variables.exists("show_system_kernel")) systemKernel = interp.variables.get("show_system_kernel");
            if (interp.variables.exists("system_kernel")) systemKernelString = interp.variables.get("system_kernel");

            if (interp.variables.exists("show_desktop_environment")) showDesktop = interp.variables.get("show_desktop_environment");
            if (interp.variables.exists("desktop")) desktopString = interp.variables.get("desktop");

            if (interp.variables.exists("show_window_manager")) showSession = interp.variables.get("show_window_manager");
            if (interp.variables.exists("session")) sessionString = interp.variables.get("session");
            if (interp.variables.exists("display_protocol")) protocol = interp.variables.get("display_protocol");

            if (interp.variables.exists("show_ram")) showRAM = interp.variables.get("show_ram");
            if (interp.variables.exists("ram")) ramString = interp.variables.get("ram");
            if (interp.variables.exists("ram_percentage")) ramPercent = interp.variables.get("ram_percentage");

            if (interp.variables.exists("show_swap")) showSWAP = interp.variables.get("show_swap");
            if (interp.variables.exists("swap")) swapString = interp.variables.get("swap");
            if (interp.variables.exists("swap_percentage")) swapPercent = interp.variables.get("swap_percentage");

            if (interp.variables.exists("show_cpu")) showCPU = interp.variables.get("show_cpu");
            if (interp.variables.exists("cpu")) cpuString = interp.variables.get("cpu");
            if (interp.variables.exists("cpu_frequency")) cpuFreq = interp.variables.get("cpu_frequency");
            if (interp.variables.exists("cores_threads")) cpuCAT = interp.variables.get("cores_threads");

            if (interp.variables.exists("show_gpu")) showGPU = interp.variables.get("show_gpu");
            if (interp.variables.exists("gpu")) gpuString = interp.variables.get("gpu");
            if (interp.variables.exists("gpu_type")) gpuType = interp.variables.get("gpu_type");

            if (interp.variables.exists("show_disk_usage")) showDisk = interp.variables.get("show_disk_usage");
            if (interp.variables.exists("disk")) diskString = interp.variables.get("disk");

            if (interp.variables.exists("show_package")) showPackages = interp.variables.get("show_package");
            if (interp.variables.exists("package")) packageString = interp.variables.get("package");
            if (interp.variables.exists("package_manager")) packageManager = interp.variables.get("package_manager");
            if (interp.variables.exists("package_separator")) packageSeparator = interp.variables.get("package_separator");

            if (interp.variables.exists("show_shell")) showShell = interp.variables.get("show_shell");
            if (interp.variables.exists("shell")) shellString = interp.variables.get("shell");

            if (interp.variables.exists("show_uptime")) showUptime = interp.variables.get("show_uptime");
            if (interp.variables.exists("uptime")) uptimeString = interp.variables.get("uptime");
            if (interp.variables.exists("days")) daysString = interp.variables.get("days");
            if (interp.variables.exists("hours")) hoursString = interp.variables.get("hours");
            if (interp.variables.exists("minutes")) minutesString = interp.variables.get("minutes");

            if (interp.variables.exists("show_birthday")) showBirthday = interp.variables.get("show_birthday");
            if (interp.variables.exists("birthday")) birthdayString = interp.variables.get("birthday");

            if (interp.variables.exists("show_birth")) showBirth = interp.variables.get("show_birth");
            if (interp.variables.exists("birth")) birthString = interp.variables.get("birth");

            if (interp.variables.exists("show_color_block")) showBlock = interp.variables.get("show_color_block");
            if (interp.variables.exists("show_bright_color_block")) showBlock2 = interp.variables.get("show_bright_color_block");

        } catch (e:hscript.Expr.Error) {
            var lineNumb = switch (e) {
                case EInvalidChar(_), EUnexpected(_), EUnterminatedString, EUnterminatedComment:
                    null;
    
                default: null;
            };

            var lineNumb = parser.line;
            var lineInfo = (lineNumb > 0) ? '[Line ${lineNumb}]:' : '';
            var error = Printer.errorToString(e);

            Sys.println('${Colors.colorize("Error in configuration of Haxefetch!", Colors.RED)} ${Colors.colorize(lineInfo, Colors.YELLOW)} ${Colors.colorize(error, Colors.RED)}');
            Sys.exit(0);
        } catch (e:Dynamic) {
            Sys.println('${Colors.colorize("Error loading .hx config script: ", Colors.RED)} ${e}');
            Sys.exit(0);
        }
    }
    #end

    private static function parseConfigOptions(key:String, value:String, lineNumber:Int):Void {
        switch (key) {
            case "modules":
                var raw = value.split(",");
                modules = [for (item in raw) StringTools.trim(item)];
            case "separator": separator = parseString(value);

            case "logo": logo = parseString(value);
            // case "custom_logo": customLogo = parseString(value);
            case "logo_x": logoX = parseInt(value, 2);
            case "logo_y": logoY = parseInt(value, 1);
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
            case "show_system_kernel": systemKernel = parseBool(value);
            case "system_kernel": systemKernelString = parseString(value);

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
            case "package_separator": packageSeparator = parseString(value);

            case "show_shell": showShell = parseBool(value);
            case "shell": shellString = parseString(value);

            case "show_uptime": showUptime = parseBool(value);
            case "uptime": uptimeString = parseString(value);
            case "days": daysString = parseString(value);
            case "hours": hoursString = parseString(value);
            case "minutes": minutesString = parseString(value);

            case "show_birthday": showBirthday = parseBool(value);
            case "birthday": birthdayString = parseString(value);

            case "show_birth": showBirth = parseBool(value);
            case "birth": birthString = parseString(value);

            case "show_color_block": showBlock = parseBool(value);
            case "show_bright_color_block": showBlock2 = parseBool(value);
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

    private static function parseInt(value:String, fallback:Int):Int {
        if (value == null || value == "") return fallback;
        var parse = Std.parseInt(value);
        return parse != null ? parse : fallback;
    }

    private static function createConfiguration(directory:String, path:String, creation:Bool, isHScript:Bool = false):Void {
        try {
            if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);

            var defaults:String;

            if (isHScript) {
                defaults =
                "modules = [\"hostname\", \"host\", \"os\", \"kernel\", \"de\", \"wm\", \"ram\", \"swap\", \"cpu\", \"gpu\", \"disk\", \"packages\", \"shell\", \"uptime\", \"birthday\", \"birth\", \"colors\"];\n" +
                "separator = \":\";\n\n" +

                "logo = \'\';\n" +
                "logo_x = \'2\';\n" +
                "logo_y = \'1\';\n" +
                "logo_type = \'normal\';\n" +
                "logo_color = \'\';\n\n" +

                "show_hostname = true;\n" +
                "show_host = true;\n" +
                "machine_vendor = true;\n" +
                "machine_product = true;\n" +
                "host = \'Host\';\n\n" +

                "show_distro = true;\n" +
                "distro = \'OS\';\n" +
                "cpu_architecture = true;\n" +
                "init = true;\n\n" +

                "show_kernel = true;\n" +
                "kernel = \'Kernel\';\n" +
                "show_system_kernel = true;\n" +
                "system_kernel = \'Linux\';\n\n" +

                "show_desktop_environment = true;\n" +
                "desktop = \'DE\';\n\n" +

                "show_window_manager = true;\n" +
                "session = \'WM\';\n" +
                "display_protocol = true;\n\n" +

                "show_ram = true;\n" +
                "ram = \'RAM\';\n" +
                "ram_percentage = true;\n\n" +

                "show_swap = true;\n" +
                "swap = \'SWAP\';\n" +
                "swap_percentage = true;\n\n" +

                "show_cpu = true;\n" +
                "cpu = \'CPU\';\n" +
                "cpu_frequency = true;\n" +
                "cores_threads = true;\n\n" +

                "show_gpu = true;\n" +
                "gpu = \'GPU\';\n" +
                "gpu_type = true;\n\n" +

                "show_disk_usage = true;\n" +
                "disk = \'Disk\';\n\n" +

                "show_package = true;\n" +
                "package = \'Packages\';\n" +
                "package_manager = true;\n" +
                "package_separator = \', \';\n\n" +

                "show_shell = true;\n" +
                "shell = \'Shell\';\n\n" +

                "show_uptime = true;\n" +
                "uptime = \'Uptime\';\n" +
                "days = \'d\';\n" +
                "hours = \'h\';\n" +
                "minutes = \'m\';\n\n" + 

                "show_birthday = true;\n" +
                "birthday = \'OS Birthday\';\n\n" +

                "show_birth = true;\n" +
                "birth = \'OS Birth\';\n\n" +

                "show_color_block = true;\n" +
                "show_bright_color_block = true;";
            } else {
                defaults =
                "# Haxefetch configuration\n\n" +
                "modules=hostname, host, os, kernel, de, wm, ram, swap, cpu, gpu, disk, packages, shell, uptime, birthday, birth, colors\n" +
                "separator=':'\n\n" +

                "logo=''\n" +
                "logo_x='2'\n" +
                "logo_y='1'\n" + 
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
                "kernel='Kernel'\n" +
                "show_system_kernel=true\n" +
                "system_kernel='Linux'\n\n" +

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
                "package_manager=true\n" +
                "package_separator=', '\n\n" +

                "show_shell=true\n" +
                "shell='Shell'\n\n" +

                "show_uptime=true\n" +
                "uptime='Uptime'\n" +
                "days='d'\n" +
                "hours='h'\n" +
                "minutes='m'\n\n" +

                "show_birthday=true\n" +
                "birthday='OS Birthday'\n\n" +

                "show_birth=true\n" +
                "birth='OS Birth'\n\n" +

                "show_color_block=true\n" + 
                "show_bright_color_block=true";
            }

            File.saveContent(path, defaults);

            if (creation) {
                Sys.println('${Colors.colorize('Configuration is now generated in', Colors.YELLOW)}${Colors.colorize(':', Colors.WHITE)} ${Colors.colorize('"${directory}"', Colors.GREEN)} ${Colors.colorize('as ->', Colors.WHITE)} ${Colors.colorize('"${path}"', Colors.YELLOW)}');
                Sys.exit(1);
            }
        } catch (e:Dynamic) {
            Sys.println('${Colors.colorize('Genereting config failed:', Colors.RED)}) ${Colors.colorize('${e}', Colors.YELLOW)}');
            if (creation) Sys.exit(1);
        }
    }
}
