//
//  DOJOSearch4DojosViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 10/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import "DOJOSearch4DojoTableViewCell.h"
#import "DOJOInviteButton.h"
#import <CoreLocation/CoreLocation.h>
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "DOJOSearchJoinAlertView.h"
#import "DOJOSpecialDojoPageViewController.h"
#import "networkConstants.h"


@interface DOJOSearch4DojosViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *dojoSearchBar;

@property (strong, nonatomic) DOJOSearch4DojoTableViewCell *searchCell;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) NSString *initialSearchString;
@property (strong, nonatomic) NSArray *searchTableViewData;
@property (strong, nonatomic) NSArray *locationTableViewData;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSwitcha;
@property (strong, nonatomic) DOJOSearchJoinAlertView *joinAlertView;

@property (strong, nonatomic) NSDictionary *selectedDojoInfo;

// location info
@property (strong, nonatomic) CLLocation *dojoLocation;
@property (strong, nonatomic) CLLocationManager *dojoLocationManager;
@property BOOL foundLocationYet;
@property BOOL sawFirstTime;

//AWS
@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;

-(IBAction)inviteYourself:(id)sender;
-(IBAction)changeSearchType:(UISegmentedControl *)segmentedControl;
-(IBAction)refreshSearch:(id)sender;

@end
