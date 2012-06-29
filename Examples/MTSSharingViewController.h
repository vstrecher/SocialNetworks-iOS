//
//  MTSSharingViewController.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNSocialNetwork;

@interface MTSSharingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *socialNetworks;
    SNSocialNetwork *socialNetwork;
    UITableView *mainTableView;

}

@end
