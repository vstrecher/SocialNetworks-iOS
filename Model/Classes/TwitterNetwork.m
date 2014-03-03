//
//  TwitterNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterNetwork.h"
#import "SNFastMessage.h"
#import "SNDefines.h"
#import <Accounts/Accounts.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#import <Twitter/Twitter.h>
#else
#import <Social/Social.h>
#endif

@interface TwitterNetwork ()
- (NSString *)sharingURL;

@end

@implementation TwitterNetwork

- (void)postMessage
{
    [self postMessage: self.post];

}

- (NSString *)_clipString: (NSString *)string
                       to: (NSInteger)maxLength
{
    if ( string.length <= maxLength )
    {
        return string;
    }

    return [string substringWithRange: NSMakeRange(0, maxLength)];
}

- (void)postMessage: (NSString *)aPost
               link: (NSString *)aLink
{
    NSString *clippedPost;
    NSMutableString *messageToPost;
    NSInteger linkLenth = 0;
    
    if(aLink != nil) {
        linkLenth = aLink.length + 1;
    }
    
    clippedPost = [self _clipString: aPost to: MIN(140, aPost.length + linkLenth) - MIN(140, linkLenth)];

    messageToPost = [NSMutableString stringWithFormat: @"%@", clippedPost];
    
    if(aLink != nil) {
        [messageToPost appendFormat: @" %@", aLink];
    }
    
    Log(@"twit message: %@ (%d)", messageToPost, messageToPost.length);
    
    [self postMessage: messageToPost];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000  && __IPHONE_OS_VERSION_MIN_REQUIRED < 60000

- (void)postMessage:(NSString *)message
{
    NSDictionary *params;
    ACAccountStore *accountStore;
    ACAccountType *twitterAccountType;
    NSURL *requestURL;
    
    
    if ( self.fullVersion )
    {
        params = @{@"status": message};
        
        requestURL = [NSURL URLWithString: [self apiURL]];
        
        accountStore = [[[ACAccountStore alloc] init] autorelease];
        
        twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAccountType
                                withCompletionHandler:^(BOOL granted, NSError *error) {
                                    NSArray *twitterAccounts;
                                    TWRequest *postRequest;
                                    
                                    if (granted) {
                                        twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
                                        
                                        postRequest = [[[TWRequest alloc]initWithURL: requestURL parameters: params requestMethod: TWRequestMethodPOST] autorelease];
                                        
                                        if([TWTweetComposeViewController canSendTweet] == YES) {
                                            postRequest.account = [twitterAccounts lastObject];
                                            
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
    else
    {
        NSString *sUrl = [NSString stringWithFormat: @"%@%@&text=%@", [self sharingURL], self.link, [message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        Log(@"tweeting %@", sUrl);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: sUrl]];
    }
}

#else

- (void)postMessage:(NSString *)message
{
    NSDictionary *params;

    if ( self.fullVersion ) {
        params = @{@"status": message};
        [self postSLRequestWithParams: params options: nil typeIdentifier: ACAccountTypeIdentifierTwitter serviceType: SLServiceTypeTwitter];
    }
    else {
        NSString *sUrl = [NSString stringWithFormat: @"%@%@&text=%@", [self sharingURL], self.link, [message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        Log(@"tweeting %@", sUrl);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: sUrl]];
    }
}

- (NSString *) apiURL {
    return @"https://api.twitter.com/1.1/statuses/update.json";
}

#endif

- (void) processResponse: (NSData *) responseData urlResponse: (NSHTTPURLResponse *)urlResponse error: (NSError *) error {
    NSError *jsonError;
    NSDictionary *responceJson, *responceError;
    NSArray *responceErrors;
    NSString *errorMessage = nil;
    BOOL successSend = NO;
    
    @try {
        if(error == nil) {
            responceJson = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
            
            Log(@"Responce from twitter api: [%@]", responceJson);
            
            if(responceJson != nil) {
                responceErrors = [responceJson objectForKey: @"errors"];
                responceError = responceErrors.lastObject;
                errorMessage = [responceError objectForKey: @"message"];
                
                if(errorMessage == nil) {
                    successSend = YES;
                }
                else {
                    [self slRequestFailedWithError: [NSError errorWithDomain: errorMessage code:0 userInfo:nil]];
                }
            }
            else {
                [self slRequestFailedWithError: [NSError errorWithDomain: SN_T(@"kSNUnknownErrorTag", @"Неизвестная ошибка") code:0 userInfo:nil]];
            }
        }
        else {
            [self slRequestFailedWithError: error];
        }
        
        if(successSend) {
            [self slRequestSent];
        }
    }
    @catch (NSException *exception) {
        Log(@"Exception when process twitter responce : %@", exception);
        [self slRequestFailedWithError: [NSError errorWithDomain: SN_T(@"kSNUnknownErrorTag", @"Неизвестная ошибка") code:0 userInfo:nil]];
    }
}

- (NSString *)sharingURL {
    return @"https://twitter.com/share?url=";
}

#pragma mark - TwitterVC Delegate

- (void) slRequestSent {
    Log(@"%@ request sent", self.type);

    dispatch_async(dispatch_get_main_queue(), ^{
        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNTwitterTitle", @"Twitter") message: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
    });

    if([self.delegate respondsToSelector: @selector(postMessageSucceeded:)]) {
        [self.delegate postMessageSucceeded: self];
    }
}

@end
