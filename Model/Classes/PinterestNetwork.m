//
//  Created by eugene on 22.06.12.
//
#import "PinterestNetwork.h"
#import "PinterestVC.h"


@implementation PinterestNetwork {

}

- (NSString *)protectedFromString:(NSString *)string {
    NSString *protectedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% \n",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return protectedString;
}

- (NSString *)generatePinterestURL {
    NSString *description = [self protectedFromString:self.messageDescription];
    NSString *protectedUrl = [self protectedFromString:self.link];
    NSString *buttonUrl = [NSString stringWithFormat:@"http://pinterest.com/pin/create/button/?url=www.archergoods.com&media=%@&description=%@", protectedUrl, description];

    return buttonUrl;
}

- (NSString *)generatePinterestHTML {
    NSString *imageUrl = [NSString stringWithFormat:@"\"%@\"", self.picture];
    NSString *buttonUrl = [NSString stringWithFormat:@"\"%@\"", [self generatePinterestURL]];

    NSMutableString *htmlString = [[[NSMutableString alloc] init] autorelease];
    [htmlString appendFormat:@"<html> <body background=\"https://assets.pinterest.com/images/paper.jpg\">"];
    [htmlString appendFormat:@"<center><h3>%@</h3></center>", self.post];
    [htmlString appendFormat:@"<p align=\"center\"><img width=\"400px\" height = \"400px\" src=%@></img></p>", imageUrl];
    [htmlString appendFormat:@"<p align=\"center\"><a href=%@ class=\"pin-it-button\" count-layout=\"horizontal\"><img border=\"0\" src=\"http://assets.pinterest.com/images/PinExt.png\" title=\"Pin It\" /></a></p>", buttonUrl];
    [htmlString appendFormat:@"<script type=\"text/javascript\" src=\"//assets.pinterest.com/js/pinit.js\"></script>"];
    [htmlString appendFormat:@"</body> </html>"];

    return htmlString;
}

- (void)postMessage {
    PinterestVC *pinterestVC = [[PinterestVC alloc] init];
    [pinterestVC setOpenURL:[self generatePinterestURL]];
    [pinterestVC setModalPresentationStyle:UIModalPresentationPageSheet];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:pinterestVC animated:YES];

    [pinterestVC release];
}


@end