//
//  DOJOSpecialDojoPageViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 11/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import "DOJOPostCollectionViewCell.h"
#import "DojoPageMessageView.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "networkConstants.h"

@interface DOJOSpecialDojoPageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nameLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *followButton;

@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;

@property BOOL preventJumping;

@property (strong, nonatomic) NSDictionary *dojoData;
@property (strong, nonatomic) NSArray *dojoPostList;
@property (strong, nonatomic) NSArray *receivedDataArray;

@property (nonatomic, strong) UICollectionView *latestCollectionView;
@property (nonatomic, strong) IBOutlet DojoPageMessageView *messageViewBox;
@property (strong, nonatomic) UIImageView *blurredView;

-(void)magnifyMessageBoard;

@end
