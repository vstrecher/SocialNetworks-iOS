//
//  MTSCrossPromoDataSource.m
//  Employees
//
//  Created by Dymov Eugene on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNCrossPromoDataLoader.h"
#import "SNCrossPromoXMLLoader.h"
#import "../Model/SNApplicationObject.h"
#import "SNCrossPromoXMLParser.h"
#import "SFNetworkManager.h"

@implementation SNCrossPromoDataLoader

@synthesize dataDelegate;
@synthesize xmlContents;
@synthesize applicationsArray;
@synthesize applicationsLogosDictionary;


+ (SNCrossPromoDataLoader *)instance {
    static SNCrossPromoDataLoader *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.applicationsLogosDictionary = [[[NSMutableDictionary alloc] init] autorelease];

    }

    return self;
}


- (void)startWithDelegate:(id <SNCrossPromoDataLoaderDelegate>)aDataDelegate {
    self.dataDelegate = aDataDelegate;
    [[SNCrossPromoXMLLoader instance] loadXMLWithDelegate:self];
}

- (SNApplicationObject *)itemWithIndex:(NSUInteger)itemIndex {
    if (itemIndex < self.applicationsArray.count) {
        SNApplicationObject *requestedItem = [self.applicationsArray objectAtIndex:itemIndex];

        if (!requestedItem.image) {
            UIImage *applicationLogo = [self.applicationsLogosDictionary objectForKey:[NSNumber numberWithInt:itemIndex]];

            if (applicationLogo) {
                requestedItem.image = applicationLogo;
            } else {
                NSData *imageData = [[SFNetworkManager sharedInstance] getData:requestedItem.IconURL withDelegate:self forObject:[NSNumber numberWithInt:itemIndex] forceUpdate:NO];
                if (imageData) {
                    applicationLogo = [[UIImage alloc] initWithData:imageData];
                    requestedItem.image = applicationLogo;
                    [self.applicationsLogosDictionary setObject:applicationLogo forKey:[NSNumber numberWithInt:itemIndex]];
                    [applicationLogo release];
                } else {
                    requestedItem.image = nil;
                }
            }
        }

        return requestedItem;

    }

    return nil;

}

#pragma mark - SFNetworkManagerDelegate

- (void)networkManager:(SFNetworkManager *)manager didGetData:(NSData *)data forObject:(id)object {
    NSNumber *itemIndex = object;
    UIImage *image = [[UIImage alloc] initWithData:data];
    [self.applicationsLogosDictionary setObject:image forKey:itemIndex];
    [image release];

    [self.dataDelegate dataLoader:self gotLogoForItem:itemIndex.unsignedIntegerValue];
}

- (void)networkManager:(SFNetworkManager *)manager didFailToGetDataForObject:(id)object {
    [self.dataDelegate dataLoader:self failedWithError:nil];
}

- (void)networkManager:(SFNetworkManager *)manager didFailToGetDataForObject:(id)object withError:(NSError *)error {
    [self.dataDelegate dataLoader:self failedWithError:error];
}


#pragma mark - MTSCrossPromoXMLLoaderDelegate

- (void)xmlLoader:(SNCrossPromoXMLLoader *)xmlLoader gotResponseString:(NSString *)responseString {
    self.xmlContents = responseString;
    self.applicationsArray = [[SNCrossPromoXMLParser instance] getItems:self.xmlContents];

    if (self.applicationsArray.count) {
        [self.dataDelegate dataLoaderReady:self itemsCount:self.applicationsArray.count];
    } else {
        [self.dataDelegate dataLoader:self failedWithError:nil];
    }

}

- (void)xmlLoader:(SNCrossPromoXMLLoader *)xmlLoader gotError:(NSError *)error {
    [self.dataDelegate dataLoader:self failedWithError:error];

}

- (void)dealloc {
    [applicationsLogosDictionary release];
    [super dealloc];
}

@end
