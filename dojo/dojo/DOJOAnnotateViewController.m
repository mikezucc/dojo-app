//
//  DOJOAnnotateViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/18/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOAnnotateViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "../DOJOHomeViewController.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import "DOJOHomeTableViewController.h"
#import "DOJONavigationController.h"
//#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import "DOJOAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DOJOAnnotateViewController () <UITextFieldDelegate , MPMediaPlayback, DrawButtonDelegate>

@property (strong, nonatomic) AVAssetWriter *videoWriter;

@property (strong, nonatomic) dispatch_queue_t pickerqueue;
@property (strong, nonatomic) UIColor *selectedColor;

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint currentPointinButton;
@property (nonatomic) CGPoint lastPointinButton;
@property (nonatomic) BOOL drawingIsEnabled;
@property (nonatomic) BOOL didDraw;
@property (strong, nonatomic) NSMutableArray *paintHistory;

@property CGRect squashedRect;

@property (strong, nonatomic) UIImage *aLayer;
 
@end

@implementation DOJOAnnotateViewController

@synthesize mediaType, imageData, editingBar, isMovie, moviePlayer, cancelButton, doneButton, annotateField, picImage, capturedMovie, capturedImage, annotateView, preventJumping, codeKey, sendViewController, viewDidLoadAlready, numberOfRequiredResponses, numberOfReceivedResponses, uploadingShit, performedPost, uploadRequest, uploadRequest2, uploadingShitDone, videoWriter, didUseImagePicker, urlFromPicker, uploadArrow, uploadGroup, startTouch, rotateVal, parentHash, drawTool, drawPlatform, selectedColor, currentPoint, lastPoint, drawingIsEnabled, paintHistory, aLayer, didDraw, undoButton, capturedImageView, colorWheel, imageDims, didAppearOnce, didEndChoosingColor, squashedRect, forwardCameraString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // closebuttoncamera.png
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.drawingIsEnabled)
    {
        //[self touchesCancelled:touches withEvent:event];
        return;
    }
    self.startTouch = [(UITouch *)[touches anyObject] locationInView:self.view];
    self.rotateVal = 0;
    self.lastPoint = self.startTouch;
    self.aLayer = [[UIImage alloc] init];
    self.didDraw = NO;
    CGPoint pointSwag = [[touches anyObject] locationInView:self.colorWheel];
    if ((pointSwag.x > 0) && (pointSwag.x < self.colorWheel.frame.size.width) && (pointSwag.y > 0) && (pointSwag.y < self.colorWheel.frame.size.height))
    {
        self.didEndChoosingColor = NO;
    }
    else
    {
        self.didEndChoosingColor = YES;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.drawingIsEnabled)
    {
        //[self touchesCancelled:touches withEvent:event];
        return;
    }
    self.didEndChoosingColor = YES;
    CGPoint pointSwag = [[touches anyObject] locationInView:self.colorWheel];
    if ((pointSwag.x > 0) && (pointSwag.x < self.colorWheel.frame.size.width) && (pointSwag.y > 0) && (pointSwag.y < self.colorWheel.frame.size.height))
    {
        unsigned char pixel[4] = {0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
        CGContextTranslateCTM(context, -pointSwag.x, -pointSwag.y);
        [self.colorWheel.layer renderInContext:context];
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
        if ((pixel[3]/255.0) > 0.9)
        {
            self.selectedColor = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
            self.annotateView.backgroundColor = self.selectedColor;
            [self.annotateView setNeedsDisplay];
        }
        return;
    }
    
    if (self.didDraw)
    {
        UIImage *image = [[UIImage alloc] initWithCGImage:self.drawPlatform.image.CGImage];
        [self.paintHistory addObject:image];
        [self.undoButton setHidden:NO];
        NSLog(@"adding an image, total images: %ld",(long)self.paintHistory.count);
        /*
        CGSize size = CGSizeMake(image.size.width, image.size.height);
        UIGraphicsBeginImageContext(size);
        for (int i=0; i<self.paintHistory.count;i++)
        {
            UIImage *temp = [self.paintHistory objectAtIndex:i];
            [temp drawInRect:CGRectMake(0, 0, temp.size.width, temp.size.height)];
        }
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        self.drawPlatform.image = finalImage;
        UIGraphicsEndImageContext();
         */
    }
    else
    {
        CGPoint aPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawPlatform.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), aPoint.x, aPoint.y+30);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), aPoint.x, aPoint.y+30);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 6.0 );
        const CGFloat *components = CGColorGetComponents(self.selectedColor.CGColor);
        CGFloat compR = components[0];
        CGFloat compG = components[1];
        CGFloat compB = components[2];
        CGFloat compA = components[3];
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), compR, compG, compB, compA);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        //self.aLayer = UIGraphicsGetImageFromCurrentImageContext();
        self.drawPlatform.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage *image = [[UIImage alloc] initWithCGImage:self.drawPlatform.image.CGImage];
        [self.paintHistory addObject:image];
        [self.undoButton setHidden:NO];
        NSLog(@"adding an image, total images: %ld",(long)self.paintHistory.count);
    }
    /*
    if (self.uploadArrow.center.y <= self.uploadGroup.center.y)
    {
        //[self.view setUserInteractionEnabled:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotate) userInfo:nil repeats:YES];
        [self doneButtonPress];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.uploadGroup.frame;
            frm.origin.y = 44;
            self.uploadGroup.frame = frm;
            
            frm = self.uploadArrow.frame;
            frm.origin.y = 343;
            self.uploadArrow.frame = frm;
            
            self.uploadGroup.alpha = 0;
            self.uploadArrow.alpha = 0;
        }];
    }
     */
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.drawingIsEnabled)
    {
        //[self touchesCancelled:touches withEvent:event];
        return;
    }
    CGPoint pointSwag = [[touches anyObject] locationInView:self.colorWheel];
    if ((pointSwag.x > 0) && (pointSwag.x < self.colorWheel.frame.size.width) && (pointSwag.y > 0) && (pointSwag.y < self.colorWheel.frame.size.height))
    {
        unsigned char pixel[4] = {0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
        CGContextTranslateCTM(context, -pointSwag.x, -pointSwag.y);
        [self.colorWheel.layer renderInContext:context];
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
        if ((pixel[3]/255.0) > 0.9)
        {
            self.selectedColor = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
            self.annotateView.backgroundColor = self.selectedColor;
            [self.annotateView setNeedsDisplay];
        }
        return;
    }
    if (!self.didEndChoosingColor)
    {
        return;
    }
    self.didDraw = YES;
    NSLog(@"drawing within the platform");
    currentPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawPlatform.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y+30);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y+30);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 6.0 );
    const CGFloat *components = CGColorGetComponents(self.selectedColor.CGColor);
    CGFloat compR = components[0];
    CGFloat compG = components[1];
    CGFloat compB = components[2];
    CGFloat compA = components[3];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), compR, compG, compB, compA);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    //self.aLayer = UIGraphicsGetImageFromCurrentImageContext();
    self.drawPlatform.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.lastPoint = self.currentPoint;
    /*
    float distance = self.startTouch.y - newtouch.y;
    NSLog(@"distance is %f",distance);
    if (distance > 0)
    {
        if ((self.uploadArrow.center.y-distance+100) < self.uploadGroup.center.y)
        {
            
        }
        else
        {
            CGRect frm = self.uploadGroup.frame;
            frm.origin.y = (distance*1.25) + 44;
            //frm.size.width = 1/sqrtf(distance/400) + 100;
            self.uploadGroup.frame = frm;
            
            frm = self.uploadArrow.frame;
            frm.origin.y = 343 - (distance*2);
            //frm.size.width = 1/sqrtf(distance/400) + 100;
            self.uploadArrow.frame = frm;
        }
        
        [self.uploadArrow setAlpha:(distance/100)];
        [self.uploadArrow setTintColor:[UIColor colorWithHue:(distance/100) saturation:0.8 brightness:1.0 alpha:1]];
        [self.uploadGroup setAlpha:(distance/100)];
        [self.uploadGroup setTintColor:[UIColor colorWithHue:(distance/100) saturation:0.8 brightness:1.0 alpha:1]];
    }
    else
    {
        [self.uploadArrow setAlpha:0];
        [self.uploadGroup setAlpha:0];
    }
     */
}

-(IBAction)undoALayer
{
    @try {
        [self.paintHistory removeObjectAtIndex:(self.paintHistory.count-1)];
        NSLog(@"undoing a layer, now total images: %ld",self.paintHistory.count);
        if (self.paintHistory.count >0)
        {
            CGSize size = CGSizeMake(((UIImage *)[self.paintHistory objectAtIndex:0]).size.width, ((UIImage *)[self.paintHistory objectAtIndex:0]).size.height);
            UIGraphicsBeginImageContext(size);
            for (int i=0; i<self.paintHistory.count;i++)
            {
                UIImage *temp = [self.paintHistory objectAtIndex:i];
                [temp drawInRect:CGRectMake(0, 0, temp.size.width, temp.size.height)];
            }
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            self.drawPlatform.image = finalImage;
            UIGraphicsEndImageContext();
        }
        else
        {
            CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
            UIGraphicsBeginImageContext(size);
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            self.drawPlatform.image = finalImage;
            UIGraphicsEndImageContext();
            [self.undoButton setHidden:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"undo a layer exception is %@",exception);
    }
    @finally {
        NSLog(@"finally run tha trap");
    }
}

-(void)activatedInDrawButton:(UITouch *)startyTouch
{
    [self.colorWheel setHidden:NO];
    [self.view bringSubviewToFront:self.colorWheel];
    self.didMove = NO;
    self.currentPointinButton = [startyTouch locationInView:self.view];
}

-(void)movingInDrawButton:(UITouch *)currentTouch
{
    //self.annotateField.textColor = [self getPixelColorAtLocation:currentPoint];
    self.didMove = YES;
    CGPoint pointSwag = [currentTouch locationInView:self.colorWheel];
    /*
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    
    CGContextTranslateCTM(context, -pointSwag.x, -pointSwag.y);
    
    [self.colorWheel.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    self.selectedColor = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    self.annotateView.backgroundColor = self.selectedColor;
    [self.annotateView setNeedsDisplay];
    */
    self.lastPointinButton = pointSwag;
    
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    CGImageRef inImage = self.colorWheel.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    // Get image width, height. We'll use the entire image.
    bitmapBytesPerRow   = (4 * pixelsWide);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!\n");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

-(void)releasedInDrawButton:(UITouch *)lastTouch
{
    //[self.colorWheel setHidden:YES];
    if ((fabs([lastTouch locationInView:self.view].x - self.currentPointinButton.x) < 17) && (fabs([lastTouch locationInView:self.view].y - self.currentPointinButton.y) < 17))
    {
        if (self.drawingIsEnabled)
        {
            [self.drawTool setImage:[UIImage imageNamed:@"emptydrawtool.png"] forState:UIControlStateNormal];
            self.drawingIsEnabled = NO;
            [self.undoButton setHidden:YES];
            [self.colorWheel setHidden:YES];
        }
        else
        {
            [self.drawTool setImage:[UIImage imageNamed:@"filleddrawtool.png"] forState:UIControlStateNormal];
            self.drawingIsEnabled = YES;
            [self.undoButton setHidden:NO];
            [self.colorWheel setHidden:NO];
        }
    }
    /*
    if (self.didMove)
    {
        if ((fabs([lastTouch locationInView:self.view].x - self.currentPointinButton.x) < 17) && (fabs([lastTouch locationInView:self.view].y - self.currentPointinButton.y) < 17))
        {
            if (self.drawingIsEnabled)
            {
                [self.drawTool setImage:[UIImage imageNamed:@"emptydrawtool.png"] forState:UIControlStateNormal];
                self.drawingIsEnabled = NO;
                [self.undoButton setHidden:YES];
            }
            else
            {
                [self.drawTool setImage:[UIImage imageNamed:@"filleddrawtool.png"] forState:UIControlStateNormal];
                self.drawingIsEnabled = YES;
                [self.undoButton setHidden:NO];
            }
        }
        else
        {
            [self.drawTool setImage:[UIImage imageNamed:@"filleddrawtool.png"] forState:UIControlStateNormal];
            self.drawingIsEnabled = YES;
            [self.undoButton setHidden:NO];
        }
    }
    else
    {
        [self.drawTool setImage:[UIImage imageNamed:@"emptydrawtool.png"] forState:UIControlStateNormal];
        self.drawingIsEnabled = NO;
        [self.undoButton setHidden:YES];
    }
     */
    /*
    UIColor* color = nil;
    CGImageRef inImage = self.capturedImageView.image.CGImage;
    
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return; }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(lastPoint.y+30))+round(lastPoint.x+30));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        NSLog(@"updating with new colors");
        self.annotateView.backgroundColor = color;
        [self.annotateView setNeedsDisplay];
    }
    
    // When finished, release the context
    //CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    //CGImageRelease(inImage);
    */
}

-(void)colorRotate
{
    self.rotateVal = (self.rotateVal + 1);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.uploadArrow setTintColor:[UIColor colorWithHue:(rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
    [self.uploadGroup setTintColor:[UIColor colorWithHue:(rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.didAppearOnce)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
        NSDictionary *didpostdict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        if ([(NSString *)[didpostdict objectForKey:@"didPost"] isEqualToString:@"yes"])
        {
            [moviePlayer stop];
            [moviePlayer.view removeFromSuperview];
            moviePlayer = nil;
            [self dismissViewControllerAnimated:NO completion:^{NSLog(@"NANNOTATE");}];
        }
    }
    else
    {
        self.didAppearOnce = YES;
        
        //DOJONavigationController *NavVC = (DOJONavigationController *)[self.presentingViewController presentingViewController];
        //DOJOHomeTableViewController *homeVC = NavVC.childViewControllers[0];
        //NSLog(@"homeVC CURRENT LOCATION %@",homeVC.currentLocation);
        
        UIImage *image = [UIImage imageNamed:@"uploadarrow.png"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.uploadArrow setImage:image];
        self.uploadArrow.contentMode = UIViewContentModeScaleAspectFit;
        self.uploadArrow.tintColor = [UIColor redColor];
        [self.uploadArrow setAlpha:0];
        UIImage *another = [UIImage imageNamed:@"earth26-2.png"];
        another = [another imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.uploadGroup setImage:another];
        self.uploadGroup.contentMode = UIViewContentModeScaleAspectFit;
        self.uploadGroup.tintColor = [UIColor redColor];
        [self.uploadGroup setAlpha:0];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *virginityPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"virginity.plist"]];
        NSMutableDictionary *virginDict = [[NSMutableDictionary alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:virginityPath])
        {
            virginDict = [[NSMutableDictionary alloc] initWithContentsOfFile:virginityPath];
            NSLog(@"virgindict is %@",virginDict);
            if ([[virginDict valueForKey:@"AnnotateVirgin"] isEqualToString:@"yes"])
            {
                //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Describe your thought. Press Done to send it to some Dojos. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
                //[alertView show];
                [virginDict setValue:@"no" forKey:@"AnnotateVirgin"];
                [virginDict writeToFile:virginityPath atomically:YES];
            }
            else
            {
                // do nothing
            }
        }
        else
        {
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Describe your thought. Press Done to send it to some Dojos. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            //[alertView show];
            [virginDict setValue:@"no" forKey:@"AnnotateVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        
        //[uploadingShitDone setAlpha:0];
        //[uploadingShit setAlpha:0];
        if ([viewDidLoadAlready isEqualToString:@"loaded"])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
            NSDictionary *didpostdict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            if ([(NSString *)[didpostdict objectForKey:@"didPost"] isEqualToString:@"yes"])
            {
                [moviePlayer stop];
                [moviePlayer.view removeFromSuperview];
                moviePlayer = nil;
                [self dismissViewControllerAnimated:NO completion:^{NSLog(@"NANNOTATE");}];
            }
        }
        else
        {
            viewDidLoadAlready = @"loaded";
        }
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    doneButton.enabled = YES;
    
    if (self.didAppearOnce)
    {
        
    }
    else
    {
        self.didAppearOnce = YES;
        
        self.annotateField.text = self.forwardCameraString;
        
        UIImage *image = [UIImage imageNamed:@"closebuttoncamera.png"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.cancelButton setImage:image forState:UIControlStateNormal];
        [self.cancelButton setTintColor:[UIColor whiteColor]];
        
        if ([viewDidLoadAlready isEqualToString:@"loaded"])
        {
            //loaded, after send cancels
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"mediaType.plist"]];
            NSDictionary *mediaTypeDict = [[NSDictionary alloc] initWithContentsOfURL:selectedPath];
            mediaType = [mediaTypeDict valueForKey:@"mediaType"];
            
            NSLog(@"TESTING FOR REMOVAL OF SEND VIEW");
            
            //editingBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 30)];
            NSLog(@"media type is %@",mediaType);
            self.view.backgroundColor = [UIColor whiteColor];
            
            if ([mediaType isEqualToString:@"movie"])
            {
                [self.drawTool setHidden:YES];
                //display movie, and set to loop (set movie to play on viewDidAppear <<<< THAT THAT HAT
                NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
                NSLog(@"movie path is %@",selectedPath);
                moviePlayer = [[MPMoviePlayerController alloc] init];
                moviePlayer.controlStyle = MPMovieControlStyleNone;
                if (self.didUseImagePicker)
                {
                    [moviePlayer setContentURL:urlFromPicker];
                }
                else
                {
                    [moviePlayer setContentURL:selectedPath];
                }
                [moviePlayer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
                [self.view addSubview:moviePlayer.view];
                moviePlayer.repeatMode = MPMovieRepeatModeOne;
                moviePlayer.movieSourceType = MPMovieSourceTypeFile;
                moviePlayer.view.contentMode = UIViewContentModeScaleAspectFit;
                [moviePlayer prepareToPlay];
                [moviePlayer play];
            }
            else
            {
                NSLog(@"is image right?");
                // Save image.
                selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"captured.jpeg"]];
                //self.capturedImageView.image =
                //imageData = [NSData dataWithContentsOfURL:selectedPath];
                //self.capturedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, 0, 320, self.view.frame.size.height-self.annotateView.frame.size.height+20)];
                UIImage *sweg = [UIImage imageWithContentsOfFile:[selectedPath path]];
                self.capturedImageView.image = sweg;//[UIImage imageWithData:imageData];
                self.blurredView.image = sweg;
                
                if (self.didUseImagePicker)
                {
                    float hfactor = sweg.size.width / self.capturedImageView.frame.size.width;
                    float vfactor = sweg.size.height / self.capturedImageView.frame.size.height;
                    
                    float factor = fmax(hfactor, vfactor);
                    
                    // Divide the size by the greater of the vertical or horizontal shrinkage factor
                    float newWidth = sweg.size.width / factor;
                    float newHeight = sweg.size.height / factor;
                    
                    // Then figure out if you need to offset it to center vertically or horizontally
                    float leftOffset = (self.capturedImageView.frame.size.width - newWidth) / 2;
                    float topOffset = (self.capturedImageView.frame.size.height - newHeight) / 2;
                    
                    self.squashedRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
                    UIGraphicsBeginImageContextWithOptions(self.capturedImageView.frame.size, NO, 0.0);
                    [sweg drawInRect:self.squashedRect blendMode:kCGBlendModeLuminosity alpha:1];
                    UIImage *tmpValue = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    self.capturedImageView.image = tmpValue;
                    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
                }
                else
                {
                    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
                    [self.capturedImageView setFrame:CGRectMake(0, 0, 320, 480)];
                }
                //float degrees = 90;
                //imageViewPic.clipsToBounds = YES;
                //imageViewPic.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
            }
            
            //add in the editing bar
            /*
             editingBar = [[UIToolbar alloc] init];
             //[editingBar setBarStyle:UIBarStyleBlackOpaque];
             [editingBar setBackgroundColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
             [editingBar setBarTintColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
             editingBar.tintColor = [UIColor whiteColor];
             editingBar.alpha = 1.0;
             //create buttons and set their corresponding selectors
             // cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPress)];
             doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPress)];
             UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
             //add buttons to the toolbar
             //[editingBar setItems:[NSArray arrayWithObjects:cancelButton, spacer, doneButton, nil]];
             //add toolbar to the main view
             // editingBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-50, self.view.frame.size.width, 50);
             // [self.view addSubview:editingBar];
             */
            /*
             annotateField = [[UITextField alloc] initWithFrame:CGRectMake(annotateView.frame.origin.x, annotateView.frame.origin.y, self.view.frame.size.width, 100)];
             annotateField.text = @"what you on about";
             annotateField.textColor = [UIColor whiteColor];
             //[annotateField setBackgroundColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:0.8]];
             //[self.view addSubview:annotateField];
             */
            [annotateField setDelegate:self];
            annotateField.delegate = self;
            
            /*
             annotateView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, 440, self.view.frame.size.width, 130)];
             [annotateView addSubview:annotateField];
             [annotateView setBackgroundColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
             [self.view addSubview:annotateView];
             */
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *checkedListPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"sendchecked.plist"]];
        [fileManager removeItemAtPath:checkedListPath error:nil];
        
        NSLog(@"got here");
        [self.view bringSubviewToFront:self.uploadArrow];
        [self.view bringSubviewToFront:self.uploadGroup];
        [self.view bringSubviewToFront:self.cancelButton];
        [self.view bringSubviewToFront:self.drawTool];
        [self.view bringSubviewToFront:self.drawPlatform];
        [self.view bringSubviewToFront:self.undoButton];
        [self.view bringSubviewToFront:self.annotateView];
        [self.undoButton setHidden:YES];
        
        self.paintHistory = [[NSMutableArray alloc] init];
        
        self.drawTool.drawDelegate = self;
    }
}

-(IBAction)saveThisImage
{
    if ([mediaType isEqualToString:@"image"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"captured.jpeg"]];
        NSData *readData = [NSData dataWithContentsOfURL:selectedPath];
        UIImage *highRes = [UIImage imageWithData:readData];
        if (self.didUseImagePicker)
        {
            float hfactor = highRes.size.width / self.capturedImageView.frame.size.width;
            float vfactor = highRes.size.height / self.capturedImageView.frame.size.height;
            
            float factor = fmax(hfactor, vfactor);
            
            // Divide the size by the greater of the vertical or horizontal shrinkage factor
            float newWidth = highRes.size.width / factor;
            float newHeight = highRes.size.height / factor;
            
            // Then figure out if you need to offset it to center vertically or horizontally
            float leftOffset = (self.capturedImageView.frame.size.width - newWidth) / 2;
            float topOffset = (self.capturedImageView.frame.size.height - newHeight) / 2;
            
            self.squashedRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
        }
        else
        {
            self.squashedRect = CGRectMake(0, 0, highRes.size.width, highRes.size.height);
        }
        if (self.paintHistory.count >0)
        {
            UIGraphicsBeginImageContextWithOptions(self.squashedRect.size, NO, 0.0);
            [highRes drawInRect:CGRectMake(0, 0, self.squashedRect.size.width, self.squashedRect.size.height)];
            for (int i=0; i<self.paintHistory.count;i++)
            {
                UIImage *temp = [self.paintHistory objectAtIndex:i];
                /*
                 CGRect clippedRect  = CGRectMake(0 ,0,180 ,180);
                 CGImageRef imageRef = CGImageCreateWithImageInRect(imgVw1.image.CGImage, clippedRect);
                 UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
                 CGImageRelease(imageRef);
                 imgVw1Cliped.image=newImage;
                 */
                NSLog(@"IMAGE FRAME IS");
                [temp drawInRect:CGRectMake(0, -self.squashedRect.origin.y, self.squashedRect.size.width, self.squashedRect.size.height)];
            }
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            highRes = finalImage;
            UIGraphicsEndImageContext();
        }
        [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[highRes CGImage] orientation:(ALAssetOrientation)[highRes imageOrientation] completionBlock:nil];
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
        NSLog(@"movie path is %@",selectedPath);
        if (self.didUseImagePicker)
        {
            [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:urlFromPicker completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error)
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Could not save!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved!" delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil] show];
                }
            }];
        }
        else
        {
            [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:selectedPath completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error)
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Could not save!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved!" delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles:nil] show];
                }
            }];
        }
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 150 || returnKey;
}

- (void)viewDidLoad
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
    
    self.preventJumping = NO;
    
    [super viewDidLoad];
    
    self.selectedColor = [UIColor purpleColor];
    
    self.squashedRect = CGRectZero;
    
    // Do any additional setup after loading the view.
    //self.parentHash = [[NSString alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateProgessOfUpload:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t) totalBytesExpectedToSend
{
    NSLog(@"bytes sent %ld, totalByes sent %ld, totalBytesExpected to send %ld",(long)bytesSent,(long)totalBytesSent,(long)totalBytesExpectedToSend);
    @try {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            UIImage *unlocked = [UIImage imageNamed:@"loadingicongreen.png"];
            double newHeight = floor(300.0*((float)totalBytesSent/(float)totalBytesExpectedToSend));
            NSLog(@"newHeight is %f",newHeight);
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, newHeight),NO,0.0);
            [unlocked drawInRect:CGRectMake(0, 0, 300, 300)];
            UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            uploadingShitDone.image = resizedUnlock;
        } completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"exception for rendering is %@",exception);
        UIImage *unlocked = [UIImage imageNamed:@"loadingicongreen.png"];
        double newHeight = floor(300.0*((float)totalBytesSent/(float)totalBytesExpectedToSend));
        NSLog(@"newHeight is %f",newHeight);
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, newHeight),NO,0.0);
        [unlocked drawInRect:CGRectMake(0, 0, 300, 300)];
        UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        uploadingShitDone.image = resizedUnlock;
    }
    @finally {
        NSLog(@"ran through anim block");
    }
    
}

-(IBAction)doneButtonIB:(id)sender
{
    [self doneButtonPress];
}

-(void)doneButtonPress
{
    //uploadingShit = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-150, (self.view.frame.size.height/2)-150, 300, 300)];
    //uploadingShit.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //uploadingShit.image = [UIImage imageNamed:@"loadingiconblue.png"];
    //uploadingShit.alpha=0;
    //[self.view addSubview:uploadingShit];
    //doneButton.enabled = NO;
   // [UIView animateWithDuration:0.2 animations:^{
    //    uploadingShit.alpha = 1.0;
   // }];
    /*
    uploadingShitDone = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-150, (self.view.frame.size.height/2)-150, 300, 300)];
    uploadingShitDone.contentMode = UIViewContentModeTopLeft;
    uploadingShitDone.backgroundColor = [UIColor clearColor];
    [self.view addSubview:uploadingShitDone];
    */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
   
    codeKey = [self generateCode];
    NSLog(@"key code is %@",codeKey);
    
    //[AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    self.numberOfReceivedResponses = 0;
    numberOfRequiredResponses = 2;
    if ([mediaType isEqualToString:@"image"])
    {
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"captured.jpeg"]];
        NSData *readData = [NSData dataWithContentsOfURL:selectedPath];
        UIImage *highRes = [UIImage imageWithData:readData];
        if (self.didUseImagePicker)
        {
            float hfactor = highRes.size.width / self.capturedImageView.frame.size.width;
            float vfactor = highRes.size.height / self.capturedImageView.frame.size.height;
            
            float factor = fmax(hfactor, vfactor);
            
            // Divide the size by the greater of the vertical or horizontal shrinkage factor
            float newWidth = highRes.size.width / factor;
            float newHeight = highRes.size.height / factor;
            
            // Then figure out if you need to offset it to center vertically or horizontally
            float leftOffset = (self.capturedImageView.frame.size.width - newWidth) / 2;
            float topOffset = (self.capturedImageView.frame.size.height - newHeight) / 2;
            
            self.squashedRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
        }
        else
        {
            self.squashedRect = CGRectMake(0, 0, highRes.size.width, highRes.size.height);
        }
        if (self.paintHistory.count >0)
        {
            UIGraphicsBeginImageContextWithOptions(self.squashedRect.size, NO, 0.0);
            [highRes drawInRect:CGRectMake(0, 0, self.squashedRect.size.width, self.squashedRect.size.height)];
            for (int i=0; i<self.paintHistory.count;i++)
            {
                UIImage *temp = [self.paintHistory objectAtIndex:i];
                /*
                CGRect clippedRect  = CGRectMake(0 ,0,180 ,180);
                CGImageRef imageRef = CGImageCreateWithImageInRect(imgVw1.image.CGImage, clippedRect);
                UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                imgVw1Cliped.image=newImage;
                 */
                NSLog(@"IMAGE FRAME IS");
                [temp drawInRect:CGRectMake(0, -self.squashedRect.origin.y, self.squashedRect.size.width, self.squashedRect.size.height)];
            }
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            highRes = finalImage;
            UIGraphicsEndImageContext();
        }/*
        else
        {
            CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
            UIGraphicsBeginImageContext(size);
            [highRes drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            picImage = finalImage;
            UIGraphicsEndImageContext();
            [self.undoButton setHidden:YES];
        }
          */
        NSLog(@"image size is WIDT: %f and HEIGHT %f",highRes.size.width/4,highRes.size.height/4);
        UIImage *lowImage = [[UIImage alloc] init];
        CGRect rect = CGRectMake(0,0,highRes.size.width/4,highRes.size.height/4);
        UIGraphicsBeginImageContextWithOptions( rect.size , NO, 0.0);
        [highRes drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageDataForResize = UIImageJPEGRepresentation(picture1,0.5);
        lowImage = [UIImage imageWithData:imageDataForResize];
        /*
        if (highRes.size.width >= 1000.0)
        {
            
        }
        else
        {
            CGRect rect = CGRectMake(0,0,highRes.size.width,highRes.size.height);
            UIGraphicsBeginImageContext( rect.size );
            [highRes drawInRect:rect];
            UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *imageDataForResize = UIImageJPEGRepresentation(picture1,0.9);
            lowImage = [UIImage imageWithData:imageDataForResize];
        }*/
        
        //post high quality
        NSData *highresData = UIImageJPEGRepresentation(highRes, 0.9);
        NSLog(@"image compression on high res layer one is %lu", (unsigned long)imageData.length);
        
        NSURL *highresURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[codeKey stringByAppendingString:@"-high"]]];
        [highresData writeToURL:highresURL atomically:YES];
        NSURL *lowresURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:codeKey]];
        [imageDataForResize writeToURL:lowresURL atomically:YES];
        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        NSLog(@"transferManager is %@",transferManager);
        AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
        uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
        uploadRequestBig.bucket = @"dojopicbucket";
        uploadRequestBig.key = [codeKey stringByAppendingString:@"-high"];
        uploadRequestBig.contentType = @"image/jpeg";
        uploadRequestBig.contentLength = [NSNumber numberWithFloat:[highresData length]];
        uploadRequestBig.body = highresURL;
        
        self.uploadRequest = uploadRequestBig;

        AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
        uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
        uploadRequestSmall.bucket = @"dojopicbucket";
        uploadRequestSmall.key = codeKey;
        uploadRequestSmall.contentType = @"image/jpeg";
        uploadRequestSmall.contentLength = [NSNumber numberWithFloat:[highresData length]];
        uploadRequestSmall.body = lowresURL;
        
        self.uploadRequest2 = uploadRequestSmall;
        
        NSLog(@"parent hash is %@",self.parentHash);
        if ([self.parentHash isEqualToString:@""])
        {
            NSLog(@"dont need that parent hash");
            // upload via direct
            AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            NSMutableArray *tasks = [NSMutableArray new];
            
            AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
            uploadRequestBig = self.uploadRequest;
            AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
            uploadRequestSmall = self.uploadRequest2;
            
            uploadRequestBig.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update progress.
                    DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appdelegate updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
                });};
            
            DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [appdelegate beginUploadWithKey:codeKey];
            [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task)
            {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    [appdelegate errorDuringUpload:codeKey];
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    [appdelegate finishedUpload:codeKey];
                    /*
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                    NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                    
                    NSString *userEmail = [dictToStore valueForKey:@"userEmail"];
                    NSLog(@"email is %@",userEmail);
                    
                    //LOAD WHOLE RESULTS LIST
                    plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"sendchecked.plist"]];
                    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
                    NSArray *resultLoadedArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
                    NSLog(@"resultLoadedArray is %@", resultLoadedArray);
                    
                    NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
                    //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
                    
                    NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
                    [unlimitedStrings appendString:self.parentHash];
                    //postHash = [self generateCode];
                    
                    [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
                    [postxhashList setObject:codeKey forKey:@"posthash"];
                    [postxhashList setObject:annotateField.text forKey:@"description"];
                    [postxhashList setObject:userEmail forKey:@"email"];
                    
                    NSLog(@"posthash:%@",postxhashList);
                    
                    @try {
                        NSError *error = nil;
                        NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
                        
                        //customize request information
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                        [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:result];
                        
                        NSURLResponse *response = nil;
                        
                        //fire the request and wait for response
                        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                        NSLog(@"decoded string is %@",decodedString);
                        
                        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
                        NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
                        [didpostdict writeToFile:plistPath atomically:YES];
                        //[self performSegueWithIdentifier:@"returnToHomeVC" sender:self];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    @catch (NSException *exception)
                    {
                        //UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
                        //[unable show];
                    }
                    @finally
                    {
                        NSLog(@"elevate yo self");
                    }
                     */
                }
                return nil;
            }]];
            
            [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    [appdelegate errorDuringUpload:codeKey];
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                }
                return nil;
            }]];
            [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
            
        }
        else
        {
            // upload via direct
            AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            NSMutableArray *tasks = [NSMutableArray new];
            
            AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
            uploadRequestBig = self.uploadRequest;
            AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
            uploadRequestSmall = self.uploadRequest2;
            
            DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                    NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                    
                    NSString *userEmail = [dictToStore valueForKey:@"userEmail"];
                    NSLog(@"email is %@",userEmail);
                    
                    //LOAD WHOLE RESULTS LIST
                    plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"sendchecked.plist"]];
                    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
                    NSArray *resultLoadedArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
                    NSLog(@"resultLoadedArray is %@", resultLoadedArray);
                    
                    NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
                    //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
                    
                    NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
                    [unlimitedStrings appendString:self.parentHash];
                    //postHash = [self generateCode];
                    
                    [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
                    [postxhashList setObject:codeKey forKey:@"posthash"];
                    [postxhashList setObject:annotateField.text forKey:@"description"];
                    [postxhashList setObject:userEmail forKey:@"email"];
                    
                    NSLog(@"posthash:%@",postxhashList);
                    
                    @try {
                        NSError *error = nil;
                        NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
                        
                        //customize request information
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                        [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:result];
                        
                        NSURLResponse *response = nil;
                        
                        //fire the request and wait for response
                        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                        NSLog(@"decoded string is %@",decodedString);
                        
                        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
                        NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
                        [didpostdict writeToFile:plistPath atomically:YES];
                        //[self performSegueWithIdentifier:@"returnToHomeVC" sender:self];
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                    @catch (NSException *exception)
                    {
                        //UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
                        //[unable show];
                    }
                    @finally
                    {
                        NSLog(@"elevate yo self");
                    }
                }
                return nil;
            }]];
            
            [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                }
                return nil;
            }]];
        }
        
    }
    else if ([mediaType isEqualToString:@"movie"])
    {
        
        NSLog(@"is movie");
        
        //create thumbnail for collection view, generated should = @"clip-xxx" now @"thumb-clip-xxx"
        [self loadImage];
        
        [moviePlayer stop];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath;
        if (self.didUseImagePicker)
        {
            selectedPath = self.urlFromPicker;
        }
        else
        {
            selectedPath = self.compressedVideoURL;
        }
        NSData *videoData = [[NSData alloc] initWithContentsOfURL:selectedPath];

        //AVURLAsset *asset = [AVURLAsset URLAssetWithURL:selectedPath options:nil];
        
        codeKey = [NSString stringWithFormat:@"%@%@",@"clip-",codeKey];
        // create url for the thumb
        NSURL *thumbURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]];
        
        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        //AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
        uploadRequestBig.bucket = @"dojopicbucket";
        uploadRequestBig.key = codeKey;
        uploadRequestBig.contentType = @"movie/mov";
        uploadRequestBig.contentLength = [NSNumber numberWithFloat:[videoData length]];
        uploadRequestBig.body = selectedPath;
        
        self.uploadRequest = uploadRequestBig;
        
        AWSS3TransferManagerUploadRequest * uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
        uploadRequestSmall.bucket = @"dojopicbucket";
        uploadRequestSmall.key = [NSString stringWithFormat:@"%@%@",@"thumb-",codeKey];
        uploadRequestSmall.contentType = @"image/jpeg";
        uploadRequestSmall.contentLength = [NSNumber numberWithFloat:[(NSData *)UIImageJPEGRepresentation(picImage, 0.9) length]];
        uploadRequestSmall.body = thumbURL;
        
        self.uploadRequest2 = uploadRequestSmall;
        
        NSLog(@"parent hash is %@",self.parentHash);
        if ([self.parentHash isEqualToString:@""])
        {
            NSLog(@"we need tha stanky hash");
            // upload via direct
            AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            NSMutableArray *tasks = [NSMutableArray new];
            
            AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
            uploadRequestBig = self.uploadRequest;
            AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
            uploadRequestSmall = self.uploadRequest2;
            
            DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                }
                return nil;
            }]];
            
            [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                    //[failureAlert show];
                } else {
                    NSLog(@"completed upload");
                    //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                }
                return nil;
            }]];
            [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
        }
        
        
        /*
        AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:selectedPath options:nil];
        AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        //CGSize videoSize = videoTrack.naturalSize;
        
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:600000],AVVideoAverageBitRateKey, AVVideoProfileLevelH264Main32, AVVideoProfileLevelKey,
                                   [NSNumber numberWithInt:24], AVVideoMaxKeyFrameIntervalKey, [NSNumber numberWithInt:0.0], AVVideoMaxKeyFrameIntervalDurationKey, nil],
                                  AVVideoCompressionPropertiesKey, [NSNumber numberWithInt:self.moviePlayer.naturalSize.width], AVVideoWidthKey, [NSNumber numberWithInt:self.moviePlayer.naturalSize.height], AVVideoHeightKey, nil];
        
        AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        videoWriterInput.expectsMediaDataInRealTime = YES;
        videoWriterInput.transform = videoTrack.preferredTransform;
        
        videoWriter = [[AVAssetWriter alloc] initWithURL:compressedPath fileType:AVFileTypeQuickTimeMovie error:nil];
        [videoWriter addInput:videoWriterInput];
        
        NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
        AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
        [videoReader addOutput:videoReaderOutput];
        AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                                assetWriterInputWithMediaType:AVMediaTypeAudio
                                                outputSettings:nil];
        audioWriterInput.expectsMediaDataInRealTime = NO;
        [videoWriter addInput:audioWriterInput];
        AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
        [audioReader addOutput:audioReaderOutput];
        [videoWriter startWriting];
        [videoReader startReading];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
        NSLog(@"BEGINNING video compression");
        [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:
         ^{
             while ([videoWriterInput isReadyForMoreMediaData]) {
                 CMSampleBufferRef sampleBuffer;
                 NSLog(@"READING video compression");
                 if ([videoReader status] == AVAssetReaderStatusReading &&
                     (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
                     NSLog(@"WRITING VIDEO sample buffer");
                     [videoWriterInput appendSampleBuffer:sampleBuffer];
                     CFRelease(sampleBuffer);
                 }
                 else {
                    NSLog(@"VIDEO STATUS COMPLETED OR FAILED");
                     [videoWriterInput markAsFinished];
                     if ([videoReader status] == AVAssetReaderStatusCompleted) {
                         //start writing from audio reader
                         
                         [audioReader startReading];
                         [videoWriter startSessionAtSourceTime:kCMTimeZero];
                         NSLog(@"BEGINNING audio compression");
                         dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue2", NULL);
                         [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:^{
                             while (audioWriterInput.readyForMoreMediaData) {
                                 CMSampleBufferRef sampleBuffer;
                                 if ([audioReader status] == AVAssetReaderStatusReading &&
                                     (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                     NSLog(@"WRITING AUDIO sample buffer");
                                     [audioWriterInput appendSampleBuffer:sampleBuffer];
                                     CFRelease(sampleBuffer);
                                 }
                                 else {
                                     [audioWriterInput markAsFinished];
                                     NSLog(@"AUDIO mark as finished");
                                     if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                         NSLog(@"AUDIO READER flagged completed");
                                         [videoWriter finishWritingWithCompletionHandler:^(){
                                             NSLog(@"Success");
                                             NSLog(@"compressed succesfully");
                                             numberOfRequiredResponses = 2;
                                             
                                             codeKey = [NSString stringWithFormat:@"%@%@",@"clip-",codeKey];
                                             // create url for the thumb
                                             NSURL *thumbURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]];
                                             
                                             AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                                             AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                                             [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                                             
                                             //AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                                             
                                             AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
                                             uploadRequestBig.bucket = @"dojopicbucket";
                                             uploadRequestBig.key = codeKey;
                                             uploadRequestBig.contentType = @"movie/mov";
                                             uploadRequestBig.contentLength = [NSNumber numberWithFloat:[videoData length]];
                                             uploadRequestBig.body = compressedPath;
                                             
                                             self.uploadRequest = uploadRequestBig;
                                             
                                             AWSS3TransferManagerUploadRequest * uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
                                             uploadRequestSmall.bucket = @"dojopicbucket";
                                             uploadRequestSmall.key = [NSString stringWithFormat:@"%@%@",@"thumb-",codeKey];
                                             uploadRequestSmall.contentType = @"image/jpeg";
                                             uploadRequestSmall.contentLength = [NSNumber numberWithFloat:[(NSData *)UIImageJPEGRepresentation(picImage, 0.9) length]];
                                             uploadRequestSmall.body = thumbURL;
                                             
                                             self.uploadRequest2 = uploadRequestSmall;
                                             
                                             NSLog(@"parent hash is %@",self.parentHash);
                                             if ([self.parentHash isEqualToString:@""])
                                             {
                                                 NSLog(@"we need tha stanky hash");
                                                 // upload via direct
                                                 AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
                                                 AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                                                 AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                                                 [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                                                 
                                                 NSMutableArray *tasks = [NSMutableArray new];
                                                 
                                                 AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
                                                 uploadRequestBig = self.uploadRequest;
                                                 AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
                                                 uploadRequestSmall = self.uploadRequest2;
                                                 
                                                DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                 
                                                 [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                                                     if (task.error != nil) {
                                                         NSLog(@"Error: [%@]", task.error);
                                                         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                                                         //[failureAlert show];
                                                     } else {
                                                         NSLog(@"completed upload");
                                                         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                                                         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                                                     }
                                                     return nil;
                                                 }]];
                                                 
                                                 [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                                                     if (task.error != nil) {
                                                         NSLog(@"Error: [%@]", task.error);
                                                         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                                                         //[failureAlert show];
                                                     } else {
                                                         NSLog(@"completed upload");
                                                         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                                                         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                                                     }
                                                     return nil;
                                                 }]];
                                                 [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                                                 [self performSegueWithIdentifier:@"toSendSegue" sender:self];
                                             }
                                             else
                                             {
                                                 // upload via direct
                                                 AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
                                                 AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                                                 AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                                                 [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                                                 
                                                 NSMutableArray *tasks = [NSMutableArray new];
                                                 
                                                 AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
                                                 uploadRequestBig = self.uploadRequest;
                                                 AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
                                                 uploadRequestSmall = self.uploadRequest2;
                                                 
                                                DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                 
                                                 [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                                                     if (task.error != nil) {
                                                         NSLog(@"Error: [%@]", task.error);
                                                         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                                                         //[failureAlert show];
                                                     } else {
                                                         NSLog(@"completed upload");
                                                         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                                                         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                                                         
                                                        }
                                                     return nil;
                                                 }]];
                                                 
                                                 [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
                                                     if (task.error != nil) {
                                                         NSLog(@"Error: [%@]", task.error);
                                                         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                                                         //[failureAlert show];
                                                     } else {
                                                         NSLog(@"completed upload");
                                                         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                                                         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
                                                     }
                                                     return nil;
                                                 }]];
                                             }
                                         }];
                                     }
                                 }
                             }
                         }
                          ];
                     }
                 }
             }
         }
         ];
        */
        /*
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = compressedPath;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        [exportSession exportAsynchronouslyWithCompletionHandler: ^(void) {
            if (exportSession.status == AVAssetExportSessionStatusCompleted)
            {
                NSLog(@"compressed succesfully");
                numberOfRequiredResponses = 2;
                
                codeKey = [NSString stringWithFormat:@"%@%@",@"clip-",codeKey];
                // create url for the thumb
                NSURL *thumbURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]];
                
                AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                self.uploadRequest = [AWSS3TransferManagerUploadRequest new];
                self.uploadRequest.bucket = @"dojopicbucket";
                self.uploadRequest.key = codeKey;
                self.uploadRequest.contentType = @"movie/mov";
                self.uploadRequest.contentLength = [NSNumber numberWithFloat:[videoData length]];
                self.uploadRequest.body = compressedPath;
                
                __weak DOJOAnnotateViewController *weakSelf = self;
                self.uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update progress.
                        DOJOAnnotateViewController *strongSelf = weakSelf;
                        [strongSelf updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
                    });};
                [[transferManager upload:self.uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        [uploadingShit removeFromSuperview];
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                        [failureAlert show];
                    } else {
                        NSLog(@"completed upload 1");
                        self.numberOfReceivedResponses = self.numberOfReceivedResponses + 1;
                        NSLog(@"%ld number of responses",(long)self.numberOfReceivedResponses);
                        if (self.numberOfReceivedResponses >= 2)
                        {
                            [uploadingShit removeFromSuperview];
                            [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
                        }
                    }
                    return nil;
                }];
                 continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                 if (task.error != nil) {
                 NSLog(@"Error: [%@]", task.error);
                 } else {
                 NSLog(@"completed upload");
                 }
                 return nil;
                 }];
                
                self.uploadRequest2 = [AWSS3TransferManagerUploadRequest new];
                self.uploadRequest2.bucket = @"dojopicbucket";
                self.uploadRequest2.key = [NSString stringWithFormat:@"%@%@",@"thumb-",codeKey];
                self.uploadRequest2.contentType = @"image/jpeg";
                self.uploadRequest2.contentLength = [NSNumber numberWithFloat:[(NSData *)UIImageJPEGRepresentation(picImage, 0.9) length]];
                self.uploadRequest2.body = thumbURL;
                
                [[transferManager upload:self.uploadRequest2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        [uploadingShit removeFromSuperview];
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                        [failureAlert show];
                    } else {
                        NSLog(@"completed upload 2");
                        self.numberOfReceivedResponses = self.numberOfReceivedResponses + 1;
                        NSLog(@"%ld number of responses",(long)self.numberOfReceivedResponses);
                        if (self.numberOfReceivedResponses >= 2)
                        {
                            [uploadingShit removeFromSuperview];
                            [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
                        }
                    }
                    return nil;
                }];
                continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                 if (task.error != nil) {
                 NSLog(@"Error: [%@]", task.error);
                 } else {
                 NSLog(@"completed upload");
                 }
                 return nil;
                 }];
            }
            else
            {
                NSLog(@"failed to compress");
                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"failed to compress" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
                [failureAlert show];
            }
        }];
*/
        
        //create s3 handlers
        /*
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        NSLog(@"image compression layer one is %u",capturedMovie.length);
        
        numberOfRequiredResponses = 2;
        
        //post full video
        codeKey = [NSString stringWithFormat:@"%@%@",@"clip-",codeKey];
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:codeKey inBucket:@"dojopicbucket"];
        por.contentType = @"movie/mov";
        por.data = videoData;
        por.delegate = self;
        [por setDelegate:self];
        por.contentLength = [videoData length];
        [s3 putObject:por];
        NSLog(@"after clip");
        
        // post thumb
        por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@%@",@"thumb-",codeKey] inBucket:@"dojopicbucket"];
        por.contentType = @"image/jpeg";
        por.data = [NSData dataWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]]];
        por.delegate = self;
        [por setDelegate:self];
        por.contentLength = [por.data length];
        [s3 putObject:por];
        NSLog(@"after thumb");
        */
        
        
        
    }
    else
    {
        NSLog(@"could not identify media type");
    }
}

-(IBAction)cancelButtonPress
{
    [self dismissViewControllerAnimated:NO completion:^{NSLog(@"dismissing annotate");}];
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

 /*
 
 CONTAINS THE INFORMATION RELEVANT TO HANDLE THE UPLOAD RESPONSES RECEIVED
 CONTAINS THE INFORMATION RELEVANT TO HANDLE THE UPLOAD RESPONSES RECEIVED
 CONTAINS THE INFORMATION RELEVANT TO HANDLE THE UPLOAD RESPONSES RECEIVED
 CONTAINS THE INFORMATION RELEVANT TO HANDLE THE UPLOAD RESPONSES RECEIVED
 
 */
    /*
    //
    numberOfReceivedResponses = numberOfReceivedResponses + 1;
    NSLog(@"number of responses is %d",(int)numberOfReceivedResponses);
    if (numberOfReceivedResponses >= 2)
    {
        NSLog(@"contains two more responses");
        if ([viewDidLoadAlready isEqualToString:@"loaded"])
        {
            //already loaded
            NSLog(@"already loaded");
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSDictionary *didpostdict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            if (([(NSString *)[didpostdict objectForKey:@"didPost"] isEqualToString:@"no"]) || ([fileManager fileExistsAtPath:plistPath]))
            {
                NSLog(@"did not post yet");
                [uploadingShit dismissWithClickedButtonIndex:0 animated:YES];
                [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
                [self performSegueWithIdentifier:@"toSendSegue" sender:self];
                
            }
            NSLog(@"why no send?");
        }
        else
        {
            [uploadingShit dismissWithClickedButtonIndex:0 animated:YES];
            [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
        }
    }
    //request = nil;
    //
    if (((float)bytesWritten/(float)totalBytesExpectedToWrite) == 1)
    {
    }
     */

    /*
    DOJOHomeViewController *parentVC = (DOJOHomeViewController *)[self presentingViewController];
    
            [self dismissViewControllerAnimated:YES completion:^{NSLog(@"anchov");
                [parentVC presentViewController:parentVC.sendController animated:YES completion:^{NSLog(@"YEAH");}];
            }];
    NSLog(@"wtf");
     */
    //[self dismissViewControllerAnimated:YES completion:^{NSLog(@"anchov");}];
    //[self removeFromParentViewController];
    
    
    
   /* dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toSendSegue" sender:self];
    });*/

    /*
    id selfTemp = self;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [selfTemp dismissViewControllerAnimated:YES completion:^{}];
    });
     */

/*
-(void) uploadData:(NSData*)data toBucket:(NSString*)bucket withKey:(NSString*)key {
    typeof(self) weakSelf = self;
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(aQueue, ^{
        typeof(self) strongSelf = weakSelf;
        S3PutObjectRequest * request = [[S3PutObjectRequest alloc] initWithKey:key inBucket:bucket];
        [request setData:data];
        S3PutObjectResponse *response = nil;
        int attempts = 0;
        do {
            //response = [request putObject:request];
            response = [request ]
            attempts++;
        } while (response.error && attempts<3);
        
        //Let the UI thread know what happened with the upload
        dispatch_async(dispatch_get_main_queue(),^(void) {
            [strongSelf uploadDidCompleteWithSuccess:response.error = nil];
        });
    });
}
*/

-(void)scrollUp
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    annotateView.center = CGPointApplyAffineTransform(annotateView.center, CGAffineTransformMakeTranslation(0, -240));
    CGRect frm = annotateView.frame;
    frm.size.width = 320;
    annotateView.frame = frm;
    frm = annotateField.frame;
    frm.size.width = 320;
    annotateField.frame = frm;
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    annotateView.backgroundColor = [UIColor whiteColor];
    [annotateField setTextColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
    [UIView commitAnimations];
}

-(void)scrollDown
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    annotateView.center = CGPointApplyAffineTransform(annotateView.center, CGAffineTransformMakeTranslation(0, 240));
    CGRect frm = annotateView.frame;
    frm.size.width = 264;
    annotateView.frame = frm;
    frm = annotateField.frame;
    frm.size.width = 264;
    annotateField.frame = frm;
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    annotateView.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
    [annotateField setTextColor:[UIColor whiteColor]];
    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"BEGINcenter is %fl",annotateView.center.y);
    if (annotateView.center.y > 300)
    {
        [self scrollUp];
        if ([textField.text isEqualToString:@"what you on about"] || [textField.text isEqualToString:@"what u on a bout eh"])
        {
            textField.text = @"";
        }
    }
    else
    {
        NSLog(@"already up");
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    NSLog(@"ENDcenter is %fl",annotateView.center.y);
    if ((annotateView.center.y < 300) && (self.preventJumping))
    {
        [self scrollDown];
        self.preventJumping = NO;
    }
    else
    {
        NSLog(@"already down");
    }
    //[textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self scrollDown];
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toSendSegue"])
    {
        DOJOSendViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.postHash = codeKey;
        vc.postDescription = annotateField.text;
        
        vc.uploadRequest = self.uploadRequest;
        vc.uploadRequest2 = self.uploadRequest2;
        
        NSLog(@"applying properties");
        NSLog(@"in prepare for segue");
    }
}

-(void)callSendController:(id)sender
{
 //   DOJOSendViewController *sendViewController = [[DOJOSendViewController alloc] init];
  //  [sender presentViewController:sendViewController animated:YES completion:^{NSLog(@"YEAH");}];
}

-(void)viewWillDisappear:(BOOL)animated
{
    /*
    [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
    NSLog(@"instantiated the view controller");
    [self performSegueWithIdentifier:@"toSend" sender:self];
    NSLog(@"call perform segue thing");
     */
    NSLog(@"REMOVED ANNOTATE");
    NSLog(@"instantiated the view controller");
    //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
    
    [self.moviePlayer stop];
}

- (void)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *vidURL;
    if (self.didUseImagePicker)
    {
        vidURL = self.urlFromPicker;
    }
    else
    {
        vidURL = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    UIImage *uiImage = [UIImage imageWithCGImage:imgRef];
    NSData *jpgData = UIImageJPEGRepresentation(uiImage, 0.6);
    [jpgData writeToURL:[[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"thumbTemp.jpeg"]] atomically:NO];
    
    //return [[UIImage alloc] initWithCGImage:imgRef];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL
{
    
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
