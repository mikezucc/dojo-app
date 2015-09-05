//
//  DOJONotificationViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 12/27/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "DOJONotificationCell.h"
#import "DOJOPeekButton.h"
#import "networkConstants.h"
#import "DOJOPerformAPIRequest.h"
#import "DOJOHomeTableSwagView.h"

@protocol NotiDelegate <NSObject>

@required
-(void)swipeStartedMAJOR;
-(void)swipeIsMovingMAJOR:(NSNumber *)distance;
-(void)swipeLetGoMAJOR;

-(void)homeTableViewTouchStarted2:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)homeTableViewTouchSwiping2:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)homeTableViewTouchCancelled2;

@end

@interface DOJONotificationViewController : UIViewController <NotiCellegate, APIRequestDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;
@property (weak, nonatomic) id<NotiDelegate> delegate;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) BOOL didPerformSwipeMovement;

@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;

@property (strong, nonatomic) IBOutlet DOJOHomeTableSwagView *notiTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *dojoSearchBar;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (nonatomic) BOOL isSearching;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *temporaryDirectory;

@property (strong ,nonatomic) NSArray *notificationFeedData;

-(void)mixedSearch;
-(void)reloadNotificationFeed;
-(void)genericRefresh;

@end
