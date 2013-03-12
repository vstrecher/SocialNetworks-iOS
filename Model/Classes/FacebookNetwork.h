//
//  Facebook.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "../SNSocialNetwork.h"
#import "FBConnect.h"

@interface FacebookNetwork : SNSocialNetwork <FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {
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


- (BOOL)isLogged;
- (void)login;
- (void)logout;

@end
