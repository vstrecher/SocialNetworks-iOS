//
//  SNFastMessage.h
//  Debts
//
//  Created by Dymov Eugene on 17.10.11.
//  Copyright (c) 2011 MobileUp LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFastMessage : NSObject

+ (void)showFastMessageWithTitle:(NSString *)title;

+ (void)showFastMessageWithTitle:(NSString *)title message:(NSString *)message;

+ (void)showFastMessageWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

+ (NSString*) localizedToken: (NSString *) tokenKey defaultValue: (NSString *) defaultValue;

@end
