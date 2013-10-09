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
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

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
    
    [self postMessage: messageToPost];
}


- (void)postMessage:(NSString *)message
{
    NSDictionary *params;
    ACAccountStore *accountStore;
    ACAccountType *twitterAccountType;
    NSURL *requestURL;
    
    if ( self.fullVersion )
    {
        params = @{@"status": message};
        
        requestURL = [NSURL URLWithString: [self twitterApiURL]];
        
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
                        NSError *jsonError;
                        NSDictionary *responceJson, *responceError;
                        NSArray *responceErrors;
                        NSString *errorMessage;
                        BOOL successSend = NO;
                        
                        @try {
                            if(error == nil) {
                                responceJson = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                                
                                Log(@"Responce from twitter api: [%@]", responceJson);
                                
                                responceErrors = [responceJson objectForKey: @"errors"];
                                responceError = responceErrors.lastObject;
                                errorMessage = [responceError objectForKey: @"message"];
                                
                                if(errorMessage == nil) {
                                    successSend = YES;
                                }
                                else {
                                    [self tweetFailedWithError: [NSError errorWithDomain: errorMessage code:0 userInfo:nil]];
                                }
                            }
                            else {
                                [self tweetFailedWithError: error];
                            }
                            
                            if(successSend == YES) {
                                [self tweetSent];
                            }
                        }
                        @catch (NSException *exception) {
                            Log(@"Exception when process twitter responce : %@", exception);
                            [self tweetFailedWithError: [NSError errorWithDomain: SN_T(@"kSNUnknownErrorTag", @"Неизвестная ошибка") code:0 userInfo:nil]];
                        }
                    }];
                }
                else {
                    Log(@"Twitter account not set");
                    [self tweetFailedWithError: [NSError errorWithDomain: SN_T(@"kSNTwitterAccountNotSetTag", @"Не настроен не один аккаунт в twitter") code:0 userInfo:nil]];
                }
            }
            else {
                [self tweetFailedWithError: [NSError errorWithDomain: SN_T(@"kSNTwitterAccountAccessFailTag", @"Ошибка доступа к аккаунтам twitter") code:0 userInfo:nil]];
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

- (NSString *) twitterApiURL {
    return @"http://api.twitter.com/1.1/statuses/update.json";
}

- (NSString *)sharingURL {
    return @"https://twitter.com/share?url=";
}

#pragma mark - TwitterVC Delegate

- (void)tweetSent {
    Log(@"twit sent");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNTwitterTitle", @"Twitter") message: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
    });
    
    if([self.delegate respondsToSelector: @selector(postMessageSucceeded:)] == YES) {
        [self.delegate postMessageSucceeded: self];
    }
}

- (void)tweetFailedWithError:(NSError *)error {
    Log(@"twit failed: %@", error);
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка") message:[error domain]];
    });
}

- (void)tweetCancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}


@end
