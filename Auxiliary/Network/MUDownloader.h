//
//  MUDownloader.h
//
//  Created by Eugeny Valeyev on 23.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MUDownloader;


@protocol MUDownloaderDelegate <NSObject>
@required
- (void)downloaderDidSucceed:(MUDownloader*)sender;
- (void)downloaderDidFail:(MUDownloader*)sender error:(NSError*)error;

@end


@interface MUDownloader : NSObject {
@private
	id<MUDownloaderDelegate> delegate_;
    NSMutableArray *delegates_;
	NSMutableData* buf_;
	NSURLConnection* conn_;

	NSString* url_;
	NSData* data_;
    
    id object_;
    NSData *body_;
    
    BOOL started;
}

@property (nonatomic, retain) NSMutableArray *delegates;
@property (nonatomic, readonly) NSData* data;
@property (nonatomic, readonly) NSString* url;
@property (nonatomic, retain)   id object;
@property (nonatomic, readonly, getter = isStarted) BOOL started;
@property (nonatomic, retain) NSData *body;

- (id)initWithDelegate:(id)aDelegate;
- (void)start:(NSString*)aUrl;
- (void)cancel;
- (void)appendDelegate:(id)object;
- (void)removeDelegate:(id)object;
- (BOOL)hasDelegates;

@end
