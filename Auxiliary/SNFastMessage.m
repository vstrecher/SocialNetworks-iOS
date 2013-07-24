//
//  SNFastMessage.m
//  Debts
//
//  Created by Dymov Eugene on 17.10.11.
//  Copyright (c) 2011 MobileUp LLC.. All rights reserved.
//

#import "SNFastMessage.h"
#import "SNDefines.h"

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

+ (NSString*) localizedToken: (NSString *) tokenKey defaultValue: (NSString *) defaultValue {
    NSString *result = nil;
    
    @try {
        if([[UIApplication sharedApplication].delegate respondsToSelector: NSSelectorFromString(APP_DELEGATE_TOKEN_FOR_SN)] == YES) {
            result = [[UIApplication sharedApplication].delegate performSelector: NSSelectorFromString(APP_DELEGATE_TOKEN_FOR_SN) withObject: tokenKey];
        }
        if(result == nil) {
            result = NSLocalizedString(defaultValue, defaultValue);
        }
    }
    @catch (NSException *exception) {
        Log(@"Exception when recive localize token : %@", exception);
    }
    
    
    return result;
}

@end
