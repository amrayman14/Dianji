import 'package:booking_system_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'common.dart';
import 'configs.dart';

//region Get Configurations

bool get isCurrencyPositionLeft => appConfigurationStore.currencyPosition == CURRENCY_POSITION_LEFT;

bool get isCurrencyPositionRight => appConfigurationStore.currencyPosition == CURRENCY_POSITION_RIGHT;

//endregion

//region Set Configurations
Future<void> setAppConfigurations(AppConfigurationModel data) async {
  await setValue(SITE_NAME, data.siteName);
  await setValue(SITE_DESCRIPTION, data.siteDescription);
  await setValue(SITE_COPYRIGHT, data.siteCopyright);
  await setValue(WEBSITE, data.website);
  appConfigurationStore.setInquiryEmail(data.inquiryEmail.validate());
  appConfigurationStore.setHelplineNumber(data.helplineNumber.validate());
  await setValue(DATE_FORMAT, getDateFormat(data.dateFormat.validate()));
  await setValue(TIME_FORMAT, getDisplayTimeFormat(data.timeFormat.validate()));
  await setValue(TIMEZONE, data.timeZone);
  await setValue(DISTANCE_TYPE, data.distanceType);

  await setValue(CUSTOMER_APP_STORE_URL, data.appstoreUrl.validate());
  await setValue(CUSTOMER_PLAY_STORE_URL, data.playStoreUrl.validate());
  await setValue(PROVIDER_PLAY_STORE_URL, data.providerPlayStoreUrl.validate());
  await setValue(PROVIDER_APPSTORE_URL, data.providerAppstoreUrl.validate());

  await appConfigurationStore.setCurrencyCode(data.currencyCode.validate());
  await appConfigurationStore.setCurrencyPosition(data.currencyPosition.validate());
  await appConfigurationStore.setCurrencySymbol(data.currencySymbol.validate());
  await appConfigurationStore.setPriceDecimalPoint(data.decimalPoint.toInt());

  await appConfigurationStore.setAdvancePaymentAllowed(data.advancePaymentStatus.validate().getBoolInt());
  await appConfigurationStore.setSlotServiceStatus(data.slotServiceStatus.validate().getBoolInt());
  await appConfigurationStore.setDigitalServiceStatus(data.digitalServiceStatus.validate().getBoolInt());
  await appConfigurationStore.setServicePackageStatus(data.servicePackageStatus.validate().getBoolInt());
  await appConfigurationStore.setServiceAddonStatus(data.serviceAddonStatus.validate().getBoolInt());
  await appConfigurationStore.setJobRequestStatus(data.jobRequestServiceStatus.validate().getBoolInt());

  await appConfigurationStore.setSocialLoginStatus(data.socialLoginStatus.validate().getBoolInt());
  await appConfigurationStore.setGoogleLoginStatus(data.googleLoginStatus.validate().getBoolInt());
  await appConfigurationStore.setAppleLoginStatus(data.appleLoginStatus.validate().getBoolInt());
  await appConfigurationStore.setOTPLoginStatus(data.otpLoginStatus.validate().getBoolInt());

  await appConfigurationStore.setOnlinePaymentStatus(data.onlinePaymentStatus.getBoolInt());
  await appConfigurationStore.setBlogStatus(data.blogStatus.validate().getBoolInt());
  await appConfigurationStore.setMaintenanceModeStatus(data.maintenanceMode.validate().getBoolInt());
  await appConfigurationStore.setEnableUserWallet(data.walletStatus.validate().getBoolInt());
  await appConfigurationStore.setChatGptStatus(data.chatGptStatus.validate().getBoolInt());
  await appConfigurationStore.setTestWithoutKey(data.testChatGptWithoutKey.validate().getBoolInt());

  await setValue(FORCE_UPDATE_USER_APP, data.forceUpdateUserApp);
  await setValue(USER_APP_MINIMUM_VERSION, data.userAppMinimumVersion);
  await setValue(USER_APP_LATEST_VERSION, data.userAppLatestVersion);

  await setValue(FACEBOOK_URL, data.facebookUrl.validate());
  await setValue(INSTAGRAM_URL, data.instagramUrl.validate());
  await setValue(TWITTER_URL, data.twitterUrl.validate());
  await setValue(LINKEDIN_URL, data.linkedinUrl.validate());
  await setValue(YOUTUBE_URL, data.youtubeUrl.validate());

  await appConfigurationStore.setPrivacyPolicy(data.privacyPolicy ?? PRIVACY_POLICY_URL);
  await appConfigurationStore.setTermConditions(data.termsConditions ?? TERMS_CONDITION_URL);
  await appConfigurationStore.setHelpAndSupport(data.helpAndSupport ?? HELP_AND_SUPPORT_URL);
  await appConfigurationStore.setRefundPolicy(data.refundPolicy ?? REFUND_POLICY_URL);

  appConfigurationStore.setGoogleMapKey(data.googleMapKey.validate());

  /// Place ChatGPT Key Here
  if (data.chatGptKey.validate().isNotEmpty) {
    chatGPTAPIkey = data.chatGptKey!;
  }
  appConfigurationStore.setFirebaseKey(data.firebaseKey.validate());

  setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, DateTime.timestamp().millisecondsSinceEpoch);
  await setValue(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE, true);
}
//endregion

// region Shared Preference Keys
const DISTANCE_TYPE = 'DISTANCE_TYPE';
const TIMEZONE = 'TIMEZONE';
const PRIVACY_POLICY = 'PRIVACY_POLICY';
const TERM_CONDITIONS = 'TERM_CONDITIONS';
const HELP_AND_SUPPORT = 'HELP_AND_SUPPORT';
const REFUND_POLICY = 'REFUND_POLICY';
const INQUIRY_EMAIL = 'INQUIRY_EMAIL';
const HELPLINE_NUMBER = 'HELPLINE_NUMBER';
const IN_MAINTENANCE_MODE = 'IN_MAINTENANCE_MODE';
const CURRENCY_POSITION = 'CURRENCY_POSITION';
const PRICE_DECIMAL_POINTS = 'PRICE_DECIMAL_POINTS';
const ENABLE_USER_WALLET = 'ENABLE_USER_WALLET';
const CURRENCY_COUNTRY_SYMBOL = 'CURRENCY_COUNTRY_SYMBOL';
const CURRENCY_COUNTRY_CODE = 'CURRENCY_COUNTRY_CODE';

const SOCIAL_LOGIN_STATUS = 'SOCIAL_LOGIN';
const GOOGLE_LOGIN_STATUS = 'GOOGLE_LOGIN';
const APPLE_LOGIN_STATUS = 'APPLE_LOGIN';
const OTP_LOGIN_STATUS = 'OTP_LOGIN';
const ONLINE_PAYMENT_STATUS = 'ONLINE_PAYMENT_STATUS';
const BLOG_STATUS = 'BLOG';
const SLOT_SERVICE_STATUS = 'SLOT_SERVICE_STATUS';
const DIGITAL_SERVICE_STATUS = 'DIGITAL_SERVICE_STATUS';
const SERVICE_PACKAGE_STATUS = 'SERVICE_PACKAGE_STATUS';
const SERVICE_ADDON_STATUS = 'SERVICE_ADDON_STATUS';
const JOB_REQUEST_SERVICE_STATUS = 'JOB_REQUEST_SERVICE_STATUS';
const CHAT_GPT_STATUS = 'CHAT_GPT_STATUS';
const TEST_CHAT_GPT_WITHOUT_KEY = 'TEST_CHAT_GPT_WITHOUT_KEY';

const CUSTOMER_APP_STORE_URL = 'APPSTORE_URL';
const CUSTOMER_PLAY_STORE_URL = 'PLAY_STORE_URL';
const PROVIDER_PLAY_STORE_URL = 'PROVIDER_PLAY_STORE_URL';
const PROVIDER_APPSTORE_URL = 'PROVIDER_APPSTORE_URL';

const FORCE_UPDATE_USER_APP = 'FORCE_UPDATE_USER_APP';
const USER_APP_MINIMUM_VERSION = 'USER_APP_MINIMUM_VERSION';
const USER_APP_LATEST_VERSION = 'USER_APP_LATEST_VERSION';

const IS_ADVANCE_PAYMENT_ALLOWED = 'IS_ADVANCE_PAYMENT_ALLOWED';

const DATE_FORMAT = 'DATE_FORMAT';
const TIME_FORMAT = 'TIME_FORMAT';
const SITE_DESCRIPTION = 'SITE_DESCRIPTION';
const SITE_COPYRIGHT = 'SITE_COPYRIGHT';
const SITE_NAME = 'SITE_NAME';
const WEBSITE = 'WEBSITE';

const FACEBOOK_URL = 'FACEBOOK_URL';
const INSTAGRAM_URL = 'INSTAGRAM_URL';
const TWITTER_URL = 'TWITTER_URL';
const LINKEDIN_URL = 'LINKEDIN_URL';
const YOUTUBE_URL = 'YOUTUBE_URL';

//endregion

//region Models

class AppConfigurationModel {
  String? siteName;
  String? siteDescription;
  String? inquiryEmail;
  String? helplineNumber;
  String? website;
  String? zipcode;
  String? siteCopyright;
  String? dateFormat;
  String? timeFormat;
  String? timeZone;
  String? distanceType;
  String? radius;
  String? playStoreUrl;
  String? appstoreUrl;
  String? providerAppstoreUrl;
  String? providerPlayStoreUrl;
  String? currencyCode;
  String? currencyPosition;
  String? currencySymbol;
  String? decimalPoint;
  String? googleMapKey;
  int? advancePaymentStatus;
  int? slotServiceStatus;
  int? digitalServiceStatus;
  int? servicePackageStatus;
  int? serviceAddonStatus;
  int? jobRequestServiceStatus;
  int? socialLoginStatus;
  int? googleLoginStatus;
  int? appleLoginStatus;
  int? otpLoginStatus;
  int? onlinePaymentStatus;
  int? blogStatus;
  int? maintenanceMode;
  int? walletStatus;
  int? chatGptStatus;
  int? testChatGptWithoutKey;
  String? chatGptKey;
  int? forceUpdateUserApp;
  int? userAppMinimumVersion;
  int? userAppLatestVersion;
  int? firebaseNotificationStatus;
  String? firebaseKey;
  String? facebookUrl;
  String? linkedinUrl;
  String? instagramUrl;
  String? youtubeUrl;
  String? twitterUrl;
  String? termsConditions;
  String? privacyPolicy;
  String? helpAndSupport;
  String? refundPolicy;
  String? earningType;

  AppConfigurationModel.fromJsonMap(Map<String, dynamic> map)
      : siteName = map["site_name"],
        siteDescription = map["site_description"],
        inquiryEmail = map["inquiry_email"],
        helplineNumber = map["helpline_number"],
        website = map["website"],
        zipcode = map["zipcode"],
        siteCopyright = map["site_copyright"],
        dateFormat = map["date_format"],
        timeFormat = map["time_format"],
        timeZone = map["time_zone"],
        distanceType = map["distance_type"],
        radius = map["radius"],
        playStoreUrl = map["playstore_url"],
        appstoreUrl = map["appstore_url"],
        providerAppstoreUrl = map["provider_appstore_url"],
        providerPlayStoreUrl = map["provider_playstore_url"],
        currencyCode = map["currency_code"],
        currencyPosition = map["currency_position"],
        currencySymbol = map["currency_symbol"],
        decimalPoint = map["decimal_point"],
        googleMapKey = map["google_map_key"],
        advancePaymentStatus = map["advance_payment_status"],
        slotServiceStatus = map["slot_service_status"],
        digitalServiceStatus = map["digital_service_status"],
        servicePackageStatus = map["service_package_status"],
        serviceAddonStatus = map["service_addon_status"],
        jobRequestServiceStatus = map["job_request_service_status"],
        socialLoginStatus = map["social_login_status"],
        googleLoginStatus = map["google_login_status"],
        appleLoginStatus = map["apple_login_status"],
        otpLoginStatus = map["otp_login_status"],
        onlinePaymentStatus = map["online_payment_status"],
        blogStatus = map["blog_status"],
        maintenanceMode = map["maintenance_mode"],
        walletStatus = map["wallet_status"],
        chatGptStatus = map["chat_gpt_status"],
        testChatGptWithoutKey = map["test_chat_gpt_without_key"],
        chatGptKey = map["chat_gpt_key"],
        forceUpdateUserApp = map["force_update_user_app"],
        userAppMinimumVersion = map["user_app_minimum_version"],
        userAppLatestVersion = map["user_app_latest_version"],
        firebaseNotificationStatus = map["firebase_notification_status"],
        firebaseKey = map["firebase_key"],
        facebookUrl = map["facebook_url"],
        linkedinUrl = map["linkedin_url"],
        instagramUrl = map["instagram_url"],
        youtubeUrl = map["youtube_url"],
        twitterUrl = map["twitter_url"],
        termsConditions = map["terms_conditions"],
        privacyPolicy = map["privacy_policy"],
        earningType = map["earning_type"],
        helpAndSupport = map["help_Support"],
        refundPolicy = map["refund_policy"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['site_name'] = siteName;
    data['site_description'] = siteDescription;
    data['inquiry_email'] = inquiryEmail;
    data['helpline_number'] = helplineNumber;
    data['website'] = website;
    data['zipcode'] = zipcode;
    data['site_copyright'] = siteCopyright;
    data['date_format'] = dateFormat;
    data['time_format'] = timeFormat;
    data['time_zone'] = timeZone;
    data['distance_type'] = distanceType;
    data['radius'] = radius;
    data['playstore_url'] = playStoreUrl;
    data['appstore_url'] = appstoreUrl;
    data['provider_appstore_url'] = providerAppstoreUrl;
    data['provider_playstore_url'] = providerPlayStoreUrl;
    data['currency_code'] = currencyCode;
    data['currency_position'] = currencyPosition;
    data['currency_symbol'] = currencySymbol;
    data['decimal_point'] = decimalPoint;
    data['google_map_key'] = googleMapKey;
    data['advance_payment_status'] = advancePaymentStatus;
    data['slot_service_status'] = slotServiceStatus;
    data['digital_service_status'] = digitalServiceStatus;
    data['service_package_status'] = servicePackageStatus;
    data['service_addon_status'] = serviceAddonStatus;
    data['job_request_service_status'] = jobRequestServiceStatus;
    data['social_login_status'] = socialLoginStatus;
    data['google_login_status'] = googleLoginStatus;
    data['apple_login_status'] = appleLoginStatus;
    data['otp_login_status'] = otpLoginStatus;
    data['online_payment_status'] = onlinePaymentStatus;
    data['blog_status'] = blogStatus;
    data['maintenance_mode'] = maintenanceMode;
    data['wallet_status'] = walletStatus;
    data['chat_gpt_status'] = chatGptStatus;
    data['test_chat_gpt_without_key'] = testChatGptWithoutKey;
    data['chat_gpt_key'] = chatGptKey;
    data['force_update_user_app'] = forceUpdateUserApp;
    data['user_app_minimum_version'] = userAppMinimumVersion;
    data['user_app_latest_version'] = userAppLatestVersion;
    data['firebase_notification_status'] = firebaseNotificationStatus;
    data['firebase_key'] = firebaseKey;
    data['facebook_url'] = facebookUrl;
    data['linkedin_url'] = linkedinUrl;
    data['instagram_url'] = instagramUrl;
    data['youtube_url'] = youtubeUrl;
    data['twitter_url'] = twitterUrl;
    data['terms_conditions'] = termsConditions;
    data['privacy_policy'] = privacyPolicy;
    data['earning_type'] = earningType;
    data['help_support'] = helpAndSupport;
    data['refund_policy'] = refundPolicy;
    return data;
  }
}
//endregion
