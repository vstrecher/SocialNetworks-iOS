//
//  SNCrossPromoXMLParser.m
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNCrossPromoXMLParser.h"
#import "../Model/SNApplicationObject.h"
#import "DDXMLDocument.h"

@interface SNCrossPromoXMLParser ()
- (void)kissTraverseElement:(DDXMLNode *)element;

//- (void)traverseElement:(TBXMLElement *)element;

@end

@implementation SNCrossPromoXMLParser

+ (SNCrossPromoXMLParser *)instance {
    static SNCrossPromoXMLParser *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (NSArray *)getItems:(NSString *)xmlContents {
    applications = [[NSMutableArray alloc] init];

    NSError *error = nil;
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:xmlContents options:0 error:&error];

    /*
    for (DDXMLElement *child in root.children) {
        MLOG(@"%@", child.name);
        for (DDXMLElement *children in child.children) {
            MLOG(@"  %@ -> %@ [%d]", children.name , children.stringValue, children.childCount);
        }


    }
    */

    DDXMLNode *root = [doc nextNode];
    if (root) {
        [self kissTraverseElement:root];
    }


    /*
    tbxml = [[TBXML tbxmlWithXMLString:xmlContents error:nil] retain];

    if (tbxml.rootXMLElement)
        [self traverseElement:tbxml.rootXMLElement];

    [tbxml release];

    return [applications autorelease];
    */

    [doc release];
    return [applications autorelease];

}


- (void)kissTraverseElement:(DDXMLNode *)element {
    do {

        NSString *elementName = element.name;
        NSString *textForElement = element.stringValue;

//        MLOG(@"%@[%d]", elementName, element.childCount);

        if ([elementName isEqualToString:@"Application"]) {
            [applicationObject release];
            applicationObject = [[SNApplicationObject alloc] init];
            [applications addObject:applicationObject];
        }

        if (element.childCount > 1) {
            DDXMLNode *nextNode = element.nextNode;
            [self kissTraverseElement:nextNode];
        } else {
            [applicationObject setValue:textForElement forKey:elementName];

        }


    } while ((element = element.nextSibling));
}

/*
- (void) traverseElement:(TBXMLElement *)element {
    do {
        NSString *elementName = [TBXML elementName:element];
        NSString *textForElement = [TBXML textForElement:element];

        if ([elementName isEqualToString:@"Application"]) {
            [applicationObject release];
            applicationObject = [[ApplicationObject alloc] init];

            [applications addObject:applicationObject];

        } else if (![elementName isEqualToString:@"ExportApplicationInfo"]) {
            [applicationObject setValue:textForElement forKey:elementName];

        }

        if (element->firstChild)
            [self traverseElement:element->firstChild];

    } while ((element = element->nextSibling));

}
*/

@end
