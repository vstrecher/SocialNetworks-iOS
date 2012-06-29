//
//  SNSocialsXMLParser.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNSocialsXMLParser.h"
#import "../Model/SNSocialNetwork.h"
#import "DDXMLDocument.h"
#import "SNDefines.h"

@interface SNSocialsXMLParser ()
@property(nonatomic, retain) NSArray *socialNetworks;

- (SNSocialNetwork *)createNetworkWithType:(NSString *)networkType;
@end

@implementation SNSocialsXMLParser
@synthesize socialNetworks = _socialNetworks;


+ (SNSocialsXMLParser *)instance {
    static SNSocialsXMLParser *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (NSArray *)getNetworksFromConfigFileName:(NSString *)aConfigXMLFileName {
    NSMutableArray *socialNetworks = [[NSMutableArray alloc] init];

    id applicationDelegate = [[UIApplication sharedApplication] delegate];
    NSString *configXMLFileName = aConfigXMLFileName ? aConfigXMLFileName : [applicationDelegate valueForKey:APP_DELEGATE_CONFIG_XML_PATH_PROPERTY_NAME];

    NSString *configString = [NSString stringWithContentsOfFile:configXMLFileName encoding:NSUTF8StringEncoding error:nil];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:configString options:0 error:nil];
    NSString *xpathForNetwork = [NSString stringWithFormat:@"//%@", CONFIG_NETWORK];
    NSArray *items = [doc nodesForXPath:xpathForNetwork error:nil];

    for (DDXMLElement *item in items) {

        for (DDXMLElement *child in item.children) {
            if ([child.name isEqualToString:CONFIG_TYPE]) {
                [socialNetwork release];
                NSString *networkType = child.stringValue;
                socialNetwork = [[self createNetworkWithType:networkType] retain];
                socialNetwork.logo = [UIImage imageNamed:networkType];
                [socialNetwork setType:child.stringValue];
                [socialNetworks addObject:socialNetwork];
            } else {
                if (child.childCount <= 1) {
                    [socialNetwork setValue:child.stringValue forKey:child.name];
                }
            }
        }

    }

    [doc release];

    NSArray *resultArray = [NSArray arrayWithArray:socialNetworks];
    [socialNetworks release];

    return resultArray;
}

- (NSArray *)getNetworks {
    if ( ! self.socialNetworks ) {
        [self setSocialNetworks:[self getNetworksFromConfigFileName:nil]];
    }

    return self.socialNetworks;
}

- (SNSocialNetwork *)getNetworkWithType:(NSString *)type {
    NSArray *networks = [[SNSocialsXMLParser instance] getNetworks];

    for (SNSocialNetwork *network in networks) {
        if ([network.type isEqualToString:type] ) {
            return network;
        }
    }

    return nil;
}

- (SNSocialNetwork *)createNetworkWithType:(NSString *)networkType {
    SNSocialNetwork *resultSocialNetwork = nil;
    NSString *className = [[NSString alloc] initWithFormat:@"%@Network", networkType];
    resultSocialNetwork = [[NSClassFromString(className) alloc] init];
    [className release];
    return [resultSocialNetwork autorelease];

}

- (void)dealloc {
    [_socialNetworks release];
    [super dealloc];
}

@end
