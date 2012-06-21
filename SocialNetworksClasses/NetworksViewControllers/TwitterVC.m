//
//  Created by default on 22.11.11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TwitterVC.h"
#import "TDOAuth.h"
#import <QuartzCore/QuartzCore.h>
#import "SNDefines.h"

//#define CONSUMER_KEY @"nJlp0PfbLTvbOOalhpAgdQ"
//#define CONSUMER_SECRET @"RUq4oatdz06POW11NxqzHk8AN1FGAVgU0L5TSStGk"
#define CONSUMER_KEY @"TWtSf7c2viJfLpBuOPXg"
#define CONSUMER_SECRET @"HttEwBDVVLjDkgCdPz6l7m7Ef0nyWusVcx1Baw6CY"
#define CALLBACK_URL @"twitter_callback"

@interface TwitterVC(private)
- (void) addActivityIndicator;
- (void) removeActivityIndicator;
- (void) postMessage;
@end


@interface TwitterVC ()
- (void)close;

@end

@implementation TwitterVC

@synthesize delegate;
@synthesize oauthToken;
@synthesize oauthTokenSecret;
@synthesize consumerKey;
@synthesize consumerSecret;


- (id) init
{
    self = [super init];

    webView = [[UIWebView alloc] init];
    webView.frame = self.view.frame;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;

    //drop shadow
    /*
    if (self.view.frame.size.width > w) {
        webView.layer.shadowColor = [[UIColor blackColor] CGColor];
        webView.layer.shadowOffset = CGSizeMake(0, 0);
        webView.layer.shadowOpacity = 0.4f;
        webView.layer.shadowRadius = 5.0f;
    }
    */

    self.view.backgroundColor = [UIColor whiteColor];

    closeButton = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        closeButton.frame = CGRectMake(10, 10, 25, 25);
        [closeButton setTitle:@"✖" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
    }

    return self;
}

- (BOOL) hasSession
{
    return ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"twitter_%@_access_token", self.consumerKey]] != nil);
}


- (NSString*) getParameterFromString:(NSString*)string withKey:(NSString*)key
{
    NSRange questionMarkRange = [string rangeOfString:@"?"];
    int questionMarkPos = (questionMarkRange.location == NSNotFound) ? 0:questionMarkRange.location+1;

    NSArray* keyValuePairs = [[string substringFromIndex:questionMarkPos] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    for (int i=0; i<[keyValuePairs count]; i+=2) {
        NSString *s = [keyValuePairs objectAtIndex:i];
        if ([s isEqualToString:key])
            return [keyValuePairs objectAtIndex:i+1];
    }
    return nil;
}

- (void) sendMessage:(NSString *)message
{
    [messageToSend release];
    messageToSend = [message retain];

    if (![self hasSession]) {
        NSURLRequest *request = [TDOAuth URLRequestForPath:@"/oauth/request_token"
                                             GETParameters:nil
                                                      host:@"api.twitter.com"
                                               consumerKey:self.consumerKey
                                            consumerSecret:self.consumerSecret
                                               accessToken:nil
                                               tokenSecret:nil];

        NSURLResponse* response;
        NSError* error = nil;
        NSData* replyData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *reply = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
        Log(@"response = %@, reply: %@", response, reply);
        self.oauthToken = [self getParameterFromString:reply withKey:@"oauth_token"];
        self.oauthTokenSecret = [self getParameterFromString:reply withKey:@"oauth_token_secret"];
        Log(@"oauthToken = %@, oauthTokenSecret: %@", oauthToken, oauthTokenSecret);
        [reply release];

        NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", oauthToken];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        self.oauthToken = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"twitter_%@_access_token", self.consumerKey]];
        self.oauthTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"twitter_%@_token_secret", self.consumerSecret]];
        [self postMessage];
    }
}


- (void)postMessage
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:messageToSend forKey:@"status"];
    NSURLRequest *request = [TDOAuth URLRequestForPath:@"/1/statuses/update.json"
                                        POSTParameters:params
                                                  host:@"api.twitter.com"
                                           consumerKey:self.consumerKey
                                        consumerSecret:self.consumerSecret
                                           accessToken:oauthToken
                                           tokenSecret:oauthTokenSecret];

    NSURLResponse* response;
    NSError* error = nil;
    NSData* replyData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *reply = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
    Log(@"response = %@, reply: %@", response, reply);

    if ([reply rangeOfString:@"error"].location == NSNotFound) {
        [delegate tweetSent];
    } else {
        [delegate tweetFailedWithError:[NSError errorWithDomain:@"postTokenTicket did not succeed" code:0 userInfo:nil]];
    }

    [reply release];
}


//----------------------------------------------------------------

- (void) showWebView
{
    if (!webView.superview) {

        webView.frame = self.view.frame;

        if ([closeButton superview]) {
            [self.view insertSubview:webView belowSubview:closeButton];
        } else {
            [self.view addSubview:webView];
        }

        webView.alpha = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        webView.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void) hideWebView
{
    if (webView.superview) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        webView.alpha = 0;
        [UIView commitAnimations];

        [webView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    }
}

#pragma mark --------------------------
#pragma mark WebView delegate
#pragma mark --------------------------

- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* url = [[request URL] absoluteString];
    Log(@"webView is loading %@", url);
    [self addActivityIndicator];

    //user press "go back to application"
    if ([url rangeOfString:@"?denied"].location != NSNotFound) {
        [self hideWebView];
        [self removeActivityIndicator];
        [delegate tweetCancel];
        return NO;
    }

    if ([url rangeOfString:CALLBACK_URL].location != NSNotFound) {
        [self hideWebView];
        [self removeActivityIndicator];

        self.oauthToken = [self getParameterFromString:url withKey:@"oauth_token"];
        NSString *oauthVerifier = [self getParameterFromString:url withKey:@"oauth_verifier"];
        Log(@"oauthToken = %@, oauthVerifier: %@", oauthToken, oauthVerifier);

        NSDictionary *params = [NSDictionary dictionaryWithObject:oauthVerifier forKey:@"oauth_verifier"];

        NSURLRequest *urlRequest = [TDOAuth URLRequestForPath:@"/oauth/access_token"
                                               POSTParameters:params
                                                         host:@"api.twitter.com"
                                                  consumerKey:self.consumerKey
                                               consumerSecret:self.consumerSecret
                                                  accessToken:oauthToken
                                                  tokenSecret:oauthTokenSecret];

        NSURLResponse* response;
        NSError* error = nil;
        NSData* replyData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        NSString *reply = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
        Log(@"response = %@, error = %@, reply: %@", response, error, reply);
        self.oauthToken = [self getParameterFromString:reply withKey:@"oauth_token"];
        self.oauthTokenSecret = [self getParameterFromString:reply withKey:@"oauth_token_secret"];
        Log(@"oauthToken = %@, oauthTokenSecret: %@", oauthToken, oauthTokenSecret);
        [reply release];

        //store received token
        [[NSUserDefaults standardUserDefaults] setObject:oauthToken forKey:[NSString stringWithFormat:@"twitter_%@_access_token", self.consumerKey]];
        [[NSUserDefaults standardUserDefaults] setObject:oauthTokenSecret forKey:[NSString stringWithFormat:@"twitter_%@_token_secret", self.consumerSecret]];

        [self postMessage];

        return NO;
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [self removeActivityIndicator];

    //когда webView загрузился, показываем его
    [self showWebView];
}

//----------------------------------------------------------------

- (void) addActivityIndicator
{
    if (!activityIndicatorView) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [activityIndicatorView startAnimating];
        [self.view addSubview: activityIndicatorView];
    }
}

- (void) removeActivityIndicator
{
    if (activityIndicatorView) {
        [activityIndicatorView removeFromSuperview];
        [activityIndicatorView release];
        activityIndicatorView = nil;
    }
}

//----------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    else
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);

}

//----------------------------------------------------------------

- (void) dealloc
{
    [messageToSend release];
    [webView release];
    [consumerKey release];
    [consumerSecret release];
    [oauthToken release];
    [oauthTokenSecret release];
    [activityIndicatorView release];
    [super dealloc];
}

#pragma mark - User Interactions

- (void)close {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}

@end