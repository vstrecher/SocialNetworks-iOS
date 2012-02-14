//
//  SFNetworkManager.h
//  Snowflake
//
//  Created by Ivan Chalov on 19/12/2011.
//  Copyright (c) 2011 Eugene Valeyev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUDownloader.h"

@class SFNetworkManager;
@protocol SFNetworkManagerDelegate <NSObject>
- (void)networkManager:(SFNetworkManager *)manager didGetData:(NSData *)data forObject:(id)object;
- (void)networkManager:(SFNetworkManager *)manager didFailToGetDataForObject:(id)object;
@optional
- (void)networkManager:(SFNetworkManager *)manager didFailToGetDataForObject:(id)object withError:(NSError *)error;
@end

@interface SFNetworkManager : NSObject<MUDownloaderDelegate>

+ (SFNetworkManager *)sharedInstance;

- (NSData *)getData:(NSString*)url withDelegate:(id<SFNetworkManagerDelegate>)delegate forObject:(id)object forceUpdate:(BOOL)forceUpdate;
- (NSData *)getData:(NSString *)url withDelegate:(id<SFNetworkManagerDelegate>)delegate withBody:(NSData *)body forObject:(id)object forceUpdate:(BOOL)forceUpdate;
- (BOOL)cancelDownloading:(NSString *)URL forDelegate:(id<SFNetworkManagerDelegate>)delegate;
- (BOOL)isConnectionListEmpty;

@end
