//
//  SNApplicationObject.h
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNApplicationObject : NSObject {
@private
    NSString *Label;
    NSString *ShortDescription;
    NSString *FullDescription;
    NSString *IconURL;
    NSString *IsMtsRecommend;
    NSString *Like_Facebook;
    NSString *Like_Twitter;
    NSString *Like_VKontakte;
    NSString *Like_YaRu;
    NSString *Like_Odnoklassniki;
    NSString *Like_MailRu;
    NSString *Like_Google;
    NSString *Like_Total;
    NSString *Screenshot;
    NSString *ApplicationLabel;
    NSString *ScreenshotURL;
    NSString *DownloadLink;
    NSString *PlatformLabel;
    NSString *Url;
    UIImage *image;
}
@property(nonatomic, retain) NSString *Label;
@property(nonatomic, retain) NSString *ShortDescription;
@property(nonatomic, retain) NSString *FullDescription;
@property(nonatomic, retain) NSString *IconURL;
@property(nonatomic, retain) NSString *IsMtsRecommend;
@property(nonatomic, retain) NSString *ApplicationLabel;
@property(nonatomic, retain) NSString *PlatformLabel;
@property(nonatomic, retain) NSString *Url;
@property(nonatomic, retain) NSString *Like_Facebook;
@property(nonatomic, retain) NSString *Like_Twitter;
@property(nonatomic, retain) NSString *Like_VKontakte;
@property(nonatomic, retain) NSString *Like_YaRu;
@property(nonatomic, retain) NSString *Like_Odnoklassniki;
@property(nonatomic, retain) NSString *Like_MailRu;
@property(nonatomic, retain) NSString *Like_Google;
@property(nonatomic, retain) NSString *Like_Total;
@property(nonatomic, retain) NSString *Screenshot;
@property(nonatomic, retain) NSString *ScreenshotURL;
@property(nonatomic, retain) NSString *DownloadLink;
@property(nonatomic, assign) UIImage *image;


@end
