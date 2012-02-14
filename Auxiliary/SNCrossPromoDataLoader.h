//
//  MTSCrossPromoDataSource.h
//  Employees
//
//  Created by Dymov Eugene on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCrossPromoXMLLoader.h"
#import "SFNetworkManager.h"

@class SNCrossPromoDataLoader;
@class SNApplicationObject;

@protocol SNCrossPromoDataLoaderDelegate
@required
- (void)dataLoaderReady:(SNCrossPromoDataLoader *)dataLoader itemsCount:(NSUInteger)itemsCount;
- (void)dataLoader:(SNCrossPromoDataLoader *)dataLoader gotLogoForItem:(NSUInteger)itemIndex;
- (void)dataLoader:(SNCrossPromoDataLoader *)dataLoader failedWithError:(NSError *)error;
@end


@interface SNCrossPromoDataLoader : NSObject <SNCrossPromoXMLLoaderDelegate, SFNetworkManagerDelegate> {
    id<SNCrossPromoDataLoaderDelegate> dataDelegate;
    NSString *xmlContents;
    NSArray *applicationsArray;
    NSMutableDictionary *applicationsLogosDictionary;
}

@property(nonatomic, assign) id <SNCrossPromoDataLoaderDelegate> dataDelegate;
@property(nonatomic, retain) NSString *xmlContents;
@property(nonatomic, retain) NSArray *applicationsArray;
@property(nonatomic, retain) NSMutableDictionary *applicationsLogosDictionary;


+ (SNCrossPromoDataLoader *)instance;

- (void)startWithDelegate:(id <SNCrossPromoDataLoaderDelegate>)aDataDelegate;
- (SNApplicationObject *)itemWithIndex:(NSUInteger)itemIndex;


@end
