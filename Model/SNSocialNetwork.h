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


+ (FacebookNetwork *)facebookNetwork;
+ (VkontakteNetwork *)vkNetwork;

- (void)postMessage;
- (BOOL)isLogged;
- (void)login;
- (void)loginDidSucceeded;
- (void)loginDidFail;


@end
