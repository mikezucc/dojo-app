//
//  DOJOProfileViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 1/5/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

#import <UIKit/UIKit.h>
#import "networkConstants.h"
#import "DOJORevoCell.h"
#import "DOJOPersonCell.h"
#import "DOJOProfileTableView.h"
#import "DOJOPersonSelectView.h"
#import "DojoPageMessageView.h"
#import "DOJOMagnifiedImageView.h"
#import "DOJODSV3000.h"

@interface DOJOProfileViewController : UIViewController

@property (strong, nonatomic) DOJODSV3000 *dsv3000;
@property (strong, nonatomic) UIView *dsv300Container;

@property (strong, nonatomic) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) NSIndexPath *pathOfDownloadingCell;

@property (strong, nonatomic) IBOutlet UILabel *followingLoudLabel;

@property (strong, nonatomic) IBOutlet UIImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UITextView *personBio;
@property (strong, nonatomic) IBOutlet DOJOPersonSelectView *customSelectSegment;
@property (strong, nonatomic) IBOutlet UILabel *postsLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet DOJOProfileTableView *profileTableView;
@property (strong, nonatomic) IBOutlet UIButton *sortButton;
//@property (strong, nonatomic) IBOutlet UIButton *personNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dojoHeader;
@property (nonatomic) float rotateVal;
@property (strong, nonatomic) NSTimer *rotater;
@property (strong, nonatomic) IBOutlet UILabel *noPostLabel;
@property (strong, nonatomic) IBOutlet UILabel *votesLabel;
@property (strong, nonatomic) IBOutlet UILabel *peoplesLabel;
@property (strong, nonatomic) IBOutlet UIImageView *followView;
@property (strong, nonatomic) IBOutlet UILabel *followLabel;
@property (strong, nonatomic) IBOutlet DOJOMagnifiedImageView *magnifiedView;
@property (strong, nonatomic) IBOutlet UIImageView *backTypeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *backButtonForMask;
@property (nonatomic) BOOL isGoingUp;
@property (nonatomic) BOOL isYou;

@property (strong, nonatomic) IBOutlet UIView *uppaView;

@property (strong, nonatomic) NSIndexPath *cellWithMessageView;
@property (nonatomic) BOOL chatOpenSomewhere;
@property (strong, nonatomic) NSDictionary *selectedPostForMessageView;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) NSTimer *sendRotater;
@property (nonatomic) BOOL preventJumping;

@property (nonatomic) NSInteger sortSelectType;
@property (nonatomic) NSInteger tableType;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint postStartPoint;
@property (nonatomic) CGPoint followerStartPoint;
@property (nonatomic) BOOL didMove;

@property (strong, nonatomic) NSString *previousType;
@property (strong, nonatomic) NSDictionary *previousInfo;

@property (nonatomic) NSInteger selectedPost;

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *temporaryDirectory;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSDictionary *userProperties;

@property (strong, nonatomic) NSDictionary *personInfo;
@property (strong, nonatomic) NSArray *postArray;
@property (strong, nonatomic) NSArray *followerArray;

@end
