//
//  MTSSharingViewController.m
//  MTSSharing
//
//  Created by Dymov Eugene on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MTSSharingViewController.h"
#import "SNSocialNetwork.h"
#import "SNSocialsXMLParser.h"
#import "SNDefines.h"

@interface MTSSharingViewController ()

- (void)removeObserverForNotifications;

- (void)showModalViewController:(NSNotification *)notification;

- (void)hideModalViewController:(NSNotification *)notification;


@end

@implementation MTSSharingViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    socialNetworks = [[NSMutableArray alloc] init];
    socialNetwork = nil;

    socialNetworks = [[[SNSocialsXMLParser instance] getNetworks] retain];

    mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showModalViewController:) name:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideModalViewController:) name:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}

- (void)viewDidUnload
{
    [self removeObserverForNotifications];

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [self removeObserverForNotifications];

    [socialNetwork release];
    [socialNetworks release];
    [mainTableView release];
    [super dealloc];

}

- (void)removeObserverForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOW_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_MODAL_VIEW_CONTROLLER_NOTIFICATION object:nil];

}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return socialNetworks.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentificator";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    SNSocialNetwork *currentSocialNetwork = [socialNetworks objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = currentSocialNetwork.name;
    cell.imageView.image = currentSocialNetwork.logo;
    
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;

}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SNSocialNetwork *currentSocialNetwork = [socialNetworks objectAtIndex:(NSUInteger) indexPath.row];
    [currentSocialNetwork postMessage];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];


}

- (void)showModalViewController:(NSNotification *)notification {
    [self presentModalViewController:[notification.userInfo objectForKey:NOTIFICATION_VIEW_CONTROLLER] animated:YES];

}

- (void)hideModalViewController:(NSNotification *)notification {
    [self dismissModalViewControllerAnimated:YES];

}





@end
