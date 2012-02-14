//
//  SFNetworkManager.m
//  Snowflake
//
//  Created by Ivan Chalov on 19/12/2011.
//  Copyright (c) 2011 Eugene Valeyev. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "SFNetworkManager.h"

#define NETWORK_CACHE_DIR       @"NetworkCache"
#define MAX_CAPACITY            100
#define MAX_ALLOWED_DOWNLOADS   10

@interface SFNetworkManager()
+ (void)createCacheFolder;
+ (NSString*)getCacheDirPath;

- (void)startDownloaderIfNeeded;

- (void)sendRequest:(NSString*)url withDelegate:(id<SFNetworkManagerDelegate>)delegate forObject:(id)object;
- (void)sendRequest:(NSString *)url withDelegate:(id<SFNetworkManagerDelegate>)delegate withBody:(NSData *)body forObject:(id)object;
- (NSString*)createSafePathFromURL:(NSString*)url;

@property (nonatomic, retain) NSMutableDictionary *downloaders;
@property (nonatomic, assign) int activeDownloads;
@property (nonatomic, retain) NSMutableDictionary *requestBodies;
@end

@implementation SFNetworkManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SFNetworkManager)

@synthesize downloaders,
            activeDownloads,
            requestBodies;

+ (NSString*)getCacheDirPath 
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];   
    NSString *cachePath = [documentsDirectory stringByAppendingPathComponent:NETWORK_CACHE_DIR];
    
    return cachePath;
}

+ (void)createCacheFolder 
{
    NSString *cachePath = [SFNetworkManager getCacheDirPath];
	
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:cachePath isDirectory:nil]) {
		BOOL success = [fileManager createDirectoryAtPath:cachePath 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:&err];
		if(!success) {
			NSLog(@"Failed to create Cache folder at %@",cachePath);
		}
	}
}

- (id)init
{
	if ((self = [super init])) {
        [SFNetworkManager createCacheFolder];
        downloaders  = [[NSMutableDictionary alloc] initWithCapacity:MAX_CAPACITY];
        requestBodies = [[NSMutableDictionary alloc] init];
    }
	return self;    
}

- (BOOL)hasFileAtPath:(NSString *)url 
{
    NSString* safePath = [self createSafePathFromURL:url];
    NSString *cachePath = [SFNetworkManager getCacheDirPath];
    NSString* filePath = [cachePath stringByAppendingPathComponent:safePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSData *)getData:(NSString*)url withDelegate:(id<SFNetworkManagerDelegate>)delegate forObject:(id)object forceUpdate:(BOOL)forceUpdate 
{
    return [self getData:url withDelegate:delegate withBody:nil forObject:object forceUpdate:forceUpdate];
}

- (NSData *)getData:(NSString *)url withDelegate:(id<SFNetworkManagerDelegate>)delegate withBody:(NSData *)body forObject:(id)object forceUpdate:(BOOL)forceUpdate
{
    NSString* safePath = [self createSafePathFromURL:url];
	NSString* pathToFile = nil;
    NSString *cachePath = [SFNetworkManager getCacheDirPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:cachePath]) {
        NSString* filePath = [cachePath stringByAppendingPathComponent:safePath];
        if(![fileManager fileExistsAtPath:filePath] || forceUpdate) {
            [self sendRequest:url withDelegate:delegate withBody:body forObject:object];
        } else {
            pathToFile = filePath;
        }
    }
	return pathToFile ? [NSData dataWithContentsOfFile:pathToFile] : nil;
}

- (BOOL)cancelDownloading:(NSString *)URL forDelegate:(id<SFNetworkManagerDelegate>)delegate
{
    MUDownloader *downloader = [downloaders objectForKey:URL];
    [downloader removeDelegate:delegate];
    if (![downloader hasDelegates]) {
        [downloader cancel];
        [downloaders removeObjectForKey:URL];
        --(self.activeDownloads);
        [self startDownloaderIfNeeded];
    }
    return YES;
}

- (void)cancelAllRequests 
{
    for (id key in downloaders) {
        [[downloaders objectForKey:key] cancel];
    }
    [downloaders removeAllObjects];
}

- (void)sendRequest:(NSString*)url withDelegate:(id<SFNetworkManagerDelegate>)delegate forObject:(id)object 
{
    [self sendRequest:url withDelegate:delegate withBody:nil forObject:object];
}

- (void)sendRequest:(NSString *)url withDelegate:(id<SFNetworkManagerDelegate>)delegate withBody:(NSData *)body forObject:(id)object
{
    MUDownloader *downloader = [[self.downloaders objectForKey:url] retain];
    if (!downloader) {
        downloader = [[MUDownloader alloc] initWithDelegate:self];
        downloader.body = body;
        downloader.object = object;
        [downloaders setObject:downloader forKey:url];
    }
    [downloader appendDelegate:delegate];
    if (![downloader isStarted] && self.activeDownloads < MAX_ALLOWED_DOWNLOADS) {
        [downloader start:url];
        ++(self.activeDownloads);
        NSLog(@"%d", self.activeDownloads);
    }
    [downloader release];
}


- (void)downloaderDidSucceed:(MUDownloader*)sender 
{
	NSString* url = [sender.url retain];
	
    NSString* filePath = nil;
    
	NSData* data = sender.data;
	if (data) {
		NSString *safePath = [self createSafePathFromURL:url];
        NSString *cachePath = [SFNetworkManager getCacheDirPath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:cachePath isDirectory:nil]) {
			filePath=[cachePath stringByAppendingPathComponent:safePath];
            [data writeToFile:filePath atomically:YES];
		}
	}
	NSArray *delegates = [sender.delegates retain];
    id object = [sender.object retain];
    //TODO check delegates not nil after removing downloader
    [downloaders removeObjectForKey:url];
    --(self.activeDownloads);
    [self startDownloaderIfNeeded];
    
    for (id delegate in delegates) {
        if (delegate && [delegate conformsToProtocol:@protocol(SFNetworkManagerDelegate)]) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            [delegate networkManager:self didGetData:data forObject:object];
        }
        else {
            if (nil == delegate) NSLog(@"nil delegate");
            else NSLog(@"not response");
        }
    }
    [object release];
    [url release];
    [delegates release];

}

- (void)downloaderDidFail:(MUDownloader*)sender error:(NSError*)error 
{
	NSString* url = [sender.url retain];
    NSArray *delegates = [sender.delegates retain];
    id object = [sender.object retain];
    
	[downloaders removeObjectForKey:url];
    --(self.activeDownloads);
    [self startDownloaderIfNeeded];

    for (id delegate in delegates) {
        if (delegate && [delegate conformsToProtocol:@protocol(SFNetworkManagerDelegate)]) {
            if ([delegate respondsToSelector:@selector(networkManager:didFailToGetDataForObject:withError:)]) {
                [delegate networkManager:self didFailToGetDataForObject:object withError:(NSError*)error];
            } else {
                [delegate networkManager:self didFailToGetDataForObject:object];
            }
        }
    }
    
    [object release];
    [url release];
    [delegates release];
}

- (NSString *)createSafePathFromURL:(NSString *)url 
{
    NSString *result = nil;
    NSMutableString *retStr = [[NSMutableString alloc] initWithString:url];
    [retStr replaceOccurrencesOfString:@"/" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [retStr length])];
    [retStr replaceOccurrencesOfString:@":" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [retStr length])];
    result = [NSString stringWithString:retStr];
    [retStr release];
    return result;
}

- (BOOL)isConnectionListEmpty
{
    return [downloaders count] == 0;
}

- (void)setActiveDownloads:(int)active
{
    @synchronized (self) {
        activeDownloads = active > 0 ? active : 0;
    }
}

- (int)activeDownloads
{
    return activeDownloads;
}

- (void)startDownloaderIfNeeded
{
    if ([self.downloaders count] == self.activeDownloads) return;
    for (id key in self.downloaders) {
        int possibleToStart = MAX_ALLOWED_DOWNLOADS - self.activeDownloads;
        if (possibleToStart == 0) return;
        MUDownloader *downloader = [self.downloaders objectForKey:key];
        if ([downloader isStarted]) continue;
        //we reach this part if we have place for downloader to start and it's not already started
        [downloader start:key];
        ++(self.activeDownloads);
    }
}

@end
