//
//  DOJOLoginViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/9/14.
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
#import "DOJOHomeViewController.h"
#import "DOJONavigationController.h"
#import "networkConstants.h"
#import "dojo/DOJOWelcomeSequence.h"

@interface DOJOLoginViewController : UIViewController <AWSNetworkingHTTPResponseInterceptor>

@property (strong, nonatomic) NSArray *dataConv;

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *fullname;

@property (strong, nonatomic) IBOutlet UIButton *loginbutton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UILabel *dojoTitle;

@property (strong, nonatomic) DOJONavigationController *navigationMain;

@property (nonatomic) BOOL authenticated;

@end
