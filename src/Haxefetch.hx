package;

import sys.io.Process;

class Haxefetch {
    static function main():Void {
        Commands.parse(Sys.args());
        Configuration.loadConfig();

        #if (windows || macos || android || bsd)
        Sys.println('Haxefetch on ${SystemUtils.osPlatform()} is not currently supported!');
        #else
        initFetch();
        #end
    }

    static function initFetch():Void {
        var user = getEnvironment("USER", getEnvironment("USERNAME", "user"));
        var hostname = SystemUtils.fetchHostname();
        var host = SystemUtils.fetchHost();
        var distro = SystemUtils.fetchDistro();
        var architecture = CPUUtility.fetchArchitecture();
        var archSuffix = (architecture != "") ? ' ${architecture}' : '';
        var init = SystemUtils.fetchInit();
        var initSuffix = (init != "") ? ' [${Colors.colorize(init, Colors.GREEN)}]' : '';
        var logoFetch = (Configuration.logo != "") ? Configuration.logo : distro;
        var kernel = SystemUtils.fetchKernel();
        var desktop = XdgSession.fetchDestkop();
        var session = XdgSession.fetchSession();
        var protocol = XdgSession.fetchProtocol();
        var memory = Memory.memoryStats();        
        var ram = memory.ram;
        var swap = memory.swap;
        var cpu = CPUUtility.fetchCPU();
        var gpu = GPUUtility.fetchGPU();
        var disk = DiskUtility.fetchDisk();
        var packages = Packages.fetchPackage();
        var packageSuffix = (packages != "") ? packages : '';
        var shell = SystemUtils.fetchShell();
        var uptime = SystemUtils.fetchUptime();
        var birthday = SystemUtils.fetchBirthday();
        var birth = SystemUtils.fetchInstalledDate();
        var separator:String = " ";

        var target = (Configuration.logo != null && Configuration.logo != "") ? Configuration.logo : distro;
        var object = Logo.fetchColor(target);
        var mainColor = (object != null && object.primary != null) ? object.primary : Colors.RESET;

        var rawString:String = Configuration.logoColor;
        var rawColor:Array<String> = (rawString != null) ? rawString.split(",") : [];

        var customColor = (rawColor.length > 0 && StringTools.trim(rawColor[0]) != "") ? StringTools.trim(rawColor[0]) : "";
        var customColor1 = (rawColor.length > 1 && StringTools.trim(rawColor[1]) != "") ? StringTools.trim(rawColor[1]) : "";
        var customColor2 = (rawColor.length > 2 && StringTools.trim(rawColor[2]) != "") ? StringTools.trim(rawColor[2]) : "";

        var parseColor = (customColor != "") ? Colors.getColors(customColor) : "";
        var parseColor1 = (customColor1 != "") ? Colors.getColors(customColor1): "";
        var parseColor2 = (customColor1 != "") ? Colors.getColors(customColor2): "";

        var logoColor = (parseColor != "" && parseColor != null) ? parseColor : mainColor;

        var logo = Logo.fetchLogo(distro, Configuration.logoSize, Configuration.logo, logoColor, parseColor1, parseColor2);

        var modules:Map<String, String> = [
            "hostname" => Configuration.showHostname ? Colors.colorize(user, Colors.RED) + "@" + Colors.colorize(hostname, Colors.RED) : null,
            "host"     => (Configuration.showHost && host != null) ? (Configuration.showHost ? Colors.colorize(Configuration.hostString, logoColor) + Configuration.separator + separator + host : null) : null,
            "os"       => Configuration.showDistro ? Colors.colorize(Configuration.distroString, logoColor) + Configuration.separator + separator + distro + (Configuration.architecture ? archSuffix : "") + (Configuration.init ? initSuffix : "") : null,
            "kernel"   => Configuration.showKernel ? Colors.colorize(Configuration.kernelString, logoColor) + Configuration.separator + separator + (Configuration.systemKernel ? Configuration.systemKernelString + separator + kernel : kernel) : null,
            "de"       => (desktop != null && desktop != "N/A" && desktop != "" && Configuration.showDesktop) ? Colors.colorize(Configuration.desktopString, logoColor) + Configuration.separator + separator + desktop : null,
            "wm"       => (Configuration.showSession && session != null && session != "") ? Colors.colorize(Configuration.sessionString, logoColor) + Configuration.separator + separator + session + (Configuration.protocol ? ' (${protocol})' : '') : null,
            "ram"      => Configuration.showRAM ? Colors.colorize(Configuration.ramString, logoColor) + Configuration.separator + separator + ram : null,
            "swap"     => Configuration.showSWAP ? Colors.colorize(Configuration.swapString, logoColor) + Configuration.separator + separator + swap : null,
            "cpu"      => Configuration.showCPU ? Colors.colorize(Configuration.cpuString, logoColor) + Configuration.separator + separator + cpu : null,
            "gpu"      => Configuration.showGPU ? Colors.colorize(Configuration.gpuString, logoColor) + Configuration.separator +separator + gpu : null,
            "disk"     => Configuration.showDisk ? Colors.colorize(Configuration.diskString, logoColor) + Configuration.separator + separator + disk : null,
            "packages" => Configuration.showPackages ? Colors.colorize(Configuration.packageString, logoColor) + Configuration.separator + separator + packageSuffix : null,
            "shell"    => Configuration.showShell ? Colors.colorize(Configuration.shellString, logoColor) + Configuration.separator + separator + shell : null,
            "uptime"   => Configuration.showUptime ? Colors.colorize(Configuration.uptimeString, logoColor) + Configuration.separator + separator + uptime : null,
            "birthday" => Configuration.showBirthday ? Colors.colorize(Configuration.birthdayString, logoColor) + Configuration.separator + separator + birthday : null,
            "birth"    => Configuration.showBirth ? Colors.colorize(Configuration.birthString, logoColor) + Configuration.separator + separator + birth : null,
            "colors"   => Configuration.showBlock ? Colors.getColorBlocks() + (Configuration.showBlock2 ? separator + Colors.getBrightColorBlocks() : "") : null
        ];

        var infoLine:Array<String> = Configuration.modules.map(function(key) return modules.get(key)).filter(function(line) return line != null);

        var offsetX = Configuration.logoX;
        var offsetY = Configuration.logoY;

        var horizontalPad = StringTools.lpad("", " ", offsetX);
        var paddingLogo = logo.map(line -> horizontalPad + line);

        var finalLogo:Array<String> = [];
        for (i in 0...offsetY) finalLogo.push("");
        for (line in paddingLogo) finalLogo.push(line);

        var logoWidth = 0;
        for (line in finalLogo) {
            var visibleLen = Colors.stripAnsi(line).length;
            if (visibleLen > logoWidth) logoWidth = visibleLen;
        }

        var maximumLine = finalLogo.length > infoLine.length ? finalLogo.length : infoLine.length;
        for (i in 0...maximumLine) {
            var left = i < finalLogo.length ? finalLogo[i] : "";
            var right = i < infoLine.length ? infoLine[i] : "";

            if (logoColor != "" && logoColor != null) {
                var color = Colors.getColors(logoColor);
                if (color != "") left = color + Colors.stripAnsi(left) + Colors.RESET; 
            }

            var visibleLeftLen = Colors.stripAnsi(left).length;
            var padding = (logoWidth + 3) - visibleLeftLen;
            if (padding < 0) padding = 0;
            
            var space = StringTools.lpad("", " ", padding);
            Sys.println('$left$space$right');
        }
    }
    
    static function getEnvironment(key:String, fallback:String):String {
        var value = Sys.getEnv(key);
        return (value != null) ? value : fallback;
    }

    public static function roundDecimal(val:Float, precision:Int):Float {
        var factor = Math.pow(10, precision);
        return Math.round(val * factor) / factor;
    }

    public static function executeCount(cmd:String, args:Array<String>):Int {
        try {
            var p = new Process(cmd, args);
            var count = 0;
            try {
                while (true) {
                    p.stdout.readLine();
                    count++;
                }
            } catch (e:haxe.io.Eof) {}
            p.close();
            return count;
        } catch (e:Dynamic) {
            return 0;
        }
    }

    public static function runCmd(cmd:String, args:Array<String>):String {
        try {
            var p = new Process(cmd, args);
            var stdout = p.stdout.readAll().toString();
            p.close();
            return StringTools.trim(stdout);
        } catch (e:Dynamic) {
            return "N/A";
        }
    }
}