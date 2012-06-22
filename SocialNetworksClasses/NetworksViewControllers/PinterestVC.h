//
//  Created by eugene on 22.06.12.
//
#import <Foundation/Foundation.h>


@interface PinterestVC : UIViewController {
    UIWebView *_webView;
    UIButton *_dismissButton;

    NSString *_htmlString;
    NSString *_openURL;
}

@property(nonatomic, copy) NSString *htmlString;
@property(nonatomic, copy) NSString *openURL;


@end