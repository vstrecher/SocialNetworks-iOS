//
//  Facebook.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookNetwork.h"
#import "SNDefines.h"
#import "SNFastMessage.h"


@interface FacebookNetwork ()
- (NSString *)sharingURL;
- (void)sendToFacebook;
@end

@implementation FacebookNetwork

- (void)postMessage {

    if ( self.fullVersion ) {
        [self getFacebookInstance];

        if (![facebook isSessionValid]) {
            [facebook authorize:[NSArray arrayWithObjects:@"publish_stream", nil]];
        } else {
            [self performSelector:@selector(sendToFacebook) withObject:nil afterDelay:0.1];
        }
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self sharingURL], self.link]]];
    }

}

- (BOOL)isLogged {
    if ( self.fullVersion ) {
        [self getFacebookInstance];
        return facebook.isSessionValid;
    }

    return NO;
}


- (void)login {
    if ( self.fullVersion ) {
        [self getFacebookInstance];

        if ( facebook.isSessionValid ) {
            [super loginDidSucceeded];
        } else {
            [self setIsLoginAction:YES];
            [facebook authorize:[NSArray arrayWithObject:@"publish_stream"]];
        }
    }
}

- (void)logout {
    if ( self.fullVersion ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:kFBDefaultsAccessToken];
        [defaults removeObjectForKey:kFBDefaultsExpirationDate];
        [self getFacebookInstance];
        [facebook logout];
    }
}

- (void)getFacebookInstance {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    facebook = [appDelegate valueForKey:@"facebook"];
    if ( ! facebook ) {
        facebook = [[Facebook alloc] initWithAppId:self.token andDelegate:self];
        [appDelegate setValue:facebook forKey:@"facebook"];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kFBDefaultsAccessToken] && [defaults objectForKey:kFBDefaultsExpirationDate]) {
        facebook.accessToken = [defaults objectForKey:kFBDefaultsAccessToken];
        facebook.expirationDate = [defaults objectForKey:kFBDefaultsExpirationDate];
    }
}

- (NSString *)sharingURL {
    return @"http://facebook.com/sharer.php?u=";
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
    [defaults setObject:[facebook accessToken] forKey:kFBDefaultsAccessToken];
    [defaults setObject:[facebook expirationDate] forKey:kFBDefaultsExpirationDate];
    [defaults synchronize];

    if ( self.isLoginAction) {
        [self setIsLoginAction:NO];
        [super loginDidSucceeded];
        return;
    }

    [self sendToFacebook];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    Log(@"fbDidNotLogin");

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Ошибка")
                                                        message:NSLocalizedString(@"Не удалось войти в Facebook.", @"Could not login to Facebook") delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];

    [super loginDidFail];
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
    [SNFastMessage showFastMessageWithTitle:NSLocalizedString(@"Facebook", @"Facebook")
                                    message:NSLocalizedString(@"Вы успешно вышли из сети.", @"Вы успешно вышли из сети.")];
    [super logoutDidSucceeded];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    Log(@"request did load: %@", result);

    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook", @"Facebook")
                                                        message:NSLocalizedString(@"Запись успешно опубликована!", @"Запись успешно опубликована!") delegate:nil
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
        Log(@"%@", error.localizedDescription);
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Error sharing to facebook")
                                                            message:NSLocalizedString(@"Не удалось опубликовать запись.", @"Не удалось опубликовать запись.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
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
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook", @"Facebook")
                                                            message:NSLocalizedString(@"Запись успешно опубликована!", @"Запись успешно опубликована!") delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

    Log(@"%@", error.localizedDescription);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Error sharing to facebook")
                                                        message:NSLocalizedString(@"Не удалось опубликовать запись.", @"Не удалось опубликовать запись.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
