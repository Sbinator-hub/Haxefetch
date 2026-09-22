package utils;

import sys.FileSystem;
import sys.io.File;

class Memory {
    public static function memoryStats():{ram:String, swap:String} {
        var totalMemory:Float = 0.0;
        var freeMemory:Float = 0.0;
        var availableMemory:Float = 0.0;
        var bufferedMemory:Float = 0.0;
        var cachedMemory:Float = 0.0;
        var totalSwap:Float = 0.0;
        var freeSwap:Float = 0.0;

        if (FileSystem.exists("/proc/meminfo")) {
            try {
                var fin = File.read("/proc/meminfo", false);
                
                while (true) {
                    try {
                        var line = fin.readLine();
                        var colonIdx = line.indexOf(":");
                        if (colonIdx == -1) continue;

                        var key = StringTools.trim(line.substring(0, colonIdx));
                        var value = extractDigits(line.substring(colonIdx + 1));

                        switch (key) {
                            case "MemTotal": totalMemory = value;
                            case "MemFree": freeMemory = value;
                            case "MemAvailable": availableMemory = value;
                            case "Buffers": bufferedMemory = value;
                            case "Cached": cachedMemory = value;
                            case "SwapTotal": totalSwap = value;
                            case "SwapFree": freeSwap = value;
                            default: 
                        }
                    } catch (e:haxe.io.Eof) {
                        break;
                    }
                }
                fin.close();
            } catch (e:Dynamic) {}
        }

        var ramString = "N/A";
        if (totalMemory > 0) {
            var usedKylo = (availableMemory > 0) ? (totalMemory - availableMemory) : (totalMemory - freeMemory - bufferedMemory - cachedMemory);
            if (usedKylo < 0) usedKylo = 0;

            var percentage = Math.floor((usedKylo / totalMemory) * 100.0);
            var colors = (percentage >= 85) ? Colors.RED : (percentage >= 60 ? Colors.YELLOW : Colors.GREEN);
            var coloredPact = Colors.colorize('$percentage%', colors);
 
            var pairedMemoryString = formatMemory(usedKylo, totalMemory);
            Configuration.ramPercent ? ramString = '${pairedMemoryString} (${coloredPact})' : ramString = '${pairedMemoryString}';
        }

        var swapString = "Disabled";
        if (totalSwap > 0) {
            var usedSwapKilo = totalSwap - freeSwap;
            if (usedSwapKilo < 0) usedSwapKilo = 0;

            var percentage = Math.floor((usedSwapKilo / totalSwap) * 100.0);
            var colors = (percentage >= 85) ? Colors.RED : (percentage >= 60 ? Colors.YELLOW : Colors.GREEN);
            var coloredPact = Colors.colorize('$percentage%', colors);

            var pairedSwapString = formatMemory(usedSwapKilo, totalSwap);
            Configuration.swapPercent ? swapString = '${pairedSwapString} (${coloredPact})' : swapString = '${pairedSwapString}';
        }

        return {ram: ramString, swap: swapString};
    }

    private static function formatData(kilo:Float):String {
        var value = kilo * 1024.0;
        var units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"];
        var unitIDx = 0;

        while (value >= 1024.0 && unitIDx < units.length - 1) {
            value /= 1024.0;
            unitIDx++;
        }

        return '${roundDecimal(value, 2)} ${units[unitIDx]}';
    }

    private static function formatMemory(usedKilo:Float, totalKilo:Float):String {
        return '${formatData(usedKilo)} / ${formatData(totalKilo)}';
    }

    private static function extractDigits(raw:String):Float {
        var stringBuff = new StringBuf();
        for (i in 0...raw.length) {
            var code = raw.charCodeAt(i);
            if (code >= 48 && code <= 57) {
                stringBuff.addChar(code);
            } else if (stringBuff.length > 0) {
                break;
            }
        }

        var numberString = stringBuff.toString();
        if (numberString.length == 0) return 0.0;

        var floatParser = Std.parseFloat(numberString);
        return Math.isNaN(floatParser) ? 0.0 : floatParser;
    }

    private static function roundDecimal(val:Float, precision:Int):Float {
        var factor = Math.pow(10, precision);
        return Math.round(val * factor) / factor;
    }
}