//
//  DOJOMagnifiedViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DOJOPostCollectionViewCell.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "networkConstants.h"

@interface DOJOMagnifiedViewController : UIViewController <UIGestureRecognizerDelegate>
{
    NSMutableArray *totalPostList;
    NSDictionary *dojoData;
    NSInteger selectedPostIndex;
}

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (nonatomic, strong) NSFileManager *fMan;
@property (nonatomic, strong) NSString *userEmail;
@property NSInteger selectedPostIndex;

@property (strong, nonatomic) NSMutableArray *totalPostList;
@property (strong, nonatomic) NSDictionary *dojoData;
@property (nonatomic, strong) UICollectionView *latestCollectionView;

@property BOOL playContent;

@end
