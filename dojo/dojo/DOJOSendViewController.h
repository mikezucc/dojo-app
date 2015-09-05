//
//  DOJOSendViewController.h
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

#import <UIKit/UIKit.h>
#import "DOJOSendTableViewBox.h"
#import "networkConstants.h"

@interface DOJOSendViewController : UIViewController


@property (nonatomic, strong) AWSS3TransferManager *tm;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest2;

@property (strong, nonatomic) IBOutlet DOJOSendTableViewBox *sendViewBox;

-(void)postToDojo:(UIButton *)button;
@property (strong, nonatomic) UIButton *postButton;

- (NSString *)generateCode;

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *postHash;
@property (strong, nonatomic) NSString *postDescription;
@property (nonatomic) BOOL isRepost;

-(IBAction)removeSelf:(id)sender;

@end
