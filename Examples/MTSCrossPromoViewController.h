//
//  ViewController.h
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFNetworkManager.h"
#import "../../SocialNetworks/Auxiliary/SNCrossPromoXMLLoader.h"
#import "../../SocialNetworks/Auxiliary/SNCrossPromoDataLoader.h"

@interface MTSCrossPromoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MTSCrossPromoDataLoaderDelegate> {
@private
    UIView *loadingView;
    UITableView *mainTableView;
    NSUInteger applicationsCount;

}


@end
