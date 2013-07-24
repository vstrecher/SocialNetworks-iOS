//
//  EmailSharing.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "EmailNetwork.h"
#import "SNFastMessage.h"
#import "SNDefines.h"

@implementation EmailNetwork

- (void)postMessage {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:self.subject];
    if ( self.fullVersion ) {
        id appDelegate = [[UIApplication sharedApplication] delegate];

        [controller setMessageBody:[appDelegate valueForKey:@"emailSharingHTMLString"]
                            isHTML:YES];
    } else {
        [controller setMessageBody:self.post
                            isHTML:NO];
    }


    if (controller) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:controller, NOTIFICATION_VIEW_CONTROLLER, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil userInfo:userInfo];
        [userInfo release];
    }

    [controller release];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNSuccessEmailSendTag", @"Email successfully sent")];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
}


@end
