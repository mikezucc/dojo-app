//
//  DOJORevoViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 12/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import "networkConstants.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "DojoPageMessageView.h"
#import "DOJOMagnifiedImageView.h"
#import "DOJODSV3000.h"
#import "DOJOHomeTableViewController.h"

@interface DOJORevoViewController : UIViewController

@property (strong, nonatomic) UIButton *createPostButton;
@property (strong, nonatomic) UIButton *openCameraButton;
@property (strong, nonatomic) UITextView *sweetMessageView;

@property (strong, nonatomic) DOJODSV3000 *dsv3000;
@property (strong, nonatomic) UIView *dsv300Container;

@property (strong, nonatomic) IBOutlet UILabel *followingLoudLabel;

@property (strong, nonatomic) IBOutlet DojoPageMessageView *messageView;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) NSTimer *sendRotater;
@property (nonatomic) BOOL preventJumping;
@property (strong, nonatomic) NSIndexPath *cellWithMessageView;
@property (nonatomic) BOOL chatOpenSomewhere;
@property (strong, nonatomic) NSDictionary *selectedPostForMessageView;

@property (nonatomic) BOOL shouldOpenWithChat;
@property (nonatomic) BOOL shouldOpenWithPost;

@property (strong, nonatomic) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) AWSS3TransferManager *transferManager;
@property (strong, nonatomic) NSIndexPath *pathOfDownloadingCell;


@property (strong, nonatomic) IBOutlet UITableView *revoTableView;
@property (strong, nonatomic) NSString *selectedHashForDojo;
@property (nonatomic) NSInteger rowToScrollTo;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIImageView *notiBubble;
@property (strong, nonatomic) IBOutlet UIImageView *backTypeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *backButtonForMask;
@property (nonatomic) CGPoint startOffset;
@property (nonatomic) float rotateVal;
@property (strong, nonatomic) NSTimer *rotater;
@property (strong, nonatomic) IBOutlet DOJOMagnifiedImageView *magnifiedView;
@property (nonatomic) BOOL isGoingUp;
@property (nonatomic) BOOL wasBrowsing;

@property (strong, nonatomic) NSString *previousType;
@property (strong, nonatomic) NSDictionary *previousInfo;

@property (strong, nonatomic) IBOutlet UIView *customHeaderView;
//@property (strong, nonatomic) IBOutlet UIButton *dojoHeader;
@property (strong, nonatomic) IBOutlet UILabel *dojoHeader;
@property (strong, nonatomic) IBOutlet UIButton *sortButton;
@property (strong, nonatomic) IBOutlet UILabel *followLabel;
@property (strong, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersCountLabel;

@property (strong, nonatomic) NSDictionary *dojoInfo;
@property (strong, nonatomic) NSArray *postListNew;
@property (strong, nonatomic) NSArray *postListTop;
@property (strong, nonatomic) NSArray *postListRoster;
@property (strong, nonatomic) NSString *userEmail;
@property (nonatomic) BOOL youAreCreator;
@property (nonatomic) NSInteger selectedPost;
@property (strong, nonatomic) NSDictionary *userProperties;

@property (nonatomic) BOOL userIsCreator;

@property (strong, nonatomic) NSDictionary *selectedPerson;

@property (nonatomic) NSInteger selectedSortType;

@end
