//
//  VkontakteNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VkontakteNetwork.h"
#import "VkontakteVC.h"
#import "SNDefines.h"
#import "JSONKit.h"
#import "Macros.h"
#import "SNFastMessage.h"

typedef void(^VKNetworkCompletionBlock_t)(NSError *error);

@interface VkontakteNetwork ()
@property(nonatomic, assign) BOOL isCaptcha;
@property(nonatomic, assign) BOOL isAuth;
@property (nonatomic, copy) VKNetworkCompletionBlock_t authorizeCompletion;


- (NSString *)sharingURL;

- (void)doLogout;

- (BOOL)isAccessTokenValid;

- (void)sendText:(NSString *)text;

- (void)sendText:(NSString *)text link:(NSString *)aLink;

- (void)sendUploadedImage:(NSString *)uploadedImage text:(NSString *)text;

- (void)sendUploadedImage:(NSString *)uploadedImage text:(NSString *)text link:(NSString *)aLink;

- (void)sendImageData:(NSData *)imageData text:(NSString *)text;

- (void)sendFailedWithError:(NSString *)error;

- (void)sendSuccessWithMessage:(NSString *)message;

- (NSString *)URLEncodedString:(NSString *)str;

- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha;

- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData;

- (void)getCaptcha;


@end

@implementation VkontakteNetwork
@synthesize isCaptcha = _isCaptcha;
@synthesize isAuth = _isAuth;

- (void)postMessage
{
    [self postMessage: self.post
                 link: self.link
              picture: self.picture];
}

- (void)postMessage: (NSString *)vkMessage
               link: (NSString *)vkLink
{
    [self postMessage: vkMessage
                 link: vkLink
              picture: nil];
}

- (void)postMessage: (NSString *)vkMessage
               link: (NSString *)vkLink
            picture: (NSString *)vkPicture
{
    if ( self.fullVersion )
    {
        [self _authorizeVKOnCompletion: ^(NSError *error)
        {
            if ( ! error )
            {
                if ( vkPicture.length )
                {
                    if ( [vkPicture hasPrefix: @"photo"] )
                    {
                        [self sendUploadedImage: vkPicture
                                           text: vkMessage];
                    }
                    else
                    {
                        [self sendImageData: UIImageJPEGRepresentation(
                                [UIImage imageWithContentsOfFile: vkPicture], 1.0
                        )
                                       text: vkMessage];
                    }
                }
                else
                {
                    if ( vkLink.length )
                    {
                        [self sendText: vkMessage
                                  link: vkLink];
                    }
                    else
                    {
                        [self sendText: vkMessage];
                    }
                }
            }
        }];
    }
    else
    {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@%@",
                                                                                                      [self sharingURL],
                                                                                                      vkLink]]];
    }
}

- (void)_authorizeVKOnCompletion: (VKNetworkCompletionBlock_t)completion
{
    self.authorizeCompletion = completion;

    [self setIsAuth: [self isAccessTokenValid]];

    if ( self.isAuth )
    {
        if ( self.authorizeCompletion )
        {
            self.authorizeCompletion(nil);
        }
    }
    else
    {
        [self showAuthViewController];
    }
}

- (NSString *)sharingURL {
    return @"http://vk.com/share.php?url=";
}

- (BOOL)isLogged {
    return [self isAccessTokenValid];
}

- (void)login {
    [self setIsLoginAction:YES];
    [self showAuthViewController];
}

- (void)logout {
    [self doLogout];
}


#pragma mark - Private

- (void)doLogout {
    NSString *logout = @"http://api.vk.com/oauth/logout";

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logout]
            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
        timeoutInterval:60.0];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(responseData){
        NSDictionary *dict = [responseData objectFromJSONData];
        NSLog(@"Logout: %@", dict);

        [self setIsAuth:NO];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVKDefaultsAccessToken];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVKDefaultsExpirationDate];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVKDefaultsUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self sendSuccessWithMessage: SN_T(@"kSNSuccessLogoutTag", @"Вы успешно вышли из сети.")];
        [super logoutDidSucceeded];
    }
}

- (void)showAuthViewController {
    VkontakteVC *vkontakteVC = [[VkontakteVC alloc] init];
    vkontakteVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    /* adding this condition for support other applications where permissions were hardcoded */
    NSString *permissions = self.permissions;
    if ( ! permissions.length ) {
        INFO(@"Using predefined permissions");
        permissions = @"wall,photos,offline";
    }
    INFO(@"Permissions: %@", permissions);
    vkontakteVC.permissions = permissions;

    vkontakteVC.token = self.token;

    [vkontakteVC setDelegate:self];

    if ( [SNSocialNetwork presentWithNotification] ) {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:vkontakteVC, NOTIFICATION_VIEW_CONTROLLER, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil userInfo:info];
    } else {
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController: vkontakteVC animated: YES completion: nil];
    }
    [vkontakteVC release];
}

- (void)hideAuthViewController {
    if ( [SNSocialNetwork presentWithNotification] ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil userInfo:nil];
    } else {
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated: NO completion: nil];
    }
}

- (BOOL)isAccessTokenValid {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsAccessToken];

    if ( ! accessToken.length ) {
        INFO(@"Access token is null");
        return NO;
    }

    NSDate *expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsExpirationDate];

    if ( expiryDate ) {
        NSTimeInterval delta = [expiryDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];

        if ( delta <= 0 ) {
            INFO(@"Access token expired");
            return NO;
        }

        INFO(@"Seconds till expiration: %.0f", delta);
    } else {
        INFO(@"Access token will never expired");
    }

    INFO(@"Access token loaded from user defaults: %@", accessToken);

    return YES;
}

- (void)clearToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVKDefaultsAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVKDefaultsExpirationDate];
}

- (void)sendText:(NSString *)text {
    [self sendUploadedImage:nil text:text];
}

- (void)sendText:(NSString *)text link:(NSString *)aLink {
    [self sendUploadedImage:nil text:text link:aLink];
}

- (void)sendUploadedImage:(NSString *)uploadedImage text:(NSString *)text {
    [self sendUploadedImage:uploadedImage text:text link:nil];
}

- (void)sendUploadedImage:(NSString *)uploadedImage text:(NSString *)text link:(NSString *)aLink {
    if ( ! self.isAuth ) return;

    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsAccessToken];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsUserId];

    NSMutableString *attachments = [[NSMutableString alloc] init];

    if ( ! uploadedImage ) {
        uploadedImage = @"";
    }

    [attachments appendString:uploadedImage];

    NSString *linkToPost = @"";
    if ( aLink.length ) {
        linkToPost = [NSString stringWithFormat:@"%@", [self URLEncodedString:aLink]];
    }

    if ( attachments.length ) {
        [attachments appendString:@","];
    }
    [attachments appendFormat:@"%@", linkToPost];

    NSDictionary *result = [self sendRequest:kWallPostURL(user_id, accessToken, [self URLEncodedString:text], attachments) withCaptcha:NO];

    NSString *errorMsg = [[result objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
    NSInteger errorCode = [[[result objectForKey:kVKErrorKey] objectForKey:kVKErrorCode] integerValue];
    INFO(@"%@", errorMsg);
    if( errorMsg || !result ) {
        if ( errorCode == 5 ) {
            [self clearToken];

            // Retrying
            [self postMessage: text
                         link: aLink
                      picture: uploadedImage];
        } else {
            [self sendFailedWithError: SN_T(@"kSNFailPublishTag", @"Не удалось опубликовать запись.")];
        }
    } else {
        [self sendSuccessWithMessage:SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
    }

    [attachments release];
}

- (void)sendImageData:(NSData *)imageData text:(NSString *)text {
    if( ! self.isAuth ) return;

    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsAccessToken];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsUserId];

    NSDictionary *uploadServer = [self sendRequest:kPhotosGetWallUploadServerURL(user_id, accessToken) withCaptcha:NO];
    NSString *upload_url = [[uploadServer objectForKey:kVKResponseKey] objectForKey:kVKUploadURLKey];

    NSDictionary *postDictionary = [self sendPOSTRequest:upload_url withImageData:imageData];
    NSString *hash = [postDictionary objectForKey:kVKHashKey];
    NSString *photo = [postDictionary objectForKey:kVKPhotoKey];
    NSString* photoEscaped = [photo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *server = [postDictionary objectForKey:kVKServerKey];

    NSDictionary *saveWallPhotoDict = [self sendRequest:kPhotosSaveWallPhotoURL(accessToken, server, photoEscaped, hash) withCaptcha:NO];
    NSDictionary *photoDict = [[saveWallPhotoDict objectForKey:kVKResponseKey] lastObject];
    NSString *photoId = [photoDict objectForKey:kVKIdKey];

    NSDictionary *postToWallDict = [self sendRequest:kWallPostURL(user_id, accessToken, [self URLEncodedString:text], photoId) withCaptcha:NO];

    NSString *errorMsg = [[postToWallDict  objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
    if(errorMsg) {
        [self sendFailedWithError: SN_T(@"kSNFailPublishTag", @"Не удалось опубликовать запись.")];
    } else {
        [self sendSuccessWithMessage: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
    }
}

- (void) sendFailedWithError:(NSString *)error {
    if ( self.isCaptcha ) {
        return;
    }
    
    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNAlertViewErrorTitle", @"Ошибка") message: error];
}

- (void) sendSuccessWithMessage:(NSString *)message {
    
    [SNFastMessage showFastMessageWithTitle: SN_T(@"kSNVkontakteTitle", @"ВКонтакте") message: message];
    
    if([self.delegate respondsToSelector: @selector(postMessageSucceeded:)] == YES) {
        [self.delegate postMessageSucceeded: self];
    }
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSDictionary *) sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha {

    if(captcha == YES){
        NSString *captcha_sid = [[NSUserDefaults standardUserDefaults] objectForKey:kVKCaptchaSidKey];
        NSString *captcha_user = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_user"];

        reqURl = [reqURl stringByAppendingFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, [self URLEncodedString: captcha_user]];
    }
    NSLog(@"Sending request: %@", reqURl);
    NSURL *url = [NSURL URLWithString:reqURl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:60.0];

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if(responseData){
        NSDictionary *dict = [responseData objectFromJSONData];

        NSString *errorMsg = [[dict objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);

        if([errorMsg isEqualToString:@"Captcha needed"]){
            [self setIsCaptcha:YES];

            NSString *captcha_sid = [[dict objectForKey:kVKErrorKey] objectForKey:kVKCaptchaSidKey];
            NSString *captcha_img = [[dict objectForKey:kVKErrorKey] objectForKey:kVKCaptchaImgKey];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_img forKey:kVKCaptchaImgKey];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_sid forKey:kVKCaptchaSidKey];
            [[NSUserDefaults standardUserDefaults] setObject:reqURl forKey:kVKRequestKey];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self getCaptcha];
        }

        return dict;
    }
    return nil;
}

- (NSDictionary *) sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData {
    NSLog(@"Sending request: %@", reqURl);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl]
                                                                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                  timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];

    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = [(NSString*)CFUUIDCreateString(nil, uuid) autorelease];
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;  boundary=%@", stringBoundary];

    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dict;
    if(responseData){
        dict = [responseData objectFromJSONData];

        NSString *errorMsg = [[dict objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);

        return dict;
    }
    return nil;
}

- (void) getCaptcha {
    NSString *captcha_img = [[NSUserDefaults standardUserDefaults] objectForKey:kVKCaptchaImgKey];
    NSString *captchaTitle = SN_T(@"kSNEnterCaptchaCodeTag", @"Введите код с картинки");
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle: [captchaTitle stringByAppendingString: @":\n\n\n\n\n"]
                                                          message:@"\n" delegate:self cancelButtonTitle:SN_T(@"kSNCancelTitle", @"Отмена")
                                                                                      otherButtonTitles: SN_T(@"kSNOkTitle", @"Ок"), nil];

    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(12.0, 45.0, 130.0, 50.0)] autorelease];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:captcha_img]]];
    [myAlertView addSubview:imageView];

    UITextField *myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12.0, 110.0, 260.0, 25.0)] autorelease];
    [myTextField setBackgroundColor:[UIColor whiteColor]];

    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    myTextField.tag = 33;

    [myAlertView addSubview:myTextField];
    [myAlertView show];
    [myAlertView release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.isCaptcha && buttonIndex == 1){
        [self setIsCaptcha:NO];

        UITextField *myTextField = (UITextField *)[actionSheet viewWithTag:33];
        [[NSUserDefaults standardUserDefaults] setObject:myTextField.text forKey:@"captcha_user"];
        NSLog(@"Captcha entered: %@",myTextField.text);

        NSString *request = [[NSUserDefaults standardUserDefaults] objectForKey:kVKRequestKey];

        NSDictionary *newRequestDict =[self sendRequest:request withCaptcha:YES];
        NSString *errorMsg = [[newRequestDict  objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
        if(errorMsg) {
            [self sendFailedWithError: SN_T(@"kSNFailPublishTag", @"Не удалось опубликовать запись.")];
        } else {
            [self sendSuccessWithMessage: SN_T(@"kSNSuccessPublishTag", @"Запись успешно опубликована!")];
        }
    }
}

#pragma mark - VkontakteVCDelegate

- (void)vk:(VkontakteVC *)viewController completedAuthenticationWithStatus:(BOOL)isSuccessful {
    [self hideAuthViewController];
    [self setIsAuth: isSuccessful];

    if ( isSuccessful )
    {

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
    else
    {

        if ( self.authorizeCompletion )
        {
            self.authorizeCompletion(
                    [NSError errorWithDomain: @"VkontakteNetworkDomain"
                                        code: 01
                                    userInfo: @{NSLocalizedDescriptionKey : @"Unknown Error"}]
            );
        }

        [super loginDidFail];

    }
}


@end
