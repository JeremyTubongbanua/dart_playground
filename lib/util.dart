import 'dart:io';

import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_utils/at_utils.dart';
import 'package:dart_playground/service_factories.dart';
import 'package:version/version.dart';

// Get the home directory or null if unknown.
String? getHomeDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'];
    case 'windows':
      return Platform.environment['USERPROFILE'];
    case 'android':
      // Probably want internal storage.
      return '/storage/sdcard0';
    case 'ios':
      // iOS doesn't really have a home directory.
      return null;
    case 'fuchsia':
      // I have no idea.
      return null;
    default:
      return null;
  }
}

String? getAtKeysFilePath(final String atSign) {
  final String formattedAtSign = AtUtils.fixAtSign(atSign);
  return '${getHomeDirectory()}/.atsign/keys/${formattedAtSign}_key.atKeys';
}

AtOnboardingPreference generatePreference(
    final String atSign, final String? namespace) {
  AtOnboardingPreference pref = AtOnboardingPreference()
    ..atKeysFilePath = getAtKeysFilePath(atSign)
    ..namespace = namespace
    ..atProtocolEmitted = Version(2, 0, 0)
    ..isLocalStoreRequired = true
    ..commitLogPath = '${getHomeDirectory()}/.atsign/temp/$atSign/commitlog'
    ..downloadPath = '${getHomeDirectory()}/.atsign/temp/$atSign/download'
    ..hiveStoragePath = '${getHomeDirectory()}/.atsign/temp/$atSign/hive'
    ..rootDomain = 'root.atsign.org'
    ..rootPort = 64
    ..fetchOfflineNotifications = false
    ;
  return pref;
}

Future<AtClient> onboard(final String atSign) async  {
  final AtOnboardingPreference pref = generatePreference(atSign, null);
  final AtOnboardingServiceImpl onboardingService = AtOnboardingServiceImpl(atSign, pref, atServiceFactory: ServiceFactoryWithNoOpSyncService());
  bool success = await onboardingService.authenticate();
  if(success) {
    return onboardingService.atClient!;
  } else {
    throw Exception('Failed to onboard $atSign');
  }
}