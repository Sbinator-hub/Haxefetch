package utils;

import haxe.Resource;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Logo {
    public static function fetchLogo(distroName:String, size:String = "normal", overrideLogo:String = "", customColor:String = "", customColor2:String = "", customColor3:String = ""):Array<String> {
        var raw:String = null;
        
        var resolve = resolvePath(overrideLogo);
        if (resolve != "" && FileSystem.exists(resolve)) {
            try {
                raw = File.getContent(resolve);
            } catch (e:Dynamic) {}
        }

        if (raw == null) {
            var logo = (overrideLogo != "") ? overrideLogo : distroName;
            var low = logo.toLowerCase();
            var key = fetchDistro(low);

            if (key != null) {
                var small = (size.toLowerCase() == "small");
                var resourceKey = small ? '${key}_small' : key;

                raw = Resource.getString(resourceKey);
                if (raw == null && small) raw = Resource.getString(key);
            }
        }

        if (raw != null) {
            var color = fetchColor((overrideLogo != "") ? overrideLogo : distroName);
            var custom = (customColor != null && customColor != "") ? customColor : color.primary; 
            var custom2 = (customColor2 != null && customColor2 != "") ? customColor2 : color.secondary;
            var custom3 = (customColor3 != null && customColor3 != "") ? customColor3 : color.third;
            var txt = StringTools.replace(raw, "\r\n", "\n");

            if (txt.indexOf("$1") != -1) {
                txt = StringTools.replace(txt, "$1", custom);
                txt = StringTools.replace(txt, "$2", custom2);
                txt = StringTools.replace(txt, "$3", custom3);
                
                var lines = txt.split("\n");
                var colorredLine:Array<String> = [];

                for (line in lines) {
                    var format = line;
                    if (format.indexOf("\033") == 1) {
                        format = custom + format;
                    }
                    colorredLine.push(format + Colors.RESET);
                }

                return colorredLine;
            }
        }

        return fetchTux();
    }

    private static function fetchDistro(low:String):Null<String> {
        switch (low) {
            case _ if (low.contains("aerynos") ): return "aeryn";
            case _ if (low.contains("alpine") ): return "alpine";
            case _ if (low.contains("arco") ): return "arco";
            case _ if (low.contains("tonarchy") ): return "tonarchy"; // Tony Banters my beloved guy
            case _ if (low.contains("parch") ): return "parch";
            case _ if (low.contains("arch") ): return "arch";
            case _ if (low.contains("artix") ): return "artix";
            case _ if (low.contains("bazzite") ): return "bazzite";
            case _ if (low.contains("cachyos") ): return "cachy";
            case _ if (low.contains("devuan") ): return "devuan";
            case _ if (low.contains("debian") ): return "debian";
            case _ if (low.contains("endeavouros") ): return "endeavour";
            case _ if (low.contains("exherbo") ): return "exherbo";
            case _ if (low.contains("fedora") ): return "fedora";
            case _ if (low.contains("glaucus") ): return "glaucus";
            case _ if (low.contains("garuda") ): return "garuda";
            case _ if (low.contains("gentoo") ): return "gentoo";
            case _ if (low.contains("guix") ): return "guix";
            case _ if (low.contains("kali") ): return "kali";
            case _ if (low.contains("kaos") ): return "kaos";
            case _ if (low.contains("neon") ): return "neon";
            case _ if (low.contains("kiss") ): return "kiss";
            case _ if (low.contains("kubuntu")  || low.contains("kde-ubuntu") ): return "kubuntu";
            case _ if (low.contains("lfs") ): return "lfs";
            case _ if (low.contains("manjaro") ): return "manjaro";
            case _ if (low.contains("mx") ): return "mx";
            case _ if (low.contains("linuxmint")  || low.contains("linux-mint") ): return "mint";
            case _ if (low.contains("nixos") ): return "nix";
            case _ if (low.contains("nobara") ): return "nobara";
            case _ if (low.contains("opensuse")  || low.contains("opensuse-microos")  || low.contains("opensuse-leap")  || low.contains("opensuse-tumbleweed")  || low.contains("opensuse-slowroll") ): return "suse";
            case _ if (low.contains("parabola") ): return "parabola";
            case _ if (low.contains("pikaos") ): return "pika";
            case _ if (low.contains("pisi") ): return "pisi";
            case _ if (low.contains("pop")  || low.contains("popos") ): return "pop";
            case _ if (low.contains("redcore") ): return "redcore";
            case _ if (low.contains("rhel") ): return "rhel";
            case _ if (low.contains("rocky") ): return "rocky";
            case _ if (low.contains("prismlinux") ): return "prism";
            case _ if (low.contains("slackware") ): return "slack";
            case _ if (low.contains("solus") ): return "solus"; 
            case _ if (low.contains("steamos") ): return "steam";
            case _ if (low.contains("zorin") ): return "zorin";
            case _ if (low.contains("lubuntu") ): return "lubuntu";
            case _ if (low.contains("xubuntu")  || low.contains("xfce-ubuntu") ): return "xubuntu";
            case _ if (low.contains("ubuntu")  || low.contains("ubuntu-cinnamon")  || low.contains("ubuntu-mate")  || low.contains("ubuntu-sway")  || low.contains("uwuntu") ): return "ubuntu";
            case _ if (low.contains("ultramarine") ): return "ultramarine";
            case _ if (low.contains("void") ): return "void";
            case _ if (low.contains("vylen") ): return "vylen";
            default: return null;
        }
    }

    public static function fetchColor(low:String):{primary:String, secondary:String, third:String} {
        var s = low != null ? low.toLowerCase() : "";

        if (s.contains("aerynos") ) return { primary: Colors.fg(23), secondary: Colors.fg(136), third: Colors.fg(23) };
        if (s.contains("alpine") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.BLUE };
        if (s.contains("arch") ) return { primary: Colors.BRIGHT_CYAN, secondary: Colors.BLUE, third: Colors.WHITE };
        if (s.contains("arco") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("artix") ) return { primary: Colors.CYAN, secondary: Colors.CYAN, third: Colors.CYAN };
        if (s.contains("bazzite") ) return { primary: Colors.fg(26), secondary: Colors.fg(97), third: Colors.BLUE };
        if (s.contains("cachyos") ) return { primary: Colors.CYAN, secondary: Colors.CYAN, third: Colors.CYAN };
        if (s.contains("debian") ) return { primary: Colors.fg(196), secondary: Colors.fg(124), third: Colors.WHITE };
        if (s.contains("devuan") ) return { primary: Colors.MAGENTA, secondary: Colors.MAGENTA, third: Colors.MAGENTA };
        if (s.contains("endeavour") ) return { primary: Colors.fg(99), secondary: Colors.fg(211), third: Colors.fg(141) };
        if (s.contains("exherbo") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.RED };
        if (s.contains("fedora") ) return { primary: Colors.fg(33), secondary: Colors.WHITE, third: Colors.fg(39) };
        if (s.contains("garuda") ) return { primary: Colors.RED, secondary: Colors.RED, third: Colors.RED };
        if (s.contains("gentoo") ) return { primary: Colors.fg(141), secondary: Colors.fg(61), third: Colors.WHITE };
        if (s.contains("glaucus") ) return { primary: Colors.MAGENTA, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("guix") ) return { primary: Colors.YELLOW, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("kaos") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("kubuntu") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("lubuntu") ) return { primary: Colors.fg(26), secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("xubuntu") ) return { primary: Colors.fg(20), secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("ubuntu") ) return { primary: Colors.fg(202), secondary: Colors.fg(202), third: Colors.WHITE };
        if (s.contains("neon") ) return { primary: Colors.CYAN, secondary: Colors.CYAN, third: Colors.CYAN };
        if (s.contains("manjaro") ) return { primary: Colors.GREEN, secondary: Colors.GREEN, third: Colors.GREEN };
        if (s.contains("linuxmint")  || s.contains("mint") ) return { primary: Colors.GREEN, secondary: Colors.WHITE, third: Colors.GREEN };
        if (s.contains("nixos") ) return { primary: Colors.fg(26), secondary: Colors.COLOR_63, third: Colors.fg(25) };
        if (s.contains("nobara") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("parabola") ) return { primary: Colors.MAGENTA, secondary: Colors.MAGENTA, third: Colors.MAGENTA };
        if (s.contains("parch") ) return { primary: Colors.COLOR_55, secondary: Colors.COLOR_55, third: Colors.COLOR_55 };
        if (s.contains("pika") ) return { primary: Colors.YELLOW, secondary: Colors.YELLOW, third: Colors.YELLOW };
        if (s.contains("pisi") ) return { primary: Colors.YELLOW, secondary: Colors.YELLOW, third: Colors.YELLOW };
        if (s.contains("pop") ) return { primary: Colors.BRIGHT_CYAN, secondary: Colors.WHITE, third: Colors.CYAN };
        if (s.contains("prism") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("redcore") ) return { primary: Colors.RED, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("rhel") ) return { primary: Colors.RED, secondary: Colors.WHITE, third: Colors.WHITE};
        if (s.contains("rocky") ) return { primary: Colors.GREEN, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("slackware") ) return { primary: Colors.fg(26), secondary: Colors.WHITE, third: Colors.fg(26) };
        if (s.contains("suse") ) return { primary: Colors.fg(28), secondary: Colors.fg(28), third: Colors.WHITE };
        if (s.contains("steamos") ) return { primary: Colors.fg(27), secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("solus") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("tonarchy") ) return { primary: Colors.GREEN, secondary: Colors.WHITE, third: Colors.WHITE }; // Tony Banters my beloved guy
        if (s.contains("ultramarine") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };
        if (s.contains("void") ) return { primary: Colors.COLOR_22, secondary: Colors.WHITE, third: Colors.COLOR_22 };
        if (s.contains("vylen") ) return { primary: Colors.GREEN, secondary: Colors.GREEN, third: Colors.WHITE }; 
        if (s.contains("zorin") ) return { primary: Colors.BLUE, secondary: Colors.WHITE, third: Colors.WHITE };

        return { primary: Colors.WHITE, secondary: Colors.WHITE, third: Colors.WHITE };
    }

    private static function fetchTux():Array<String> {
        return [
            "   .--.",
            "  |o_o |",
            "  |:_/ |",
            " //   \\ \\",
            "(|     | )",
            "/'\\_   _/'\\",
            "\\___)=(___)"
        ];
    }

    static macro function embedLogo(filePath:String):Expr {
        if (!FileSystem.exists(filePath)) return Context.parse("[]", Context.currentPos());
        
        var content = File.getContent(filePath);
        var lines = content.split("\n");

        return macro $v{lines};
    }

    private static function resolvePath(path:String):String {
        if (path == null || path == "") return "";

        var cleanPath = StringTools.trim(path);
        if ((StringTools.startsWith(cleanPath, "'") && StringTools.endsWith(cleanPath, "'")) || (StringTools.startsWith(cleanPath, '"') &&  StringTools.endsWith(cleanPath, '"'))) {
            cleanPath = cleanPath.substring(1, cleanPath.length -1);
        }

        if (StringTools.startsWith(cleanPath, "~")) {
            var home = Sys.getEnv("HOME");
            if (home != null && home != "") {
                return home + path.substr(1);
            }
        }
        return path;
    }
}