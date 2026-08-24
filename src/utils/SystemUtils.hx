package utils;

import sys.io.FileSeek;
import sys.FileSystem;
import sys.io.File;

class SystemUtils {
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
            vendor = bios
        else if (board != "" && board != "None")
            vendor = board;

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

    private static function readFile(path:String):String {
        #if sys
        if (sys.FileSystem.exists(path)) {
            try {
                var content = sys.io.File.getContent(path);
                if (content != null) return StringTools.trim(content);
            } catch (e:Dynamic) {}
        }
        #end
        var output = Haxefetch.runCmd("cat", [path]);
            if (output != null && output != "") {
            return StringTools.trim(output);
        }
        return "";
    }

    public static function fetchDistro():String {
        #if sys
        if (FileSystem.exists("/etc/os-release")) {
            try {
                var lines = File.getContent("/etc/os-release").split("\n");
                for (line in lines) {
                    var cleanLine = StringTools.trim(line);

                    if (StringTools.startsWith(cleanLine, "PRETTY_NAME=")) {
                        var parts = cleanLine.indexOf("=");
                        if (parts != -1) {
                            var name = StringTools.trim(cleanLine.substr(parts + 1));
                            if ((StringTools.startsWith(name, '"') && StringTools.endsWith(name, '"')) || (StringTools.startsWith(name, "'") && StringTools.endsWith(name, "'"))) {
                                name = name.substring(1, name.length -1 );
                            }
                            
                            return name;
                        }
                    }
                }
            } catch (e:Dynamic) {}
        }
        #end
        return Sys.systemName();
    }

    public static function fetchInit():String {
        if (FileSystem.exists("/run/systemd/system")) return "systemD";
        if (FileSystem.exists("/run/openrc") || FileSystem.exists("/run/openrc/softlevel")) return "OpenRC";
        if (FileSystem.exists("/run/runit")) return "Runit";
        if (FileSystem.exists("/run/dinit")) return "Dinit";
        if (FileSystem.exists("/run/finit")) return "Finit";
        if (FileSystem.exists("/run/s6")) return "S6";
        
        try {
            if (FileSystem.exists("/proc/1/comm")) {
                var input = File.read("/proc/1/comm", false);
                var com = StringTools.trim(input.readLine());
                input.close();

                switch (com) {
                    case "systemd": return "systemD";
                    case "openrc-init": return "OpenRC";
                    case "runit": return "Runit";
                    case "dinit": return "Dinit";
                    case "finit": return "Finit";
                    case "s6-svscan": return "S6";
                    case "init": return "SysVinit";
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
                        return binary;
                    }
                }
            }
        } catch (e:Dynamic) {}

        var environment = Sys.getEnv("SHELL");
        if (environment !=  null) {
            var part = environment.split("/");
            return part[part.length - 1];
        }

        return "Unknown";
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
                    if (days > 0) part.push(days + 'd');
                    if (hours > 0) part.push(hours + 'h');
                    if (minutes > 0) part.push(minutes + 'm');

                    return part.length > 0 ? part.join(" ") : "0m";
                }
            }
        } catch (e:Dynamic) {}
        return "N/A";
    }

    public static function fetchBirthday():String {
        try {
            var status = FileSystem.stat("/");
            var birth:Float = 0;

            if (status.ctime != null) birth = status.ctime.getTime() / 1000.0;

            var seconds = Date.now().getTime() / 1000.0;
            var days = Math.floor((seconds - birth) / 86400.0);

            if (days >= 0 && birth > 0) return '${days}d';
        } catch (e:Dynamic) {}
        
        return "N/A";
    }

    public static function fetchInstalledDate():String {
        try {
            if (FileSystem.exists("/")) {
                var stats = FileSystem.stat("/");
                var timestamp = stats.ctime.getTime();
                var date = Date.fromTime(timestamp);

                var day = StringTools.lpad(Std.string(date.getDate()), "0", 2);
                var month = StringTools.lpad(Std.string(date.getMonth() + 1), "0", 2);
                var year = date.getFullYear();
                
                return '$day.$month.$year.';
            }
        } catch (e:Dynamic) {}
        return "N/A";
    }
}