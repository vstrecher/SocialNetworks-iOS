//
//  SNSocialNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNSocialNetwork.h"
#import "FacebookNetwork.h"
#import "VkontakteNetwork.h"
#import "SNSocialsXMLParser.h"
#import "SNDefines.h"
#import "TwitterNetwork.h"
#import "EmailNetwork.h"

@implementation SNSocialNetwork
@synthesize name;
@synthesize token;
@synthesize post;
@synthesize secret;
@synthesize logo;
@synthesize subject;
@synthesize link;
@synthesize picture;
@synthesize messageName;
@synthesize messageCaption;
@synthesize messageDescription;
@synthesize fullVersion = _fullVersion;
@synthesize isLoginAction = _isLoginAction;
@synthesize type = _type;
@synthesize permissions = _permissions;


static BOOL _presentWithNotification = NO;

- (void)dealloc {
    [name release];
    [token release];
    [post release];
    [secret release];
    [logo release];
    [subject release];
    [link release];
    [picture release];
    [messageName release];
    [messageCaption release];
    [messageDescription release];
    [_fullVersion release];
    [_type release];
    [_permissions release];
    [super dealloc];

}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@,%@,%@} %@", self.type, self.token, self.post, [super description]];

}

- (void)postMessage {
    NSLog(@"Posting to %@: %@", self.type, self.post);

}

- (BOOL)isLogged {
    return NO;
}

- (void)login {
    NSLog(@"Logging to %@", self.type);
}

- (void)logout {
    NSLog(@"Logging out %@", self.type);
}


- (void)loginDidSucceeded {
    Log(@"");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLoginSuccessful object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

- (void)loginDidFail {
    Log(@"");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLoginError object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

- (void)logoutDidSucceeded {
    Log(@"");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLogoutSuccessful object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

- (void)logoutDidFail {
    Log(@"");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLogoutError object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

#pragma mark - Instance Methods

+ (BOOL)presentWithNotification {
    return _presentWithNotification;
}

+ (void)setPresentWithNotification:(BOOL)withNotification {
    _presentWithNotification = withNotification;
}

+ (void)initiate {
    [[SNSocialsXMLParser instance] getNetworks];
}

+ (FacebookNetwork *)facebookNetwork {
    FacebookNetwork *facebookNetwork = (FacebookNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_FACEBOOK_TYPE];
    return facebookNetwork;
}

+ (VkontakteNetwork *)vkNetwork {
    VkontakteNetwork *vkontakteNetwork = (VkontakteNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_VK_TYPE];
    return vkontakteNetwork;
}

+ (TwitterNetwork *)twitterNetwork {
    TwitterNetwork *network = (TwitterNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_TWITTER_TYPE];
    return network;
}

+ (EmailNetwork *)emailNetwork {
    EmailNetwork *network = (EmailNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_EMAIL_TYPE];
    return network;
}

- (void)postMessage: (NSString *)aPost
               link: (NSString *)aLink
{
    NSLog(@"Posting to %@: %@ %@", self.type, aPost, aLink);
}


@end
