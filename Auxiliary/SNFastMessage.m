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
    [self showFastMessageWithTitle:title message:@"" delegate:nil];
}

+ (void)showFastMessageWithTitle:(NSString *)title message:(NSString *)message{
    [self showFastMessageWithTitle:title message:message delegate:nil];
}

+ (void)showFastMessageWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
}
@end
