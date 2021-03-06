//  VkontakteVC.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VkontakteVC.h"
#import "SNDefines.h"
#import "VkontakteVCDelegate.h"
#import "SNFastMessage.h"
#import "Macros.h"
#import "SNSocialNetwork.h"
#import "VkontakteNetwork.h"

#define CALLBACK_VK_URL @"http://api.vk.com/blank.html"
#define CALLBACK_VKONTAKTE_URL @"http://api.vkontakte.ru/blank.html"

@interface VkontakteVC ()
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;


- (void)close;

- (void)findAccessTokenAndStuff:(NSString *)responseURL;

- (NSString *)getParameterFromString:(NSString *)string withKey:(NSString *)key;

@end

@implementation VkontakteVC

@synthesize access_token;
@synthesize messageToPost;
@synthesize token;
@synthesize delegate = _delegate;
@synthesize activityIndicator = _activityIndicator;
@synthesize permissions = _permissions;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];

        CGSize size = [[[UIApplication sharedApplication] keyWindow] bounds].size;

        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(size.width - 7 - 32, 7, 32, 32);
        [closeButton setImage:[UIImage imageNamed:@"sn-close-dialog.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];

        mainWebView = [[UIWebView alloc] init];
        mainWebView.delegate = self;
        mainWebView.frame = CGRectMake(0, 0, size.width, size.height);
        [self.view insertSubview:mainWebView belowSubview:closeButton];

        [self setActivityIndicator:[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease]];
        [self.activityIndicator setFrame:(CGRect){CENTER_IN_PARENT(self.view, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height), self.activityIndicator.frame.size}];
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator stopAnimating];
        [self.view addSubview:self.activityIndicator];
    }
    return self;
}

- (void)dealloc {
    [mainWebView setDelegate:nil];
    [mainWebView release], mainWebView = nil;
    [access_token release], access_token = nil;
    [messageToPost release], messageToPost = nil;
    [token release], token = nil;
    [self setActivityIndicator:nil];
    [_permissions release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Getters / Setters

- (void)setToken:(NSString *)aToken {
    if (token != aToken) {
        [aToken retain];
        [token release];
        token = aToken;
    }

    [mainWebView stopLoading];

    NSString *string = [NSString stringWithFormat:@"http://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=http://oauth.vk.com/blank.html&display=touch&response_type=token", self.token, self.permissions];
    NSString *webString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webString]]];

}

- (void)viewDidUnload {
    [mainWebView setDelegate:nil];

    [super viewDidUnload];
}


#pragma mark - User Interactions

- (void)close {
    [[SNSocialNetwork vkNetwork] hideAuthViewController];
//    [self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    INFO(@"OK: %@", request.URL.absoluteString);
    return YES;

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    INFO(@"OK: %@", webView.request.URL.absoluteString);
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    INFO(@"OK: %@", webView.request.URL.absoluteString);
    [self.activityIndicator stopAnimating];

    NSString *const urlString = webView.request.URL.absoluteString;

    if ( [urlString rangeOfString:kVKAccessTokenKey].location != NSNotFound ) {
        [self findAccessTokenAndStuff:urlString];

        [self.delegate vk:self completedAuthenticationWithStatus:YES];
    } else if ([urlString rangeOfString:kVKErrorKey].location != NSNotFound ) {
        INFO(@"AUTH FAILED: %@", urlString);
        [self.delegate vk:self completedAuthenticationWithStatus:NO];
        //TODO: show alert view
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    INFO(@"FAIL: %@ %@", mainWebView.request.URL.absoluteString, error.localizedDescription);
    [self.activityIndicator stopAnimating];
    [SNFastMessage showFastMessageWithTitle:@"Ошибка" message:[error localizedDescription] delegate:self];
}

#pragma mark - Private Methods

- (void)findAccessTokenAndStuff:(NSString *)responseURL {
    // getting access token
    NSString *accessToken = [self getParameterFromString:responseURL withKey:kVKAccessTokenKey];
    INFO(@"Got access token: %@", accessToken);
    if ( accessToken.length ) {
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kVKDefaultsAccessToken];

        // getting expires in
        NSString *expiresInString = [self getParameterFromString:responseURL withKey:kVKExpiresInKey];
        if ( expiresInString.length ) {
            NSInteger expiresInInteger = expiresInString.integerValue;
            if ( expiresInInteger > 0 ) {
                NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:expiresInString.integerValue];
                INFO(@"Expiry date: %@", expiryDate);
                [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:kVKDefaultsExpirationDate];
            } else {
                INFO(@"Expiry date: NEVER");
            }
        }
    }

    // getting user id
    NSString *userId = [self getParameterFromString:responseURL withKey:kVKUserIdKey];
    INFO(@"Got user id: %@", userId);
    if ( userId.length ) {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kVKDefaultsUserId];
    }
}


- (NSString*) getParameterFromString:(NSString*)string withKey:(NSString*)key
{
    NSRange questionMarkRange = [string rangeOfString:@"#"];
    NSUInteger questionMarkPos = (questionMarkRange.location == NSNotFound) ? 0:questionMarkRange.location+1;

    NSArray* keyValuePairs = [[string substringFromIndex:questionMarkPos] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    for (NSUInteger i=0; i<[keyValuePairs count]; i+=2) {
        NSString *s = [keyValuePairs objectAtIndex:i];
        if ([s isEqualToString:key])
            return [keyValuePairs objectAtIndex:i+1];
    }
    return nil;
}

@end
