package utils;

import sys.io.File;
import sys.FileSystem;

class GPUUtility {
    public static function fetchGPU():String {
        var gpuId:Array<String> = [];
        var pci = "/sys/bus/pci/devices";

        if (FileSystem.exists(pci)) {
            try {
                var device = FileSystem.readDirectory(pci);
                for (devices in device) {
                    var devicePath = pci + "/" + devices;
                    var classPath = devicePath + "/class";
                    if (!FileSystem.exists(classPath)) continue;

                    var classCode = fetchLine(classPath).toLowerCase();

                    if (StringTools.startsWith(classCode, "0x0300") || 
                        StringTools.startsWith(classCode, "0x0301") || 
                        StringTools.startsWith(classCode, "0x0380")) {
                    
                        var vendorId = fetchLine(devicePath + "/vendor").toLowerCase();
                        var deviceId = fetchLine(devicePath + "/device").toLowerCase();

                        var raw = fetchGPUName(vendorId, deviceId);
                        var actualG = fetchActualGPU(raw);

                        var typeG = fetchGPUType(actualG, vendorId);
                        var finalG = (Configuration.gpuType && typeG != "") ? '${actualG} [${Colors.colorize(typeG, Colors.GREEN)}]' : actualG;

                        if (finalG != "" && gpuId.indexOf(finalG) == -1) gpuId.push(finalG);
                    }
                } 
            } catch (e:Dynamic) {}
        }

        if (gpuId.length == 0) {
            var lspci = Haxefetch.runCmd("lspci", []);
            if (lspci != null && lspci != "") {
                for (line in lspci.split("\n")) {
                    if (line.indexOf("VGA compatible controller") != -1 || line.indexOf("3D controller") != -1) {
                        var part = line.split(":");
                        if (part.length >= 3) {
                            var raw = StringTools.trim(part.slice(2).join(":"));
                            var actualGpu = fetchActualGPU(raw);
                            if (actualGpu != "") {
                                gpuId.push(actualGpu);
                            }
                        }
                    }
                }
            }
        }

        if (gpuId.length == 0) return "N/A";
        return gpuId.join("\n");
    }   

    private static function fetchGPUName(vendorId:String, deviceId:String):String {
        var vendor = fetchVendor(vendorId);
        
        var pcis = [
            "/run/current-system/sw/share/hwdata/pci.ids",
            "/etc/profiles/per-user/" + Sys.getEnv("USER") + "/share/hwdata/pci.ids",
            "/usr/share/hwdata/pci.ids",
            ".usr/share/misc/pci.ids"
        ];

        var pciFile = "";
        for (path in pcis) {
            if (FileSystem.exists(path)) {
                pciFile = path;
                break;
            }
        }

        trace('Found ${pciFile}!');

        var device = "";
        if (FileSystem.exists(pciFile) && vendorId != "" && deviceId != "") device = parsePCI(pciFile, vendorId, deviceId);
        if (device != "") return fetchActualGPU('${vendor}  ${device}');

        return vendor != "" ? vendor + 'GPU (${deviceId})' : "N/A";
    }

    private static function fetchActualGPU(gpu:String):String {
        if (gpu == null || gpu == "") return "";

        var navi = ~/\s*Navi\s*\d+/i;
        gpu = navi.replace(gpu, "");

        var brackets = ~/([A-Za-z0-9\s]+?)(\/[A-Za-z0-9\s]+)+/g;
        gpu = brackets.replace(gpu, "$1");

        gpu = StringTools.replace(gpu, "[", "");
        gpu = StringTools.replace(gpu, "]", "");

        var gtString = ~/\(GT[0-9](\.[0-9]+)?\)|\bGT[0-9](\.[0-9]+)?\b/gi;
        gpu = gtString.replace(gpu, "");

        var codenames = ~/Intel\s+(Alder|Raptor|Tiger|Ice|Comet|Coffe|Kaby|Skylake|Haswell|Ivy|Rocket|Jasper|Whiskey|Amber|Cannon|Lake|Meteor|Lunar|Arrow|Panther|Gemini|Apollo|Elkhart)\s*Lake[A-Za-z0-9-]*\s+/i;
        gpu = codenames.replace(gpu, "Intel ");

        var amdCodeRegex = new EReg("AMD\\s+(.*?)\\s+Radeon", "i");
        gpu = amdCodeRegex.replace(gpu, "AMD Radeon");

        var nvidiaCodeRegex = new EReg("\\b[A-Z]{2,3}[0-9]{2-3}\\b", "");
        gpu = nvidiaCodeRegex.replace(gpu, "");

        gpu = StringTools.replace(gpu, "Corporation", "");
        gpu = StringTools.replace(gpu, "Integrated Graphics Controller", "");
        gpu = StringTools.replace(gpu, "Graphics Controller", "");

        var space = ~/\s+/g;
        gpu = space.replace(gpu, " ");

        return StringTools.trim(gpu);
    }

    private static function fetchVendor(vendor:String):String {
        return switch (vendor) {
            case "0x8086": "Intel";
            case "0x10de": "NVIDIA";
            case "0x1002" | "0x1022": "AMD";
            case _: "";
        }
    }

    private static function fetchGPUType(gpu:String, vendor:String):String {
        var name = gpu.toLowerCase();
        switch (name) {
            case _ if (name.indexOf("geforce") != -1 || name.indexOf("gtx") != -1 || name.indexOf("rtx") != -1 || name.indexOf("radeon rx") != -1 || name.indexOf("arc") != -1): return "Dedicated";
            case _ if (name.indexOf("hd graphics") != -1 || name.indexOf("uhd") != -1 || name.indexOf("iris") != -1 || name.indexOf("vega") != -1 || name.indexOf("radeon graphics") != -1): return "Integrated";
            default: return "";
            
            if (vendor == "0x10de") return "Dedicated" else if (vendor == "0x8086") return "Integrated";
        }
    }

    private static function parsePCI(file:String, vendor:String, device:String):String {
        var targetVendorID = StringTools.replace(vendor, "0x", "").toLowerCase();
        var targetDeviceID = StringTools.replace(device, "0x", "").toLowerCase();
        var content = fetchFileContent(file);
        if (content == "" || content == null) return "";

        var linesList = content.split("\n");
        var targetVendor = false;

        for (l in linesList) {
            var trimmedLine = StringTools.trim(l);
            if (StringTools.startsWith(l, "#") || trimmedLine == "") continue;

            if (!StringTools.startsWith(l, "\t")) {
                var id = l.substring(0, 4).toLowerCase();
                targetVendor = (id == targetVendorID);
            } else if (targetVendor && StringTools.startsWith(l, "\t") && !StringTools.startsWith(l, "\t\t")) {
                var dev = l.substring(1);
                var dID = dev.substring(0, 4).toLowerCase();

                if (dID == targetDeviceID) {
                    return StringTools.trim(dev.substring(4));
                }
            }
        }

        return "";
    }

    private static function fetchLine(path:String):String {
        var content = fetchFileContent(path);
        if (content != "") return StringTools.trim(content.split("\n")[0]);
        return "";
    }

    private static function fetchFileContent(path:String):String {
        if (FileSystem.exists(path)) {
            try {
                var file = File.getContent(path);
                if (file != null && file != "") return file;
            } catch (e:Dynamic) {}
        }
        return Haxefetch.runCmd("cat", [path]);
    }
}