//
//  SNCrossPromoXMLLoader.h
//  Employees
//
//  Created by Dymov Eugene on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNCrossPromoXMLLoader;

@protocol MTSCrossPromoXMLLoaderDelegate
@required
- (void)xmlLoader:(SNCrossPromoXMLLoader *)xmlLoader gotResponseString:(NSString *)responseString;
- (void)xmlLoader:(SNCrossPromoXMLLoader *)xmlLoader gotError:(NSError *)error;
@end


@interface SNCrossPromoXMLLoader : NSObject <NSURLConnectionDataDelegate> {
    NSMutableData *xmlData;
    id<MTSCrossPromoXMLLoaderDelegate>loadDelegate;
    NSString *xmlResponseString;
}

@property(nonatomic, assign) id <MTSCrossPromoXMLLoaderDelegate> loadDelegate;
@property(nonatomic, retain) NSString *xmlResponseString;


+ (SNCrossPromoXMLLoader *)instance;
- (void)loadXMLWithDelegate:(id <MTSCrossPromoXMLLoaderDelegate>)aLoadDelegate;

@end
