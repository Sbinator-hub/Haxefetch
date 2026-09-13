package utils;

import sys.io.File;
import sys.FileSystem;
import StringTools;

// Requires for RPM since using rpm -qa is most slowest way to fetch RPM packages + it is lightweight
@:buildXml('
<target id="haxe">
    <lib name="-ldl" />
</target>
')
@:cppInclude("dlfcn.h")

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
            // Debian/GNU Linux based system (dpkg) - Debian Organization
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

            // RPM based system (rpm) - Red Hat team
            var rpmPath = root + "/usr/lib/sysimage/rpm/rpmdb.sqlite";
            if (!FileSystem.exists(rpmPath)) rpmPath = root + "/var/lib/rpm/rpmdb.sqlite";
            if (FileSystem.exists(rpmPath)) {
                try {
                    var count = getSQLiteCount(rpmPath, "SELECT count(*) FROM Packages;");

                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (rpm)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Arch Linux based system (pacman) - Arch Linux devs
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

            // Void Linux based system (xbps) - Void Linux devs
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

            // Alpine Linux based system (apk) - Alpine Linux Development Team
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

            // NixOS based system (nix) - Nix Team
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

            // Slackware Linux based system (slackpkg) - Patrick Volkerding
            if (FileSystem.exists(root + "/var/log/packages")) {
                try {
                    var total = FileSystem.readDirectory(root + "/var/log/packages").length;
                    if (total > 0) {
                        var entry = Configuration.packageManager ? '$total (pkgtools)' : '${total}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // GNU Guix based system (guix) - Efraim Flashner, Mathieu Othacehe, Maxim Cournoyer and Tobias Geerinckx-Rice
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

            // Gentoo Linux based system (emerge/portage) - Gentoo Linux devs
            if (FileSystem.exists(root + "/var/db/pkg")) {
                try {
                    var total = 0;
                    var catPath = FileSystem.readDirectory(root + "/var/db/pkg");

                    for (cats in catPath) {
                        var cat = root + "/var/db/pkg/" + cats;
                        if (FileSystem.isDirectory(cat)) total += FileSystem.readDirectory(cat).length;
                    }

                    if (total > 0) {
                        var entry = Configuration.packageManager ? '$total (emerge)' : '${total}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Exherbo Linux based system (cave/paludis) - forked from Gentoo, but it is indipendent distro according to distrowatch.com
            if (FileSystem.exists(root + "/var/db/paludis/repositories/installed")) {
                try {
                    var total = 0;
                    var entries = FileSystem.readDirectory(root + "/var/db/paludis/repositories/installed");

                    for (entry in entries) {
                        var path = root + "/var/db/paludis/repositories/installed" + entry;
                        if (FileSystem.exists(path)) total += FileSystem.readDirectory(path).length;
                    }

                    if (total > 0) {
                        var entry = Configuration.packageManager ? '$total (cave)' : '${total}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                }
            }

            // Solus based system (eopkg) - David Harder, Joey Riches, Reilly Brogan, Tracey Clark, Troy Harvey
            if (FileSystem.exists(root + "/var/lib/eopkg/package")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/eopkg/package").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (eopkg)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // AerynOS / Serpent OS (moss) - AerynOS/Serpent OS devs
            var database = root + "/.moss/db/state";
            if (FileSystem.exists(database)) {
                try {
                    var count = getSQLiteCount(database, "SELECT COUNT(*) FROM state_selections WHERE state_id = (SELECT MAX(id) FROM state);");

                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (moss)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // KISS Linux (kiss) - Dylan Araps
            if (FileSystem.exists(root + "/var/db/kiss/installed")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/db/kiss/installed").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (kiss)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Paldo Linux (upkg) - Jürg and Raffaele
            if (FileSystem.exists(root + "/var/lib/upkg/db")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/upkg/db").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (upkg)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // PiSi Linux (pisi) - Temel Bilgiler
            if (FileSystem.exists(root + "/var/lib/pisi/package")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/pisi/package").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (pisi)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    } 
                } catch (e:Dynamic) {}
            }

            // Unknown distribution/OS (Veiler) - ilovetrees242 
            if (FileSystem.exists(root + "/var/db/Veiler")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/db/Veiler").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '$count (velier)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Glaucus Linux (rad) - Firas Khana
            if (FileSystem.exists(root + "/var/lib/rad/local")) {
                try {
                    var count = FileSystem.readDirectory(root + "/var/lib/rad/local").length;
                    if (count > 0) {
                        var entry = Configuration.packageManager ? '${count} (rad)' : '${count}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }

            // Snaps - Canocial devs
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

        // Flatpak - Flathub devs
        var path:Array<String> = ["/var/lib/flatpak/app"];
        if (home != null && home != "") path.push(home + "/.local/share/flatpak/app");
        var flatpaks = 0;

        for (paths in path) {
            if (paths != null && FileSystem.exists(paths) && FileSystem.isDirectory(paths)) {
                try {
                    flatpaks += FileSystem.readDirectory(paths).length;

                    if (flatpaks > 0) {
                        var entry = Configuration.packageManager ? '$flatpaks (flatpak)' : '${flatpaks}';
                        if (!counts.contains(entry)) counts.push(entry);
                    }
                } catch (e:Dynamic) {}
            }
        }
        
        return counts.join(Configuration.packageSeparator != null ? Configuration.packageSeparator : "");
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

    private static function getSQLiteCount(dbPath:String, query:String):Int {
        var count:Int = 0;
        #if cpp
        var cPath = dbPath;
        var cQuery = query;
        count = untyped __cpp__('[](const char* path, const char* query) -> int {
            void* handle = dlopen("libsqlite3.so.0", RTLD_LAZY);
            if (!handle) handle = dlopen("libsqlite3.so", RTLD_LAZY);
            if (!handle) return 0;

            auto s_open = (int(*)(const char*, void**, int, const char*))dlsym(handle, "sqlite3_open_v2");
            auto s_prep = (int(*)(void*, const char*, int, void**, const char**))dlsym(handle, "sqlite3_prepare_v2");
            auto s_step = (int(*)(void*))dlsym(handle, "sqlite3_step");
            auto s_col  = (int(*)(void*, int))dlsym(handle, "sqlite3_column_int");
            auto s_fin  = (int(*)(void*))dlsym(handle, "sqlite3_finalize");
            auto s_cls  = (int(*)(void*))dlsym(handle, "sqlite3_close");

            if (!s_open || !s_prep || !s_step || !s_col || !s_fin || !s_cls) {
                dlclose(handle);
                return 0;    
            }

            void * db = nullptr;
            int total = 0;
            if (s_open(path, &db, 1, nullptr) == 0) {
                void* stmt = nullptr;
                if (s_prep(db, query, -1, &stmt, nullptr) == 0) {
                    if (s_step(stmt) == 100) {
                        total = s_col(stmt, 0);
                    }
                    s_fin(stmt);       
                }
                s_cls(db);    
            }
            dlclose(handle);
            return total;
        }({0}, {1})', cPath, cQuery);
        #end
        return count;
    }
}