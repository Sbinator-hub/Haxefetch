package utils;

using StringTools;

class XdgSession {
    public static function fetchDestkop():Null<String> {
        var environmentKey = ["XDG_CURRENT_DESKTOP", "XDG_SESSION_DESKTOP", "DESKTOP_SESSION", "CURRENT_DESKTOP"];
        var rawEnvironment:String = "";

        for (key in environmentKey) {
            var value = Sys.getEnv(key);
            if (value != null && StringTools.trim(value) != "") {
                rawEnvironment = value;
                break;
            }
        }
        if (rawEnvironment == "") return null;

        var part = rawEnvironment.split(":");
        for (parts in part) {
            var token = StringTools.trim(parts).toUpperCase();
            if (token == "") continue;

            if (token.contains("GNOME")) return Configuration.desktopVersion ? formatVersion("GNOME", "gnome-shell", ["--version"]) : "GNOME";
            if (token.contains("KDE") || token.contains("PLASMA")) return Configuration.desktopVersion ? formatVersion("KDE Plasma", "plasmashell", ["--version"]) : "KDE Plasma";
            if (token.contains("TDE") || token.contains("TRINITY")) return Configuration.desktopVersion ? formatVersion("TDE", "tde-config", ["--version"]) : "TDE";
            if (token.contains("CINNAMON") ) return Configuration.desktopVersion ? formatVersion("Cinnamon", "cinnamon", ["--version"]) : "Cinnamon";
            if (token.contains("XFCE") ) return Configuration.desktopVersion ? formatVersion("XFCE", "xfce4-about", ["-V"]) : "XFCE";
            if (token.contains("MATE") ) return Configuration.desktopVersion ? formatVersion("MATE", "mate-about", ["-v"]) : "MATE";
            if (token.contains("BUDGIE") ) return Configuration.desktopVersion ? formatVersion("Budgie", "budgie-desktop", ["--version"]) : "Budgie";
            if (token.contains("COSMIC") ) return Configuration.desktopVersion ? formatVersion("COSMIC", "cosmic-comp", ["--version"]) : "COSMIC";
            if (token.contains("DEEPIN")  || token.contains("DDE") ) return Configuration.desktopVersion ? formatVersion("Deepin", "dde-dock", ["--version"]) : "Deepin";
            if (token.contains("LXDE") ) return Configuration.desktopVersion ? formatVersion("LXDE", "lxsession", ["--version"]) : "LXDE";
            if (token.contains("LXQT") ) return Configuration.desktopVersion ? formatVersion("LXQt", "lxqt-session", ["-v"]) : "LXQt";
            if (token.contains("NSCDE") ) return Configuration.desktopVersion ? formatVersion("NsCDE", "sh", ["-c", "nscde -V"]) : "NsCDE";
            if (token.contains("CDE") ) return Configuration.desktopVersion ? formatVersion("CDE", "sh", ["-c", "dtversion"]) : "CDE";
        }
        return null;
    }

    public static function fetchSession():String {
        var environmentKey = ["XDG_CURRENT_DESKTOP", "XDG_SESSION_DESKTOP", "DESKTOP_SESSION"];
        for (key in environmentKey) {
            var value = Sys.getEnv(key);
            if (value != null && value != "") {
                var clean = StringTools.trim(value);
                var upper = clean.toUpperCase();

                switch (upper) {
                    // Wayland
                    case _ if (upper.contains("KWIN")  || upper.contains("KDE")  || upper.contains("PLASMA") ): return "KWin";
                    case _ if (upper.contains("MUTTER")  || upper.contains("GNOME")  || upper.contains("BUDGIE") ): return "Mutter";
                    case _ if (upper.contains("COSMIC-COMP")  || upper.contains("COSMIC") ): return "Cosmic Comp";
                    case _ if (upper.contains("SWAY") ): return Configuration.sessionVersion ? formatVersion("Sway", "sway", ["--version"]) : "Sway";
                    case _ if (upper.contains("HYPRLAND") ): return Configuration.sessionVersion ? formatVersion("Hyprland", "Hyprland", ["--version"]) : "Hyprland";
                    case _ if (upper.contains("NIRI") ): return Configuration.sessionVersion ? formatVersion("Niri", "niri", ["--version"]) : "Niri";
                    case _ if (upper.contains("MANGO") ): return Configuration.sessionVersion ? formatVersion("Mango", "mango", ["-v"]) : "Mango";
                    case _ if (upper.contains("DWL") ): return Configuration.sessionVersion ? formatVersion("DWL", "dwl", ["-v"]) : "DWL";
                    case _ if (upper.contains("MIRACLE")  || upper.contains("MIRACLE-WM") ): return "Miracle";
                    case _ if (upper.contains("RIVER") ): return Configuration.sessionVersion ? formatVersion("River", "river", ["-version"]) : "River";
                    case _ if (upper.contains("LABWC") ): return Configuration.sessionVersion ? formatVersion("LabWC", "labwc", ["--version"]) : "LabWC"; 
                    case _ if (upper.contains("WAYFIRE") ): return Configuration.sessionVersion ? formatVersion("Wayfire", "wayfire", ["--version"]) : "Wayfire";
                    case _ if (upper.contains("WESTON") ): return Configuration.sessionVersion ? formatVersion("Weston", "weston", ["--version"]) : "Weston"; 
                    case _ if (upper.contains("XFWL") ): return "XFWL";

                    // X11/Xorg
                    case _ if (upper.contains("XFCE") ): return "Xfwm4";
                    case _ if (upper.contains("TWIN")  || upper.contains("TDE")  || upper.contains("TRINITY") ): return "TWin";
                    case _ if (upper.contains("MUFFIN")  || upper.contains("CINNAMON")  || upper.contains("X-CINNAMON") ): return "Muffin";
                    case _ if (upper.contains("MARCO")  || upper.contains("MATE") ): return "Marco";
                    case _ if (upper.contains("METACITY") ): return "Metacity";
                    case _ if (upper.contains("OPENBOX")  || upper.contains("LXQT")  || upper.contains("LXDE") ): return Configuration.sessionVersion ? formatVersion("OpenBox", "openbox", ["--version"]) : "OpenBox";
                    case _ if (upper.contains("BLACKBOX") ): return Configuration.sessionVersion ? formatVersion("BlackBox", "blackbox", ["-version"]) : "BlackBox";
                    case _ if (upper.contains("FLUXBOX") ): return Configuration.sessionVersion ? formatVersion("FluxBox", "fluxbox", ["-version"]) : "FluxBox";
                    case _ if (upper.contains("AWESOME") ): return Configuration.sessionVersion ? formatVersion("Awesome", "awesome", ["--version"]) : "Awesome";
                    case _ if (upper.contains("BSPWM") ): return Configuration.sessionVersion ? formatVersion("Bspwm", "bspwm", ["--version"]) : "Bspwm";
                    case _ if (upper.contains("DWM") ): return Configuration.sessionVersion ? formatVersion("DWM", "dwm", ["--version"]) : "DWM";
                    case _ if (upper.contains("DTWM")  || upper.contains("CDE") ): return "DTWM";
                    case _ if (upper.contains("E13") ): return "E13";
                    case _ if (upper.contains("ENLIGHTENMENT") ): return "Enligthtenment";
                    case _ if (upper.contains("I3") ): return Configuration.sessionVersion ? formatVersion("i3", "i3", ["--version"]) : "i3";
                    case _ if (upper.contains("ICEWM") ): return Configuration.sessionVersion ? formatVersion("IceWM", "icewm", ["--version"]) : "IceWM"; // R.I.P Marko
                    case _ if (upper.contains("HERBSTLUFTWM") ): return Configuration.sessionVersion ? formatVersion("HerbstluftWM", "herbstluftwm", ["--version"]) : "HerbstluftWM"; 
                    case _ if (upper.contains("NSCDE")  || upper.contains("FVWM") ): return "FVWM";
                    case _ if (upper.contains("OXWM") ): return Configuration.sessionVersion ? formatVersion("OXWM", "oxwm", ["--version"]) : "OXWM"; // Tony Banters my beloved guy
                    case _ if (upper.contains("PEKWM") ): return Configuration.sessionVersion ? formatVersion("PekWM", "pekwm", ["--version"]) : "PekWM";
                    case _ if (upper.contains("QTILE") ): return Configuration.sessionVersion ? formatVersion("QTile", "qtile", ["--version"]) : "QTile";
                    case _ if (upper.contains("XMONAD") ): return Configuration.sessionVersion ? formatVersion("XMonad", "xmonad", ["--version"]) : "XMonad";
                    case _ if (upper.contains("VXWM") ): return "VXWM";
                    case _ if (upper.contains("WINDOWMAKER") ): return Configuration.sessionVersion ? formatVersion("WindowMaker", "wmaker", ["--version"]) : "WindowMaker";

                    default: return null;
                }
                
                return clean;
            }

            var currentSession = checkSession();
            if (currentSession != null) return currentSession;
        }

        return null;
    }

    private static function formatVersion(name:String, execution:String, arguments:Array<String>):String {
        var process = Haxefetch.runCmd(execution, arguments);
        if (process != null && process != "") {
            var register = ~/\b\d+\.\d+(\.\d+)?\b/;
            if (register.match(process)) return '${name} ${register.matched(0)}';
        }

        return name;
    }

    private static function checkSession():Null<String> {
        var wm = [
            //Wayland
            "kwin" => "KWin",
            "mutter" => "Mutter",
            "cosmic-comp" => "Cosmic Comp",
            "sway" => "Sway",
            "hyprland" => "Hyprland",
            "niri" => "Niri",
            "mangowc" => "Mango",
            "dwl" => "DWL",
            "miracle-wm" => "Miracle",
            "river" => "River",
            "labwc" => "LabWC",
            "wayfire" => "Wayfire",
            "xfwl" => "XFWL",

            // X11/Xorg
            "xfwm4" => "Xfwm4",
            "twin" => "TWin",
            "muffin" => "Muffin",
            "marco" => "Marco",
            "metacity" => "Metacity",
            "openbox" => "OpenBox",
            "blackbox" => "BlackBox",
            "fluxbox" => "FluxBox",
            "awesome" => "Awesome",
            "bspwm" => "Bspwm",
            "cwm" => "CWM",
            "dwm" => "DWM",
            "dtwm" => "DTWM",
            "e13" => "E13",
            "enligthtenment" => "Enligthtenment",
            "i3" => "i3",
            "icewm" => "IceWM", // R.I.P Marko
            "herbstluftwm" => "HerbstluftWM",
            "fvwm" => "FWVM",
            "oxwm" => "OXWM", // Tony Banters my beloved guy
            "pekwm" => "PekWM",
            "qtile" => "QTile",
            "xmonad" => "XMonad",
            "vxwm" => "VXWM",
            "windowmaker" => "WindowMaker"
        ];

        for (process in wm.keys()) {
            var output = StringTools.trim(Haxefetch.runCmd("pgrep", ["-x", process]));
            if (output != "" && output != "N/A" && output != null) return wm.get(process);
        }
        return null;
    }

    public static function fetchProtocol():Null<String> {
        var protocolType = Sys.getEnv("XDG_SESSION_TYPE");
        if (protocolType != null && protocolType != "") {
            switch (protocolType.toLowerCase()) {
                case "wayland": return "Wayland";
                case "x11": return checkProtocol();
                case "xlibre": return "XLibre";
                case "tty": return null;
                case _: checkProtocol();
            }
        }

        return checkProtocol();
    }

    private static function checkProtocol():Null<String> {
        if (Sys.getEnv("WAYLAND_DISPLAY") != null && Sys.getEnv("WAYLAND_DISPLAY") != "") return "Wayland";
        if (Sys.getEnv("DISPLAY") != null && Sys.getEnv("DISPLAY") != "") {
            var xorg = Xorg.fetchXorg().toLowerCase();
            if (xorg.indexOf("xlibre") != -1) return "XLibre";
            return "X11";
        } 
        return null;
    }
}