//
//  SNDefines.h
//  Employees
//
//  Created by Eugene Dymov on 02/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define Log(fmt, ...) NSLog((@"%s %d: " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// Socials Config XML Defines
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

// Cross promo XML URL
#define XML_URL @"http://www.mts.ru/xmlapi/PlatformApplicationExport.ashx?platform=Apple%20iOS"
