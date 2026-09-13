package utils;

#if cpp
@:headerCode('
#include <sys/statvfs.h>
#include <stdio.h>
#include <string.h>
#include <mntent.h>
')
#end

class DiskUtility {
    public static function fetchDisk():String {
        var diskString:String = "N/A";

        #if cpp
        var result:String = "";
        untyped __cpp__('
            struct statvfs stat;
            char targetDir[256] = "/";
            char fsType[32] = "unknown";
            int found = 0;

            FILE* mounts = setmntent("/proc/mounts", "r");
            if (mounts != NULL) {
                struct mntent* ent;
                char bestDir[256] = "/";
                char bestType[32] = "unknown";
                int bestScore = 0;
                
                while ((ent = getmntent(mounts)) != NULL) {
                    if (strcmp(ent->mnt_type, "overlay") == 0 ||
                        strcmp(ent->mnt_type, "tmpfs") == 0 ||
                        strcmp(ent->mnt_type, "devtmpfs") == 0 ||
                        strcmp(ent->mnt_type, "sysfs") == 0 ||
                        strcmp(ent->mnt_type, "proc") == 0) {
                        continue;    
                    }

                    int score = 1;
                    if (strcmp(ent->mnt_dir, "/var/home") == 0 || strcmp(ent->mnt_dir, "/home") == 0) {
                        score = 3;
                    } else if (strcmp(ent->mnt_dir, "/") == 0) {
                        score = 2;
                    }

                    if (score > bestScore) {
                        snprintf(bestDir, sizeof(bestDir), "%s", ent->mnt_dir);
                        snprintf(bestType, sizeof(bestType), "%s", ent->mnt_type);
                        bestScore = score;
                    }
                }
                endmntent(mounts);

                if (bestScore > 0) {
                    snprintf(targetDir, sizeof(targetDir), "%s", bestDir);
                    snprintf(fsType, sizeof(fsType), "%s", bestType);
                    found = 1;    
                }
            }

            if (!found) snprintf(targetDir, sizeof(targetDir), "/");

            if (statvfs(targetDir, &stat) == 0 && stat.f_blocks > 0) {
                unsigned long long total = (unsigned long long)stat.f_blocks * stat.f_frsize;
                unsigned long long free = (unsigned long long)stat.f_bavail * stat.f_frsize;
                unsigned long long used = total - free;
                
                double u_val = (double)used;
                double t_val = (double)total;
                int unit_idx = 0;
                const char* units[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB"};
                while (t_val >= 1024.0 && unit_idx < 5) {
                    u_val /= 1024.0;
                    t_val /= 1024.0;
                    unit_idx++;
                }
                int percent = (int)(((double)used / (double)total) * 100.0);

                const char* colorCode = "\\033[32m";
                if (percent >= 85) {
                    colorCode = "\\033[31m";
                } else if (percent >= 60) {
                    colorCode = "\\033[33m";    
                }
                const char* resetCode = "\\033[0m";

                char buffer[256];
                snprintf(buffer, sizeof(buffer), "%.1f %s / %.1f %s (%s%d%%%s) [%s]", u_val, units[unit_idx], t_val, units[unit_idx], colorCode, percent, resetCode, fsType);
                result = String(buffer);
            }
        ');

        if (result != "") {
            return result;
        }
        #end

        return diskString;
    }
}