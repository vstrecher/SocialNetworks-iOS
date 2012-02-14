//
//  SNSocialsXMLParser.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNSocialNetwork;

@interface SNSocialsXMLParser : NSObject {
    NSMutableArray *socialNetworks;
    SNSocialNetwork *socialNetwork;
}

+ (SNSocialsXMLParser *)instance;
- (NSArray *)getNetworks;

@end
