//
//  DOJOAnnotateViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/18/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DOJOSendViewController.h"

#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "CustomIOS7AlertView.h"
#import "DOJODrawColorView.h"
#import "DOJODrawToolButton.h"

@interface DOJOAnnotateViewController : UIViewController <AWSNetworkingHTTPResponseInterceptor>

@property (nonatomic) BOOL didAppearOnce;

@property (strong, nonatomic) NSString *forwardCameraString;

@property (nonatomic) CGPoint startTouch;
@property (strong, nonatomic) IBOutlet UIImageView *uploadArrow;
@property (strong, nonatomic) IBOutlet UIImageView *uploadGroup;
@property (nonatomic) float rotateVal;

@property (strong, nonatomic) NSString *parentHash;

@property (strong, nonatomic) NSURL *compressedVideoURL;
 
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest2;

@property (strong, nonatomic) DOJOSendViewController *sendViewController;

@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) IBOutlet UIImageView *blurredView;
@property (nonatomic) UIImage *capturedImage;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic) CGSize imageDims;

@property (strong, nonatomic) UIToolbar *editingBar;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIImage *picImage;
@property (strong, nonatomic) NSData *capturedMovie;
@property (strong, nonatomic) NSURL *urlFromPicker;
@property (nonatomic) BOOL isMovie;

@property BOOL didUseImagePicker;

@property (strong, nonatomic) IBOutlet UIView *annotateView;
@property (strong, nonatomic) IBOutlet UITextField *annotateField;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UIImageView *uploadingShit;
@property (strong, nonatomic) UIImageView *uploadingShitDone;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet DOJODrawToolButton *drawTool;
@property (strong, nonatomic) IBOutlet UIImageView *colorWheel;
@property (strong, nonatomic) IBOutlet UIImageView *drawPlatform;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property long textTapCount;
@property BOOL didMove;
@property (nonatomic) BOOL didEndChoosingColor;

-(void)cancelButtonPress;
-(void)doneButtonPress;
-(void)callSendController;
-(NSString *)generateCode;

@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSData *imageData;
@property BOOL preventJumping;

@property (strong, nonatomic) NSString *codeKey;
@property (strong, nonatomic) NSString *viewDidLoadAlready;
@property (strong, nonatomic) NSString *performedPost;

@property (nonatomic) NSInteger numberOfRequiredResponses;
@property (nonatomic) NSInteger numberOfReceivedResponses;

//@property (strong, nonatomic) BOOL appeared;

@end
