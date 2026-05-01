#!/system/bin/sh
MODDIR="${0%/*}"
OUTFD="$2"
TIMEOUT=30
PERSISTENT_CONFIG="/data/adb/ghostgms"
mkdir -p "$MODPATH/logs" "$MODPATH/config" "$MODPATH/system/bin" "$PERSISTENT_CONFIG"
ui_print() { echo "$1"; }
print_banner() {
  ui_print "╭───────────────────────────────────────╮"
  ui_print "│  $1"
  ui_print "╰───────────────────────────────────────╯"
}
print_section() {
  ui_print ""
  ui_print "────────────────────────────────────────"
  ui_print "$1"
  ui_print "────────────────────────────────────────"
  ui_print ""
}
choose_option() {
  local prompt="$1"
  local default="$2"
  ui_print ""
  print_banner "$prompt"
  ui_print "🔼 = Yes | 🔽 = No  (Default: $default)"
  while :; do
    event=$(timeout "$TIMEOUT" getevent -qlc 1 2>/dev/null)
    code=$?
    if [ "$code" -eq 124 ] || [ "$code" -eq 143 ]; then
      [ "$default" = "Yes" ] && return 0 || return 1
    fi
    if echo "$event" | grep -qE "KEY_VOLUMEUP|0073| 73 " && echo "$event" | grep -qE "DOWN| 1| 00000001"; then sleep 0.3; return 0; fi
    if echo "$event" | grep -qE "KEY_VOLUMEDOWN|0072| 72 " && echo "$event" | grep -qE "DOWN| 1| 00000001"; then sleep 0.3; return 1; fi
  done
}
print_section "📱 Welcome to GhostGMS 📱"
ui_print "Use Volume Up for YES, Volume Down for NO."
choose_option "📋 Disable GMS Logging?" "Yes"
ENABLE_LOG_DISABLE=$?
choose_option "🔧 Set GMS-optimized system properties?" "Yes"
ENABLE_SYS_PROPS=$?
choose_option "🎨 Disable UI blur effects?" "No"
ENABLE_BLUR_DISABLE=$?
choose_option "⚙️ Disable intrusive GMS services?" "Yes"
ENABLE_SERVICES_DISABLE=$?
DISABLE_ADS=0; DISABLE_TRACKING=0; DISABLE_ANALYTICS=0; DISABLE_REPORTING=0; 
DISABLE_BACKGROUND=0; DISABLE_UPDATE=0; DISABLE_LOCATION=1; DISABLE_GEOFENCE=1; 
DISABLE_NEARBY=1; DISABLE_CAST=1; DISABLE_DISCOVERY=1; DISABLE_SYNC=1; 
DISABLE_CLOUD=1; DISABLE_AUTH=1; DISABLE_WALLET=1; DISABLE_PAYMENT=1; 
DISABLE_WEAR=1; DISABLE_FITNESS=1
GMS_CATEGORIES="ADS TRACKING ANALYTICS REPORTING BACKGROUND UPDATE LOCATION GEOFENCE NEARBY CAST DISCOVERY SYNC CLOUD AUTH WALLET PAYMENT WEAR FITNESS"
if [ "$ENABLE_SERVICES_DISABLE" -eq 0 ]; then
  print_section "📋 GMS Service Categories"
  for cat in $GMS_CATEGORIES; do
    msg="Disable $cat services?"
    [ "$cat" = "NEARBY" ] && msg="$msg (Breaks Quick Share!)"
    [ "$cat" = "WEAR" ] && msg="$msg (Breaks Smartwatch!)"
    default="Yes"
    eval "current_def=\$DISABLE_$cat"
    [ "$current_def" -eq 1 ] && default="No"
    choose_option "$msg" "$default"
    eval "DISABLE_$cat=\$?"
  done
fi
{
  echo "ENABLE_LOG_DISABLE=$ENABLE_LOG_DISABLE"
  echo "ENABLE_SYS_PROPS=$ENABLE_SYS_PROPS"
  echo "ENABLE_BLUR_DISABLE=$ENABLE_BLUR_DISABLE"
  echo "ENABLE_SERVICES_DISABLE=$ENABLE_SERVICES_DISABLE"
  for cat in $GMS_CATEGORIES; do
    eval "val=\$DISABLE_$cat"
    echo "DISABLE_$cat=$val"
  done
mkdir -p "$MODPATH/config"
} > "$MODPATH/config/user_prefs"
PERSISTENT_CONFIG="/data/adb/ghostgms"
mkdir -p "$PERSISTENT_CONFIG"
cp -f "$MODPATH/config/user_prefs" "$PERSISTENT_CONFIG/user_prefs"
chmod 644 "$PERSISTENT_CONFIG/user_prefs"
chmod 644 "$MODPATH/config/user_prefs"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
for script in service.sh veloxine.sh post-fs-data.sh; do
  [ -f "$MODPATH/$script" ] && set_perm "$MODPATH/$script" 0 0 0755
done
if [ -d "$MODPATH/webroot" ]; then
  chmod -R 755 "$MODPATH/webroot"
fi
print_section "✅ Installation Complete"
ui_print "🔄 Changes take effect after reboot."
