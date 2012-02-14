//
//  Created by default on 22.11.11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol TwitterDelegate

- (void) tweetSent;
- (void) tweetFailedWithError:(NSError*)error;
- (void) tweetCancel;

@end

@interface TwitterVC : UIViewController <UIWebViewDelegate> {
	id<TwitterDelegate> delegate;

	NSString *oauthToken;
	NSString *oauthTokenSecret;
    NSString *consumerKey;
    NSString *consumerSecret;

	NSString *messageToSend;

	UIWebView *webView;
	UIActivityIndicatorView *activityIndicatorView;

    UIButton *closeButton;
}

@property (nonatomic, assign) id<TwitterDelegate> delegate;
@property (nonatomic, retain) NSString *oauthToken;
@property (nonatomic, retain) NSString *oauthTokenSecret;
@property(nonatomic, retain) NSString *consumerKey;
@property(nonatomic, retain) NSString *consumerSecret;


- (void) sendMessage:(NSString*)message;
- (BOOL) hasSession;

@end