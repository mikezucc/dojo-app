//
//  DOJODojoPageViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "DOJOPostCollectionViewCell.h"
#import "DOJOMagnifiedViewController.h"
#import "DOJOMessageBoardViewController.h"
#import "DOJOPageSettingsViewController.h"
#import "DojoPageMessageView.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "networkConstants.h"

@interface DOJODojoPageViewController : UIViewController

//inputs
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property BOOL preventJumping;

@property (strong, nonatomic) IBOutlet DojoPageMessageView *messageViewBox;
@property (strong, nonatomic) IBOutlet UIButton *readButton;
@property (strong, nonatomic) UIImageView *blurredView;

//amazon stuff
@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;

@property (nonatomic, strong) NSArray *messageReceivedArr;

@property (nonatomic, strong) UICollectionView *latestCollectionView;
//@property (strong, nonatomic) DOJOPageCollectionViewCell *customCell;

@property (strong, nonatomic) NSArray *dojoPageData;
@property (strong, nonatomic) NSDictionary *dojoData;

@property (strong, nonatomic) NSArray *dojoPostList;
@property (strong, nonatomic) NSArray *receivedDataArray;
@property (strong, nonatomic) NSString *selectedSection;
@property (strong, nonatomic) NSDictionary *selectedPost;

@property (strong, nonatomic) DOJOMagnifiedViewController *magnifyVC;
@property (strong, nonatomic) DOJOPageSettingsViewController *dojoSettingsVC;

-(IBAction)reloadCollectionViewSelector;
-(IBAction)closeMe;

-(void)magnifyMessageBoard;
-(void)magnifyImage:(id)sender;
@property (nonatomic) NSInteger *selectedTag;
@property (strong, nonatomic) NSData *tappedData;

@property (strong, nonatomic) NSMutableArray *trackOfLoaded;

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
-(IBAction)showMessageController:(id)sender;

@end
