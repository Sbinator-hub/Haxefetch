package utils;

import sys.io.File;
import sys.FileSystem;

class CPUUtility{
    private static function fetchInfo():String {
        if (FileSystem.exists("/proc/cpuinfo")) {
            try {
                var content = File.getContent("/proc/cpuinfo");
                if (content != null && StringTools.trim(content) != "") return content;
            } catch (e:Dynamic) {}
        }

        var process = Haxefetch.runCmd("cat", ["/proc/cpuinfo"]);
        if (process != null && process != "") return process;

        return "";
    }
    public static function fetchCPU():String {
        var modelName:String = "";
        var architecture:String = "";
        var maxFreqGHz:Float = 0.0;
        var threadCount:Int = 0;
        var coreIds = new Map<String, Bool>();

        var content = fetchInfo();

        if (content != "") {
            var lines = content.split("\n");

            for (line in lines) {
                var trimmed = StringTools.trim(line);
                if (trimmed == "") continue;

                var parts = trimmed.split(":");
                if (parts.length < 2) continue;

                var key = StringTools.trim(parts[0]).toLowerCase();
                var val = StringTools.trim(parts.slice(1).join(":"));

                if (key == "processor") {
                    threadCount++;
                } 
                
                if (modelName == "" && (key == "model name" || key == "hardware"|| key == "cpu")) {
                    modelName = val;
                } else if (key == "processor" && Math.isNaN(Std.parseFloat(val))) {
                    modelName = val;
                } else if (key == "cpu architecture") {
                    modelName = 'ARM v${val} Processor';
                }
                
                if (key == "core id") {
                    coreIds.set(val, true);
                } else if (maxFreqGHz == 0.0 && key == "cpu mhz") {
                    var mhz = Std.parseFloat(val);
                    if (!Math.isNaN(mhz) && mhz > 0) {
                        maxFreqGHz = mhz / 1000.0;
                    }
                }
            }
        }

        if (threadCount == 0 && FileSystem.exists("/sys/devices/system/cpu")) {
            try {
                var entries = FileSystem.readDirectory("/sys/devices/system/cpu");
                for (entry in entries) {
                    var reg = ~/^\bcpu[0-9]+\b$/;
                    if (reg.match(entry)) {
                        threadCount++;
                    }
                }
            } catch (e:Dynamic) {}
        }

        var coreCount = Lambda.count(coreIds);
        if (threadCount == 0) threadCount = 1;
        if (coreCount == 0) coreCount = threadCount;

        var freqPath = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq";
        if (!FileSystem.exists(freqPath)) {
            freqPath = "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq";
        }

        var freqContent = "";
        if (FileSystem.exists(freqPath)) {
            try {
                freqContent = File.getContent(freqPath);
            } catch (e:Dynamic) {}
        }
        if (freqContent == "" || freqContent == null) {
            freqContent = Haxefetch.runCmd("cat", [freqPath]);
        }

        if (freqContent != null && freqContent != "") {
            var khz = Std.parseFloat(StringTools.trim(freqContent));
            if (!Math.isNaN(khz) && khz > 0) {
                maxFreqGHz = khz / 1000000.0;
            }
        }

        modelName = fetchCleanCPU(modelName);
        if (modelName == "") modelName = "Unknown CPU";

        var result = modelName;

        if (maxFreqGHz > 0.0) {
            var formattedFreq = Math.round(maxFreqGHz * 100) / 100;
            Configuration.cpuFreq ? result += " @ " + formattedFreq + " GHz" : result += "";
        }

        Configuration.cpuCAT ? result += ' (${Colors.colorize(Std.string(coreCount), Colors.GREEN)} cores / ${Colors.colorize(Std.string(threadCount), Colors.GREEN)} threads)' : result += '';

        return result;
    }

    private static function fetchCleanCPU(model:String):String {
        if (model == "") return "";

        model = StringTools.replace(model, "(R)", "");
        model = StringTools.replace(model, "(TM)", "");
        model = StringTools.replace(model, "(tm)", "");

        var frequency = ~/ @\s*\d+(\.\d+)?\s*(GHz|Mhz)/i;
        model = frequency.replace(model, "");

        model = StringTools.replace(model, "CPU", "");
        model = StringTools.replace(model, "Processor", "");

        var space = ~/\s+/g;
        model = space.replace(model, " ");

        return StringTools.trim(model);
    }

    public static function fetchArchitecture():String {
        try {
            var exe = File.read("/proc/self/exe", true);
            var byte = exe.read(20);

            var machine = byte.get(18);

            return switch (machine) {
                case 0x3E: "x86_64";
                case 0xB7: "aarch64";
                case 0x03: "x86";
                case 0x28: "armv7l";
                case 0xF3: "riscv64";
                default: "N/A";
            };
        } catch (e:Dynamic) {}

        return "N/A";
    }
}