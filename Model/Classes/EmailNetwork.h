//
//  EmailSharing.h
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "../SNSocialNetwork.h"

@interface EmailNetwork : SNSocialNetwork <MFMailComposeViewControllerDelegate>
@end
