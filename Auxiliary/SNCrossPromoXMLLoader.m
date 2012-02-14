//
//  SNCrossPromoXMLLoader.m
//  Employees
//
//  Created by Dymov Eugene on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNCrossPromoXMLLoader.h"
#import "SNDefines.h"

@implementation SNCrossPromoXMLLoader

@synthesize loadDelegate;
@synthesize xmlResponseString;


+ (SNCrossPromoXMLLoader *)instance {
    static SNCrossPromoXMLLoader *_instance = nil;

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
        xmlData = [[NSMutableData alloc] init];
        self.xmlResponseString = nil;
        self.loadDelegate = nil;
    }

    return self;
}

- (void)loadXMLWithDelegate:(id <MTSCrossPromoXMLLoaderDelegate>)aLoadDelegate {
    self.loadDelegate = aLoadDelegate;

    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:XML_URL]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    [urlConnection release];
    [urlRequest release];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [xmlData setData:nil];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadDelegate xmlLoader:self gotError:error];

    [xmlData setData:nil];
    self.xmlResponseString = nil;

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [xmlData appendData:data];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    self.xmlResponseString = responseString;
    [responseString release];

    [self.loadDelegate xmlLoader:self gotResponseString:self.xmlResponseString];

}

@end
