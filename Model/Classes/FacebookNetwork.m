//
//  Facebook.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookNetwork.h"
#import "SNDefines.h"


@interface FacebookNetwork ()
- (void)sendToFacebook;

@end

@implementation FacebookNetwork

- (void)postMessage {

    facebook = [[Facebook alloc] initWithAppId:self.token andDelegate:self];

    EmployeeAppDelegate *appDelegate = (EmployeeAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.facebook = facebook;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }

    if (![facebook isSessionValid]) {
        [facebook authorize:[NSArray arrayWithObjects:@"publish_stream", nil]];
    } else {
        [self performSelector:@selector(sendToFacebook) withObject:nil afterDelay:0.1];
    }

}

- (void)sendToFacebook
{
    Log(@"sending to facebook...");

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            self.link, @"link",
            self.picture, @"picture",
            self.messageName, @"name",
            self.messageCaption, @"caption",
            self.post, @"message",
            self.messageDescription, @"description",
            nil];


    [facebook requestWithGraphPath:@"me/feed"
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:self];

//	[facebook dialog:@"feed" andParams:params andDelegate:self];
}


- (void)dealloc {
    [facebook release];
    [super dealloc];
}

- (void)fbDidLogin
{
    Log(@"fbDidLogin");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];

    [self sendToFacebook];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    Log(@"fbDidNotLogin");

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", @"Error!")
                                                        message:NSLocalizedString(@"Could not login to Facebook", @"Could not login to Facebook") delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    Log(@"fbDidExtendToken: %@ %@", accessToken, expiresAt);
}

- (void)fbSessionInvalidated {
    Log(@"--");
}

- (void)fbDidLogout
{
    Log(@"fbDidLogout");
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    Log(@"request did load: %@", result);

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Done!", @"Done!")
                                                        message:NSLocalizedString(@"Facebook sharing successful", @"Facebook sharing successful") delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    Log(@"Facebook error: %@", error);

    if ([[[error.userInfo objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
        Log(@"OAuthException - relogin...");
        [facebook authorize:[NSArray arrayWithObjects:@"publish_stream", nil]];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error sharing to facebook", @"Error sharing to facebook")
                                                            message:error.localizedDescription delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void)dialogDidComplete:(FBDialog *)dialog
{
    Log(@"dialogDidComplete: %@", dialog);
}

- (void) dialogCompleteWithUrl:(NSURL*) url
{
    Log(@"<FBDialogDelegate>.dialogDidCompleteWithURL: %@", url);

    if ([url.absoluteString rangeOfString:@"post_id="].location != NSNotFound) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Done!", @"Done!")
                                                            message:NSLocalizedString(@"Facebook sharing successful", @"Facebook sharing successful") delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void) dialogDidNotComplete:(FBDialog*) dialog
{
    Log(@"<FBDialogDelegate>.dialogDidNotComplete: %@", dialog);
}

- (void)dialogDidNotCompleteWithUrl:(NSURL*) url
{
    Log(@"<FBDialogDelegate>.dialogDidNotCompleteWithUrl: %@", url);
}


- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*) error
{
    Log(@"<FBDialogDelegate>.didFailWithError: %@", dialog);

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error sharing to facebook", @"Error sharing to facebook")
                                                        message:error.localizedDescription delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
