//
//  ViewController.m
//  MTSCrossPromo
//
//  Created by Dymov Eugene on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MTSCrossPromoViewController.h"
#import "SNCrossPromoXMLParser.h"
#import "SNApplicationObject.h"
#import "SNCrossPromoXMLLoader.h"
#import "SNFastMessage.h"
#import "SNCrossPromoDataLoader.h"

@implementation MTSCrossPromoViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)setup {
    loadingView = [[UIView alloc] init];
    mainTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];

}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];

    }

    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    loadingView.frame = CGRectMake(0, 0, 120, 20);
    loadingView.backgroundColor = [UIColor clearColor];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(10, 10);
    [activityIndicatorView startAnimating];
    [loadingView addSubview:activityIndicatorView];
    [activityIndicatorView release];

    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.frame = CGRectMake(30, 0, 90, 20);
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.text = NSLocalizedString(@"Загрузка...", @"Загрузка...");
    loadingLabel.textColor = [UIColor darkGrayColor];
    [loadingView addSubview:loadingLabel];
    [loadingLabel release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [mainTableView removeFromSuperview];

    loadingView.center = self.view.center;
    [self.view addSubview:loadingView];
    
    [[SNCrossPromoDataLoader instance] startWithDelegate:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [loadingView release];
    [mainTableView release];
    [super dealloc];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return applicationsCount;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentificator";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }

    SNApplicationObject *currentApplication = [[SNCrossPromoDataLoader instance] itemWithIndex:indexPath.row];

    cell.imageView.image = currentApplication.image;
    cell.textLabel.text = currentApplication.Label;
    cell.detailTextLabel.text = currentApplication.ShortDescription;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;

}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SNApplicationObject *currentApplication = [[SNCrossPromoDataLoader instance] itemWithIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentApplication.Url]];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -MTSCrossPromoDataLoaderDelegate

- (void)dataLoaderReady:(SNCrossPromoDataLoader *)dataLoader itemsCount:(NSUInteger)itemsCount {
    applicationsCount = itemsCount;

    [loadingView removeFromSuperview];

    mainTableView.frame = self.view.frame;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];

}

- (void)dataLoader:(SNCrossPromoDataLoader *)dataLoader gotLogoForItem:(NSUInteger)itemIndex {
    [mainTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:itemIndex inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dataLoader:(SNCrossPromoDataLoader *)dataLoader failedWithError:(NSError *)error {
    [SNFastMessage showFastMessageWithTitle:@"Возникла ошибка" message:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
}


@end
