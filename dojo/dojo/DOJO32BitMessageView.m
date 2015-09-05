//
//  DOJO32BitMessageView.m
//  dojo
//
//  Created by Michael Zuccarino on 2/10/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJO32BitMessageView.h"
#import "DOJOPerformAPIRequest.h"

#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>
#import <Social/Social.h>

@interface DOJO32BitMessageView () <APIRequestDelegate, UITextViewDelegate, scrolled>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;
@property (strong, nonatomic) SLComposeViewController *fbSLComposeViewController;

@end

@implementation DOJO32BitMessageView

@synthesize messageField, messageView, fieldContainer, sendButton, customNavView, preventJumping, isGoingUp, sendRotater, apiBot, postInfo, rotateVal, fileManager, documentsDirectory, downloadRequest, transferManager;

@synthesize fbSLComposeViewController;

-(IBAction)shareThisShit
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        NSString *picNameCache = [NSString stringWithFormat:@"%@-high.jpeg",[postInfo valueForKey:@"posthash"]];
        NSLog(@"pic name cache is %@",[postInfo valueForKey:@"posthash"]);
        NSString *picPath = [[NSString alloc] initWithString:[NSTemporaryDirectory() stringByAppendingPathComponent:picNameCache]];
        UIImage *image = [[UIImage alloc] init];
        if ([fileManager fileExistsAtPath:picPath])
        {
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
        }
        //http://www.wedojo.com/post/TA76dY31Sc96Mu38/jBG5dGUxj6avbl5akYJUrU7Oqr7RSWdJppx8jkpK2oXZ/
        NSString *baseUrl = @"http://www.wedojo.com/post/";
        fbSLComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        (image != nil ? [fbSLComposeViewController addImage:image] : NSLog(@"no image") );
        [fbSLComposeViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",baseUrl,[postInfo objectForKey:@"dojohash"],[postInfo objectForKey:@"posthash"]]]];
        [fbSLComposeViewController setInitialText:[postInfo objectForKey:@"description"]];
        [self presentViewController:fbSLComposeViewController animated:YES completion:nil];
        
        fbSLComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"facebook: CANCELLED");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"facebook: SHARED");
                    break;
            }
        };
    }
    else {
        UIAlertView *fbError = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"Sorry, we're unable to find a Facebook account on your device.\nPlease setup an account in your devices settings and try again." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [fbError show];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageView = [[DojoPageMessageView alloc] initWithFrame:CGRectMake(0, 62, 320, 506)];
    CGRect frm = self.messageView.messageCollectionView.frame;
    frm.size.height =self.messageView.frame.size.height - self.fieldContainer.frame.size.height;
    self.messageView.messageCollectionView.frame = frm;
    [self.messageView.bongReloader invalidate];
    self.messageView.bongReloader = nil;
    self.messageView.delegate = self;
    
    self.messageView.messageCollectionView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
    
    [self.view addSubview:self.messageView];
    
    fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
     frm = self.fieldContainer.frame;
    frm.origin.y = self.view.frame.size.height-frm.size.height;
    self.fieldContainer.frame = frm;
    
    [self.view bringSubviewToFront:self.fieldContainer];
    
    self.preventJumping = NO;
    
    self.isGoingUp = NO;
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)keyboardFrameDidShow:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
    CGRect frm = self.fieldContainer.frame;
    frm.origin.y = (keyboardFrame.origin.y < 320 ? 262 : 292);
    self.fieldContainer.frame = frm;
    NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
}

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
    CGRect frm = self.fieldContainer.frame;
    frm.origin.y = (keyboardFrame.origin.y < 320 ? 262 : 292);
    self.fieldContainer.frame = frm;
    NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
}

-(IBAction)removeMe
{
    [self.messageView.bongReloader invalidate];
    //self.messageView.bongReloader = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"message board post info is %@",postInfo);
    messageView.postDict = postInfo;
    messageView.isAPost = YES;
    messageView.delegate = self;
    @try {
        //[self becomeFirstResponder];
        [messageView customReloadTheBoard];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through reload board block");
    }
    BOOL isTextPost = NO;
    if ([[postInfo valueForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
    {
        
    }
    else
    {
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[postInfo valueForKey:@"posthash"]];
        NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
        NSLog(@"clip location %lu",(unsigned long)[[postInfo valueForKey:@"posthash"] rangeOfString:@"clip"].location);
        UIImage *image = [[UIImage alloc] init];
        /*if ([fileManager fileExistsAtPath:picPath])
        {
            //load this instead
            @try {
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [self.messageView.backgroundImageView setImage:image];
                NSLog(@"must blur");
                float blurRadius = 1.0f;
                int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
                vImage_Buffer inBuffer, outBuffer;
                vImage_Error error; void *pixelBuffer;
                CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
                CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
                inBuffer.width = CGImageGetWidth(rawImage);
                inBuffer.height = CGImageGetHeight(rawImage);
                inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
                pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
                outBuffer.data = pixelBuffer;
                outBuffer.width = CGImageGetWidth(rawImage);
                outBuffer.height = CGImageGetHeight(rawImage);
                outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
                if (error) { NSLog(@"error from convolution %ld", error);
                } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
                CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                NSData *blurredImage = UIImageJPEGRepresentation(returnImage, 0.6);
                //clean up
                CGContextRelease(ctx);
                CGColorSpaceRelease(colorSpace);
                free(pixelBuffer);
                CFRelease(inBitmapData);
                CGImageRelease(imageRef);
                
                [self.messageView.backgroundImageView setImage:returnImage];
            }
            @catch (NSException *exception) {
                NSLog(@"blur exception is %@",exception);
            }
            @finally {
                NSLog(@"finally ran initial file exist blur");
            }
        }
        else
        {
            if ([[postInfo valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
            {
                NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[postInfo valueForKey:@"posthash"]];
                NSLog(@"code key is %@",codekeythumb);
                
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = codekeythumb;
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [self.messageView.backgroundImageView setImage:dlthumb];
                            NSLog(@"must blur");
                            float blurRadius = 1.0f;
                            int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                            CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
                            vImage_Buffer inBuffer, outBuffer;
                            vImage_Error error; void *pixelBuffer;
                            CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
                            CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
                            inBuffer.width = CGImageGetWidth(rawImage);
                            inBuffer.height = CGImageGetHeight(rawImage);
                            inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
                            pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
                            outBuffer.data = pixelBuffer;
                            outBuffer.width = CGImageGetWidth(rawImage);
                            outBuffer.height = CGImageGetHeight(rawImage);
                            outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
                            if (error) { NSLog(@"error from convolution %ld", error);
                            } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                            CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
                            CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                            UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                            NSData *blurredImage = UIImageJPEGRepresentation(returnImage, 0.6);
                            //clean up
                            CGContextRelease(ctx);
                            CGColorSpaceRelease(colorSpace);
                            free(pixelBuffer);
                            CFRelease(inBitmapData);
                            CGImageRelease(imageRef);
                            
                            [self.messageView.backgroundImageView setImage:returnImage];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"exception executor %@",exception);
                        }
                        @finally {
                            NSLog(@"ran through try block executor");
                        }
                    } else {
                        @try {
                            NSLog(@"completed download");
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [self.messageView.backgroundImageView setImage:dlthumb];
                            
                            NSLog(@"must blur");
                            float blurRadius = 1.0f;
                            int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                            CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
                            vImage_Buffer inBuffer, outBuffer;
                            vImage_Error error; void *pixelBuffer;
                            CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
                            CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
                            inBuffer.width = CGImageGetWidth(rawImage);
                            inBuffer.height = CGImageGetHeight(rawImage);
                            inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
                            pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
                            outBuffer.data = pixelBuffer;
                            outBuffer.width = CGImageGetWidth(rawImage);
                            outBuffer.height = CGImageGetHeight(rawImage);
                            outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
                            if (error) { NSLog(@"error from convolution %ld", error);
                            } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                            CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
                            CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                            UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                            //clean up
                            CGContextRelease(ctx);
                            CGColorSpaceRelease(colorSpace);
                            free(pixelBuffer);
                            CFRelease(inBitmapData);
                            CGImageRelease(imageRef);
                            
                            [self.messageView.backgroundImageView setImage:returnImage];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"random ass exception is %@",exception);
                        }
                        @finally {
                            NSLog(@"finally ran this thing here");
                        }
                    }
                    return nil;
                }];
            }
            else
            {
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = [NSString stringWithFormat:@"%@",[postInfo valueForKey:@"posthash"]];
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                            self.downloadRequest.bucket = @"dojopicbucket";
                            self.downloadRequest.key = [postInfo valueForKey:@"posthash"];
                            self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                            
                            [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                                if (task.error != nil) {
                                    NSLog(@"Error: [%@]", task.error);
                                    @try {
                                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                        [self.messageView.backgroundImageView setImage:image];
                                    }
                                    @catch (NSException *exception) {
                                        NSLog(@"exception executor %@",exception);
                                    }
                                    @finally {
                                        NSLog(@"ran through try block executor");
                                    }
                                } else {
                                    NSLog(@"completed download");
                                    @try {
                                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                        [self.messageView.backgroundImageView setImage:image];
                                        
                                        NSLog(@"must blur");
                                        float blurRadius = 1.0f;
                                        int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                                        CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
                                        vImage_Buffer inBuffer, outBuffer;
                                        vImage_Error error; void *pixelBuffer;
                                        CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
                                        CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
                                        inBuffer.width = CGImageGetWidth(rawImage);
                                        inBuffer.height = CGImageGetHeight(rawImage);
                                        inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                                        inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
                                        pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
                                        outBuffer.data = pixelBuffer;
                                        outBuffer.width = CGImageGetWidth(rawImage);
                                        outBuffer.height = CGImageGetHeight(rawImage);
                                        outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                                        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
                                        if (error) { NSLog(@"error from convolution %ld", error);
                                        } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                                        CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
                                        CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                                        UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                                        //clean up
                                        CGContextRelease(ctx);
                                        CGColorSpaceRelease(colorSpace);
                                        free(pixelBuffer);
                                        CFRelease(inBitmapData);
                                        CGImageRelease(imageRef);
                                        
                                        [self.messageView.backgroundImageView setImage:returnImage];
                                    }
                                    @catch (NSException *exception) {
                                        NSLog(@"blur3 exception is %@",exception);
                                    }
                                    @finally {
                                        NSLog(@"the finaly string is this");
                                    }
                                }
                                return nil;
                            }];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"exception executor %@",exception);
                        }
                        @finally {
                            NSLog(@"ran through try block executor");
                        }
                    } else {
                        NSLog(@"completed download");
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [self.messageView.backgroundImageView setImage:dlthumb];
                            
                            NSLog(@"must blur");
                            float blurRadius = 1.0f;
                            int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                            CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
                            vImage_Buffer inBuffer, outBuffer;
                            vImage_Error error; void *pixelBuffer;
                            CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
                            CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
                            inBuffer.width = CGImageGetWidth(rawImage);
                            inBuffer.height = CGImageGetHeight(rawImage);
                            inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
                            pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
                            outBuffer.data = pixelBuffer;
                            outBuffer.width = CGImageGetWidth(rawImage);
                            outBuffer.height = CGImageGetHeight(rawImage);
                            outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
                            error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
                            if (error) { NSLog(@"error from convolution %ld", error);
                            } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                            CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
                            CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                            UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                            //clean up
                            CGContextRelease(ctx);
                            CGColorSpaceRelease(colorSpace);
                            free(pixelBuffer);
                            CFRelease(inBitmapData);
                            CGImageRelease(imageRef);
                            
                            [self.messageView.backgroundImageView setImage:returnImage];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"blur454 exception is %@",exception);
                        }
                        @finally {
                            NSLog(@"the finally ran this is");
                        }
                    }
                    return nil;
                }];
            }
        }*/
    }
/*
    NSLog(@"must blur");
    float blurRadius = 1.0f;
    int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
    CGImageRef rawImage = self.messageView.backgroundImageView.image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error; void *pixelBuffer;
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) { NSLog(@"error from convolution %ld", error);
    } CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(rawImage));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    [self.messageView.backgroundImageView setImage:returnImage];
    */
    //[self rotateSortType:self.segControl];
}

-(void)detectedTapInMessageView
{
    if ([self.messageField isFirstResponder])
    {
        [self.messageField resignFirstResponder];
        //[self.view sendSubviewToBack:self.fieldContainer];
    }
    else
    {
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.messageField becomeFirstResponder];
    }
}

-(void)messageViewWasScrolled
{
    
}

-(IBAction)submitMessage:(id)sender
{
    if ([self.messageField.text isEqualToString:@""])
    {
        
    }
    else
    {
        self.sendRotater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotateSendButton) userInfo:nil repeats:YES];
        [self.apiBot submitAComment:self.postInfo withText:self.messageField.text];
    }
}

-(void)colorRotateSendButton
{
    self.rotateVal = (self.rotateVal + 2);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.sendButton setBackgroundColor:[UIColor colorWithHue:(self.rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
}

-(void)sentMessage:(NSString *)decodeString
{
    if ([decodeString rangeOfString:@"posted"].location == NSNotFound)
    {
        NSLog(@"posted");
        [self.sendRotater invalidate];
        self.sendRotater = nil;
        [self.sendButton setBackgroundColor:[UIColor colorWithRed:155.0/255.0 green:250.0/255.0 blue:70.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.messageField setText:@""];
        [self.sendRotater invalidate];
        self.sendRotater = nil;
        [self.sendButton setBackgroundColor:[UIColor colorWithRed:155.0/255.0 green:250.0/255.0 blue:70.0/255.0 alpha:1.0]];
        
        [self.messageView customReloadTheBoard];
    }
}

-(NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 3; i++) {
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
    //NSLog(@"s-->%@",s);
    return s;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    //NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    if (returnKey)
    {
        [textView resignFirstResponder];
        return YES;
    }
    
    return newLength <= 200 || returnKey;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%dx %dy prevent:%@", (int)fieldContainer.frame.origin.x, (int)fieldContainer.frame.origin.y,self.preventJumping);
    NSLog(@"BEGINcenter is %fl",self.fieldContainer.center.y);
    if (self.fieldContainer.center.y > 300)
    {
        if ([self.messageField.text isEqualToString:@"Say something to this group"])
        {
            [self.messageField setText:@""];
        }
        [self scrollUp];
    }
    else
    {
        NSLog(@"already up");
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    @try {
        NSLog(@"ENDcenter is %fl",self.fieldContainer.center.y);
        if (self.fieldContainer.center.y < 400)
        {
            if ([self.messageField.text isEqualToString:@""])
            {
                //[self.messageField setText:@"cm on u kno u wanna"];
            }
            else
            {
                
            }
            [self scrollDown];
            self.preventJumping = NO;
        }
        else
        {
            NSLog(@"already down");
        }
        //[textField resignFirstResponder];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"did end editing ran through block");
    }
}

-(void)scrollUp
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frm = self.fieldContainer.frame;
        frm.origin.y = 292;
        self.fieldContainer.frame = frm;
        [self.fieldContainer setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1.0]];
        
        frm = self.messageView.messageCollectionView.frame;
        frm.size.height = self.messageView.frame.size.height - 270;
        self.messageView.messageCollectionView.frame = frm;
        
        if (self.messageView.messageCollectionView.contentSize.height > self.messageView.messageCollectionView.bounds.size.height)
        {
            CGPoint bottomOffset = CGPointMake(0, self.messageView.messageCollectionView.contentSize.height - self.messageView.messageCollectionView.bounds.size.height + 15);
            [self.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
        }
    }];
}

-(void)scrollDown
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frm = self.fieldContainer.frame;
        frm.origin.y = self.view.frame.size.height-frm.size.height;
        self.fieldContainer.frame = frm;
        [self.fieldContainer setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        frm = self.messageView.messageCollectionView.frame;
        frm.size.height =self.messageView.frame.size.height - self.fieldContainer.frame.size.height;
        self.messageView.messageCollectionView.frame = frm;
        
        if (self.messageView.messageCollectionView.contentSize.height > self.messageView.messageCollectionView.bounds.size.height)
        {
            CGPoint bottomOffset = CGPointMake(0, self.messageView.messageCollectionView.contentSize.height - self.messageView.messageCollectionView.bounds.size.height + 15);
            [self.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //scroll view did scroll bug
    //self.revoTableView.contentOffset = CGPointMake(0, 0);
    [self.messageView.bongReloader invalidate];
    //self.messageView.bongReloader = nil;
    [self.messageView endLoadSesh];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
