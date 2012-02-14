//
//  ViewController.h
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFNetworkManager.h"
#import "SNCrossPromoXMLLoader.h"
#import "SNCrossPromoDataLoader.h"

@interface MTSCrossPromoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SNCrossPromoDataLoaderDelegate> {
@private
    UIView *loadingView;
    UITableView *mainTableView;
    NSUInteger applicationsCount;

}


@end
