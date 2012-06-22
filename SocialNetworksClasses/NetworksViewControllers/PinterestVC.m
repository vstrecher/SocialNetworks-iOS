//
//  Created by eugene on 22.06.12.
//
#import <QuartzCore/QuartzCore.h>
#import "PinterestVC.h"

@interface PinterestVC ()
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) UIButton *dismissButton;
@end

@implementation PinterestVC {

}
@synthesize htmlString = _htmlString;
@synthesize webView = _webView;
@synthesize dismissButton = _dismissButton;
@synthesize openURL = _openURL;


- (id)init {
    self = [super init];
    if (self) {
    }

    return self;
}

- (void)dealloc {
    [_htmlString release];
    [_webView release];
    [_dismissButton release];
    [_openURL release];
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

@end