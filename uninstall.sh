#!/system/bin/sh
# GhostGMS Uninstall — re-enables all GMS services & reverses system changes

LOGFILE="/data/local/tmp/ghostgms_uninstall.log"

until [ -e "/sdcard/" ]; do sleep 1; done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Uninstall started" > "$LOGFILE"

# ── Reverse settings ───────────────────────────────────────────
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
settings put global usage_stats_enabled 1
settings put global usagestats_collection_enabled 1

# ── Reverse resetprop ──────────────────────────────────────────
for prop in tombstoned.max_tombstone_count ro.lmk.debug ro.lmk.log_stats \
  dalvik.vm.check-dex-sum dalvik.vm.checkjni dalvik.vm.dex2oat-minidebuginfo \
  dalvik.vm.minidebuginfo dalvik.vm.verify-bytecode disableBlurs \
  enable_blurs_on_windows ro.launcher.blur.appLaunch \
  ro.sf.blurs_are_expensive ro.surface_flinger.supports_background_blur; do
  resetprop --delete "$prop" 2>/dev/null
done

# ── Helper ─────────────────────────────────────────────────────
e() { pm enable "$1" >/dev/null 2>&1 || true; }

# ── Ads & Tracking ─────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdNotificationService"
e "com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdService"
e "com.google.android.gms/com.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService"
e "com.google.android.gms/com.google.android.gms.ads.AdRequestBrokerService"
e "com.google.android.gms/com.google.android.gms.ads.settings.AdsSettingsActivityService"
e "com.google.android.gms/com.google.android.gms.ads.GservicesValueBrokerService"
e "com.google.android.gms/com.google.android.gms.ads.measurement.GmpConversionTrackingBrokerService"
e "com.google.android.gms/com.google.android.gms.ads.jams.NegotiationService"
e "com.google.android.gms/com.google.android.gms.ads.MobileAdsSettingManagerService"

# ── Analytics & Reporting ──────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.analytics.AnalyticsService"
e "com.google.android.gms/com.google.android.gms.analytics.service.AnalyticsService"
e "com.google.android.gms/com.google.android.gms.analytics.AnalyticsTaskService"
e "com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
e "com.google.android.gms/com.google.android.gms.stats.eastworld.EastworldService"
e "com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedService"
e "com.google.android.gms/com.google.android.gms.stats.PlatformStatsCollectorService"
e "com.google.android.gms/com.google.android.gms.common.stats.GmsCoreStatsService"
e "com.google.android.gms/com.google.android.gms.common.stats.StatsUploadService"
e "com.google.android.gms/com.google.android.gms.backup.stats.BackupStatsService"
e "com.google.android.gms/com.google.android.gms.checkin.CheckinApiService"
e "com.google.android.gms/com.google.android.gms.checkin.CheckinService"
e "com.google.android.gms/com.google.android.gms.tron.CollectionService"
e "com.google.android.gms/com.google.android.gms.common.config.PhenotypeCheckinService"
e "com.google.android.gms/com.google.android.gms.romanesco.ContactsLoggerUploadService"
e "com.google.android.gms/com.google.android.gms.clearcut.service.ClearcutLoggerService"
e "com.google.android.gms/com.google.android.gms.backup.BackupOrchestrationService"
e "com.google.android.gms/com.google.android.gms.crash.service.CrashReportService"
e "com.google.android.gms/com.google.android.gms.common.stats.net.NetworkReportService"
e "com.google.android.gms/com.google.android.gms.presencemanager.service.PresenceManagerPresenceReportService"
e "com.google.android.gms/com.google.android.gms.usagereporting.service.UsageReportingIntentService"
e "com.google.android.gms/com.google.android.gms.measurement.AppMeasurementService"
e "com.google.android.gms/com.google.android.gms.measurement.AppMeasurementJobService"
e "com.google.android.gms/com.google.android.gms.measurement.AppMeasurementReceiver"
e "com.google.android.gms/com.google.android.gms.measurement.PackageMeasurementReceiver"
e "com.google.android.gms/com.google.android.gms.feedback.FeedbackAsyncService"
e "com.google.android.gms/com.google.android.gms.feedback.LegacyBugReportService"
e "com.google.android.gms/com.google.android.gms.feedback.OfflineReportSendTaskService"
e "com.google.android.gms/com.google.android.gms.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"
e "com.google.android.gms/com.google.android.gms.locationsharingreporter.service.reporting.periodic.PeriodicReporterMonitoringService"
e "com.google.android.gms/com.google.android.gms.checkin.EventLogService"
e "com.google.android.gms/com.google.android.gms.magictether.logging.DailyMetricsLoggerService"
e "com.google.android.gms/com.google.android.gms.backup.component.FullBackupJobLoggerService"
e "com.google.android.gms/com.google.android.gms.common.download.DownloadWorkService"

# ── Cast ───────────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService"
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Isolated"
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Persistent"
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService"
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Isolated"
e "com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Persistent"
e "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService"
e "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Isolated"
e "com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Persistent"
e "com.google.android.gms/com.google.android.gms.cast.service.CastPersistentService_Persistent"
e "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService"
e "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Isolated"
e "com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Persistent"
e "com.google.android.gms/com.google.android.gms.chimera.CastPersistentBoundBrokerService"
e "com.google.android.gms/com.google.android.gms.cast.service.CastService"
e "com.google.android.gms/com.google.android.gms.cast.service.media.CastMediaService"
e "com.google.android.gms/com.google.android.gms.cast.service.session.CastSessionService"

# ── Discovery ──────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.nearby.messages.debug.DebugPokeService"
e "com.google.android.gms/com.google.android.gms.clearcut.debug.ClearcutDebugDumpService"
e "com.google.firebase.components.ComponentDiscoveryService"
e "com.google.android.gms/com.google.android.gms.nearby.discovery.service.DiscoveryService"
e "com.google.android.gms/com.google.mlkit.common.internal.MlKitComponentDiscoveryService"
e "com.google.android.gms/com.google.android.gms.mobiledataplan.service.MobileDataPlanService"

# ── Auth ───────────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolated"
e "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolate"
e "com.google.android.gms/com.google.android.gms.chimera.PersistentApiService_AuthAccountIsolated"
e "com.google.android.gms/com.google.android.gms.chimera.PersistentIntentOperationService_AuthAccountIsolated"
e "com.google.android.gms/com.google.android.gms.auth.api.credentials.credentialsapi.service.CredentialsApiService"
e "com.google.android.gms/com.google.android.gms.auth.api.identity.service.IdentityService"
e "com.google.android.gms/com.google.android.gms.auth.api.phone.service.SmsRetrieverApiService"
e "com.google.android.gms/com.google.android.gms.auth.api.signin.RevocationService"
e "com.google.android.gms/com.google.android.gms.auth.authzen.api.AuthzenAutofillSyncSetupService"
e "com.google.android.gms/com.google.android.gms.auth.cryptauth.cryptauthservice.CryptauthService"
e "com.google.android.gms/com.google.android.gms.auth.trustagent.GoogleTrustAgent"
e "com.google.android.gms/com.google.android.gms.auth.trustagent.ActiveUnlockTrustAgent"
e "com.google.android.gms/com.google.android.gms.trustagent.api.bridge.TrustAgentBridgeService"
e "com.google.android.gms/com.google.android.gms.trustagent.api.state.TrustAgentState"
e "com.google.android.gms/com.google.android.gms.trustagent.AuthenticatorService"

# ── Update & Core ──────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.auth.folsom.service.FolsomPublicKeyUpdateService"
e "com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"
e "com.google.android.gms/com.google.android.gms.icing.proxy.IcingInternalCorporaUpdateService"
e "com.google.android.gms/com.google.android.gms.instantapps.routing.DomainFilterUpdateService"
e "com.google.android.gms/com.google.android.gms.mobiledataplan.service.PeriodicUpdaterService"
e "com.google.android.gms/com.google.android.gms.phenotype.service.sync.PackageUpdateTaskService"
e "com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService"
e "com.google.android.gms/com.google.android.gms.update.SystemUpdateService"
e "com.google.android.gms/com.google.android.gms.update.UpdateFromSdCardService"
e "com.google.android.gms/com.google.android.gms.update.OtaSuggestionSummaryProvider"
e "com.google.android.gms/com.google.android.gms.chimera.PersistentBoundBrokerService"
e "com.google.android.gms/com.google.android.gms.chimera.GmsApiService"
e "com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService"
e "com.google.android.gms/com.google.android.gms.gmscompliance.service.GmsComplianceService"
e "com.google.android.gms/com.google.android.gms.chimera.GmsApiServiceNoInstantApps"
e "com.google.android.gms/com.google.android.gms.chimera.PersistentApiServiceNoInstantApps"
e "com.google.android.gms/com.google.android.gms.instantapps.service.InstantAppsService"
e "com.google.android.gms/com.google.android.gms.chimera.UiApiServiceNoInstantApps"
e "com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"

# ── Wear & Fitness ─────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.backup.wear.BackupSettingsListenerService"
e "com.google.android.gms/com.google.android.gms.dck.service.DckWearableListenerService"
e "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncAccountService"
e "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConfigService"
e "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConnectionService"
e "com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncMessageService"
e "com.google.android.gms/com.google.android.gms.fitness.wearables.WearableSyncService"
e "com.google.android.gms/com.google.android.gms.wearable.service.WearableControlService"
e "com.google.android.gms/com.google.android.gms.wearable.service.WearableService"
e "com.google.android.gms/com.google.android.gms.wearable.service.ListenerService"
e "com.google.android.gms/com.google.android.gms.wearables.settings.WearablesSyncService"
e "com.google.android.gms/com.google.android.gms.nearby.fastpair.service.WearableDataListenerService"
e "com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
e "com.google.android.gms/com.google.android.location.fused.wearable.GmsWearableListenerService"
e "com.google.android.gms/com.google.android.gms.mdm.services.MdmPhoneWearableListenerService"
e "com.google.android.gms/com.google.android.gms.tapandpay.wear.WearProxyService"
e "com.google.android.gms/com.google.android.gms.kids.chimera.KidsServiceProxy"
e "com.google.android.gms/com.google.android.gms.personalsafety.service.PersonalSafetyService"
e "com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
e "com.google.android.gms/com.google.android.gms.fitness.service.ble.FitBleBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.config.FitConfigBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.goals.FitGoalsBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.history.FitHistoryBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.internal.FitInternalBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.proxy.FitProxyBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.recording.FitRecordingBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.sensors.FitSensorsBroker"
e "com.google.android.gms/com.google.android.gms.fitness.service.sessions.FitSessionsBroker"
e "com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
e "com.google.android.gms/com.google.android.gms.fitness.sync.FitnessSyncAdapterService"
e "com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"
e "com.google.android.gms/com.google.android.gms.fitness.GoogleFitnessService"
e "com.google.android.gms/com.google.android.gms.fitness.service.FitnessSensorService"

# ── Nearby & Quick Share ───────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.nearby.bootstrap.service.NearbyBootstrapService"
e "com.google.android.gms/com.google.android.gms.nearby.connection.service.NearbyConnectionsAndroidService"
e "com.google.android.gms/com.google.android.gms.nearby.messages.service.NearbyMessagesService"
e "com.google.android.gms/com.google.location.nearby.direct.service.NearbyDirectService"
e "com.google.android.gms/com.google.android.gms.nearby.exposurenotification.service.ExposureNotificationService"
e "com.google.android.gms/com.google.android.gms.nearby.sharing.service.ShareSheetSessionService"

# ── Emergency ──────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyLocationService"
e "com.google.android.gms/com.google.android.gms.thunderbird.EmergencyPersistentService"
e "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalPersistentService"
e "com.google.android.gms/com.google.android.gms.enpromo.PromoInternalService"

# ── Security ───────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.security.safebrowsing.SafeBrowsingUpdateTaskService"
e "com.google.android.gms/com.google.android.gms.security.verifier.ApkUploadService"
e "com.google.android.gms/com.google.android.gms.security.verifier.InternalApkUploadService"
e "com.google.android.gms/com.google.android.gms.security.snet.SnetIdleTaskService"
e "com.google.android.gms/com.google.android.gms.security.snet.SnetNormalTaskService"
e "com.google.android.gms/com.google.android.gms.security.snet.SnetService"
e "com.google.android.gms/com.google.android.gms.tapandpay.security.StorageKeyCacheService"
e "com.google.android.gms/com.google.android.gms.droidguard.DroidGuardGcmTaskService"
e "com.google.android.gms/com.google.android.gms.pay.security.storagekey.service.StorageKeyCacheService"

# ── Wallet & Payments ──────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.wallet.service.PaymentsService"
e "com.google.android.gms/com.google.android.gms.pay.service.PayGrpcUiService"
e "com.google.android.gms/com.google.android.gms.wallet.notifications.WalletNotificationsService"
e "com.google.android.gms/com.google.android.gms.wallet.service.WalletGoogleServiceBroker"
e "com.google.android.gms/com.google.android.gms.tapandpay.hce.service.TpHceService"
e "com.google.android.gms/com.google.android.gms.tapandpay.gcmtask.TapAndPayGcmTaskService"
e "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.QuickAccessWalletService"
e "com.google.android.gms/com.google.android.gms.tapandpay.globalactions.WalletQuickAccessWalletService"
e "com.google.android.gms/com.google.android.gms.pay.gcmtask.PayGcmTaskService"
e "com.google.android.gms/com.google.android.gms.pay.hce.service.PayHceService"
e "com.google.android.gms/com.google.android.gms.pay.notifications.PayNotificationService"
e "com.google.android.gms/com.google.android.gms.wallet.service.PaymentService"
e "com.google.android.gms/com.google.android.gms.wallet.service.WalletGcmTaskService"

# ── Location (полный список — главный фикс) ────────────────────
e "com.google.android.gms/com.google.android.gms.geotimezone.GeoTimeZoneService"
e "com.google.android.gms/com.google.android.gms.location.geocode.GeocodeService"
e "com.google.android.gms/com.google.android.gms.deviceconnection.service.DeviceConnectionServiceBroker"
e "com.google.android.gms/com.google.android.gms.fido.fido2.pollux.CableAuthenticatorService"
e "com.google.android.gms/com.google.android.location.internal.GoogleLocationManagerService"
e "com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingService"
e "com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingSettingInjectorService"
e "com.google.android.gms/com.google.android.gms.places.PlaceDetectionService"
e "com.google.android.gms/com.google.android.gms.persistent.offnetwork.service.OffNetworkService"
e "com.google.android.gms/com.google.android.gms.geofence.GeofenceApiService"
e "com.google.android.gms/com.google.android.location.geofencer.service.GeofenceProviderService"
e "com.google.android.gms/com.google.android.location.fused.FusedLocationService"
e "com.google.android.gms/com.google.android.location.internal.server.GoogleLocationService"
e "com.google.android.gms/com.google.android.location.internal.server.HardwareArProviderService"
e "com.google.android.gms/com.google.android.location.network.NetworkLocationService"
e "com.google.android.gms/com.google.android.location.persistent.LocationPersistentService"
e "com.google.android.gms/com.google.android.location.reporting.service.LocationHistoryInjectorService"
e "com.google.android.gms/com.google.android.location.reporting.service.ReportingAndroidService"
e "com.google.android.gms/com.google.android.location.reporting.service.ReportingSyncService"
e "com.google.android.gms/com.google.android.location.util.LocationAccuracyInjectorService"
e "com.google.android.gms/com.google.android.gms.semanticlocation.service.SemanticLocationService"
e "com.google.android.gms/com.google.android.gms.location.reporting.service.GcmBroadcastReceiver"

# ── Games ──────────────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.games.chimera.GamesSignInIntentServiceProxy"
e "com.google.android.gms/com.google.android.gms.games.chimera.GamesSyncServiceNotificationProxy"
e "com.google.android.gms/com.google.android.gms.games.chimera.GamesUploadServiceProxy"
e "com.google.android.gms/com.google.android.gms.gp.gameservice.GameService"
e "com.google.android.gms/com.google.android.gms.gp.gameservice.GameSessionService"

# ── Sync & Cloud ───────────────────────────────────────────────
e "com.google.android.gms/com.google.android.gms.auth.authzen.api.AuthzenAutofillSyncSetupService"
e "com.google.android.gms/com.google.android.gms.chromesync.sync.BackendMeetingPointService"
e "com.google.android.gms/com.google.android.gms.backup.component.BackupSnapshotService"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] GhostGMS Uninstall completed" >> "$LOGFILE"

# Cleanup
rm -rf "/data/local/tmp/ghostgms_config" 2>/dev/null
sleep 5
rm -f "$0"