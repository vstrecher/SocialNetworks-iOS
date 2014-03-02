//
//  SNSocialNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SNSocialNetwork.h"
#import "FacebookNetwork.h"
#import "VkontakteNetwork.h"
#import "SNSocialsXMLParser.h"
#import "SNDefines.h"
#import "TwitterNetwork.h"
#import "EmailNetwork.h"
#import "SNFastMessage.h"

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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

- (void)postSLRequestWithParams: (NSDictionary *)params
                        options: (NSDictionary *)options
                 typeIdentifier: (NSString *) typeIdentifier
                    serviceType: (NSString *) serviceType {
    ACAccountStore *accountStore;
    ACAccountType *accountType;
    NSURL *requestURL;

    requestURL = [NSURL URLWithString: [self apiURL]];

    accountStore = [[[ACAccountStore alloc] init] autorelease];

    accountType = [accountStore accountTypeWithAccountTypeIdentifier: typeIdentifier];

    [accountStore requestAccessToAccountsWithType: accountType
                                          options: options
                                       completion: ^(BOOL granted, NSError *error) {
                                           NSArray *slAccounts;
                                           SLRequest *postRequest;

                                           if (granted) {
                                               slAccounts = [accountStore accountsWithAccountType:accountType];

                                               postRequest = [SLRequest requestForServiceType: serviceType requestMethod:  SLRequestMethodPOST URL: requestURL parameters:params];

                                               if([SLComposeViewController isAvailableForServiceType:serviceType]) {
                                                   postRequest.account = [slAccounts lastObject];

                                                   [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                       [self processResponse: responseData urlResponse: urlResponse error: error];
                                                   }];
                                               }
                                               else {
                                                   Log(@"SL account not set");
                                                   [self slRequestFailedWithError:
                                                           [NSError errorWithDomain:
                                                                   [NSString stringWithFormat: SN_T(@"kSNSLAccountNotSetTag", @"Не настроен не один аккаунт в %@"), self.type]  code:0 userInfo:nil]];
                                               }
                                           }
                                           else {
                                               Log(@"SL account access error");
                                               [self slRequestFailedWithError:
                                                       [NSError errorWithDomain:
                                                               [NSString stringWithFormat: SN_T(@"kSNSLAccountAccessFailTag", @"Ошибка доступа к аккаунтам %@"), self.type] code:0 userInfo:nil]];
                                           }
                                       }];
}

- (NSString *) apiURL {
    //
    return @"";
}

- (void) processResponse: (NSData *) responseData urlResponse: (NSHTTPURLResponse *)urlResponse error: (NSError *) error {
    //
}

- (void) slRequestSent {
    //
}

- (void) slRequestFailedWithError:(NSError *)error {
    Log(@"%@ request failed: %@", self.type, error);

    dispatch_async(dispatch_get_main_queue(), ^{
        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка") message:[error domain]];
    });
}

#endif


@end
