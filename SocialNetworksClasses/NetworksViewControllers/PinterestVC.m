//
//  Created by eugene on 22.06.12.
//
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PinterestVC.h"

@interface PinterestVC ()
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) UIButton *dismissButton;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation PinterestVC {

}
@synthesize htmlString = _htmlString;
@synthesize webView = _webView;
@synthesize dismissButton = _dismissButton;
@synthesize openURL = _openURL;
@synthesize activityIndicatorView = _activityIndicatorView;


- (id)init {
    self = [super init];
    if (self) {
    }

    return self;
}

- (void)dealloc {
    [self.webView setDelegate:nil];
    [_htmlString release];
    [_webView release];
    [_dismissButton release];
    [_openURL release];
    [_activityIndicatorView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUp];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    else
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark - Interactions

- (void)dismissButtonDidClick:(id)sender {
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Getters / Setters

#pragma mark - Setting Up

- (void)setUp {
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];

    [self setUpViews];
}

- (void)createWebView {
    [self setWebView:[[[UIWebView alloc] init] autorelease]];
    [self.webView setDelegate:self];
    if ( self.htmlString.length) {
        [self.webView loadHTMLString:self.htmlString baseURL:[NSURL URLWithString:@"http://pinterest.com"]];
    } else if ( self.openURL.length ) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.openURL]]];
    }

}

- (void)createDismissButton {
    [self setDismissButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.dismissButton setImage:[UIImage imageNamed:@"sn-close-dialog.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.dismissButton.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.dismissButton.layer setShadowOpacity:0.4];
    [self.dismissButton.layer setShadowRadius:2];
}

- (void)setUpViews {
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self createWebView];
    [self createDismissButton];

    [self sizeAndPlaceViews];

    [self.view addSubview:self.webView];
    [self.view addSubview:self.dismissButton];
}

- (void)sizeAndPlaceViews {
    [self.webView setFrame:self.view.bounds];
    [self.dismissButton sizeToFit];
}

#pragma mark - Private

- (void) addActivityIndicator
{
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray] autorelease];
        self.activityIndicatorView.center = CGPointMake(self.view.frame.size.width - self.activityIndicatorView.frame.size.width , self.activityIndicatorView.frame.size.height);
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin ;
        [self.activityIndicatorView startAnimating];
        [self.view addSubview: self.activityIndicatorView];
    }
}

- (void) removeActivityIndicator
{
    if (self.activityIndicatorView) {
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
}

- (void) showWebView
{
    if (!self.webView.superview) {
        self.webView.frame = self.view.frame;
        [self.view insertSubview:self.webView belowSubview:self.dismissButton];
        self.webView.alpha = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.webView.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void) hideWebView
{
    if (self.webView.superview) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.webView.alpha = 0;
        [UIView commitAnimations];

        [self.webView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    }
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self addActivityIndicator];
//    [self hideWebView];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self showWebView];
    [self removeActivityIndicator];
}


@end