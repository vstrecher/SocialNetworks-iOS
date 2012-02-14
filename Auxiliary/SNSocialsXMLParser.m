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
- (SNSocialNetwork *)createNetworkWithType:(NSString *)networkType;


@end

@implementation SNSocialsXMLParser

+ (SNSocialsXMLParser *)instance {
    static SNSocialsXMLParser *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (NSArray *)getNetworks {
    socialNetworks = [[NSMutableArray alloc] init];

    NSString *configString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CONFIG_FILE_NAME ofType:CONFIG_FILE_EXTENSION] encoding:NSUTF8StringEncoding error:nil];
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
                [socialNetworks addObject:socialNetwork];
            } else {
                if (child.childCount <= 1) {
                    [socialNetwork setValue:child.stringValue forKey:child.name];
                }
            }
        }

    }

    [doc release];
    return [socialNetworks autorelease];

    /*
    tbxml = [[TBXML tbxmlWithXMLFile:CONFIG_FILE_NAME error:nil] retain];

    if (tbxml.rootXMLElement)
        [self traverseElement:tbxml.rootXMLElement];

    [tbxml release];

    return [socialNetworks autorelease];
    */



}

/*
- (void) traverseElement:(TBXMLElement *)element {
    do {
        NSString *elementName = [TBXML elementName:element];
        NSString *textForElement = [TBXML textForElement:element];

        if ([elementName isEqualToString:CONFIG_TYPE]) {
            [socialNetwork release];
            NSString *networkType = textForElement;
            socialNetwork = [[self createNetworkWithType:networkType] retain];
            socialNetwork.logo = [UIImage imageNamed:networkType];
            [socialNetworks addObject:socialNetwork];

        } else if (![elementName isEqualToString:CONFIG_NETWORK] && ![elementName isEqualToString:CONFIG_NETWORKS]){
            [socialNetwork setValue:textForElement forKey:elementName];

        }

        if (element->firstChild)
            [self traverseElement:element->firstChild];

    } while ((element = element->nextSibling));

}
 */

- (SNSocialNetwork *)createNetworkWithType:(NSString *)networkType {
    SNSocialNetwork *resultSocialNetwork = nil;
    NSString *className = [[NSString alloc] initWithFormat:@"%@Network", networkType];
    resultSocialNetwork = [[NSClassFromString(className) alloc] init];
    [className release];
    return [resultSocialNetwork autorelease];

}

@end
