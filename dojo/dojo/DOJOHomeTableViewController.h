//
//  DOJOHomeTableViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOSwagCell.h"
#import "DOJONotificationCell.h"
#import "DOJOSampleView.h"
#import "DOJOPage.h"
#import "networkConstants.h"
#import "DOJOCameraViewController.h"
#import "DOJONotificationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "DojoPageMessageView.h"
#import "DOJOPerformAPIRequest.h"
#import "DOJOHomeTableSwagView.h"

@interface DOJOHomeTableViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, CameraControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, APIRequestDelegate, HomeTableViewDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) NSInteger locUpdateCount;

@property (nonatomic) CGPoint startTouch;
@property (nonatomic) BOOL didMoveTheRow;

@property (strong, nonatomic) DOJOCameraViewController *cameraVC;
@property (strong, nonatomic) DOJONotificationViewController *notiVC;
@property (nonatomic) BOOL didLoadCamera;
@property (nonatomic) BOOL didLoadNotiVC;
@property (nonatomic) BOOL statusBarHide;
@property (nonatomic) BOOL didStartCameraSession;
@property (nonatomic) BOOL forwardToCamera;

@property (strong, nonatomic) NSString *forwardCameraString;

@property (nonatomic) BOOL shouldOpenWithChat;

@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (strong, nonatomic) IBOutlet UIButton *leftHeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *rightHeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *cameraHeaderButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsHeaderButton;
@property (strong, nonatomic) IBOutlet UILabel *numberUndeadLabel;

@property (strong, nonatomic) IBOutlet UIView *cameraContainer;
@property (strong, nonatomic) IBOutlet UIView *notificationsContainer;

@property (strong, nonatomic) IBOutlet DOJOHomeTableSwagView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIView *containerBanana;
@property (strong, nonatomic) IBOutlet UIButton *settingsIcon;
@property (strong, nonatomic) IBOutlet UIButton *createIcon;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) UISearchBar *dojoSearchBar;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refresh;
@property (strong, nonatomic) DOJOPeekButton *storePeek;
@property (strong ,nonatomic) NSDictionary *selectedDojoInfo;
@property (strong, nonatomic) NSString *selectedHashForDojo;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *temporaryDirectory;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSDictionary *selectedPerson;
@property (strong, nonatomic) IBOutlet UIView *topHeaderView;
@property (strong, nonatomic) IBOutlet UIView *loadingdojoview;

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) DOJOSampleView *sampleView;

@property (strong, nonatomic) NSMutableArray *colorList;

@property (strong, nonatomic) NSArray *dojoTableViewData;
@property (strong, nonatomic) NSArray *searchTableViewData;
@property (strong, nonatomic) NSArray *locationTableViewData;
@property (strong, nonatomic) NSArray *notificationFeedData;
@property (strong, nonatomic) NSMutableArray *usableLocations;
@property (strong, nonatomic) NSIndexPath *cellWithMessageView;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL firsTimeBoot;
@property (nonatomic) BOOL chatOpenSomewhere;

-(void)addToUploadQueue:(AWSS3TransferManagerUploadRequest *)uploadRequest;
-(void)goToProfileVC:(NSDictionary *)selectedSelf;

@end
