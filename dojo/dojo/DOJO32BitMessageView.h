//
//  DOJO32BitMessageView.h
//  dojo
//
//  Created by Michael Zuccarino on 2/10/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

#import <UIKit/UIKit.h>
#import "DojoPageMessageView.h"

@interface DOJO32BitMessageView : UIViewController

@property (strong, nonatomic) NSString *currentDojoHash;
@property (strong, nonatomic) NSString *currentPostHash;

@property (strong, nonatomic) DojoPageMessageView *messageView;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIImageView *blurredBackground;
@property (nonatomic) float rotateVal;

@property (strong, nonatomic) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) AWSS3TransferManager *transferManager;

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSFileManager *fileManager;

@property (strong, nonatomic) IBOutlet UIView *customNavView;

@property (nonatomic) BOOL isGoingUp;
@property (nonatomic) BOOL preventJumping;
@property (strong, nonatomic) NSTimer *sendRotater;

@property (strong, nonatomic) NSDictionary *postInfo;

@end
