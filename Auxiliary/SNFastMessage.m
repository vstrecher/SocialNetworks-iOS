//
//  SNFastMessage.m
//  Debts
//
//  Created by Dymov Eugene on 17.10.11.
//  Copyright (c) 2011 MobileUp LLC.. All rights reserved.
//

#import "SNFastMessage.h"

@implementation SNFastMessage

+ (void)showFastMessageWithTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
}

+ (void)showFastMessageWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
}
@end
