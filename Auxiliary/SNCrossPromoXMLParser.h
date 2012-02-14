//
//  SNCrossPromoXMLParser.h
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBXML;
@class SNApplicationObject;

@interface SNCrossPromoXMLParser : NSObject {
    TBXML *tbxml;
    SNApplicationObject *applicationObject;
    NSMutableArray *applications;
}
+ (SNCrossPromoXMLParser *)instance;

- (NSArray *)getItems:(NSString *)xmlContents;


@end
