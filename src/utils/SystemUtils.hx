package utils;

import sys.io.Process;
import haxe.macro.Expr;
import sys.io.FileSeek;
import sys.FileSystem;
import sys.io.File;

class SystemUtils {
    private static var realDistro:String = null;

    public static function fetchHostname():String {
        #if sys
        if (FileSystem.exists("/etc/hostname")) {
            var host = StringTools.trim(File.getContent("/etc/hostname"));
            if (host.length > 0) return host;
        }

        if (FileSystem.exists("/etc/conf.d/hostname")) {
            var content = File.getContent("/etc/conf.d/hostname");
            for (line in content.split("\n")) {
                line = StringTools.trim(line);
                if (StringTools.startsWith(line, "#")) continue;

                if (StringTools.startsWith(line, "hostname=") || StringTools.startsWith(line, "HOSTNAME=")) {
                    var name = line.split("=")[1];
                    name = StringTools.replace(name, "\"", "");
                    name = StringTools.replace(name, "'", "");
                    if (name.length > 0) return StringTools.trim(name);
                }
            }
        }

        if (FileSystem.exists("/proc/sys/kernel/hostname")) {
            var proc = StringTools.trim(File.getContent("/proc/sys/kernel/hostname"));
            if (proc.length > 0) return proc;
        }
        #end
        return "Haxefetch";
    }

    public static function fetchHost():String {
        var bios:String = readFile("/sys/class/dmi/id/bios_vendor");
        var board:String = readFile("/sys/clas/dmi/id/board_vendor");
        var family:String = readFile("/sys/class/dmi/id/product_family");
        var version:String = readFile("/sys/class/dmi/id/product_version");
        var name:String = readFile("/sys/class/dmi/id/product_name");

        var vendor:String = "";
        var model:String = "";

        if (bios != "" && bios != "None")
            vendor = convertTitle(bios);
        else if (board != "" && board != "None")
            vendor = convertTitle(board);

        if (version != "" && version != "None" && version != "System Version")
            model = version;
        else if (family != "" && family != "None")
            model = family;
        else if (name != "" && name != "None" && name != "System Product Name")
            model = name;
        if (model == "") return "";

        if (name != "" && name != model && name != "None" && name != "System Product Name") Configuration.productName ? model += " (" + name + ")" : model += "";
        if (vendor != "") {
            var lowerM = model.toLowerCase();
            var lowerV = vendor.toLowerCase();
            if (lowerM.indexOf(lowerV) == -1) Configuration.vendor ? model = '${vendor} ${model}' : model = '${model}';
        }
        
        return model;
    }

    private static function convertTitle(title:String):String {
        return title.toLowerCase().split(" ").map(word -> {
            if (title.length == 0) return "";
            return word.charAt(0).toUpperCase() + word.substr(1);
        }).join(" ");
    }

    private static function readFile(path:String):String {
        #if sys
        if (sys.FileSystem.exists(path)) {
            try {
                var input = File.read(path, false);
                var content = input.readAll().toString();
                input.close();
                if (content != null && content != "") return StringTools.trim(content);
            } catch (e:Dynamic) {}
        }
        #end
        return "";
    }

    public static function getRawDistro():String {
        if (realDistro != null) return realDistro;

        var osName = "";

        // LSB release
        var lsbReleases = [
            "/etc/lsb-release",
            "/etc/upstream-release/lsb-release"
        ];

        var lsbFiles = "";
        for (lsbPath in lsbReleases) {
            if (FileSystem.exists(lsbPath)) {
                lsbFiles = lsbPath;
                break;
            }
        }

        if (lsbFiles != "") {
            try {
                var lsbLine = File.getContent(lsbFiles).split("\n");
                for (lines in lsbLine) {
                    var cleanLsbLine = StringTools.trim(lines);

                    if (StringTools.startsWith(cleanLsbLine, "DISTRIB_DESCRIPTION=")) {
                        var lsbPart = cleanLsbLine.indexOf("=");
                        if (lsbPart != -1) {
                            var lsbName = StringTools.trim(cleanLsbLine.substr(lsbPart + 1));
                            if ((StringTools.startsWith(lsbName, '"') && StringTools.endsWith(lsbName, '"')) ||
                                (StringTools.startsWith(lsbName, "'") && StringTools.endsWith(lsbName, "'"))) {
                                    lsbName = lsbName.substring(1, lsbName.length -1);
                            }
                            osName = lsbName;
                            break;
                        } 
                    }
                }
            } catch (e:Dynamic) {}
        }
 
        // Fallback to default good old OS release file
        if (osName == "" && FileSystem.exists("/etc/os-release")) {
            try {
                var lines = File.getContent("/etc/os-release").split("\n");
                for (line in lines) {
                    var cleanLine = StringTools.trim(line);

                    if (StringTools.startsWith(cleanLine, "PRETTY_NAME=")) {
                        var parts = cleanLine.indexOf("=");
                        if (parts != -1) {
                            var name = StringTools.trim(cleanLine.substr(parts + 1));
                            if ((StringTools.startsWith(name, '"') && StringTools.endsWith(name, '"')) || 
                                (StringTools.startsWith(name, "'") && StringTools.endsWith(name, "'"))) {
                                name = name.substring(1, name.length -1 );
                            }
                            osName = name;
                            break;
                        }
                    }
                }
            } catch (e:Dynamic) {}
        }

        if (osName != "") {

            // Try to fetch Ubuntu variants/flavours
            osName = getUbuntuVariants(osName);

            realDistro = osName;
            return realDistro;
        }

        realDistro = Sys.systemName();
        return realDistro;
    }

    private static function getUbuntuVariants(ubuntu:String):String {
        if (ubuntu.toLowerCase().indexOf("ubuntu") == -1) return ubuntu;

        if (FileSystem.exists("/var/lib/dpkg/info/xubuntu-desktop.list")) return StringTools.replace(ubuntu, "Ubuntu", "XUbuntu");
        if (FileSystem.exists("/var/lib/dpkg/info/kubuntu-desktop.list")) return StringTools.replace(ubuntu, "Ubuntu", "Kubuntu");
        if (FileSystem.exists("/var/lib/dpkg/info/lubuntu-desktop.list")) return StringTools.replace(ubuntu, "Ubuntu", "Lubuntu");

        return ubuntu;
    }

    private static function fetchDistro():String {
        var actualName = getRawDistro();

        if (Configuration.distroNameString != null && Configuration.distroNameString != "") {
            return Configuration.distroNameString;
        }

        return actualName;
    }

    public static function readDistroKey():String return fetchDistro();

    public static function fetchInit():String {
        try {
            if (FileSystem.exists("/proc/1/comm")) {
                var input = File.read("/proc/1/comm", false);
                var com = StringTools.trim(input.readLine());
                input.close();

                switch (com) {
                    case "systemd": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "systemD"; 
                    case "openrc-init": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "OpenRC";
                    case "runit": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "Runit";
                    case "dinit": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "Dinit";
                    case "finit": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "Finit";
                    case "s6-svscan": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "S6";
                    case "shepherd": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "GNU Shepherd";
                    case "init": return (Configuration.initString != null && Configuration.initString != "") ? Configuration.initString : "SysVInit";
                    default: return com;
                }
            }
        } catch (e:Dynamic) {}
        return "None";
    }

    public static function fetchKernel():String {
        try {
            if (FileSystem.exists("/proc/sys/kernel/osrelease")) {
                var raw = File.read("/proc/sys/kernel/osrelease");
                var line = raw.readLine();
                raw.close();
                var trim = StringTools.trim(line);
                if (trim != "") return trim;
            }
        } catch (e:Dynamic) {}
        return Sys.systemName();
    }

    public static function fetchTerminal():String {
        var raw = Sys.getEnv("TERM_PROGRAM");
        if (raw == null || raw == "") raw = Sys.getEnv("TERM");
        if (raw == null || raw == "") return "";

        var terminals = raw.toLowerCase();
        switch (terminals) {
            case "alacritty": return "Alacritty";
            case "emacs": return "Emacs";
            case "gnome-console": return "GNOME Console";
            case "gnome-terminal": return "GNOME Terminal";
            case "ghostty": return "Ghostty";
            case "kitty" | "xterm-kitty": return "Kitty";
            case "konsole" | "xterm-konsole": return "Konsole";
            case "foot": return "Foot";
            case "lx-terminal": return "LXTerminal";
            case "screen" | "screen-256color": return "Screen";
            case "st": return "ST";
            case "tmux" | "tmux-256color": return "Tmux";
            case "vscode" | "code": return "VSCode";
            case "zed" | "zed-editor": return "Zed";
            case "q-terminal": return "QTerminal";
            case "xfce4-terminal": return "XFCE4 Terminal";
            case "xterm-256color" | "xterm": return "XTerm";
            default:
                var cleaned = terminals.split("-")[0];
                if (cleaned.length == 0) return "";
                return cleaned.charAt(0).toUpperCase() + cleaned.substr(1);
        }
    }

    public static function fetchShell():String {
        try {
            var stat = File.getContent("/proc/self/stat");
            var paren = stat.lastIndexOf(")");

            if (paren != -1) {
                var rest = stat.substr(paren + 2);
                var parts = rest.split(" ");
                var ppid = parts[1];

                var command = '/proc/$ppid/cmdline';
                if (FileSystem.exists(command)) {
                    var raw = File.getContent(command);
                    var shell = raw.split(String.fromCharCode(0))[0];

                    if (shell.length > 0) {
                        var path = shell.split("/");
                        var binary = path[path.length - 1];
                        if (StringTools.startsWith(binary, "-")) {
                            binary = binary.substr(1);
                        }
                        return formatShell(binary);
                    }
                }
            }
        } catch (e:Dynamic) {}

        var environment = Sys.getEnv("SHELL");
        if (environment !=  null) {
            var part = environment.split("/");
            return formatShell(part[part.length - 1]);
        }

        return "Unknown";
    }

    private static function formatShell(shell:String):String {
        if (shell == null || shell == "") return "";

        var low = shell.toLowerCase();
        switch (low) {
            case "bash": return "Bash";
            case "zsh": return "Zsh";
            case "fish": return "Fish";
            case "sh": return "Sh";
            case "dash": return "Dash";
            case "nu" | "nushell": return "NuShell";
            case "ksh": return "Ksh";
            case "csh": return "Csh";
            case "tcsh": return "Tcsh";
            default: return low.charAt(0).toUpperCase();
        }
    }

    public static function fetchUptime():String {
        try {
            if (FileSystem.exists("/proc/uptime")) {
                var input = File.read("/proc/uptime", false);
                var raw = input.readLine().split(" ")[0];
                input.close();

                var seconds = Std.parseInt(raw.split(".")[0]);
                if (seconds != null) {
                    var days = Math.floor(seconds / 86400);
                    var hours = Math.floor((seconds % 86400) / 3600);
                    var minutes = Math.floor((seconds % 3600) / 60);

                    var part:Array<String> = [];
                    if (days > 0) part.push('${days}${Configuration.daysString}');
                    if (hours > 0) part.push('${hours}${Configuration.hoursString}');
                    if (minutes > 0) part.push('${minutes}${Configuration.minutesString}');

                    return part.length > 0 ? part.join(" ") : "0" + Configuration.minutesString;
                }
            }
        } catch (e:Dynamic) {}
        return "N/A";
    }

    public static function fetchBirthday():String {
        try {    
            var status = FileSystem.stat(getBirthPath());
            var birth:Float = 0;

            if (status.ctime != null) birth = status.ctime.getTime() / 1000.0;

            var seconds = Date.now().getTime() / 1000.0;
            var days = Math.floor((seconds - birth) / 86400.0);

            if (days >= 0 && birth > 0) return '${days}${Configuration.daysString}';
        } catch (e:Dynamic) {}
        
        return "N/A";
    }

    public static function fetchInstalledDate():String {
        try {
            var path = getBirthPath();
            if (FileSystem.exists(path)) {
                var stats = FileSystem.stat(path);
                var timestamp = stats.ctime.getTime();
                var date = Date.fromTime(timestamp);

                var day = StringTools.lpad(Std.string(date.getDate()), "0", 2);
                var month = StringTools.lpad(Std.string(date.getMonth() + 1), "0", 2);
                var year = date.getFullYear();
                
                return '$day${Configuration.birthDotString}$month${Configuration.birthDotString}$year';
            }
        } catch (e:Dynamic) {}
        return "N/A";
    }

    private static function getBirthPath():String {
        var anaconda = ["/etc/machine-id", "/var/log/anaconda/anaconda.log", "/usr", "/var"];

        for (path in anaconda) {
            if (FileSystem.exists(path)) {
                try {
                    var stat = FileSystem.stat(path);
                    if (stat.ctime != null && stat.ctime.getTime() > 0) {
                        return path;
                    }
                } catch (e:Dynamic) {}
            }
        }

        var root = "/bedrock/strata";
        if (FileSystem.exists(root) && FileSystem.isDirectory(root)) {
            try {
                var entry = FileSystem.readDirectory(root);
                var oldTime:Float = Math.POSITIVE_INFINITY;
                var oldPath:String = null;

                for (entries in entry) {
                    var path = root + "/" + entries;
                    if (FileSystem.isDirectory(path)) {
                        var stat = FileSystem.stat(path);
                        if (stat.ctime != null) {
                            var time = stat.ctime.getTime();
                            if (time < oldTime) {
                                oldTime = time;
                                oldPath = path;
                            }
                        }
                    }
                }

                if (oldPath != null) return oldPath;
            } catch (e:Dynamic) {}
        }

        if (FileSystem.exists("/lost+found")) return "/lost+found";
        return "/";
    }

    public static macro function fetchGithubCommit():Expr {
        var commit = "Release";
        try {
            var process = new Process("git", ["rev-parse", "--short", "HEAD"]);
            if (process.exitCode() == 0) {
                var output = process.stdout.readAll().toString();
                commit = StringTools.trim(output);
            }
            process.close();
        } catch (e:Dynamic) {
            commit = "Release";
        }

        if (commit == "") commit = "Release";

        return macro $v{commit};
    }

    public static function osPlatform():String {
        var platform = Sys.systemName();

        return switch (platform) {
            case "bsd": "BSD";
            case "linux": "Linux";
            case "mac": "MacOS";
            case "windows": "Windows";
            default: null;
        }
    }
}