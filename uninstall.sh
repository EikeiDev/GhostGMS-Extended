#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE="/data/local/tmp/ghostgms_uninstall.log"
PERSISTENT_CONFIG="/data/adb/ghostgms"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Uninstall started" > "$LOGFILE"
if [ -f "$MODDIR/veloxine.sh" ] && [ -f "$MODDIR/gmslist.txt" ]; then
    echo "[INFO] Re-enabling GMS services via veloxine.sh" >> "$LOGFILE"
    sh "$MODDIR/veloxine.sh" enable >> "$LOGFILE" 2>&1
else
    echo "[WARNING] veloxine.sh or gmslist.txt missing, services may remain disabled" >> "$LOGFILE"
fi
echo "[INFO] Reversing system settings" >> "$LOGFILE"
settings put global gmscorestat_enabled 1
settings put global play_store_panel_logging_enabled 1
settings put global clearcut_events 1
settings put global clearcut_gcm 1
settings delete global phenotype__debug_bypass_phenotype
settings delete global phenotype_boot_count
settings delete global phenotype_flags
settings put global ga_collection_enabled 1
settings put global clearcut_enabled 1
settings put global analytics_enabled 1
settings put global uploading_enabled 1
settings put global bug_report_in_power_menu 1
settings put global usage_stats_enabled 1
settings put global usagestats_collection_enabled 1
echo "[INFO] Reversing resetprop changes" >> "$LOGFILE"
resetprop --delete tombstoned.max_tombstone_count
resetprop --delete ro.lmk.debug
resetprop --delete ro.lmk.log_stats
resetprop --delete dalvik.vm.check-dex-sum
resetprop --delete dalvik.vm.checkjni
resetprop --delete dalvik.vm.dex2oat-minidebuginfo
resetprop --delete dalvik.vm.minidebuginfo
resetprop --delete dalvik.vm.verify-bytecode
resetprop --delete disableBlurs
resetprop --delete enable_blurs_on_windows
resetprop --delete ro.launcher.blur.appLaunch
resetprop --delete ro.sf.blurs_are_expensive
resetprop --delete ro.surface_flinger.supports_background_blur
if [ -d "$PERSISTENT_CONFIG" ]; then
    echo "[INFO] Removing persistent config at $PERSISTENT_CONFIG" >> "$LOGFILE"
    rm -rf "$PERSISTENT_CONFIG"
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Uninstall completed" >> "$LOGFILE"
exit 0