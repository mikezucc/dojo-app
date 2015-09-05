//
//  DOJOPage.h
//  dojo
//
//  Created by Michael Zuccarino on 12/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DojoPageMessageView.h"
#import "networkConstants.h"
#import "DOJOSampleView.h"
#import <CoreImage/CoreImage.h>
#import "DOJOCameraViewController.h"

@interface DOJOPage : UIViewController

@property (strong, nonatomic) IBOutlet DojoPageMessageView *messageViewBox;
@property (strong, nonatomic) UIImageView *blurredView;
@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic) BOOL preventJumping;


@property (strong, nonatomic) IBOutlet DOJOSampleView *sampleView;
@property (strong, nonatomic) IBOutlet UILabel *smallDescription;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *furtherButton;

@property (strong, nonatomic) NSDictionary *dojoInfo;
@property (strong, nonatomic) NSArray *postList;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) IBOutlet UILabel *dojoHeader;

@end
