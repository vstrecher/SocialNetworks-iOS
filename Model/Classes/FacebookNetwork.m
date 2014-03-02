//
//  Facebook.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "FacebookNetwork.h"
#import "SNDefines.h"
#import "SNFastMessage.h"


#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000

typedef void(^FacebookNetworkCompletionBlock_t)(NSError *error);

@interface FacebookNetwork () <FBSessionDelegate, FBDialogDelegate, FBRequestDelegate>
@property (nonatomic, copy) FacebookNetworkCompletionBlock_t authorizeCompletion;
- (void)getFacebookInstance;
- (void)sendToFacebookLink: (NSString *)fbLink
                   picture: (NSString *)fbPicture
               messageName: (NSString *)fbName
            messageCaption: (NSString *)fbCaption
                      post: (NSString *)fbPost
        messageDescription: (NSString *)fbDescription;

@end
#endif

@interface FacebookNetwork ()

- (NSString *)sharingURL;

@end

@implementation FacebookNetwork

- (void)postMessage
{
    [self postLink: self.link
           picture: self.picture
       messageName: self.messageName
    messageCaption: self.messageCaption
              post: self.post
messageDescription: self.messageDescription];
}

- (void)postMessage: (NSString *)fbPost
               link: (NSString *)fbLink
{
    [self postLink: fbLink
           picture: self.picture
       messageName: self.messageName
    messageCaption: self.messageCaption
              post: fbPost
messageDescription: self.messageDescription];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

- (void)postLink: (NSString *)fbLink
         picture: (NSString *)fbPicture
     messageName: (NSString *)fbName
  messageCaption: (NSString *)fbCaption
              post: (NSString *)fbPost
messageDescription: (NSString *)fbDescription
{
    NSDictionary *params;
    NSDictionary *options;

    if ( self.fullVersion )
    {
        params = @{
                @"link": fbLink,
                @"message" : fbPost,
                @"picture" : fbPicture,
                @"name" : fbName,
                @"caption" : fbCaption,
                @"description" : fbDescription
        };

        options = @{
                ACFacebookAppIdKey: self.token,
                ACFacebookPermissionsKey: @[@"publish_stream"],
                ACFacebookAudienceKey: ACFacebookAudienceFriends
        };

        [self postSLRequestWithParams: params options: options typeIdentifier: ACAccountTypeIdentifierFacebook serviceType: SLServiceTypeFacebook];

    }
    else
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@",
                                                                                                      [self sharingURL],
                                                                                                      self.link]]];
    }
}

- (NSString *) apiURL {
    return @"https://graph.facebook.com/me/feed";
}

- (void) processResponse: (NSData *) responseData urlResponse: (NSHTTPURLResponse *)urlResponse error: (NSError *) error {
    NSError *jsonError;
    NSDictionary *responseJson;
    NSString *responseId = nil;
    BOOL successSend = NO;

    @try {

        if(error == nil) {
            responseJson = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];

            if(responseJson != nil) {
                responseId = [responseJson objectForKey: @"id"];

                if(responseId != nil && responseId.length > 0) {
                    successSend = YES;
                }
                else {
                    [self slRequestFailedWithError: [NSError errorWithDomain: SN_T(@"kSNUnknownErrorTag", @"Неизвестная ошибка") code:0 userInfo:nil]];
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

- (void) slRequestSent {
    Log(@"%@ request sent", self.type);

    dispatch_async(dispatch_get_main_queue(), ^{
        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNFacebookTitle", @"Facebook") message: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
    });

    if([self.delegate respondsToSelector: @selector(postMessageSucceeded:)]) {
        [self.delegate postMessageSucceeded: self];
    }
}

#else

- (void)postLink: (NSString *)fbLink
         picture: (NSString *)fbPicture
     messageName: (NSString *)fbName
  messageCaption: (NSString *)fbCaption
              post: (NSString *)fbPost
messageDescription: (NSString *)fbDescription
{
    if ( self.fullVersion )
    {
        [self getFacebookInstance];

        [self _authorizeFBOnCompletion: ^(NSError *error)
        {
            if ( ! error )
            {
                dispatch_async(
                        dispatch_get_main_queue(), ^
                                                   {
                                                       [self sendToFacebookLink: fbLink
                                                                        picture: fbPicture
                                                                    messageName: fbName
                                                                 messageCaption: fbCaption
                                                                           post: fbPost
                                                             messageDescription: fbDescription];
                                                   }
                );
            }
        }];
    }
    else
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@",
                                                                                                      [self sharingURL],
                                                                                                      self.link]]];
    }
}

//#endif

- (void)_authorizeFBOnCompletion: (FacebookNetworkCompletionBlock_t)completion
{
    self.authorizeCompletion = completion;

    if ( ! [facebook isSessionValid] )
    {
        [facebook authorize: [NSArray arrayWithObjects: @"publish_stream", nil]];
    }
    else
    {
        if ( self.authorizeCompletion )
        {
            self.authorizeCompletion(nil);
        }
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
    NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
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

- (void)sendToFacebookLink: (NSString *)fbLink
                   picture: (NSString *)fbPicture
               messageName: (NSString *)fbName
            messageCaption: (NSString *)fbCaption
                      post: (NSString *)fbPost
        messageDescription: (NSString *)fbDescription
{
    Log(@"sending to facebook...");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                               fbLink, @"link",
                                                               fbPicture, @"picture",
                                                               fbName, @"name",
                                                               fbCaption, @"caption",
                                                               fbPost, @"message",
                                                               fbDescription, @"description",
                                                               nil];


    [facebook requestWithGraphPath: @"me/feed"
                         andParams: params
                     andHttpMethod: @"POST"
                       andDelegate: self];

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
    [defaults setObject: [facebook accessToken] forKey: kFBDefaultsAccessToken];
    [defaults setObject: [facebook expirationDate] forKey: kFBDefaultsExpirationDate];
    [defaults synchronize];

    if ( self.isLoginAction )
    {
        [self setIsLoginAction: NO];
        [super loginDidSucceeded];
        return;
    }

    if ( self.authorizeCompletion )
    {
        self.authorizeCompletion(nil);
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    Log(@"fbDidNotLogin");

    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка")
                                    message: SN_T(@"kSNCannotLoginFacebookTag", @"Не удалось войти в Facebook.")];

    if ( self.authorizeCompletion )
    {
        self.authorizeCompletion(
                [NSError errorWithDomain: @"FacebookNetworkError" code: 01 userInfo: @{NSLocalizedDescriptionKey : @"Unknown Error"}]
        );
    }

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

    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNFacebookTitle", @"Facebook")
                                    message: SN_T(@"kSNSuccessLogoutTag", @"Вы успешно вышли из сети.")];
    [super logoutDidSucceeded];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    Log(@"request did load: %@", result);

    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNFacebookTitle", @"Facebook")
                                    message: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];

    if([self.delegate respondsToSelector: @selector(postMessageSucceeded:)] == YES) {
        [self.delegate postMessageSucceeded: self];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    Log(@"Facebook error: %@", error);

    if ([[[error.userInfo objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
        Log(@"OAuthException - relogin...");
        [facebook authorize:[NSArray arrayWithObjects:@"publish_stream", nil]];
    } else {
        Log(@"%@", error.localizedDescription);

        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка")
                                        message: SN_T(@"kSNFailPublishTag", @"Не удалось опубликовать запись.")];
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

        [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNFacebookTitle", @"Facebook")
                                        message: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
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

    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка")
                                    message: SN_T(@"kSNFailPublishTag", @"Не удалось опубликовать запись.")];
}

#endif

- (NSString *)sharingURL {
    return @"http://facebook.com/sharer.php?u=";
}


@end
