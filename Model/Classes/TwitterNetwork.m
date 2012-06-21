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

- (void)postMessage {
    if ( self.fullVersion ) {
        TwitterVC *twitterVC = [[TwitterVC alloc] init];
        twitterVC.delegate = self;
        twitterVC.consumerKey = self.token;
        twitterVC.consumerSecret = self.secret;

        [twitterVC sendMessage:self.post];

        if (![twitterVC hasSession]) {
            twitterVC.modalPresentationStyle = UIModalPresentationPageSheet;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:twitterVC, NOTIFICATION_VIEW_CONTROLLER, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil userInfo:userInfo];
            [userInfo release];
        }

        [twitterVC release];
    } else {
        NSString *sUrl = [NSString stringWithFormat:@"%@%@&text=%@", [self sharingURL], self.link, [self.post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        Log(@"tweeting %@", sUrl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
    }

}

- (NSString *)sharingURL {
    return @"https://twitter.com/share?url=";
}

#pragma mark - TwitterVC Delegate

- (void)tweetSent {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    Log(@"twit sent");
    [SNFastMessage showFastMessageWithTitle:NSLocalizedString(@"Twit sent", @"Twit sent")];

}

- (void)tweetFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    Log(@"twit failed: %@", error);
    [SNFastMessage showFastMessageWithTitle:NSLocalizedString(@"Twit sending failed", @"Twit sending failed") message:[error localizedDescription]];

}

- (void)tweetCancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}


@end
