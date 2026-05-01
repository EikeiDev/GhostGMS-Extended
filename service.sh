#!/system/bin/sh
MODDIR=${0%/*}
wait_for_boot() {
  while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
}
wait_for_boot
sleep 5
PERSISTENT_CONFIG="/data/adb/ghostgms"
CONFIG_FILE="$MODDIR/config/user_prefs"
[ ! -f "$CONFIG_FILE" ] && CONFIG_FILE="$PERSISTENT_CONFIG/user_prefs"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    ENABLE_LOG_DISABLE=0
    ENABLE_SYS_PROPS=0
fi
if [ "$ENABLE_LOG_DISABLE" -eq 0 ]; then
    resetprop -n logcat.live disable
    resetprop -n rw.logger 0
    resetprop -n persist.service.logging.disable true
    resetprop -n log.redirect-stdio false
fi
if [ "$ENABLE_SYS_PROPS" -eq 0 ]; then
    resetprop -n ro.error.receiver.system.apps com.google.android.gms
    resetprop -n dalvik.vm.checkjni false
fi
sh "$MODDIR/veloxine.sh" boot