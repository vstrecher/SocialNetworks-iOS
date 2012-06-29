@class VkontakteVC;

//
//  Created by eugene on 29.06.12.
//
@protocol VkontakteVCDelegate <NSObject>
- (void)vk:(VkontakteVC *)viewController completedAuthenticationWithStatus:(BOOL)isSuccessful;
@end