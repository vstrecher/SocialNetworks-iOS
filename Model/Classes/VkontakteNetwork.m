//
//  VkontakteNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VkontakteNetwork.h"

@interface VkontakteNetwork ()
- (NSString *)sharingURL;

@end

@implementation VkontakteNetwork

- (void)postMessage {
    /*
    VkontakteVC *vkontakteVC = [[VkontakteVC alloc] init];
    vkontakteVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vkontakteVC.messageToPost = self.post;
    vkontakteVC.token = self.token;

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:vkontakteVC, @"view-controller", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil userInfo:userInfo];

    [userInfo release];
    [vkontakteVC release];
    */

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self sharingURL], self.link]]];

}

- (NSString *)sharingURL {
    return @"http://vk.com/share.php?url=";
}

@end
