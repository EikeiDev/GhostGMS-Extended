#!/system/bin/sh
COMMAND=${1:-"status"}
MODDIR="${0%/*}"
PERSISTENT_CONFIG="/data/adb/ghostgms"
LOGDIR="$MODDIR/logs"
[ ! -w "$LOGDIR" ] && LOGDIR="$PERSISTENT_CONFIG/logs"
mkdir -p "$LOGDIR" 2>/dev/null
LOGFILE="$LOGDIR/ghostgms_service.log"
exec >> "$LOGFILE" 2>&1
echo "[$(date '+%H:%M:%S')] GhostGMS Command: $COMMAND"
CONFIG_FILE="$MODDIR/config/user_prefs"
[ ! -f "$CONFIG_FILE" ] && CONFIG_FILE="$PERSISTENT_CONFIG/user_prefs"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
    echo "[INFO] Configuration loaded from $CONFIG_FILE"
else
    echo "[ERROR] No configuration found! Using defaults."
    ENABLE_SERVICES_DISABLE=0; ENABLE_LOG_DISABLE=0
fi
safe_settings_put() {
    local key=$1 val=$2 count=0
    while [ $count -lt 3 ]; do
        if settings put global "$key" "$val" >/dev/null 2>&1; then return 0; fi
        sleep 1; count=$((count + 1))
    done
    echo "[WARNING] Failed to set $key after 3 attempts"
}
toggle_gms_service() {
    local SERVICE=$1 CATEGORY=$2 ACTION=$3
    [ -z "$CATEGORY" ] || [ "$CATEGORY" = "null" ] || [ "$CATEGORY" = "core" ] || [ "$CATEGORY" = "essential" ] && return
    if [ "$ACTION" = "enable" ]; then
        cmd package enable --user 0 "$SERVICE" >/dev/null 2>&1
        return
    fi
    local CAT_UP=$(echo "$CATEGORY" | tr '[:lower:]' '[:upper:]')
    eval "SHOULD_DISABLE=\$DISABLE_$CAT_UP"
    if [ -z "$SHOULD_DISABLE" ]; then
        echo "[WARNING] Unknown category: $CATEGORY for $SERVICE"
        return
    fi
    if [ "$SHOULD_DISABLE" = "0" ]; then
        cmd package disable-user --user 0 "$SERVICE" >/dev/null 2>&1
    else
        cmd package enable --user 0 "$SERVICE" >/dev/null 2>&1
    fi
}
process_services() {
    local ACTION=$1 LIST="$MODDIR/gmslist.txt"
    [ ! -f "$LIST" ] && return 1
    while IFS="|" read -r SERVICE CATEGORY || [ -n "$SERVICE" ]; do
        case "$SERVICE" in \#*|"") continue ;; esac
        toggle_gms_service "$SERVICE" "$CATEGORY" "$ACTION"
    done < "$LIST"
}
disable_gms_logs() {
    if [ "$ENABLE_LOG_DISABLE" = "0" ]; then
        echo "[INFO] Applying full GMS battery optimizations..."
        local count=0
        while [ $count -lt 15 ] && ! settings get global sys_usb >/dev/null 2>&1; do sleep 2; count=$((count+1)); done
        safe_settings_put "gmscorestat_enabled" "0"
        safe_settings_put "play_store_panel_logging_enabled" "0"
        safe_settings_put "clearcut_events" "0"
        safe_settings_put "clearcut_gcm" "0"
        safe_settings_put "phenotype__debug_bypass_phenotype" "1"
        safe_settings_put "phenotype_boot_count" "99"
        safe_settings_put "phenotype_flags" "disable_log_upload=1,disable_log_for_missing_debug_id=1"
        safe_settings_put "ga_collection_enabled" "0"
        safe_settings_put "clearcut_enabled" "0"
        safe_settings_put "analytics_enabled" "0"
        safe_settings_put "uploading_enabled" "0"
        safe_settings_put "bug_report_in_power_menu" "0"
        safe_settings_put "usage_stats_enabled" "0"
        safe_settings_put "usagestats_collection_enabled" "0"
        setprop persist.sys.gms.offlining_disabled true
        setprop persist.sys.gms.telemetry_disabled true
    fi
}
case "$COMMAND" in
    "boot"|"disable")
        [ "$ENABLE_SERVICES_DISABLE" = "0" ] && process_services "disable"
        disable_gms_logs
        ;;
    "enable")
        process_services "enable"
        ;;
    "status")
        DISABLED=$(dumpsys package com.google.android.gms | grep -c "disabled")
        echo "[INFO] Status: $DISABLED services disabled."
        ;;
esac
exit 0