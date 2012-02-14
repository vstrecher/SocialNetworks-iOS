//
//  MUDownloader.h
//
//  Created by Eugeny Valeyev on 23.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUDownloader.h"

#define CONNECTION_TIMEOUT   30.0f
#define MAX_CAPACITY         10

@implementation MUDownloader

static NSUInteger connectionsCount = 0;

@synthesize data = data_;
@synthesize url = url_;
@synthesize object = object_;
@synthesize delegates = delegates_;
@synthesize body = body_;
@synthesize started;

- (id)initWithDelegate:(id)aDelegate {
    if((self = [super init])) {
        delegate_ = aDelegate;
        delegates_ = [[NSMutableArray alloc] initWithCapacity:MAX_CAPACITY];
    }
    return self;
}

- (void)dealloc {
    delegate_ = nil;
    [delegates_ release], delegates_ = nil;
    [body_ release];
    [url_ release];
    [buf_ release];
    [data_ release];
    [conn_ release];
    [object_ release];
    [super dealloc];
}

- (void)start:(NSString*)anUrl {
    [url_ release];
    [conn_ release];
    [buf_ release];

    url_ = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)anUrl, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    NSURL *u = [[NSURL alloc] initWithString:url_];
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:u
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:CONNECTION_TIMEOUT];
    if (self.body) {
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:self.body];
        [req setValue:@"OTTIPHONE" forHTTPHeaderField:@"User-Agent"];
    } else {
        [req setHTTPMethod:@"GET"];
    }

    conn_ = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    buf_ = [[NSMutableData alloc] initWithCapacity:1024];
    [req release];
    [u release];

    connectionsCount++;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    started = YES;
}

- (void)cancel {
    started = NO;
    if (--connectionsCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    [conn_ cancel];
    [conn_ release];
    conn_ = nil;
    [buf_ release];
    buf_ = nil;
}

- (void)appendDelegate:(id)object {
    [delegates_ addObject:object];
}

- (void)removeDelegate:(id)object {
    [delegates_ removeObject:object];
}

- (BOOL)hasDelegates {
    return !!delegates_ && [delegates_ count] > 0;
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response {
    [buf_ setLength:0];
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
    [buf_ appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error {
    [conn_ release];
    conn_ = nil;
    [buf_ release];
    buf_ = nil;

    if (--connectionsCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    NSLog(@"Connection failed! Error - %@ %@",
            [error localizedDescription],
            [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

    if (delegate_ && [delegate_ conformsToProtocol:@protocol(MUDownloaderDelegate)]) {
        [delegate_ downloaderDidFail:self error:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    if (--connectionsCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    [data_ release];
    data_ = [[NSData alloc] initWithData:buf_];

    [conn_ release];
    conn_ = nil;
    [buf_ release];
    buf_ = nil;

    if (delegate_ && [delegate_ conformsToProtocol:@protocol(MUDownloaderDelegate)]) {
        [delegate_ downloaderDidSucceed:self];
    }
}

//https auth stuff
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//    if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];

    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];

}

@end
