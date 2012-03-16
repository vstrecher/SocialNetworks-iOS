//
//  MTSSharingViewController.h
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_DELEGATE_CONFIG_XML_PATH_PROPERTY_NAME @"pathForSocialSharingConfigXML"

@class TBXML;
@class SNSocialNetwork;

@interface MTSSharingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    TBXML *tbxml;
    NSArray *socialNetworks;
    SNSocialNetwork *socialNetwork;
    UITableView *mainTableView;

}

@end
