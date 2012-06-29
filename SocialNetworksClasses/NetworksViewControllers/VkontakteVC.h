//
//  VkontakteVC.h
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VkontakteVCDelegate;

@interface VkontakteVC : UIViewController <UIWebViewDelegate> {
    UIButton *closeButton;
    UIWebView *mainWebView;
    UIActivityIndicatorView *_activityIndicator;

    NSString *access_token;
    NSString *messageToPost;
    NSString *token;

    id <VkontakteVCDelegate> _delegate;
}
@property(nonatomic, retain) NSString *access_token;
@property(nonatomic, retain) NSString *messageToPost;
@property(nonatomic, retain) NSString *token;
@property(nonatomic, assign) id <VkontakteVCDelegate> delegate;

@end
