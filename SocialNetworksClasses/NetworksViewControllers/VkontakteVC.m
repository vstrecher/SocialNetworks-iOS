//
//  VkontakteVC.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VkontakteVC.h"
#import "SNDefines.h"

#define CALLBACK_VK_URL @"http://api.vk.com/blank.html"
#define CALLBACK_VKONTAKTE_URL @"http://api.vkontakte.ru/blank.html"

@interface VkontakteVC ()
- (void)close;

- (NSString *)getParameterFromString:(NSString *)string withKey:(NSString *)key;


@end

@implementation VkontakteVC

@synthesize access_token;
@synthesize messageToPost;
@synthesize token;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];

        closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        closeButton.frame = CGRectMake(10, 10, 25, 25);
        [closeButton setTitle:@"✖" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];

        mainWebView = [[UIWebView alloc] init];
        mainWebView.delegate = self;
        mainWebView.frame = CGRectMake(0, 0, 320, 460);
        [self.view insertSubview:mainWebView belowSubview:closeButton];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidAppear:(BOOL)animated {
    NSString *string = [NSString stringWithFormat:@"http://oauth.vk.com/authorize?client_id=%@&scope=wall&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token", self.token];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Interactions

- (void)close {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* url = [[request URL] absoluteString];
    Log(@"webView is loading %@", url);
    if ([url rangeOfString:CALLBACK_VK_URL].location == 0 || [url rangeOfString:CALLBACK_VKONTAKTE_URL].location == 0) {
        if (!self.access_token) {
            self.access_token = [self getParameterFromString:url withKey:@"access_token"];
            Log(@"Got access token: '%@'", self.access_token);
            NSString *string = [NSString stringWithFormat:@"https://api.vkontakte.ru/method/wall.post?message=%@&access_token=%@", [self.messageToPost stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.access_token];
//            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
            Log(@"%@", string);

            NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:string]];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            [urlRequest release];

            [urlConnection start];

            [urlConnection release];
        }

    }
    return YES;

}

- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    Log(@"finished: %@", webView.request);

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

#pragma mark - Private Methods

- (NSString*) getParameterFromString:(NSString*)string withKey:(NSString*)key
{
    NSRange questionMarkRange = [string rangeOfString:@"#"];
    int questionMarkPos = (questionMarkRange.location == NSNotFound) ? 0:questionMarkRange.location+1;

    NSArray* keyValuePairs = [[string substringFromIndex:questionMarkPos] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    for (int i=0; i<[keyValuePairs count]; i+=2) {
        NSString *s = [keyValuePairs objectAtIndex:i];
        if ([s isEqualToString:key])
            return [keyValuePairs objectAtIndex:i+1];
    }
    return nil;
}

- (void)dealloc {
    [access_token release];
    [messageToPost release];
    [token release];
    [mainWebView release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Log(@"%@", responseString);
    [responseString release];
}



@end
