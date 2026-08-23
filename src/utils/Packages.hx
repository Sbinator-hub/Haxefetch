package utils;

import sys.io.File;
import sys.FileSystem;

class Packages {
    public static function fetchPackage():String {
        #if sys
        var counts:Array<String> = [];
        var bedrockRoot = fetchBedrockPackages();
        
        var home = Sys.getEnv("HOME");
        if (home == null) home == "";

        var user = Sys.getEnv("USER");
        if (user == null) user == "";

        for (root in bedrockRoot) {
            // Debian/GNU Linux based system (dpkg)
            if (FileSystem.exists(root + "/var/lib/dpkg/status")) {
                try {
                    var content = File.getContent(root + "/var/lib/dpkg/status");
                    var pattern = ~/^Status: install ok installed/gm;
                    var count = 0;
                    
                    while (pattern.match(content)) {
                        count++;
                        content = pattern.matchedRight();
                    }
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (dpkg)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // RPM based system (rpm)
            if (FileSystem.exists(root + "/var/lib/rpm")) {
                try {
                    var rpm = Haxefetch.executeCount("rpm", ["-qa", "--qf", ".\n" ]);

                    if (rpm > 0) {
                        var count = '${rpm}';
                        var entry = Configuration.packageManager ? '$count (rpm)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Arch Linux based system (pacman)
            if (FileSystem.exists(root + "/var/lib/pacman/local")) {
                try {
                    var entries = FileSystem.readDirectory(root + "/var/lib/pacman/local");
                    var count = entries.filter(e -> !StringTools.startsWith(e, "ALPM") && StringTools.contains(e, "-")).length;

                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (pacman)' : '$count';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Void Linux based system (xbps)
            if (FileSystem.exists(root + "/var/db/xbps")) {
                try {
                    var files = FileSystem.readDirectory(root + "/var/db/xbps");
                    var pkgFile = "";

                    for (file in files) {
                        if (StringTools.startsWith(file, "pkgdb-") && StringTools.endsWith(file, ".plist")) {
                            pkgFile = file;
                            break;
                        }
                    }

                    if (pkgFile != "") {
                        var content = File.getContent(root + "/var/db/xbps" + pkgFile);
                        var pattern = ~/<key>state<\/key>\s*<string>installed<\/string>/g;
                        var count = 0;
                        while (pattern.match(content)) {
                            count++;
                            content = pattern.matchedRight();
                        }
                        if (count > 0) {
                            var entry = Configuration.packageManager ? '$count (xbps)' : '$count';
                            if (!counts.contains(entry)) counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // Alpine Linux based system (apk)
            if (FileSystem.exists(root + "/lib/apk/db/installed")) {
                try {
                    var content = File.getContent(root + "/lib/apk/db/installed");
                    var pattern = ~/^P:/gm;
                    var count = 0;
                    while (pattern.match(content)) {
                        count++;
                        content = pattern.matchedRight();
                    }
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (apk)' : '$count';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // NixOS based system (nix)
            if (FileSystem.exists(root + "/nix/store") || FileSystem.exists(home + "/.nix-profile")) {
                try {
                    if (FileSystem.exists(root + "/nix/store")) {
                        var count = FileSystem.readDirectory(root + "/nix/store").length;
                        if (count > 0) {
                            var entry = Configuration.packageManager ? '$count (nix)' : '$count';
                            if (!counts.contains(entry)) counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // Slackware Linux based system (slackpkg)
            if (FileSystem.exists(root + "/var/log/packages")) {
                try {
                    var total = FileSystem.readDirectory(root + "/var/log/packages").length;
                    if (total > 0) {
                        var entry = Configuration.packageManager ? '$total (pkgtools)' : '${total}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // GNU Guix based system (guix)
            var manifest = home + "/.guix-profile/manifest";
            if (!FileSystem.exists(manifest) && user != "") manifest = root + "/var/guix/profiles/per-user/" + user + "/current-profile/manifest";

            if (FileSystem.exists(manifest)) {
                try {
                    var content = File.getContent(manifest);
                    var pattern = ~/\(manifest-entry/g;
                    var count = 0;
                    while (pattern.match(content)) {
                        count++;
                        content = pattern.matchedRight();
                    }
                    if (count > 0) {        
                        var entry = Configuration.packageManager ? '$count (guix)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Gentoo Linux based system (emerge/portage)
            if (FileSystem.exists(root + "/var/db/pkg")) {
                try {
                    var total = 0;
                    var catPath = FileSystem.readDirectory(root + "/var/db/pkg");
                    for (cats in catPath) {
                        var cat = root + "/var/db/pkg/" + cats;
                        if (FileSystem.isDirectory(cat)) {
                            total += FileSystem.readDirectory(cat).length;
                        }
                    }
                    if (total > 0) {
                        var entry = Configuration.packageManager ? '$total (emerge)' : '${total}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Solus based system (eopkg)
            if (FileSystem.exists(root + "/var/lib/eopkg/package")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/eopkg/package").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (eopkg)' : '${count}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // KISS Linux (kiss)
            if (FileSystem.exists(root + "/var/db/kiss/installed")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/db/kiss/installed").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (kiss)' : '${count}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // Paldo Linux (upkg)
            if (FileSystem.exists(root + "/var/lib/upkg/db")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/upkg/db").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (upkg)' : '${count}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    }
                } catch (e:Dynamic) {}
            }

            // PiSi Linux (pisi)
            if (FileSystem.exists(root + "/var/lib/pisi/package")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/pisi/package").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (pisi)' : '${count}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    } 
                } catch (e:Dynamic) {}
            }

            // Fronttier Linux (forge)
            if (FileSystem.exists(root + "/var/lib/forge/local")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/forge/local").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (forge)' : '${count}';
                        if (!counts.contains(entry)) {
                            counts.push(entry);
                        }
                    } 
                } catch (e:Dynamic) {}
            }

            // AerynOS / Serpent OS (moss)
            var database = root + "/.moss/db/state";
            if (FileSystem.exists(database)) {
                try {
                    var query = "SELECT COUNT(*) FROM state_selections WHERE state_id = (SELECT MAX(id) FROM state);";
                    var raw = Haxefetch.runCmd("sqlite3", [database, query]);
                    var count = Std.parseInt(StringTools.trim(raw));

                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (moss)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Snaps
            var path = root + "/var/lib/snapd/snaps";
            if (FileSystem.exists(path)) {
                try {
                    var snaps = FileSystem.readDirectory(path).filter(e -> StringTools.endsWith(e, ".snap"));
                    if (snaps.length > 0) {
                        var count = snaps.length;
                        var entry = Configuration.packageManager ? '$count (snaps)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }
        }

        // Flatpak
        var path:Array<String> = ["/var/lib/flatpak/app"];
        if (home != null && home != "") path.push(home + "/.local/share/flatpak/app");
        var flatpaks = 0;

        for (paths in path) {
            if (paths != null && FileSystem.exists(paths) && FileSystem.isDirectory(paths)) {
                try {
                    flatpaks += FileSystem.readDirectory(paths).length;
                } catch (e:Dynamic) {}
            }
        }
        
        if (flatpaks > 0) {
            var entry = Configuration.packageManager ? '$flatpaks (flatpak)' : '${flatpaks}';
            if (!counts.contains(entry)) counts.push(entry);
        }
        
        return counts.join(", ");
        #else
        return "Unknown";
        #end
    }

    private static function fetchBedrockPackages():Array<String> {
        var root:Array<String> = [];

        if (FileSystem.exists("/bedrock/bin/brl") && FileSystem.exists("/bedrock/strata")) {
            try {
                var strata = FileSystem.readDirectory("/bedrock/strata");
                for (str in strata) {
                    root.push("/bedrock/strata/" + str);
                }
                if (root.length > 0) return root;
            } catch (e:Dynamic) {}
        } return [""];
    }
}