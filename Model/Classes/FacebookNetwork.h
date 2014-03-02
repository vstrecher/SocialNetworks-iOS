//
//  Facebook.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "../SNSocialNetwork.h"
#import "FBConnect.h"

@interface FacebookNetwork : SNSocialNetwork  {
@private
    Facebook *facebook;
}

- (void)postMessage;

- (void)postMessage: (NSString *)fbPost
               link: (NSString *)fbLink;

- (void)postLink: (NSString *)fbLink
         picture: (NSString *)fbPicture
     messageName: (NSString *)fbName
  messageCaption: (NSString *)fbCaption
              post: (NSString *)fbPost
messageDescription: (NSString *)fbDescription;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
- (BOOL)isLogged;
- (void)login;
- (void)logout;
#endif

@end
