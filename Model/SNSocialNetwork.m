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
    [super dealloc];

}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@,%@,%@} %@", self.name, self.post, self.token, [super description]];

}

- (void)postMessage {
    NSLog(@"Posting to %@: %@", self.name, self.post);

}

- (BOOL)isLogged {
    return NO;
}

- (void)login {
    NSLog(@"Logging to %@", self.name);
}

- (void)loginDidSucceeded {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLoginSuccessful object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

- (void)loginDidFail {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkLoginError object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.type, @"type", nil]];
}

#pragma mark - Instance Methods

+ (FacebookNetwork *)facebookNetwork {
    FacebookNetwork *facebookNetwork = (FacebookNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_FACEBOOK_TYPE];
    return facebookNetwork;
}

+ (VkontakteNetwork *)vkNetwork {
    VkontakteNetwork *vkontakteNetwork = (VkontakteNetwork *) [[SNSocialsXMLParser instance] getNetworkWithType:CONFIG_VK_TYPE];
    return vkontakteNetwork;
}

@end
