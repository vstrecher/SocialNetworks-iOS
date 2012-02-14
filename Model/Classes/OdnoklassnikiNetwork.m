//
//  OdnoklassnikiNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OdnoklassnikiNetwork.h"

@interface OdnoklassnikiNetwork ()
- (NSString *)sharingURL;

@end

@implementation OdnoklassnikiNetwork

- (void)postMessage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self sharingURL], self.link]]];
}

- (NSString *)sharingURL {
    return @"http://www.odnoklassniki.ru/dk?st.cmd=addShare&st._surl=";
}

@end
