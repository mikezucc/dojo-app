//
//  DOJOCameraViewController.m
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MobileCoreServices/UTCoreTypes.h"
#import "DOJOAnnotateViewController.h"
#import "DOJOCaptureButton.h"
#import "DOJOHomeTableViewController.h"
#import "SDAVAssetExportSession.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface DOJOCameraViewController () <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, captureDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIButton *closeMe;
@property (strong, nonatomic) IBOutlet UIButton *flashToggle;

@property (strong, nonatomic) NSURL *compressedVideoURL;

@property (nonatomic, strong) IBOutlet DOJOCaptureButton *captureButton;
@property (nonatomic, strong) IBOutlet UIImageView *cameraPeek;
@property (strong, nonatomic) IBOutlet UIImageView *videoPeek;

@property (nonatomic, strong) NSURL *selectedVideoFromPicker;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureDeviceInput *audioDeviceInput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic) DOJOAnnotateViewController *annotateController;
@property (nonatomic) NSData *imageData;
@property (nonatomic) NSString *mediaType;
@property (nonatomic) UIImage *originalImage;
@property (nonatomic) NSData *videoData;

@property (nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property float initialZoom;

@property (nonatomic) NSString *viewDidLoadAlready;
@property BOOL didRun;
@property BOOL didUseImagePicker;
@property (nonatomic) BOOL didCancelRecording;

@end

@implementation DOJOCameraViewController

@synthesize cameraButton, annotateController, imageData, mediaType, originalImage, videoData, didRun, viewDidLoadAlready, pinchRecognizer, uploadButton, didUseImagePicker, closeMe, selectedVideoFromPicker, captureButton, cameraPeek, videoPeek, flashToggle, parentHash, flashIconOn, flashIconOff, progressTimer, initialZoom, didCancelRecording, forwardCameraString;

//@synthesize session;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	NSLog(@"CAMERA VIEW LOADED");
    didRun = NO;
    didUseImagePicker = NO;
    
    UIImage *flashImage = [UIImage imageNamed:@"1422091098_flash-128.png"];
    flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
    [flashImage drawInRect:CGRectMake(0, 0, 45, 45)];
    self.flashIconOff = [[UIImage alloc] init];
    self.flashIconOff = flashImage;
    UIGraphicsEndImageContext();
    
    flashImage = [UIImage imageNamed:@"1422091105_flash-outline-128.png"];
    flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
    [flashImage drawInRect:CGRectMake(0, 0, 45, 45)];
    self.flashIconOn = [[UIImage alloc] init];
    self.flashIconOn = flashImage;
    [self.flashToggle setImage:self.flashIconOn forState:UIControlStateNormal];
    UIGraphicsEndImageContext();
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    @try {
        CGRect temp = self.progressBar.frame;
        temp.size.width = 0;
        self.progressBar.frame = temp;
    }
    @catch (NSException *exception) {
        NSLog(@"compilter %@",exception);
    }
    @finally {
        NSLog(@"finally");
    }
    
    //self.parentHash = @"";
    
}

-(void)handlePinchWithGestureRecognizer
{
    [self.delegate cameraDidStartZooming];
    BOOL didChange = NO;
    NSLog(@"pinchin pinchin %f scale, %f float",pinchRecognizer.scale, pinchRecognizer.velocity);
    if ([[[self videoDeviceInput] device] respondsToSelector:@selector(setVideoZoomFactor:)]
        && ([[self videoDeviceInput] device].activeFormat.videoMaxZoomFactor >= pinchRecognizer.scale) && pinchRecognizer.scale >= 1.0)
    {
        NSLog(@"FIRST IF");
        // iOS 7.x with compatible hardware
        if ([[[self videoDeviceInput] device] lockForConfiguration:nil])
        {
            NSLog(@"IS ABLE TO LOCK FOR CONFIGURATION");
            didChange = YES;
            [[[self videoDeviceInput] device] setVideoZoomFactor:pinchRecognizer.scale];
            [[[self videoDeviceInput] device] unlockForConfiguration];
        }
    }
    else
    {
        if (pinchRecognizer.scale>=1.0)
        {
            NSLog(@"using alternative method");
            // Lesser cases
            CGRect frame = self.previewView.frame;
            float width = frame.size.width * pinchRecognizer.scale;
            float height = frame.size.height * pinchRecognizer.scale;
            float x = (frame.size.width - width)/2;
            float y = (frame.size.height - height)/2;
            self.previewView.bounds = CGRectMake(x, y, width, height);
        }
    }
    
    if (!didChange)
    {
        if ([[[self videoDeviceInput] device] lockForConfiguration:nil])
        {
            NSLog(@"IS ABLE TO LOCK FOR CONFIGURATION");
            didChange = YES;
            [[[self videoDeviceInput] device] setVideoZoomFactor:1.0];
            [[[self videoDeviceInput] device] unlockForConfiguration];
        }
    }
    /*
    if ([[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo].videoMaxScaleAndCropFactor == 1.0)
    {
        [[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo].videoMaxScaleAndCropFactor = 5.0;
        [[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo].videoMaxScaleAndCropFactor = 5.0
    }
    NSLog(@"pinchin pinchin %f scale, %f float, %f max",pinchRecognizer.scale, pinchRecognizer.velocity, [[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo].videoMaxScaleAndCropFactor);
    [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoScaleAndCropFactor:pinchRecognizer.scale];
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoScaleAndCropFactor:pinchRecognizer.scale];
     */
}

-(void)touchedAt:(NSNumber *)index
{
    NSLog(@"touch began");
    [self.cameraPeek setHidden:NO];
    [self.videoPeek setHidden:NO];
    //fmodf(temp.size.width, 320)/320
    [self.captureButton setBackgroundColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1 alpha:1.0]];//index.floatValue/self.captureButton.frame.size.width saturation:0.8 brightness:1.0 alpha:1]];
    [self.cameraPeek setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:(1-(index.floatValue/self.captureButton.frame.size.width)) brightness:1.0 alpha:(1-(index.floatValue/self.captureButton.frame.size.width))]];
    [self.cameraPeek setFrame:CGRectMake(21-((1-(index.floatValue/self.captureButton.frame.size.width))*20), 473-((1-(index.floatValue/self.captureButton.frame.size.width))*20), 56+((1-(index.floatValue/self.captureButton.frame.size.width))*20), 49+((1-(index.floatValue/self.captureButton.frame.size.width))*20))];
    [self.videoPeek setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:((index.floatValue/self.captureButton.frame.size.width)) brightness:1.0 alpha:(index.floatValue/self.captureButton.frame.size.width)]];
    [self.videoPeek setFrame:CGRectMake(193+((index.floatValue/self.captureButton.frame.size.width)*20), 473-((index.floatValue/self.captureButton.frame.size.width)*20), 56+((index.floatValue/self.captureButton.frame.size.width)*20), 49+((index.floatValue/self.captureButton.frame.size.width)*20))];
    
    [self.flashToggle.imageView setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
    
    [self.closeMe setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
}

-(void)touchIsOfPercentage:(NSNumber *)index
{
    /*
     self.cameraPeek = [[UIImageView alloc] initWithFrame:CGRectMake(21, 473, 56, 49)];
     self.videoPeek = [[UIImageView alloc] initWithFrame:CGRectMake(193, 473, 56, 49)];
     */
    NSLog(@"touch is at %f",index.floatValue/self.captureButton.frame.size.width);
    [self.captureButton setBackgroundColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1 alpha:1.0]];
    [self.cameraPeek setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:(1-(index.floatValue/self.captureButton.frame.size.width)) brightness:1.0 alpha:(1-(index.floatValue/self.captureButton.frame.size.width))]];
    [self.cameraPeek setFrame:CGRectMake(21-((1-(index.floatValue/self.captureButton.frame.size.width))*20), 473-((1-(index.floatValue/self.captureButton.frame.size.width))*20), 56+((1-(index.floatValue/self.captureButton.frame.size.width))*20), 49+((1-(index.floatValue/self.captureButton.frame.size.width))*20))];
    [self.videoPeek setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:((index.floatValue/self.captureButton.frame.size.width)) brightness:1.0 alpha:(index.floatValue/self.captureButton.frame.size.width)]];
    [self.videoPeek setFrame:CGRectMake(193+((index.floatValue/self.captureButton.frame.size.width)*20), 473-((index.floatValue/self.captureButton.frame.size.width)*20), 56+((index.floatValue/self.captureButton.frame.size.width)*20), 49+((index.floatValue/self.captureButton.frame.size.width)*20))];
    [self.closeMe setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
    [self.flashToggle setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
    [self.uploadButton setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
    [self.flashToggle.imageView setTintColor:[UIColor colorWithHue:fmodf((index.floatValue+270)/3, self.captureButton.frame.size.width)/(self.captureButton.frame.size.width) saturation:0.8 brightness:1.0 alpha:1]];
}

-(void)touchLiftedAt:(NSNumber *)index
{
    NSLog(@"removed at %f",index.floatValue/self.captureButton.frame.size.width);
    [self.cameraPeek setHidden:YES];
    [self.videoPeek setHidden:YES];
    
    if ((index.floatValue/self.captureButton.frame.size.width) < 0.35)
    {
        [self toggleMovieRecording:self];
        if ([[self movieFileOutput] isRecording])
        {
            [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
            [self.flashToggle setTintColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
        }
        else
        {
            [self.captureButton setTitle:@"Recording..." forState:UIControlStateNormal];
            [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
            [self.flashToggle setTintColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
        }
    }
    else if ((index.floatValue/self.captureButton.frame.size.width) > 0.65)
    {
        // still
        if (![[self movieFileOutput] isRecording])
        {
            [self snapStillImage:self];
            [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
            [self.flashToggle setTintColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
        }
        else
        {
            [self toggleMovieRecording:self];
            [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
            [self.flashToggle setTintColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
        }
    }
    else
    {
        if ([[self movieFileOutput] isRecording])
        {
            // video
            [self toggleMovieRecording:self];
        }
        
    }
}

-(IBAction)toggleFlashMode:(id)sender
{
    if (([[[self videoDeviceInput] device] flashMode] == AVCaptureFlashModeOn) || ([[[self videoDeviceInput] device] flashMode] == AVCaptureFlashModeAuto))
    {
        [DOJOCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
        [self.flashToggle setImage:self.flashIconOn forState:UIControlStateNormal];
        [self.flashToggle setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [DOJOCameraViewController setFlashMode:AVCaptureFlashModeOn forDevice:[[self videoDeviceInput] device]];
        [self.flashToggle setImage:self.flashIconOff forState:UIControlStateNormal];
        [self.flashToggle setTintColor:[UIColor whiteColor]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *widePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"isWidescreen.plist"]];
    
    NSDictionary *widescreenDict = [[NSDictionary alloc] initWithContentsOfFile:widePath];
    
    NSString *wideString = [[NSString alloc] initWithString:[widescreenDict valueForKeyPath:@"widescreen"]];
    
    float adjustHeight;
    if ([wideString isEqualToString:@"not"])
    {
        adjustHeight = 120;
    }
    else
    {
        adjustHeight = 120;
    }
    // [cameraButton setFrame:CGRectMake(cameraButton.frame.origin.x, self.view.frame.size.height-adjustHeight, cameraButton.frame.size.width, 57)];
    //[stillButton setFrame:CGRectMake(stillButton.frame.origin.x, self.view.frame.size.height-adjustHeight, 105, 53)];
    //[recordButton setFrame:CGRectMake(recordButton.frame.origin.x, self.view.frame.size.height-adjustHeight, 105, 53)];

    self.captureButton.delegate = self;
    
    UIImage *segmentImage = [UIImage imageNamed:@"photobowser.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 35),NO,0.0);
    [segmentImage drawInRect:CGRectMake(10, 3, 28, 29)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.uploadButton setImage:resizedImage forState:UIControlStateNormal];
    
    /*
    [DOJOCameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
    UIImage *flashImage = [UIImage imageNamed:@"whiteflashicon.png"];
    //flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
    [flashImage drawInRect:CGRectMake(0, 0, 45, 45)];
    UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.flashToggle setImage:resizedFlash forState:UIControlStateNormal];
    [self.flashToggle setTintColor:[UIColor orangeColor]];
     */
    
    UIImage *closeImage = [UIImage imageNamed:@"cameraflipthickness.png"];
    closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(41, 41),NO,0.0);
    [closeImage drawInRect:CGRectMake(0, 0, 41, 41)];
    UIImage *resizedClose = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.closeMe setImage:resizedClose forState:UIControlStateNormal];
    [self.closeMe setTintColor:[UIColor whiteColor]];
    //[self.closeMe setTintColor:self.captureButton.tintColor];
    
    [self.flashToggle.imageView setTintColor:[UIColor whiteColor]];
    [DOJOCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
    [self.flashToggle setImage:self.flashIconOn forState:UIControlStateNormal];
    
    //self.didRun = YES;
    /*
    if (([[self session] isRunning]) || (!self.didRun))
    {
        NSLog(@"reinitializing the streams");
        dispatch_async([self sessionQueue], ^{
            [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
            [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
            [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            
            __weak DOJOCameraViewController *weakSelf = self;
            [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                DOJOCameraViewController *strongSelf = weakSelf;
                dispatch_async([strongSelf sessionQueue], ^{
                    // Manually restarting the session since it must have been stopped due to an error.
                    [[strongSelf session] startRunning];
                });
            }]];
            [[self session] startRunning];
        });
    }
     */
    /*
    @try {
        dispatch_async([self sessionQueue], ^{
            [[self session] stopRunning];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
            [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"thread already killed");
    }
    @finally {
        NSLog(@"completed view will appear sanitize");
    }
     */
    /*
    NSLog(@"view will appear");
    if ((!self.didRun) && (!self.didUseImagePicker))
    {
        NSLog(@"reinitializing the streams");
        dispatch_async([self sessionQueue], ^{
            [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
            [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
            [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            
            __weak DOJOCameraViewController *weakSelf = self;
            [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                DOJOCameraViewController *strongSelf = weakSelf;
                dispatch_async([strongSelf sessionQueue], ^{
                    // Manually restarting the session since it must have been stopped due to an error.
                    [[strongSelf session] startRunning];
                    [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
                });
            }]];
            [[self session] startRunning];
        });
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *widePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"isWidescreen.plist"]];
        
        NSDictionary *widescreenDict = [[NSDictionary alloc] initWithContentsOfFile:widePath];
        
        NSString *wideString = [[NSString alloc] initWithString:[widescreenDict valueForKeyPath:@"widescreen"]];
        
        float adjustHeight;
        if ([wideString isEqualToString:@"not"])
        {
            adjustHeight = 120;
        }
        else
        {
            adjustHeight = 120;
        }
        // [cameraButton setFrame:CGRectMake(cameraButton.frame.origin.x, self.view.frame.size.height-adjustHeight, cameraButton.frame.size.width, 57)];
        [stillButton setFrame:CGRectMake(stillButton.frame.origin.x, self.view.frame.size.height-adjustHeight, 105, 53)];
        [recordButton setFrame:CGRectMake(recordButton.frame.origin.x, self.view.frame.size.height-adjustHeight, 105, 53)];
        [uploadButton.layer setCornerRadius:10];
        uploadButton.clipsToBounds = YES;
        [closeMe.layer setCornerRadius:10];
        closeMe.clipsToBounds = YES;
        //self.didRun = YES;
    }
    else
    {
        self.didRun = YES;
        //[self dismissViewControllerAnimated:YES completion:nil];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
        NSDictionary *didpostdict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        if ([[didpostdict objectForKey:@"didPost"] isEqualToString:@"didPost"])
        {
            dispatch_async([self sessionQueue], ^{
                [[self session] stopRunning];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:
                 AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
            });
            
            @try {
                [self dismissViewControllerAnimated:YES completion:^{NSLog(@"yar");}];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@", exception);
            }
            @finally {
                NSLog(@"finally ran through dismissblock");
            }
        }
    }
    */
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"IN VIEW DID APPEAR CAM CAMHASH %@",self.parentHash);
    self.cameraPeek = [[UIImageView alloc] initWithFrame:CGRectMake(21, 473, 56, 49)];
    self.videoPeek = [[UIImageView alloc] initWithFrame:CGRectMake(193, 473, 56, 49)];
    UIImage *image = [UIImage imageNamed:@"videopopup.png"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cameraPeek setImage:image];
    self.cameraPeek.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraPeek.tintColor = [UIColor redColor];
    [self.cameraPeek setHidden:YES];
    UIImage *another = [UIImage imageNamed:@"stillpopup.png"];
    another = [another imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.videoPeek setImage:another];
    self.videoPeek.contentMode = UIViewContentModeScaleAspectFit;
    self.videoPeek.tintColor = [UIColor redColor];
    [self.videoPeek setHidden:YES];
    [self.previewView addSubview:self.cameraPeek];
    [self.previewView addSubview:self.videoPeek];
    
    [self.captureButton setTitle:@"CAPTURE" forState:UIControlStateNormal];
    [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
    [self.flashToggle.imageView setTintColor:[UIColor whiteColor]];
    [self.uploadButton setTintColor:[UIColor whiteColor]];
    
    [self.progressTimer invalidate];
    CGRect temp = self.progressBar.frame;
    temp.size.width = 0;
    self.progressBar.frame = temp;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *virginityPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"virginity.plist"]];
    NSMutableDictionary *virginDict = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:virginityPath])
    {
        virginDict = [[NSMutableDictionary alloc] initWithContentsOfFile:virginityPath];
        NSLog(@"virgindict is %@",virginDict);
        if ([[virginDict valueForKey:@"CameraVirgin"] isEqualToString:@"yes"])
        {
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Swipe down to close. To take a video, just press the VID button and again to end the clip. Press PIC to get a picture. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            //[alertView show];
            [virginDict setValue:@"no" forKey:@"CameraVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Swipe down to close. To take a video, just press the VID button and again to end the clip. Press PIC to get a picture. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        //[alertView show];
        [virginDict setValue:@"no" forKey:@"CameraVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }

    if ([viewDidLoadAlready isEqualToString:@"loaded"])
    {
//        [self removeFromParentViewController];
    }
    else
    {
        viewDidLoadAlready = @"loaded";
    }
    /*
    if (([[self session] isRunning]) || (!self.didRun))
    {
        NSLog(@"reinitializing the streams");
        dispatch_async([self sessionQueue], ^{
            [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
            [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
            [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            
            __weak DOJOCameraViewController *weakSelf = self;
            [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                DOJOCameraViewController *strongSelf = weakSelf;
                dispatch_async([strongSelf sessionQueue], ^{
                    // Manually restarting the session since it must have been stopped due to an error.
                    [[strongSelf session] startRunning];
                });
            }]];
            [[self session] startRunning];
        });
    }*/
    
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
    NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"no"] forKeys:@[@"didPost"]];
    [didpostdict writeToFile:plistPath atomically:YES];
}

-(void)startCameraSession
{
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    [self setSession:session];
    
    // Setup the preview view
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    //set aspect ratio
    //[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [DOJOCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([[self session] canAddOutput:movieFileOutput])
        {
            [[self session] addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            Float64 TotalSeconds = 15;	//Total seconds
            int32_t preferredTimeScale = 15;	//Frames per second
            CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
            movieFileOutput.maxRecordedDuration = maxDuration;
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([[self session] canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [[self session] addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
    if (([[self session] isRunning]) || (!self.didRun))
    {
        NSLog(@"reinitializing the streams");
        dispatch_async([self sessionQueue], ^{
            NSError *error;
            AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            
            if (error)
            {
                NSLog(@"%@", error);
            }
            
            if ([[self session] canAddInput:_audioDeviceInput])
            {
                [[self session] addInput:_audioDeviceInput];
            }
            
            [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
            [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
            [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            
            __weak DOJOCameraViewController *weakSelf = self;
            [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
                DOJOCameraViewController *strongSelf = weakSelf;
                dispatch_async([strongSelf sessionQueue], ^{
                    // Manually restarting the session since it must have been stopped due to an error.
                    [[strongSelf session] startRunning];
                });
            }]];
            [[self session] startRunning];
        });
    }
    
}

-(void)stopCameraSession
{
    @try {
        dispatch_async([self sessionQueue], ^{
            @try {
                [[self session] stopRunning];
                
                [[self session] removeInput:_audioDeviceInput];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:
                 AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is nested %@",exception);
            }
            @finally {
                NSLog(@"ran threaded try catch loop");
            }
            @try {
                [[self session] stopRunning];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:
                 AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is nested %@",exception);
            }
            @finally {
                NSLog(@"ran threaded try catch loop");
            }
            @try {
                [[self session] stopRunning];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:
                 AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is nested %@",exception);
            }
            @finally {
                NSLog(@"ran threaded try catch loop");
            }
        });
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"fuudge");
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    /*
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
     */
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    @try {
        [self.progressTimer invalidate];
    }
    @catch (NSException *exception) {
        NSLog(@"timer invalidate exception is %@",exception);
    }
    @finally {
        CGRect frm = self.progressBar.frame;
        frm.size.width = 0;
        self.progressBar.frame = frm;
    }
    /*
    @try {
        dispatch_async([self sessionQueue], ^{
            [[self session] stopRunning];
            
           // [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
          //  [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
            [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"thread already killed");
    }
    @finally {
        NSLog(@"completed view will appear sanitize");
    }
    dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
        
        for(AVCaptureInput *input in [self session].inputs) {
            [[self session] removeInput:input];
        }
        
        for(AVCaptureOutput *output in [self session].outputs) {
            [[self session] removeOutput:output];
        }
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
    */
}

-(IBAction)pickFromPhone:(id)sender
{
    if ([[self movieFileOutput] isRecording])
    {
     //   dispatch_async(dispatch_get_main_queue(), ^{
       //             });
        //        [self.uploadButton setNeedsDisplay];
        //[self.uploadButton setNeedsLayout];
        
        self.didCancelRecording = YES;
        [self toggleMovieRecording:self];
        
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    NSLog( [[self.parentViewController class] isSubclassOfClass:[DOJOHomeTableViewController class]] ? @"is the right one" : @"NOPE");
    [picker setDelegate:self];
    //picker.allowsEditing = YES;
    NSLog(@"before show");
    [self presentViewController:picker animated:YES completion:nil];
    //[self showViewController:picker sender:self];
    NSLog(@"after show");
    didUseImagePicker = YES;
}

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    self.didUseImagePicker = YES;
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        imageData = UIImageJPEGRepresentation(originalImage, 0.8);
        int imageSize = (unsigned)imageData.length;
        NSLog(@"SIZE OF IMAGE: %i ", imageSize);
        //originalImage = [[UIImage alloc] initWithData:imageData];
        //imageData = UIImageJPEGRepresentation(originalImage, 0.6);
        NSString *mediaTypeLocal = @"image";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"captured.jpeg"]];
        [imageData writeToURL:selectedPath atomically:YES];
        selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"mediaType.plist"]];
        NSDictionary *mediaTypeDict = [[NSDictionary alloc] initWithObjects:@[mediaTypeLocal] forKeys:@[@"mediaType"]];
        [mediaTypeDict writeToURL:selectedPath atomically:YES];
        
        //[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
            [self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
        }];
    }
    else
    {
        NSLog(@"isVIDEO");
        NSError *error;
        NSString *moviePath = ((NSURL *)[info objectForKey:UIImagePickerControllerMediaURL]).path;
        self.selectedVideoFromPicker = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
        [[NSFileManager defaultManager] copyItemAtURL:[NSURL URLWithString:moviePath] toURL:selectedPath error:&error];
        videoData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:moviePath]];
        [videoData writeToURL:selectedPath atomically:YES];
        NSString *mediaTypeLocal = @"movie";
        
        selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"mediaType.plist"]];
        NSDictionary *mediaTypeDict = [[NSDictionary alloc] initWithObjects:@[mediaTypeLocal] forKeys:@[@"mediaType"]];
        [mediaTypeDict writeToURL:selectedPath atomically:YES];
        
        //[[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:moviePath] error:nil];
        
        if (_backgroundRecordingID != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
        }
        // Do something with the picked movie available at moviePath
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
            [self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
        }];
    }

}

-(IBAction)forceClose:(id)sender
{
    //[self performSegueWithIdentifier:@"backToHome" sender:self];
    //[self dealloc];
    if ([[self session] isRunning])
    {
        dispatch_async([self sessionQueue], ^{
            [[self session] stopRunning];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:
             AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
            [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        });
    }
    
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"yar");}];
}

-(IBAction)removeYoself:(id)sender
{
    //[self performSegueWithIdentifier:@"backToHome" sender:self];
    //[self dealloc];
    if (![[self movieFileOutput] isRecording])
    {
        dispatch_async([self sessionQueue], ^{
            [[self session] stopRunning];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:
             AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
            [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
            [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
        });
        
        [self dismissViewControllerAnimated:YES completion:^{NSLog(@"yar");}];
    }
}


- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == RecordingContext)
	{
		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRecording)
			{
				[[self cameraButton] setEnabled:NO];
				//[[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
			}
			else
			{
				[[self cameraButton] setEnabled:YES];
			//	[[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
			}
		});
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)showProgressBar
{
    /*
    NSLog(@"lol what");
    CGRect temp = self.progressBar.frame;
    temp.size.width = 130;
    self.progressBar.frame = temp;
    */
    if ([[self movieFileOutput] isRecording])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"lol what");
            [UIView animateWithDuration:1.0 animations:^{
                CGRect temp = self.progressBar.frame;
                temp.size.width = temp.size.width + 22;
                self.progressBar.frame = temp;
                [self.progressBar setBackgroundColor:[UIColor colorWithHue:fmodf(temp.size.width, 320)/320 saturation:0.8 brightness:1.0 alpha:1.0]];
            }];
        });
    }
    
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
    NSLog(@"recording toggled");
    self.didUseImagePicker = NO;
	
    CGRect temp = self.progressBar.frame;
    temp.size.width = 0;
    self.progressBar.frame = temp;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    //[self delete:self.progressTimer];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showProgressBar) userInfo:nil repeats:YES];
    //[self.progressTimer fire];
    
    if (self.didCancelRecording)
    {
        UIImage *segmentImage = [UIImage imageNamed:@"photobowser.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 35),NO,0.0);
        [segmentImage drawInRect:CGRectMake(10, 3, 28, 29)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.uploadButton setImage:resizedImage forState:UIControlStateNormal];
    }
    else
    {
        
        UIImage *segmentImage = [UIImage imageNamed:@"close16.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 35),NO,0.0);
        [segmentImage drawInRect:CGRectMake(10, 3, 28, 29)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.uploadButton setImage:resizedImage forState:UIControlStateNormal];

    }
    
	dispatch_async([self sessionQueue], ^{
		if (![[self movieFileOutput] isRecording])
		{
			[self setLockInterfaceRotation:YES];
			if ([[UIDevice currentDevice] isMultitaskingSupported])
			{
				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
			}
			
			// Update the orientation on the movie file output video connection before starting recording.
			[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
			
			// Turning OFF flash for video recording
			[DOJOCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
			
			// Start recording to a temporary file.
			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.captureButton setTitle:@"RECORDING..." forState:UIControlStateNormal];
            });
		}
		else
		{
			[[self movieFileOutput] stopRecording];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.captureButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
                [self.captureButton setTitle:@"CAPTURE" forState:UIControlStateNormal];
            });
		}
	});
}

- (IBAction)swipeToDaRight:(UITapGestureRecognizer *)recognizer
{
    // Get the location of the gesture
    CGPoint location = [recognizer locationInView:self.previewView];
    if (location.y < (self.captureButton.frame.origin.y-20))
    {
        if (![[self movieFileOutput] isRecording])
        {
            [self changeCamera:recognizer];
        }
    }
}

- (IBAction)swipeToDaLeft:(UITapGestureRecognizer *)recognizer
{
    // Get the location of the gesture
    CGPoint location = [recognizer locationInView:self.previewView];
    if (location.y < (self.captureButton.frame.origin.y-20))
    {
        if (![[self movieFileOutput] isRecording])
        {
            [self changeCamera:recognizer];
        }
    }
}

- (IBAction)changeCamera:(id)sender
{
    if (![[self captureButton] isSelected])
    {
        [[self cameraButton] setEnabled:NO];
        [[self uploadButton] setEnabled:NO];
        self.didUseImagePicker = NO;
        
        dispatch_async([self sessionQueue], ^{
            AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
            AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
            AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
            
            switch (currentPosition)
            {
                case AVCaptureDevicePositionUnspecified:
                    preferredPosition = AVCaptureDevicePositionBack;
                    break;
                case AVCaptureDevicePositionBack:
                    preferredPosition = AVCaptureDevicePositionFront;
                    break;
                case AVCaptureDevicePositionFront:
                    preferredPosition = AVCaptureDevicePositionBack;
                    break;
            }
            
            AVCaptureDevice *videoDevice = [DOJOCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
            
            [[self session] beginConfiguration];
            
            [[self session] removeInput:[self videoDeviceInput]];
            if ([[self session] canAddInput:videoDeviceInput])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                
                [DOJOCameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
                
                [[self session] addInput:videoDeviceInput];
                [self setVideoDeviceInput:videoDeviceInput];
            }
            else
            {
                [[self session] addInput:[self videoDeviceInput]];
            }
            
            [[self session] commitConfiguration];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self cameraButton] setEnabled:YES];
                [[self uploadButton] setEnabled:YES];
            });
        });
    }
}

- (IBAction)snapStillImage:(id)sender
{
    self.didUseImagePicker = NO;
	dispatch_async([self sessionQueue], ^{
		// Update the orientation on the still image output video connection before capturing.
		[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
		
		// Flash set to Auto for Still Capture
		//[DOJOCameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
		
		// Capture a still image.
		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
			if (imageDataSampleBuffer)
			{
				imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                int imageSize = (unsigned)imageData.length;
                NSLog(@"SIZE OF IMAGE: %i ", imageSize);
				originalImage = [[UIImage alloc] initWithData:imageData];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                UIImage *tempImage = nil;
                CGSize targetSize = originalImage.size;
                UIGraphicsBeginImageContext(targetSize);
                
                CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
                thumbnailRect.origin = CGPointMake(0.0,0.0);
                thumbnailRect.size.width  = targetSize.width;
                thumbnailRect.size.height = targetSize.height;
                
                [image drawInRect:thumbnailRect];
                
                tempImage = UIGraphicsGetImageFromCurrentImageContext();
                originalImage = tempImage;
                
                UIGraphicsEndImageContext();
                //imageData = UIImageJPEGRepresentation(originalImage, 0.6);
                mediaType = @"image";
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"captured.jpeg"]];
                [UIImageJPEGRepresentation(originalImage, 0.9) writeToURL:selectedPath atomically:YES];
                selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"mediaType.plist"]];
                NSDictionary *mediaTypeDict = [[NSDictionary alloc] initWithObjects:@[mediaType] forKeys:@[@"mediaType"]];
                [mediaTypeDict writeToURL:selectedPath atomically:YES];

                
				//[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
                [self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
			}
		}];
	});
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"did finish check");
	if (error)
		NSLog(@"%@", error);
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [self.progressTimer invalidate];
    CGRect temp = self.progressBar.frame;
    temp.size.width = 320;
    self.progressBar.frame = temp;
	
    if (!self.didCancelRecording)
    {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
        [[NSFileManager defaultManager] copyItemAtURL:outputFileURL toURL:selectedPath error:&error];
        videoData = [[NSData alloc] initWithContentsOfURL:outputFileURL];
        [videoData writeToURL:selectedPath atomically:YES];
        mediaType = @"movie";
        
        selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"mediaType.plist"]];
        NSDictionary *mediaTypeDict = [[NSDictionary alloc] initWithObjects:@[mediaType] forKeys:@[@"mediaType"]];
        [mediaTypeDict writeToURL:selectedPath atomically:YES];
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
        [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
        [self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
        
        videoData = [[NSData alloc] initWithContentsOfURL:outputFileURL];
        [videoData writeToURL:selectedPath atomically:YES];
        mediaType = @"movie";
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
        NSURL *recordedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:recordedPath options:nil];
        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generate.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 60);
        CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
        NSLog(@"err==%@, imageRef==%@", err, imgRef);
        UIImage *uiImage = [[UIImage alloc] initWithCGImage:imgRef];
        CGImageRelease(imgRef);
        //NSData *jpgData = UIImageJPEGRepresentation(uiImage, 0.6);
        //[jpgData writeToURL:[[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]] atomically:NO];
        
        //[self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
        //[self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
        
        float divisor = (float)uiImage.size.height / (float)uiImage.size.width;
        
        int newHeight = 568;
        int newWidth = (int)(((float)568)/divisor);
        
        self.selectedVideoFromPicker = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[self generateCode]]]];
        
        SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
        encoder.outputFileType = AVFileTypeMPEG4;
        encoder.outputURL = self.selectedVideoFromPicker;
        encoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: [NSNumber numberWithInt:320],
        AVVideoHeightKey: [NSNumber numberWithInt:568],
        AVVideoCompressionPropertiesKey: @
            {
            AVVideoAverageBitRateKey: @100000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
            },
        };
        encoder.audioSettings = @
        {
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000,
        };
        
        [encoder exportAsynchronouslyWithCompletionHandler:^
         {
             if (encoder.status == AVAssetExportSessionStatusCompleted)
             {
                 NSLog(@"Video export succeeded to URL %@",self.selectedVideoFromPicker);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     @try {
                         if (backgroundRecordingID != UIBackgroundTaskInvalid)
                         {
                             [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
                         }
                     }
                     @catch (NSException *exception) {
                         NSLog(@"some real **** shit %@",exception);
                     }
                     @finally {
                         //
                     }
                     [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
                     [self performSegueWithIdentifier:@"toAnnotateFromCustom" sender:self];
                 });
             }
             else if (encoder.status == AVAssetExportSessionStatusCancelled)
             {
                 NSLog(@"Video export cancelled failed to %@",self.selectedVideoFromPicker);
             }
             else
             {
                 NSLog(@"Video export failed with error: %@ (%d) for url %@", encoder.error.localizedDescription, (int)encoder.error.code, self.selectedVideoFromPicker);
             }
             [self.progressTimer invalidate];
             CGRect temp = self.progressBar.frame;
             temp.size.width = 0;
             self.progressBar.frame = temp;
         }];
    }
    else
    {
        [self.progressTimer invalidate];
        CGRect temp = self.progressBar.frame;
        temp.size.width = 0;
        self.progressBar.frame = temp;
    }
    
    self.didCancelRecording= NO;
}

- (NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 40 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 10; i++) {
        uint32_t r;
        
        // Append 2 random letters:
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        
        // Append 2 random digits:
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        
    }
    NSLog(@"s-->%@",s);
    return s;
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
    NSLog(@"authorization check");
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Dojo"
											message:@"Dojo doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toAnnotateFromCustom"])
    {
        
        // Get reference to the destination view controller
        DOJOAnnotateViewController *vc = [segue destinationViewController];
        
        NSLog(@"applying properties");
        
        dispatch_async([self sessionQueue], ^{
            @try {
                [[self session] stopRunning];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:
                 AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
                [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
                [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through remove try loop");
            }
            
        });
        
        if ([self.parentHash isEqualToString:@""])
        {
            vc.parentHash = @"";
        }
        else
        {
            vc.parentHash = self.parentHash;
            NSLog(@"camcont parent hash is %@",self.parentHash);
        }
        vc.compressedVideoURL = self.compressedVideoURL;
        NSLog(@"compressed video url is %@",vc.compressedVideoURL);
        vc.imageData = imageData;
        vc.mediaType = mediaType;
        vc.picImage = originalImage;
        vc.capturedMovie = videoData;
        vc.didUseImagePicker = self.didUseImagePicker;
        vc.urlFromPicker = self.selectedVideoFromPicker;
        vc.forwardCameraString = self.forwardCameraString;
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
