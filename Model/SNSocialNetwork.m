//
//  SNSocialNetwork.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNSocialNetwork.h"

@implementation SNSocialNetwork
@synthesize name;
@synthesize token;
@synthesize post;
@synthesize secret;
@synthesize logo;
@synthesize subject;
@synthesize link;
@synthesize picture;
@synthesize messageName;
@synthesize messageCaption;
@synthesize messageDescription;

- (void)dealloc {
    [name release];
    [token release];
    [post release];
    [secret release];
    [logo release];
    [subject release];
    [link release];
    [picture release];
    [messageName release];
    [messageCaption release];
    [messageDescription release];
    [super dealloc];

}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@,%@,%@} %@", self.name, self.post, self.token, [super description]];

}

- (void)postMessage {
    NSLog(@"Posting to %@: %@", self.name, self.post);

}

@end
