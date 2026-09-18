package utils;

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

            if (token.indexOf("GNOME") != -1) return formatDesktop("GNOME", "gnome-shell", ["--version"]);
            if (token.indexOf("KDE") != -1 || token.indexOf("PLASMA") != -1) return formatDesktop("KDE Plasma", "plasmashell", ["--version"]);
            if (token.indexOf("TDE") != -1 || token.indexOf("TRINITY") != -1) return formatDesktop("TDE", "tde-config", ["--version"]);
            if (token.indexOf("CINNAMON") != -1) return formatDesktop("Cinnamon", "cinnamon", ["--version"]);
            if (token.indexOf("XFCE") != -1) return formatDesktop("XFCE", "xfce4-about", ["-V"]);
            if (token.indexOf("MATE") != -1) return formatDesktop("MATE", "mate-about", ["-v"]);
            if (token.indexOf("BUDGIE") != -1) return formatDesktop("Budgie", "budgie-desktop", ["--version"]);
            if (token.indexOf("COSMIC") != -1) return formatDesktop("COSMIC", "cosmic-comp", ["--version"]);
            if (token.indexOf("DEEPIN") != -1 || token.indexOf("DDE") != -1) return formatDesktop("Deepin", "dde-dock", ["--version"]);
            if (token.indexOf("LXDE") != -1) return formatDesktop("LXDE", "lxsession", ["--version"]);
            if (token.indexOf("LXQT") != -1) return formatDesktop("LXQt", "lxqt-session", ["-v"]);
            if (token.indexOf("NSCDE") != -1) return formatDesktop("NsCDE", "sh", ["-c", "nscde -V"]);
            if (token.indexOf("CDE") != -1) return formatDesktop("CDE", "sh", ["-c", "dtversion"]);
        }
        return null;
    }

    private static function formatDesktop(name:String, execution:String, arguments:Array<String>):String {
        var process = Haxefetch.runCmd(execution, arguments);
        if (process != null && process != "") {
            var register = ~/\b\d+\.\d+(\.\d+)?\b/;
            if (register.match(process)) return '${name} ${register.matched(0)}';
        }

        return name;
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
                    case _ if (upper.indexOf("KWIN") != -1 || upper.indexOf("KDE") != -1 || upper.indexOf("PLASMA") != -1): return "KWin";
                    case _ if (upper.indexOf("MUTTER") != -1 || upper.indexOf("GNOME") != -1 || upper.indexOf("BUDGIE") != -1): return "Mutter";
                    case _ if (upper.indexOf("COSMIC-COMP") != -1 || upper.indexOf("COSMIC") != -1): return "Cosmic Comp";
                    case _ if (upper.indexOf("SWAY") != -1): return "Sway";
                    case _ if (upper.indexOf("HYPRLAND") != -1): return "Hyprland";
                    case _ if (upper.indexOf("NIRI") != -1): return "Niri";
                    case _ if (upper.indexOf("MANGO") != -1): return "Mango";
                    case _ if (upper.indexOf("DWL") != -1): return "DWL";
                    case _ if (upper.indexOf("MIRACLE") != -1 || upper.indexOf("MIRACLE-WM") != -1): return "Miracle";
                    case _ if (upper.indexOf("RIVER") != -1): return "River";
                    case _ if (upper.indexOf("LABWC") != -1): return "LabWC";
                    case _ if (upper.indexOf("WAYFIRE") != -1): return "Wayfire";
                    case _ if (upper.indexOf("XFWL") != -1 || upper.indexOf("XFCE") != -1): return "XFWL";

                    // X11/Xorg
                    case _ if (upper.indexOf("XFCE") != -1): return "Xfwm4";
                    case _ if (upper.indexOf("TWIN") != -1 || upper.indexOf("TDE") != -1 || upper.indexOf("TRINITY") != -1): return "TWin";
                    case _ if (upper.indexOf("MUFFIN") != -1 || upper.indexOf("CINNAMON") != -1 || upper.indexOf("X-CINNAMON") != -1): return "Muffin";
                    case _ if (upper.indexOf("MARCO") != -1 || upper.indexOf("MATE") != -1): return "Marco";
                    case _ if (upper.indexOf("METACITY") != -1): return "Metacity";
                    case _ if (upper.indexOf("OPENBOX") != -1 || upper.indexOf("LXQT") != -1 || upper.indexOf("LXDE") != -1): return "OpenBox";
                    case _ if (upper.indexOf("BLACKBOX") != -1): return "BlackBox";
                    case _ if (upper.indexOf("FLUXBOX") != -1): return "FluxBox";
                    case _ if (upper.indexOf("AWESOME") != -1): return "Awesome";
                    case _ if (upper.indexOf("BSPWM") != -1): return "Bspwm";
                    case _ if (upper.indexOf("DWM") != -1): return "DWM";
                    case _ if (upper.indexOf("DTWM") != -1 || upper.indexOf("CDE") != -1): return "DTWM";
                    case _ if (upper.indexOf("E13") != -1): return "E13";
                    case _ if (upper.indexOf("ENLIGHTENMENT") != -1): return "Enligthtenment";
                    case _ if (upper.indexOf("I3") != -1): return "i3";
                    case _ if (upper.indexOf("ICEWM") != -1): return "IceWM"; // R.I.P Marko
                    case _ if (upper.indexOf("HERBSTLUFTWM") != -1): return "HerbstluftWM"; 
                    case _ if (upper.indexOf("NSCDE") != -1 || upper.indexOf("FVWM") != -1): return "FVWM";
                    case _ if (upper.indexOf("OXWM") != -1): return "OXWM"; // Tony Banters my beloved guy
                    case _ if (upper.indexOf("PEKWM") != -1): return "PekWM";
                    case _ if (upper.indexOf("QTILE") != -1): return "QTile";
                    case _ if (upper.indexOf("XMONAD") != -1): return "XMonad";
                    case _ if (upper.indexOf("VXWM") != -1): return "VXWM";
                    case _ if (upper.indexOf("WINDOWMAKER") != -1): return "WindowMaker";

                    default: return null;
                }
                
                return clean;
            }

            var currentSession = checkSession();
            if (currentSession != null) return currentSession;
        }

        return null;
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