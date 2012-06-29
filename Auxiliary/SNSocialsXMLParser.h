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
    NSArray *_socialNetworks;
    SNSocialNetwork *socialNetwork;
}

+ (SNSocialsXMLParser *)instance;
- (NSArray *)getNetworksFromConfigFileName:(NSString *)aConfigXMLFileName;
- (NSArray *)getNetworks;

- (SNSocialNetwork *)getNetworkWithType:(NSString *)type;


@end
