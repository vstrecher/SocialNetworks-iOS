//
//  SNSocialNetwork.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FacebookNetwork;
@class VkontakteNetwork;
@class TwitterNetwork;
@class EmailNetwork;
@class SNSocialNetwork;

@protocol SNSocialNetworkDelegate <NSObject>

- (void) postMessageSucceeded: (SNSocialNetwork *) snSocialNetwork;

@end

@interface SNSocialNetwork : NSObject {
@protected
    NSString *name;
    NSString *token;
    NSString *secret;
    NSString *subject;
    NSString *post;
    UIImage *logo;
    NSString *link;
    NSString *picture;
    NSString *messageName;
    NSString *messageCaption;
    NSString *messageDescription;
    NSString *_type;
    NSNumber *_fullVersion;
    NSString *_permissions;

    BOOL _isLoginAction;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *token;
@property(nonatomic, retain) NSString *post;
@property(nonatomic, retain) NSString *secret;
@property(nonatomic, retain) UIImage *logo;
@property(nonatomic, retain) NSString *subject;
@property(nonatomic, retain) NSString *link;
@property(nonatomic, retain) NSString *picture;
@property(nonatomic, retain) NSString *messageName;
@property(nonatomic, retain) NSString *messageCaption;
@property(nonatomic, retain) NSString *messageDescription;
@property(nonatomic, retain) NSNumber *fullVersion;
@property(nonatomic, assign) BOOL isLoginAction;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *permissions;

@property(nonatomic, assign) id <SNSocialNetworkDelegate> delegate;


+ (void)setPresentWithNotification:(BOOL)withNotification;
+ (BOOL)presentWithNotification;

+ (VkontakteNetwork *)vkNetwork;

+ (void)initiate;

+ (FacebookNetwork *)facebookNetwork;
+ (TwitterNetwork *)twitterNetwork;
+ (EmailNetwork *)emailNetwork;

- (void)postMessage: (NSString *)aPost
               link: (NSString *)aLink;
- (void)postMessage;
- (BOOL)isLogged;
- (void)login;
- (void)logout;
- (void)loginDidSucceeded;
- (void)loginDidFail;
- (void)logoutDidSucceeded;
- (void)logoutDidFail;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

- (void)postSLRequestWithParams: (NSDictionary *)params
                        options: (NSDictionary *)options
                 typeIdentifier: (NSString *) typeIdentifier
                    serviceType: (NSString *) serviceType;
- (NSString *) apiURL;
- (void) processResponse: (NSData *) responseData urlResponse: (NSHTTPURLResponse *)urlResponse error: (NSError *) error;
- (void) slRequestSent;
- (void) slRequestFailedWithError:(NSError *)error;

#endif

@end
