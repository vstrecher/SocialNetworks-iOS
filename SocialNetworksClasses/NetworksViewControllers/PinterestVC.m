//
//  Created by eugene on 22.06.12.
//
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PinterestVC.h"
#import "UIView+FrameAccessor.h"

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
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
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
    [self.dismissButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
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
    [self.dismissButton setSize:CGSizeMake(27, 27)];

    [self.dismissButton setOrigin:CGPointMake(self.view.width - self.dismissButton.width - 13, 10)];
}

#pragma mark - Private

- (void) addActivityIndicator
{
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray] autorelease];
        self.activityIndicatorView.center = CGPointMake(floorf(self.view.frame.size.width / 2.0), floorf(self.view.frame.size.height / 2.0));
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
    INFO(@"%@", request.URL.absoluteString);
    [self addActivityIndicator];
//    [self hideWebView];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self showWebView];
    [self removeActivityIndicator];
}


@end