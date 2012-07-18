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

@interface VkontakteNetwork ()
@property(nonatomic, assign) BOOL isCaptcha;
@property(nonatomic, assign) BOOL isAuth;


- (NSString *)sharingURL;

@end

@implementation VkontakteNetwork
@synthesize isCaptcha = _isCaptcha;
@synthesize isAuth = _isAuth;


- (void)postMessage {
    if ( self.fullVersion ) {
        [self setIsAuth:[self isAccessTokenValid]];
        if ( self.isAuth ) {
            if ( self.picture.length) {
                if ([self.picture hasPrefix:@"photo"] ) {
                    [self sendUploadedImage:self.picture text:self.post];
                } else {
                    [self sendImageData:UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:self.picture], 1.0) text:self.post];
                }
            } else {
                [self sendText:self.post];
            }
        } else {
            [self showAuthViewController];
        }
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self sharingURL], self.link]]];
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

        [self sendSuccessWithMessage:NSLocalizedString(@"Вы успешно вышли из сети.", @"Вы успешно вышли из сети.")];
        [super logoutDidSucceeded];
    }
}

- (void)showAuthViewController {
    VkontakteVC *vkontakteVC = [[VkontakteVC alloc] init];
    vkontakteVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vkontakteVC.token = self.token;
    [vkontakteVC setDelegate:self];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:vkontakteVC animated:YES];
    [vkontakteVC release];
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

- (void)sendText:(NSString *)text {
    [self sendUploadedImage:nil text:text];
}

- (void)sendUploadedImage:(NSString *)uploadedImage text:(NSString *)text {
    if ( ! self.isAuth ) return;

    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsAccessToken];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kVKDefaultsUserId];

    NSDictionary *result = [self sendRequest:kWallPostURL(user_id, accessToken, [self URLEncodedString:text], uploadedImage) withCaptcha:NO];

    NSString *errorMsg = [[result objectForKey:kVKErrorKey] objectForKey:kVKErrorMsgKey];
    INFO(@"%@", errorMsg);
    if(errorMsg) {
        [self sendFailedWithError:NSLocalizedString(@"Не удалось опубликовать запись.", @"Не удалось опубликовать запись.")];
    } else {
        [self sendSuccessWithMessage:NSLocalizedString(@"Запись успешно опубликована!", @"Запись успешно опубликована!")];
    }
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
        [self sendFailedWithError:NSLocalizedString(@"Не удалось опубликовать запись.", @"Не удалось опубликовать запись.")];
    } else {
        [self sendSuccessWithMessage:NSLocalizedString(@"Запись успешно опубликована!", @"Запись успешно опубликована!")];
    }
}

- (void) sendFailedWithError:(NSString *)error {
    if ( self.isCaptcha ) {
        return;
    }
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Ошибка")
                                                          message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [myAlertView show];
    [myAlertView release];
}

- (void) sendSuccessWithMessage:(NSString *)message {
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ВКонтакте", @"ВКонтакте")
                                                          message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [myAlertView show];
    [myAlertView release];
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
    [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Введите цифры с изображения:\n\n\n\n\n"
                                                          message:@"\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Отмена", @"Отмена")
                                                                                      otherButtonTitles:NSLocalizedString(@"Ок", @"Ок"), nil];

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
            [self sendFailedWithError:NSLocalizedString(@"Не удалось опубликовать запись.", @"Не удалось опубликовать запись.")];
        } else {
            [self sendSuccessWithMessage:NSLocalizedString(@"Запись успешно опубликована!", @"Запись успешно опубликована!")];
        }
    }
}

#pragma mark - VkontakteVCDelegate

- (void)vk:(VkontakteVC *)viewController completedAuthenticationWithStatus:(BOOL)isSuccessful {
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:NO];
    [self setIsAuth:isSuccessful];

    if ( isSuccessful ) {

        if ( self.isLoginAction ) {
            [self setIsLoginAction:NO];
            [super loginDidSucceeded];
            return;
        }

        [self postMessage];

    } else {

        [super loginDidFail];

    }
}


@end
