//
//  SNApplicationObject.m
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNApplicationObject.h"

@implementation SNApplicationObject
@synthesize Label;
@synthesize ShortDescription;
@synthesize FullDescription;
@synthesize IconURL;
@synthesize IsMtsRecommend;
@synthesize ApplicationLabel;
@synthesize PlatformLabel;
@synthesize Url;
@synthesize Like_Facebook;
@synthesize Like_Twitter;
@synthesize Like_VKontakte;
@synthesize Like_YaRu;
@synthesize Like_Odnoklassniki;
@synthesize Like_MailRu;
@synthesize Like_Google;
@synthesize Like_Total;
@synthesize Screenshot;
@synthesize ScreenshotURL;
@synthesize DownloadLink;
@synthesize image;


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", self.Label, self.ShortDescription, self.IconURL];
}


- (void)dealloc {
    [Label release];
    [ShortDescription release];
    [FullDescription release];
    [IconURL release];
    [IsMtsRecommend release];
    [ApplicationLabel release];
    [PlatformLabel release];
    [Url release];
    [Like_Facebook release];
    [Like_Twitter release];
    [Like_VKontakte release];
    [Like_YaRu release];
    [Like_Odnoklassniki release];
    [Like_MailRu release];
    [Like_Google release];
    [Like_Total release];
    [Screenshot release];
    [ScreenshotURL release];
    [DownloadLink release];
    [super dealloc];
}
@end
