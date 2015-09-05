//
//  DOJOHomeTableViewBox.h
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import "DOJOHomeTableViewCell.h"
#import "DOJONetTestViewController.h"
#import "DOJOPostCollectionViewCell.h"
//#import "DOJOHomeViewController.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import <CoreLocation/CoreLocation.h>
#import "DOJOSearch4DojoTableViewCell.h"
#import "networkConstants.h"
#import "DOJOSampleView.h"

@interface DOJOHomeTableViewBox : UIView <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>

-(void)didChangeHomeType:(UISegmentedControl *)segControl;
@property (nonatomic) NSInteger selectedHomeType;
@property (nonatomic) BOOL isSearching;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UISearchBar *dojoSearchBar;
@property (strong, nonatomic) NSArray *searchTableViewData;
@property (strong, nonatomic) NSArray *locationTableViewData;
@property (strong, nonatomic) DOJOSearch4DojoTableViewCell *searchCell;
@property int homeLoadMask;
-(void)reloadTheSearchData;

@property (strong, nonatomic) DOJOSampleView *sampleView;

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecTap;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGesture;
@property NSInteger rowTapped;
@property BOOL didTapMessage;

@property (strong,nonatomic) IBOutlet UITableView *dojoTableView;
@property CGPoint lastOffset;
@property BOOL downards;
@property (strong, nonatomic) DOJOHomeTableViewCell *dojoCell;
-(IBAction)switchFollowState:(UIButton *)button;
@property (strong, nonatomic) NSString *userEmail;
@property (nonatomic) NSInteger indexOfSelectedButton;

@property (strong, nonatomic) NSArray *dojoTableViewData;

-(void)loadDojoHomeNotSearching;

@end
