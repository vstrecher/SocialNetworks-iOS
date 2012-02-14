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

@end
