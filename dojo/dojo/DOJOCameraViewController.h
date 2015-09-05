//
//  DOJOCameraViewController.h
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPreviewView.h"

@protocol CameraControllerDelegate <NSObject>

@required
-(void)cameraDidStartZooming;

@end

@interface DOJOCameraViewController : UIViewController

@property (strong, nonatomic) NSString *parentHash;
@property (nonatomic, strong) IBOutlet DOJOPreviewView *previewView;

@property (weak, nonatomic) id<CameraControllerDelegate> delegate;

@property (strong, nonatomic) UIImage *flashIconOn;
@property (strong, nonatomic) UIImage *flashIconOff;

@property (strong, nonatomic) IBOutlet UIImageView *progressBar;
@property (strong, nonatomic) NSTimer *progressTimer;

@property (strong, nonatomic) NSString *forwardCameraString;

-(void)stopCameraSession;
-(void)startCameraSession;

@end
