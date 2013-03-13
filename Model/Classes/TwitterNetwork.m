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

    NSString *clippedPost = [self _clipString: aPost
                                           to: 100];

    NSString *messageToPost = [NSString stringWithFormat: @"%@ %@",
                                                          clippedPost,
                                                          aLink];
    [self postMessage: messageToPost];
}


- (void)postMessage:(NSString *)message
{
    if ( self.fullVersion )
    {
        TwitterVC *twitterVC = [[TwitterVC alloc] init];
        twitterVC.delegate = self;
        twitterVC.consumerKey = self.token;
        twitterVC.consumerSecret = self.secret;

        [twitterVC sendMessage: message];

        if ( ! [twitterVC hasSession] )
        {
            twitterVC.modalPresentationStyle = UIModalPresentationPageSheet;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys: twitterVC, NOTIFICATION_VIEW_CONTROLLER, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName: SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object: nil userInfo: userInfo];
            [userInfo release];
        }

        [twitterVC release];
    }
    else
    {
        NSString *sUrl = [NSString stringWithFormat: @"%@%@&text=%@", [self sharingURL], self.link, [message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        Log(@"tweeting %@", sUrl);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: sUrl]];
    }
}

- (NSString *)sharingURL {
    return @"https://twitter.com/share?url=";
}

#pragma mark - TwitterVC Delegate

- (void)tweetSent {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    Log(@"twit sent");
    [SNFastMessage showFastMessageWithTitle:@"Twitter" message:@"Запись успешно опубликована!"];
}

- (void)tweetFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    Log(@"twit failed: %@", error);
    [SNFastMessage showFastMessageWithTitle:@"Error" message:[error localizedDescription]];

}

- (void)tweetCancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}


@end
