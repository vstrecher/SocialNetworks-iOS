//
//  SNSocialNetwork.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSocialNetwork : NSObject {
@protected
    NSString *name;
    NSString *token;
    NSString *secret;
    NSString *subject;
    NSString *post;
    UIImage *logo;
    NSString *link;
    NSString *picture;
    NSString *messageName;
    NSString *messageCaption;
    NSString *messageDescription;
    NSNumber *_fullVersion;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *token;
@property(nonatomic, retain) NSString *post;
@property(nonatomic, retain) NSString *secret;
@property(nonatomic, retain) UIImage *logo;
@property(nonatomic, retain) NSString *subject;
@property(nonatomic, retain) NSString *link;
@property(nonatomic, retain) NSString *picture;
@property(nonatomic, retain) NSString *messageName;
@property(nonatomic, retain) NSString *messageCaption;
@property(nonatomic, retain) NSString *messageDescription;
@property(nonatomic, retain) NSNumber *fullVersion;


- (void)postMessage;

@end
