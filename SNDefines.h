//
//  SNDefines.h
//  Employees
//
//  Created by Eugene Dymov on 02/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Log
#define Log(fmt, ...) NSLog((@"%s %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

// Socials Config XML Defines
#define APP_DELEGATE_CONFIG_XML_PATH_PROPERTY_NAME @"pathForSocialSharingConfigXML"
// need for localize token from framework
#define APP_DELEGATE_TOKEN_FOR_SN @"tokenForSocialNetwork:"
#define CONFIG_FILE_NAME @"SocialsConfig"
#define CONFIG_FILE_EXTENSION @"xml"
#define CONFIG_EMAIL_TYPE @"Email"
#define CONFIG_FACEBOOK_TYPE @"Facebook"
#define CONFIG_TWITTER_TYPE @"Twitter"
#define CONFIG_VK_TYPE @"Vkontakte"
#define CONFIG_ODNOKLASSNIKI_TYPE @"Odnoklassniki"
#define CONFIG_NETWORKS @"networks"
#define CONFIG_NETWORK @"network"
#define CONFIG_TYPE @"type"
#define CONFIG_NAME @"name"
#define CONFIG_SUBJECT @"subject"
#define CONFIG_POST @"post"
#define CONFIG_TOKEN @"token"
#define CONFIG_SECRET @"secret"
#define CONFIG_LINK @"link"
#define CONFIG_PICTURE @"picture"
#define CONFIG_MESSAGE_NAME @"messageName"
#define CONFIG_MESSAGE_CAPTION @"messageCaption"
#define CONFIG_MESSAGE_DESCIPTION @"messageDescription"

// Notifications
#define SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION @"ShowModalViewControllerNotification"
#define HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION @"HideModalViewControllerNotification"
#define NOTIFICATION_VIEW_CONTROLLER @"view-controller"
#define kNotificationNetworkLoginSuccessful @"NetworkLoginSuccessful"
#define kNotificationNetworkLoginError @"NetworkLoginError"
#define kNotificationNetworkLogoutSuccessful @"NetworkLogoutSuccessful"
#define kNotificationNetworkLogoutError @"NetworkLogoutError"

// Cross promo XML URL
#define XML_URL @"http://www.mts.ru/xmlapi/PlatformApplicationExport.ashx?platform=Apple%20iOS"

// VK
#define kVKDefaultsAccessToken @"VKAccessTokenKey"
#define kVKDefaultsExpirationDate @"VKExpirationDateKey"
#define kVKDefaultsUserId @"VKUserId"

#define kVKAccessTokenKey @"access_token"
#define kVKUserIdKey @"user_id"
#define kVKExpiresInKey @"expires_in"
#define kVKErrorKey @"error"
#define kVKResponseKey @"response"
#define kVKUploadURLKey @"upload_url"
#define kVKHashKey @"hash"
#define kVKPhotoKey @"photo"
#define kVKServerKey @"server"
#define kVKIdKey @"id"
#define kVKErrorMsgKey @"error_msg"
#define kVKErrorCode @"error_code"
#define kVKCaptchaSidKey @"captcha_sid"
#define kVKCaptchaImgKey @"captcha_img"
#define kVKRequestKey @"request"

#define kPhotosGetWallUploadServerURL(user_id, access_token) [NSString stringWithFormat:@"https://api.vk.com/method/photos.getWallUploadServer?owner_id=%@&access_token=%@", user_id, access_token]
#define kPhotosSaveWallPhotoURL(access_token, server, photo, hash) [NSString stringWithFormat:@"https://api.vk.com/method/photos.saveWallPhoto?access_token=%@&server=%@&photo=%@&hash=%@", access_token,server,photo,hash]
#define kWallPostURL(user_id, access_token, text, attachment) [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", user_id, access_token, text, attachment]

// FB
#define kFBDefaultsAccessToken @"FBAccessTokenKey"
#define kFBDefaultsExpirationDate @"FBExpirationDateKey"

// Localization
#define SN_T(key, string) [SNFastMessage localizedToken: (key) defaultValue: (string)]