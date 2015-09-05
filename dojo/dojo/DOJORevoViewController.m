//
//  DOJORevoViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJORevoViewController.h"
#import "DOJORevoCell.h"
#import "DOJOPersonCell.h"
#import "DOJOProfileViewController.h"
#import "DOJOSendViewController.h"
#import "DOJOPerformAPIRequest.h"
#import "DOJO32BitMessageView.h"
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "DOJODeepPostViewController.h"

@interface DOJORevoViewController () < UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, scrolled, UIAlertViewDelegate, RevolDelegate, MagnifiedDelegate, APIRequestDelegate, DSVDelegate>

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *temporaryDirectory;
@property (strong, nonatomic) NSFileManager *fileManager;

@property (nonatomic) dispatch_queue_t profileQueue;
@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@property (nonatomic) dispatch_queue_t convolvequeue;
//@property (nonatomic) dispatch_queue_t convolvequeue;

@property (strong, nonatomic) NSMutableArray *heightTopArray;
@property (strong, nonatomic) NSMutableArray *heightNewArray;

@property (strong, nonatomic) NSDictionary *selectedPostInfo;
@property (strong, nonatomic) UIImage *selectedImage;

@end

@implementation DOJORevoViewController

@synthesize revoTableView, refreshControl, dojoHeader, dojoInfo, documentsDirectory, temporaryDirectory, fileManager, downloadRequest, selectedSortType, sortButton, postListNew, postListTop, postListRoster, selectedPerson, segControl, startOffset, rotateVal, rotater,messageView, messageField, fieldContainer, sendButton, preventJumping, sendRotater, notiBubble, customHeaderView, selectedPostForMessageView, transferManager, pathOfDownloadingCell, postsCountLabel, followersCountLabel, magnifiedView, selectedPost, userProperties, apiBot, backTypeImageView, backButtonForMask, previousInfo, previousType, followLabel, isGoingUp, selectedHashForDojo, rowToScrollTo, createPostButton, sweetMessageView, convolvequeue, dsv3000, dsv300Container, heightTopArray,heightNewArray, followingLoudLabel, openCameraButton, userIsCreator, wasBrowsing, selectedPostInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    postListNew = [[NSArray alloc] init];
    postListTop = [[NSArray alloc] init];
    postListRoster = [[NSArray alloc] init];
    
    self.userIsCreator = NO;
    self.wasBrowsing = NO;
    
    [self.followingLoudLabel.layer setCornerRadius:4.0];
    self.followingLoudLabel.alpha = 0;
    [self.followingLoudLabel setClipsToBounds:YES];
    
    self.dsv300Container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.view addSubview:self.dsv300Container];
    self.dsv300Container.alpha = 0;
    DOJODSV3000 *dsvTempVC = [self.storyboard instantiateViewControllerWithIdentifier:@"dsv3000VC"];
    dsvTempVC.view.frame = self.dsv300Container.bounds;
    [dsvTempVC.view.layer setMasksToBounds:YES];
    [self.dsv300Container addSubview:dsvTempVC.view];
    [self addChildViewController:dsvTempVC];
    [dsvTempVC didMoveToParentViewController:self];
    self.dsv3000 = dsvTempVC;
    self.dsv3000.delegate = self;
    [self.view sendSubviewToBack:self.dsv300Container];
    
    
    fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    temporaryDirectory = NSTemporaryDirectory();

    self.profileQueue = dispatch_queue_create("profile fetcher", DISPATCH_QUEUE_SERIAL);
    self.convolvequeue = dispatch_queue_create("convolvequeue", DISPATCH_QUEUE_SERIAL);
    
    [self.navigationController.navigationBar setHidden:YES];
    
    self.selectedSortType = 0;
    //[self.sortButton setTitle:@"new" forState:UIControlStateNormal];
    
    [self.revoTableView setFrame:CGRectMake(0, 0, 320, 568)];
    [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    [self.revoTableView setBackgroundColor:[UIColor clearColor]];
    self.revoTableView.tag = 101;

    self.createPostButton = [[UIButton alloc] initWithFrame:CGRectMake(10, -60, 220, 60)];
    [self.createPostButton setTitle: @"Pull to Text Post" forState:UIControlStateNormal];
    self.createPostButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:19.0];
    //self.createPostButton.textAlignment = NSTextAlignmentCenter;
    [self.createPostButton addTarget:self action:@selector(postTextPost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createPostButton];
    self.openCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(235, -60, 75, 60)];
    //self.createPostButton.textAlignment = NSTextAlignmentCenter;
    
    [self.openCameraButton addTarget:self action:@selector(goToCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openCameraButton];
    [self.view bringSubviewToFront:self.customHeaderView];
    
    self.sweetMessageView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 235)];
    self.sweetMessageView.text = @"Tell us how it is...";
    self.sweetMessageView.font = [UIFont fontWithName:@"Avenir-Light" size:19.0];
    self.sweetMessageView.textAlignment = NSTextAlignmentLeft;
    self.sweetMessageView.alpha = 0;
    self.sweetMessageView.backgroundColor = [UIColor clearColor];
    self.sweetMessageView.delegate= self;
    self.sweetMessageView.tag = 1;
    [self.view addSubview:self.sweetMessageView];
    [self.view sendSubviewToBack:self.sweetMessageView];
                                    
    
    self.messageView = [[DojoPageMessageView alloc] initWithFrame:CGRectMake(0, 100, 320, 416)];
    self.messageView.messageCollectionView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [self.messageView.bongReloader invalidate];
    self.messageView.bongReloader = nil;
    
    CGRect frm = self.fieldContainer.frame;
    frm.origin.y = self.view.frame.size.height-frm.size.height;
    self.fieldContainer.frame = frm;
    
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.fieldContainer];
    
    [self.messageView setHidden:YES];
    
    [self.fieldContainer setHidden:YES];
    
    self.preventJumping = NO;
    
    self.isGoingUp = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    self.userProperties = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
}

-(void)goToCamera
{
    UINavigationController *homeNavVC = (UINavigationController *)self.navigationController;
    DOJOHomeTableViewController *vc = homeNavVC.viewControllers[0];
    vc.forwardToCamera = YES;
    if ([self.sweetMessageView.text isEqualToString:@"Tell us how it is..."])
    {
        vc.forwardCameraString = @"";
    }
    else
    {
        vc.forwardCameraString = self.sweetMessageView.text;
    }
    [homeNavVC popToRootViewControllerAnimated:YES];
}

-(void)postTextPost
{
    if ([self.sweetMessageView.text isEqualToString:@"Tell us how it is..."]) return;
    [self.apiBot postTextPost:self.sweetMessageView.text toDojo:[self.dojoInfo objectForKey:@"dojohash"]];
}

-(void)postedTextPost
{
    NSLog(@"posted text post");
    self.sweetMessageView.text = @"";
    [self.apiBot loadDojo:self.dojoInfo];
    [self.sweetMessageView resignFirstResponder];
    [self.revoTableView setContentOffset:CGPointMake(0, -100) animated:YES];
    [self scrollViewDidEndDragging:self.revoTableView willDecelerate:NO];
    self.sweetMessageView.text = @"Tell us how it is...";
}

-(IBAction)customScrollToTop
{
    [self.revoTableView setContentOffset:CGPointMake(0, -100) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    frm = self.messageView.frame;
    frm.size.height = self.fieldContainer.frame.origin.y - self.messageView.frame.origin.y;
    self.messageView.frame = frm;
    
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
    
    frm = self.messageView.frame;
    frm.size.height = self.fieldContainer.frame.origin.y - self.messageView.frame.origin.y;
    self.messageView.frame = frm;
    
    NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
}

-(void)voteReported:(NSArray *)reportData
{
    [self reloadAfterVote];
}

-(void)reloadAfterVote
{
    [self viewDidAppear:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //scroll view did scroll bug
    //self.revoTableView.contentOffset = CGPointMake(0, 0);
    [self.messageView.bongReloader invalidate];
    //self.messageView.bongReloader = nil;
    [self.messageView endLoadSesh];
    
    for (int i=0; i< [self.revoTableView indexPathsForVisibleRows].count;i++)
    {
        DOJORevoCell *cell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:[[self.revoTableView indexPathsForVisibleRows] objectAtIndex:i]];
        //[cell.messageView endLoadSesh];
        @try {
            [cell.messageView endLoadSesh];
        }
        @catch (NSException *exception) {
            NSLog(@"the pharcacy is the enemy %@",exception);
        }
        @finally {
            NSLog(@"battle of a thousand years were won in a second");
        }
        @try {
            [cell.messageView.bongReloader invalidate];
        }
        @catch (NSException *exception) {
            NSLog(@"attempted to invalidate the bong reloader");
        }
        @finally {
            NSLog(@"swag swag");
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < 0)
    {
        self.isGoingUp = YES;
    }
    else
    {
        self.isGoingUp = NO;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollview asset is %f",scrollView.contentOffset.y);
    if (!self.chatOpenSomewhere)
    {
        if (self.cellWithMessageView == nil)
        {
            if (scrollView.tag == 101)
            {
                if ((scrollView.contentOffset.y < 26) && (scrollView.contentOffset.y > -190) )
                {
                    self.wasBrowsing = NO;
                    NSLog(@"END DRAGGIN reached far enough");
                    [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
                    [self.revoTableView setContentOffset:CGPointMake(0, -100) animated:YES];
                    [self.sweetMessageView resignFirstResponder];
                    [self setScrollDownIcon];
                    [UIView animateWithDuration:0.2 animations:^{
                        [self.customHeaderView setAlpha:1.0];
                        [self.sweetMessageView setAlpha:0];
                        [self.createPostButton setTitle:@"Pull to Text Post" forState:UIControlStateNormal];
                        [self setNeedsStatusBarAppearanceUpdate];
                    }];
                }
                else
                {
                    self.wasBrowsing = YES;
                    if (scrollView.contentOffset.y > -190)
                    {
                        [self setScrollUpIcon];
                        NSLog(@"hiding messageview");
                        [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
                        [self.sweetMessageView resignFirstResponder];
                        if (!self.isGoingUp)
                        {
                            [UIView animateWithDuration:0.2 animations:^{
                                [self.customHeaderView setAlpha:0];
                                [self.sweetMessageView setAlpha:0];
                                [self setNeedsStatusBarAppearanceUpdate];
                            }];
                        }
                        else
                        {
                            [UIView animateWithDuration:0.2 animations:^{
                                [self.customHeaderView setAlpha:1.0];
                                [self.sweetMessageView setAlpha:0];
                                [self setNeedsStatusBarAppearanceUpdate];
                            }];
                        }
                    }
                    else
                    {
                        [self setScrollDownIcon];
                        if (self.sweetMessageView.alpha)
                        {
                            NSLog(@"END DRAGGIN reached far enough");
                            [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
                            [self.revoTableView setContentOffset:CGPointMake(0, -100) animated:YES];
                            [self.sweetMessageView resignFirstResponder];
                            [UIView animateWithDuration:0.2 animations:^{
                                [self.customHeaderView setAlpha:1.0];
                                [self.sweetMessageView setAlpha:0];
                                [self.createPostButton setTitle:@"Pull to Text Post" forState:UIControlStateNormal];
                                [self setNeedsStatusBarAppearanceUpdate];
                            }];
                        }
                        else
                        {
                            NSLog(@"END DRAGGIN reached far enough");
                            [self.revoTableView setContentInset:UIEdgeInsetsMake(362, 0, 0, 0)];
                            [self.revoTableView setContentOffset:CGPointMake(0, -362) animated:YES];
                            [self.view bringSubviewToFront:self.sweetMessageView];
                            [UIView animateWithDuration:0.2 animations:^{
                                [self.customHeaderView setAlpha:0];
                                [self.sweetMessageView setAlpha:1.0];
                                [self.createPostButton setTitle:@"Tap to Post" forState:UIControlStateNormal];
                                [self setNeedsStatusBarAppearanceUpdate];
                            }];
                        }
                    }
                }
                /*
                if (scrollView.contentOffset.y < -190)
                {
                    NSLog(@"END DRAGGIN reached far enough");
                    [self.revoTableView setContentInset:UIEdgeInsetsMake(362, 0, 0, 0)];
                    [self.view addSubview:self.messageView];
                    [UIView animateWithDuration:0.2 animations:^{
                        [self.customHeaderView setAlpha:0];
                        [self.sweetMessageView setAlpha:1.0];
                        [self setNeedsStatusBarAppearanceUpdate];
                    }];
                }
                else
                {
                    NSLog(@"hiding messageview");
                    [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
                }
                 */
            }
        }
    }
}

-(BOOL)prefersStatusBarHidden
{
    BOOL thang = NO;
    if (self.customHeaderView.alpha == 0)
    {
        return YES;
    }
    return NO;
    /*
    if (!self.chatOpenSomewhere)
    {
        if (self.cellWithMessageView == nil)
        {
            if (self.revoTableView.contentOffset.y > 62)
            {
                thang = YES;
            }
            else
            {
                thang = NO;
            }
        }
    }
    if (self.isGoingUp)
    {
        thang = NO;
    }
    return thang;
     */
    /*
    if (self.revoTableView.contentOffset.y > 62 || self.chatOpenSomewhere || !self.isGoingUp)
    {
        return YES;
    }
    else
    {
        return NO;
    }
     */
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.chatOpenSomewhere)
    {
        [self.dojoHeader setText:[dojoInfo valueForKey:@"dojo"]];
        CGRect frm = segControl.frame;
        frm.origin.y = -38;
        segControl.frame = frm;
        self.startOffset = self.segControl.frame.origin;
        frm = segControl.frame;
        frm.origin.y = self.startOffset.y - self.revoTableView.contentOffset.y;
        segControl.frame = frm;
        NSLog(@"dojo is %@",dojoInfo);
        
        [self.notiBubble.layer setCornerRadius:5];
        [self.notiBubble setHidden:YES];
        
        /*
        if ([previousType isEqualToString:@"person"])
        {
            NSString *profilehash = [self.previousInfo objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                self.backTypeImageView.image = [UIImage imageNamed:@"iconwhite200.png"];
                self.backTypeImageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            else
            {
                
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [self.backTypeImageView setImage:image];
                }
                else
                {
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = @"dojopicbucket";
                    self.downloadRequest.key = profilehash;
                    self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        if (task.error != nil) {
                            NSLog(@"Error: [%@]", task.error);
                            @try {
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [self.backTypeImageView setImage:dlthumb];
                            }
                            @catch (NSException *exception) {
                                NSLog(@"could not load image exception executor %@",exception);
                            }
                            @finally {
                                NSLog(@"ran through try block executor");
                            }
                        } else {
                            NSLog(@"completed download");
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [self.backTypeImageView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            
            UIImage *_maskingImage = self.backButtonForMask.image;
            CALayer *_maskingLayer = [CALayer layer];
            _maskingLayer.frame = self.backTypeImageView.bounds;
            [_maskingLayer setContents:(id)[_maskingImage CGImage]];
            [self.backTypeImageView.layer setMask:_maskingLayer];
            
            self.backTypeImageView.layer.masksToBounds = YES;
        }
        
        if ([previousType isEqualToString:@"dojo"])
        {
            UIImage *newThang = [UIImage imageNamed:@"dojoarches.png"];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.backTypeImageView.frame.size.width, self.backTypeImageView.frame.size.height),NO,2.0);
            [newThang drawInRect:CGRectMake(10, 4, 25, 25)];
            //CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
            UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.backTypeImageView.image = resizedUnlock;
            
            self.backTypeImageView.backgroundColor = [UIColor colorWithRed:0.123 green:0.345 blue:0.92 alpha:0.6];
            
            //[self.backTypeImageView setTintColor:[UIColor colorWithRed:0.123 green:0.345 blue:0.89 alpha:0.3]];
            UIImage *_maskingImage = self.backButtonForMask.image;
            CALayer *_maskingLayer = [CALayer layer];
            _maskingLayer.frame = self.backTypeImageView.bounds;
            [_maskingLayer setContents:(id)[_maskingImage CGImage]];
            [self.backTypeImageView.layer setMask:_maskingLayer];
            
            self.backTypeImageView.layer.masksToBounds = YES;
        }
        
        if ([previousType isEqualToString:@"home"])
        {
            self.backTypeImageView.backgroundColor = [UIColor whiteColor];
            
            //[self.backTypeImageView setTintColor:[UIColor colorWithRed:0.123 green:0.345 blue:0.89 alpha:0.3]];
            UIImage *_maskingImage = self.backButtonForMask.image;
            CALayer *_maskingLayer = [CALayer layer];
            _maskingLayer.frame = self.backTypeImageView.bounds;
            [_maskingLayer setContents:(id)[_maskingImage CGImage]];
            [self.backTypeImageView.layer setMask:_maskingLayer];
            
            self.backTypeImageView.layer.masksToBounds = YES;
        }
         */
    }
}

-(void)loadedDojo:(NSArray *)dojoData
{
    NSLog(@"did load dojo data with %@",dojoData);
    postListNew = [dojoData objectAtIndex:1];
    postListTop = [dojoData objectAtIndex:2];
    postListRoster = [dojoData objectAtIndex:3];
    NSDictionary *creator = [dojoData objectAtIndex:4];
    NSArray *chatNotiSwag = [dojoData objectAtIndex:5];
    NSString *followSwag = [dojoData objectAtIndex:6];
    NSArray *hashArray = [dojoData objectAtIndex:7];
    
    
    UITextView *textymessyView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 235)];
    textymessyView.font = [UIFont fontWithName:@"Avenir-Light" size:19.0];
    textymessyView.textAlignment = NSTextAlignmentLeft;
    
    
    NSDictionary *post;
    self.heightNewArray = [[NSMutableArray alloc] init];
    self.heightTopArray = [[NSMutableArray alloc] init];
    for (int i=0;i<[postListNew count];i++)
    {
        NSLog(@"looping");
        post = [[postListNew objectAtIndex:i] objectAtIndex:0];
        if ([[post objectForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
        {
            //is text
            textymessyView.text = [post objectForKey:@"description"];
            CGSize sizeOfTheThing = [textymessyView sizeThatFits:CGSizeMake(textymessyView.frame.size.width, textymessyView.contentSize.height)];
            CGFloat puffer = ((160 - sizeOfTheThing.height) > 0 ?  220 : 220 + (sizeOfTheThing.height - 160));
            [self.heightNewArray addObject:[NSNumber numberWithFloat:puffer]];
        }
        else
        {
            [self.heightNewArray addObject:[NSNumber numberWithFloat:420.0f]];
        }
    }
    for (int i=0;i<[postListTop count];i++)
    {
        NSLog(@"pooping");
        post = [[postListTop objectAtIndex:i] objectAtIndex:0];
        if ([[post objectForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
        {
            //is text
            textymessyView.text = [post objectForKey:@"description"];
            CGSize sizeOfTheThing = [textymessyView sizeThatFits:CGSizeMake(textymessyView.frame.size.width, textymessyView.contentSize.height)];
            CGFloat puffer = ((160 - sizeOfTheThing.height) > 0 ?  220 : 220 + (sizeOfTheThing.height - 160));
            [self.heightTopArray addObject:[NSNumber numberWithFloat:puffer]];
        }
        else
        {
            [self.heightTopArray addObject:[NSNumber numberWithFloat:420.0f]];
        }
    }
    
    NSLog(@"HEIGHT NEW IS %@",self.heightNewArray);
        NSLog(@"HEIGHT TOP IS %@",self.heightTopArray);
    
    BOOL foundthat = NO;
    if (![self.selectedHashForDojo isEqualToString:@""])
    {
        for (int i=0;i<hashArray.count;i++)
        {
            if ([self.selectedHashForDojo isEqualToString:[hashArray objectAtIndex:i]])
            {
                self.rowToScrollTo = i;
                foundthat = YES;
                break;
            }
        }
    }
    
    self.postsCountLabel.text = [NSString stringWithFormat:@"%ld posts",[postListNew count]];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%ld followers",[postListRoster count]];
    
    if ([chatNotiSwag count] > 0)
    {
        if ([[[chatNotiSwag objectAtIndex:0] objectForKey:@"seen"] isEqualToString:@"no"])
        {
            [self.notiBubble setHidden:NO];
        }
        else
        {
            [self.notiBubble setHidden:YES];
        }
    }
    
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSLog(@"creator is %@",creator);
    if ([[creator objectForKey:@"username"] isEqualToString:[userInfo objectForKey:@"username"]])
    {
        NSLog(@"you are creator");
        self.youAreCreator = YES;
        UIImage *flashImage = [UIImage imageNamed:@"newsettings.png"];
        flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(62, 45),NO,0.0);
        [flashImage drawInRect:CGRectMake(10, 6, 35, 35)];
        UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.sortButton setImage:resizedFlash forState:UIControlStateNormal];
        //[self.sortButton setTintColor:[UIColor whiteColor]];
        [self.followLabel setHidden:YES];
    }
    else
    {
        self.youAreCreator = NO;
        UIImage *flashImage = [UIImage imageNamed:@"diamondlove.png"];
        flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 39),NO,0.0);
        [flashImage drawInRect:CGRectMake(0, 3, 28, 28)];
        UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.sortButton setImage:resizedFlash forState:UIControlStateNormal];
        //[self.sortButton setTintColor:[UIColor whiteColor]];
    }
    //[self.revoTableView reloadData];
    
    if (!self.youAreCreator)
    {
        if ([followSwag isEqualToString:@"following"])
        {
            NSLog(@"evaluated correctly");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sortButton setTintColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
                [self.followLabel setTextColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
                [self.followLabel setText:@"Following"];
            });
        }
    }
    
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        if (self.shouldOpenWithChat)
        {
            [self.segControl setSelectedSegmentIndex:2];
            [self rotateSortType:self.segControl];
            [self.revoTableView reloadData];
            self.shouldOpenWithChat = NO;
        }
        else
        {
            [self.revoTableView reloadData];
            if (foundthat)
            {
                [self.revoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.rowToScrollTo inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                self.selectedHashForDojo = @"";
                if (self.rowToScrollTo > 0)
                {
                    [self.customHeaderView setAlpha:0];
                    [self setNeedsStatusBarAppearanceUpdate];
                }
            }
        }
    //});
}

-(void)setScrollDownIcon
{
    if (self.youAreCreator)
    {
        NSLog(@"you are creator");
        UIImage *flashImage = [UIImage imageNamed:@"newsettings.png"];
        flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(62, 45),NO,0.0);
        [flashImage drawInRect:CGRectMake(10, 6, 35, 35)];
        UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.sortButton setImage:resizedFlash forState:UIControlStateNormal];
        //[self.sortButton setTintColor:[UIColor whiteColor]];
        [self.followLabel setHidden:YES];
    }
    else
    {
        UIImage *flashImage = [UIImage imageNamed:@"diamondlove.png"];
        flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 39),NO,0.0);
        [flashImage drawInRect:CGRectMake(0, 3, 28, 28)];
        UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.sortButton setImage:resizedFlash forState:UIControlStateNormal];
        //[self.sortButton setTintColor:[UIColor whiteColor]];
    }
    [self.sortButton setNeedsDisplay];
}

-(void)setScrollUpIcon
{
    NSLog(@"you are creator");
    UIImage *flashImage = [UIImage imageNamed:@"returnToTop.png"];
    flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(62, 45),NO,0.0);
    [flashImage drawInRect:CGRectMake(10, 10, 31, 20)];
    UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.sortButton setImage:resizedFlash forState:UIControlStateNormal];
    //[self.sortButton setTintColor:[UIColor whiteColor]];
    [self.followLabel setHidden:YES];
    [self.sortButton setNeedsDisplay];
}



-(void)viewDidAppear:(BOOL)animated
{
    self.createPostButton.backgroundColor = self.customHeaderView.backgroundColor;
    self.openCameraButton.backgroundColor = self.customHeaderView.backgroundColor;
    [self.createPostButton setTitleColor:self.customHeaderView.backgroundColor forState:UIControlStateNormal];
    
    UIImage *flashImage = [UIImage imageNamed:@"faltswagera.png"];
    //flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 22),NO,0.0);
    [flashImage drawInRect:CGRectMake(0, 0, 30, 22)];
    flashImage = UIGraphicsGetImageFromCurrentImageContext();
    [self.openCameraButton setImage:flashImage forState:UIControlStateNormal];
    [self.openCameraButton.imageView setTintColor:[UIColor whiteColor]];
    [self.openCameraButton setTintColor:[UIColor whiteColor]];
    UIGraphicsEndImageContext();
    [self.openCameraButton setNeedsDisplay];
    
    if (!self.chatOpenSomewhere)
    {
        messageView.dojoData = dojoInfo;
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
        
        //[self rotateSortType:self.segControl];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.segControl.selectedSegmentIndex == 0)
    {
        [self.apiBot loadDojo:dojoInfo];
    }
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
        if (self.chatOpenSomewhere && self.selectedSortType != 3)
        {
            [self.apiBot submitAComment:self.selectedPostForMessageView withText:self.messageField.text];
        }
        else
        {
            [self.apiBot submitMessage:dojoInfo withText:self.messageField.text];
        }
    }
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
        [self.messageView genericRefresh];
        [self.sendButton setBackgroundColor:[UIColor colorWithRed:155.0/255.0 green:250.0/255.0 blue:70.0/255.0 alpha:1.0]];
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

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    /*
    __block NSMutableArray *allMatches = [[NSMutableArray alloc] init];
    [NSDataDetector enumerateMatchesInString:textView.attributedText
                                   options:0
                                     range:NSMakeRange(0, [textView.attributedText length])
                                usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        if ([match resultType] == NSTextCheckingTypeLink)
            [allMatches addObject:[match URL]];
    }];
    */
    NSLog(@"got call to load that shit");
    [self.dsv3000 loadThisSiteFromURL:URL];
    [self.view bringSubviewToFront:self.dsv300Container];
    [UIView animateWithDuration:0.4 animations:^{
        self.dsv300Container.alpha = 1;
    }];
    return NO;
}

-(void)hideDSV3000
{
    [self.dsv3000.dsvWebView stopLoading];
    [UIView animateWithDuration:0.2 animations:^{
        self.dsv300Container.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.dsv300Container];
    }];
}


-(IBAction)showHideBrowser
{
    if (self.dsv300Container.alpha)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.dsv300Container.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view sendSubviewToBack:self.dsv300Container];
        }];
    }
    else
    {
        [self.view bringSubviewToFront:self.dsv300Container];
        [UIView animateWithDuration:0.2 animations:^{
            self.dsv300Container.alpha = 1;
        }];
    }
}

-(void)didLoadTheDSV3000
{
    NSLog(@"Time to show it now");
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    //NSLog(@"newLength is %u",newLength);
    BOOL returnKey = ([text rangeOfString: @"\n"].location == 0);
    if (returnKey)
    {
        [textView resignFirstResponder];
        return YES;
    }
    if (textView.tag == 1)
    {
        if (newLength > 279)
        {
            [self.createPostButton setTitle: @"Over Limit" forState:UIControlStateNormal];
        }
        else
        {
            if ((self.revoTableView.contentOffset.y < 26) && (self.revoTableView.contentOffset.y > -190) )
            {
                self.wasBrowsing = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    [self.createPostButton setTitle:@"Pull to Text Post" forState:UIControlStateNormal];
                }];
            }
            else
            {
                if (self.revoTableView.contentOffset.y > -190)
                {
                    
                }
                else
                {
                    if (self.sweetMessageView.alpha)
                    {
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.createPostButton setTitle:@"Pull to Text Post" forState:UIControlStateNormal];
                        }];
                    }
                    else
                    {
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.createPostButton setTitle:@"Tap to Post" forState:UIControlStateNormal];
                        }];
                    }
                }
            }
        }
    }
    
    return (newLength <= 279 || returnKey) || (newLength < oldLength);
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag == 0)
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
    else
    {
        
        if ([self.sweetMessageView.text isEqualToString:@"Tell us how it is..."])
        {
            self.sweetMessageView.text = @"";
        }
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag == 0)
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
}

-(void)scrollUp
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frm = self.fieldContainer.frame;
        frm.origin.y = 292;
        self.fieldContainer.frame = frm;
        [self.fieldContainer setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1.0]];
        
        frm = self.messageView.frame;
        frm.size.height = self.fieldContainer.frame.origin.y - self.messageView.frame.origin.y;
        self.messageView.frame = frm;
        
        frm = self.messageView.messageCollectionView.frame;
        frm.size.height =self.messageView.frame.size.height;
        self.messageView.messageCollectionView.frame = frm;
        
        CGPoint bottomOffset = CGPointMake(0, self.messageView.messageCollectionView.contentSize.height - self.messageView.messageCollectionView.bounds.size.height + 15);
        if (bottomOffset.y >= 0.0)
        {
            [self.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
        }
        
        if (self.chatOpenSomewhere)
        {
            DOJORevoCell *swagcell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:self.cellWithMessageView];
            
            frm = swagcell.messageView.messageCollectionView.frame;
            frm.size.height = 245;
            swagcell.messageView.messageCollectionView.frame = frm;
            
            bottomOffset = CGPointMake(0, swagcell.messageView.messageCollectionView.contentSize.height - swagcell.messageView.messageCollectionView.bounds.size.height);
            if (bottomOffset.y >= 0.0)
            {
                [swagcell.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
            }
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
        
        frm = self.messageView.frame;
        frm.size.height = self.fieldContainer.frame.origin.y - self.messageView.frame.origin.y;
        self.messageView.frame = frm;
        
        frm = self.messageView.messageCollectionView.frame;
        frm.size.height =self.messageView.frame.size.height;
        self.messageView.messageCollectionView.frame = frm;
        
        CGPoint bottomOffset = CGPointMake(0, self.messageView.messageCollectionView.contentSize.height - self.messageView.messageCollectionView.bounds.size.height + 15);
        if (bottomOffset.y >= 0.0)
        {
            [self.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
        }
        
        if (self.chatOpenSomewhere)
        {
            DOJORevoCell *swagcell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:self.cellWithMessageView];
            
            frm = swagcell.messageView.messageCollectionView.frame;
            frm.size.height = 430;
            swagcell.messageView.messageCollectionView.frame = frm;
            
            bottomOffset = CGPointMake(0, swagcell.messageView.messageCollectionView.contentSize.height -
                                       swagcell.messageView.messageCollectionView.bounds.size.height);
            if (bottomOffset.y >= 0.0)
            {
                [swagcell.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
            }
        }
    }];
}

-(IBAction)removeYoSelf:(id)sender
{
    [self.dsv3000.dsvWebView loadHTMLString:@"" baseURL:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)rotateSortType:(UISegmentedControl *)segmentControl
{
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
            // new
            self.selectedSortType = 0;
            [self.messageField resignFirstResponder];
            [self.messageView setHidden:YES];
            [self.fieldContainer setHidden:YES];
            [self.view sendSubviewToBack:self.fieldContainer];
            [self.revoTableView setScrollEnabled:YES];
            [self.revoTableView reloadData];
            break;
        case 1:
            // top
            self.selectedSortType = 1;
            [self.messageField resignFirstResponder];
            [self.fieldContainer setHidden:YES];
            [self.messageView setHidden:YES];
            [self.view sendSubviewToBack:self.fieldContainer];
            [self.revoTableView setScrollEnabled:YES];
            [self.revoTableView reloadData];
            break;
        case 2:
            // chat
            [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
            [self.revoTableView setScrollEnabled:NO];
            if (!self.isGoingUp)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    [self.sweetMessageView setAlpha:0];
                } completion:^(BOOL finished) {
                    self.selectedSortType = 2;
                    [self.messageField resignFirstResponder];
                    [self.messageView setHidden:NO];
                    [self.fieldContainer setHidden:NO];
                    [self.view bringSubviewToFront:self.fieldContainer];
                    [self.notiBubble setHidden:YES];
                    [self.messageView initiateTheBongReloader];
                }];
            }
            else
            {
                [UIView animateWithDuration:0.2 animations:^{
                    [self.customHeaderView setAlpha:1.0];
                    [self.sweetMessageView setAlpha:0];
                    [self setNeedsStatusBarAppearanceUpdate];
                } completion:^(BOOL finished) {
                    self.selectedSortType = 2;
                    [self.messageField resignFirstResponder];
                    [self.messageView setHidden:NO];
                    [self.fieldContainer setHidden:NO];
                    [self.view bringSubviewToFront:self.fieldContainer];
                    [self.notiBubble setHidden:YES];
                    [self.messageView initiateTheBongReloader];
                }];
            }
            break;
        case 3:
            // roster
            self.selectedSortType = 3;
            [self.messageField resignFirstResponder];
            [self.fieldContainer setHidden:YES];
            [self.messageView setHidden:YES];
            [self.view sendSubviewToBack:self.fieldContainer];
            [self.revoTableView setScrollEnabled:YES];
            [self.revoTableView reloadData];
            break;
            
        default:
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectedSortType == 0)
    {
        return [postListNew count];
    }
    if (self.selectedSortType == 1)
    {
        return  [postListTop count];
    }
    if (self.selectedSortType == 3)
    {
        return [postListRoster count];
    }
    else
    {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedSortType != 3)
    {
        if (self.selectedSortType ==0)
        {
            return  [[self.heightNewArray objectAtIndex:indexPath.row] floatValue];
        }
        else
        {
            return  [[self.heightTopArray objectAtIndex:indexPath.row] floatValue];
        }
    }
    else
    {
        return 50;
    }
    return 420;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedSortType != 3)
    {
        DOJORevoCell *postCell = (DOJORevoCell *)[tableView dequeueReusableCellWithIdentifier:@"revoCell" forIndexPath:indexPath];
        postCell.cellPath = indexPath;
        postCell.indexPath = indexPath;
        postCell.delegate = self;
        
        postCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [postCell.moviePlayer.view removeFromSuperview];
        postCell.moviePlayer = nil;
        
        postCell.upvoteButton.tag = indexPath.row;
        postCell.downvoteButton.tag = indexPath.row;
        postCell.shareButton.tag = indexPath.row;
        postCell.deleteButton.tag = indexPath.row;
        
        
        [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, 0, 100)];
        
        NSDictionary *post;
        if (self.selectedSortType == 0)
        {
            post = [[postListNew objectAtIndex:indexPath.row] objectAtIndex:0];
            if ([[[postListNew objectAtIndex:indexPath.row] objectAtIndex:4] count])
            {
                NSString *voteString = [[[[postListNew objectAtIndex:indexPath.row] objectAtIndex:4] objectAtIndex:0] objectForKey:@"vote"];
                NSLog(@"vote array is %@",[[postListNew objectAtIndex:indexPath.row] objectAtIndex:4]);
                if ([voteString isEqualToString:@"1"])
                {
                    [postCell.upvoteButton setAlpha:0.5];
                    [postCell.upvoteBackground setAlpha:0.5];
                    [postCell.downvoteButton setAlpha:1.0];
                    [postCell.downvoteBackground setAlpha:1.0];
                    
                    [postCell.upthumb setAlpha:1.0];
                    [postCell.downthumb setAlpha:0.5];
                    
                    [postCell.upthumb setImage:[UIImage imageNamed:@"uptriangle.png"]];
                    [postCell.downthumb setImage:[UIImage imageNamed:@"downtrianglegrey.png"]];
                }
                else
                {
                    [postCell.upvoteButton setAlpha:1.0];
                    [postCell.upvoteBackground setAlpha:1.0];
                    [postCell.downvoteBackground setAlpha:0.5];
                    [postCell.downvoteButton setAlpha:0.5];
                    
                    [postCell.upthumb setAlpha:0.5];
                    [postCell.downthumb setAlpha:1.0];
                    
                    [postCell.upthumb setImage:[UIImage imageNamed:@"uptrianglegrey.png"]];
                    [postCell.downthumb setImage:[UIImage imageNamed:@"downtriangle.png"]];
                }
            }
            else
            {
                [postCell.upvoteButton setAlpha:1.0];
                [postCell.upvoteBackground setAlpha:1.0];
                [postCell.downvoteBackground setAlpha:1.0];
                [postCell.downvoteButton setAlpha:1.0];
                
                [postCell.upthumb setAlpha:0.5];
                [postCell.downthumb setAlpha:0.5];
                
                [postCell.upthumb setImage:[UIImage imageNamed:@"uptrianglegrey.png"]];
                [postCell.downthumb setImage:[UIImage imageNamed:@"downtrianglegrey.png"]];
            }
            
            [postCell.commentestIcon setHidden:YES];
            if ([[[postListNew objectAtIndex:indexPath.row] objectAtIndex:5] count] > 0)
            {
                if ([[[[[postListNew objectAtIndex:indexPath.row] objectAtIndex:5] objectAtIndex:0] objectForKey:@"seen"] isEqualToString:@"no"])
                {
                    [postCell.commentestIcon setHidden:NO];
                    [postCell.commentestIcon.layer setCornerRadius:postCell.commentestIcon.frame.size.height/2];
                }
            }
            [postCell.numberOfCommentsLabel setText:[NSString stringWithFormat:@"%@",[[postListNew objectAtIndex:indexPath.row] objectAtIndex:6]]];
            [postCell.timestamp setText:[NSString stringWithFormat:@"%@",[[postListNew objectAtIndex:indexPath.row] objectAtIndex:7]]];
            [postCell.repostCount setText:[NSString stringWithFormat:@"%@",[[postListNew objectAtIndex:indexPath.row] objectAtIndex:8]]];
        }
        if (self.selectedSortType == 1)
        {
            post = [[postListTop objectAtIndex:indexPath.row] objectAtIndex:0];
            if ([[[postListTop objectAtIndex:indexPath.row] objectAtIndex:4] count])
            {
                NSString *voteString = [[[[postListTop objectAtIndex:indexPath.row] objectAtIndex:4] objectAtIndex:0] objectForKey:@"vote"];
                NSLog(@"vote array is %@",[[postListTop objectAtIndex:indexPath.row] objectAtIndex:4]);
                if ([voteString isEqualToString:@"1"])
                {
                    [postCell.upvoteButton setAlpha:0.5];
                    [postCell.upvoteBackground setAlpha:0.5];
                    [postCell.downvoteButton setAlpha:1.0];
                    [postCell.downvoteBackground setAlpha:1.0];
                    
                    [postCell.upthumb setAlpha:1.0];
                    [postCell.downthumb setAlpha:0.5];
                    
                    [postCell.upthumb setImage:[UIImage imageNamed:@"uptriangle.png"]];
                    [postCell.downthumb setImage:[UIImage imageNamed:@"downtrianglegrey.png"]];
                }
                else
                {
                    [postCell.upvoteButton setAlpha:1.0];
                    [postCell.upvoteBackground setAlpha:1.0];
                    [postCell.downvoteBackground setAlpha:0.5];
                    [postCell.downvoteButton setAlpha:0.5];
                    
                    [postCell.upthumb setAlpha:0.5];
                    [postCell.downthumb setAlpha:1.0];
                    
                    [postCell.upthumb setImage:[UIImage imageNamed:@"thumbsforrealgrey.png"]];
                    [postCell.downthumb setImage:[UIImage imageNamed:@"downtriangle.png"]];
                }
            }
            else
            {
                [postCell.upvoteButton setAlpha:1.0];
                [postCell.upvoteBackground setAlpha:1.0];
                [postCell.downvoteBackground setAlpha:1.0];
                [postCell.downvoteButton setAlpha:1.0];
                
                [postCell.upthumb setAlpha:0.5];
                [postCell.downthumb setAlpha:0.5];
                
                [postCell.upthumb setImage:[UIImage imageNamed:@"uptrianglegrey.png"]];
                [postCell.downthumb setImage:[UIImage imageNamed:@"downtrianglegrey.png"]];
            }
            
            [postCell.commentestIcon setHidden:YES];
            if ([[[postListTop objectAtIndex:indexPath.row] objectAtIndex:5] count] > 0)
            {
                if ([[[[[postListTop objectAtIndex:indexPath.row] objectAtIndex:5] objectAtIndex:0] objectForKey:@"seen"] isEqualToString:@"no"])
                {
                    [postCell.commentestIcon setHidden:NO];
                    [postCell.commentestIcon.layer setCornerRadius:postCell.commentestIcon.frame.size.height/2];
                }
            }
            [postCell.numberOfCommentsLabel setText:[NSString stringWithFormat:@"%@",[[postListTop objectAtIndex:indexPath.row] objectAtIndex:6]]];
            [postCell.timestamp setText:[NSString stringWithFormat:@"%@",[[postListTop objectAtIndex:indexPath.row] objectAtIndex:7]]];
            [postCell.repostCount setText:[NSString stringWithFormat:@"%@",[[postListTop objectAtIndex:indexPath.row] objectAtIndex:8]]];
        }
        
        if ([[post objectForKey:@"username"] isEqualToString:[self.userProperties objectForKey:@"username"]] || self.youAreCreator)
        {
            [postCell.deleteButton setHidden:NO];
            [postCell.deleteIcon setHidden:NO];
        }
        else
        {
            [postCell.deleteButton setHidden:YES];
            [postCell.deleteIcon setHidden:YES];
        }
        
        /*
        [postCell.upvoteButton.layer setCornerRadius:5.0];
        [postCell.downvoteButton.layer setCornerRadius:5.0];
        [postCell.upvoteBackground.layer setCornerRadius:6.0];
        [postCell.downvoteBackground.layer setCornerRadius:6.0];
        
        [postCell.commentBackground.layer setCornerRadius:6.0];
        [postCell.commentButton.layer setCornerRadius:5.0];
        [postCell.shareBackground.layer setCornerRadius:6.0];
        [postCell.shareButton.layer setCornerRadius:5.0];
        */
        /*
        if (indexPath == self.cellWithMessageView)
        {
            postCell.messageView = [[DojoPageMessageView alloc] initWithFrame:CGRectMake(0, 47, 320, 430)];
            postCell.messageView.isAPost = YES;
            [postCell.messageView setHidden:NO];
            [self cellSelected];
            self.selectedPostForMessageView = post;
            postCell.messageView.postDict = post;
            postCell.isRunningActiveMessageView = YES;
            if (!postCell.containsActiveMessageView)
            {
                [postCell.contentView addSubview:postCell.messageView];
            }
            postCell.messageView.delegate = self;
            @try {
                //[self becomeFirstResponder];
                [postCell.messageView customReloadTheBoard];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through reload cell message view instantiate");
            }
            
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = 486;
            frm.origin.x = 135;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.x = 0;
            frm.origin.y = 477;
            frm.size.width = 320;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.x = 130;
            frm.origin.y = 483;
            frm.size.width = 120;
            postCell.numberOfCommentsLabel.frame = frm;
            postCell.numberOfCommentsLabel.text = @"close";
        }
        else
        {
            //NSLog(@"not active");
            //cell.messageView = nil;
            [postCell.messageView setHidden:YES];
            postCell.isRunningActiveMessageView = NO;
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = 383;
            frm.origin.x = 164;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.x = 150;
            frm.origin.y = 379;
            frm.size.width = 70;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.x = 191;
            frm.origin.y = 386;
            frm.size.width = 21;
            postCell.numberOfCommentsLabel.frame = frm;
        }
        */
        
        NSNumber *upvoteNumber;
        NSNumber *downvoteNumber;
        if (self.selectedSortType == 0)
        {
            NSNumberFormatter *numformattere = [[NSNumberFormatter alloc] init];
            upvoteNumber = [[self.postListNew objectAtIndex:indexPath.row] objectAtIndex:2];
            downvoteNumber = [[self.postListNew objectAtIndex:indexPath.row] objectAtIndex:3];
        }
        else
        {
            upvoteNumber = [[self.postListTop objectAtIndex:indexPath.row] objectAtIndex:2];
            downvoteNumber = [[self.postListTop objectAtIndex:indexPath.row] objectAtIndex:3];
        }
        
        postCell.upvoteCount.text = [NSString stringWithFormat:@"%@",upvoteNumber];
        if ((upvoteNumber.floatValue+downvoteNumber.floatValue) == 0)
        {
            postCell.downvoteCount.text = @"0%";
        }
        else
        {
            postCell.downvoteCount.text = [NSString stringWithFormat:@"%0.0f%%",((float)upvoteNumber.floatValue/(float)(upvoteNumber.floatValue+downvoteNumber.floatValue))*100];
        }
        
        BOOL isTextPost = NO;
        postCell.textpostview.attributedText = nil;
        [postCell.textpostview setText:@""];
        if ([[post valueForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
        {
            postCell.textpostview.dataDetectorTypes = UIDataDetectorTypeNone;
            
            [postCell.textpostview setEditable:YES];
            postCell.textpostview.text = [NSString stringWithFormat:@"%@",[post valueForKey:@"description"]];
            [postCell.contentView bringSubviewToFront:postCell.textpostview];
            CGSize newsize = [postCell.textpostview sizeThatFits:CGSizeMake(294, postCell.textpostview.contentSize.height)];
            CGRect frame = CGRectMake(13, 48, 294, newsize.height);
            postCell.textpostview.frame = frame;
            isTextPost = YES;
            [postCell.textpostview setEditable:NO];
            postCell.textpostview.dataDetectorTypes = UIDataDetectorTypeLink;
            //dispatch_async(self.convolvequeue, ^{
              /*  float blurRadius = 1.0f;
                int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                CGImageRef rawImage = postCell.profilePicture.image.CGImage;
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
                CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(postCell.imagePostView.image.CGImage));
                CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                //clean up
                CGContextRelease(ctx);
                CGColorSpaceRelease(colorSpace);
                free(pixelBuffer);
                CFRelease(inBitmapData);
                CGImageRelease(imageRef);
                */
                postCell.imagePostView.image = nil;
            //});
            [postCell.textpostview setHidden:NO];
            [postCell.postDescription setAlpha:0];
        }
        else
        {
            [postCell.postDescription setAlpha:1.0];
            [postCell.textpostview setHidden:YES];
            NSString *picNameCache = [NSString stringWithFormat:@"%@-high.jpeg",[post valueForKey:@"posthash"]];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            NSLog(@"clip location %lu",(unsigned long)[[post valueForKey:@"posthash"] rangeOfString:@"clip"].location);
            UIImage *image = [[UIImage alloc] init];
            [postCell.playButton setTitle:@"" forState:UIControlStateNormal];
            if ([fileManager fileExistsAtPath:picPath])
            {
                [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
                //load this instead
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [postCell.imagePostView setImage:image];
                if ([[post valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
                {
                    UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(postCell.frame.size.width, 250),NO,0.0);
                    [unlocked drawInRect:CGRectMake((postCell.frame.size.width/2)-17, 125, 35, 35)];
                    CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                    UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [postCell.playButton setImage:resizedUnlock forState:UIControlStateNormal];
                }
                else
                {
                    [postCell.playButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                }
            }
            else
            {
                [postCell.imagePostView setImage:[UIImage imageNamed:@"invisible.png"]];
                [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
                if ([[post valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
                {
                    [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[post valueForKey:@"posthash"]];
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
                                [postCell.imagePostView setImage:dlthumb];
                            }
                            @catch (NSException *exception) {
                                NSLog(@"exception executor %@",exception);
                            }
                            @finally {
                                NSLog(@"ran through try block executor");
                            }
                        } else {
                            NSLog(@"completed download");
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.imagePostView setImage:dlthumb];
                        }
                        return nil;
                    }];
                    UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(postCell.frame.size.width, 250),NO,0.0);
                    [unlocked drawInRect:CGRectMake((postCell.frame.size.width/2)-17, 125, 35, 35)];
                    CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                    UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [postCell.playButton setImage:resizedUnlock forState:UIControlStateNormal];
                }
                else
                {
                    
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = @"dojopicbucket";
                    self.downloadRequest.key = [NSString stringWithFormat:@"%@-high",[post valueForKey:@"posthash"]];
                    self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        if (task.error != nil) {
                            NSLog(@"Error: [%@]", task.error);
                            @try {
                                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                                self.downloadRequest.bucket = @"dojopicbucket";
                                self.downloadRequest.key = [post valueForKey:@"posthash"];
                                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                                
                                [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                                    if (task.error != nil) {
                                        NSLog(@"Error: [%@]", task.error);
                                        @try {
                                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                            [postCell.imagePostView setImage:dlthumb];
                                        }
                                        @catch (NSException *exception) {
                                            NSLog(@"exception executor %@",exception);
                                        }
                                        @finally {
                                            NSLog(@"ran through try block executor");
                                        }
                                    } else {
                                        NSLog(@"completed download");
                                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                        [postCell.imagePostView setImage:dlthumb];
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
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.imagePostView setImage:dlthumb];
                        }
                        return nil;
                    }];
                    [postCell.playButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                }
            }
        }
        if (isTextPost)
        {
            [postCell.imagePostView setHidden:YES];
            [postCell.playButton setHidden:YES];
        }
        else
        {
            [postCell.imagePostView setHidden:NO];
            [postCell.playButton setHidden:NO];
        }
        
        //if (isTextPost)
       // {
            
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.y = postCell.frame.size.height - 31;
            postCell.numberOfCommentsLabel.frame = frm;
            frm = postCell.upvoteButton.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.upvoteButton.frame = frm;
            frm = postCell.upvoteCount.frame;
            frm.origin.y = postCell.frame.size.height - 31;
            postCell.upvoteCount.frame = frm;
            frm = postCell.upthumb.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.upthumb.frame = frm;
            
            frm = postCell.downvoteButton.frame;
            frm.origin.y = postCell.frame.size.height - 40;
            postCell.downvoteButton.frame = frm;
            frm = postCell.downthumb.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.downthumb.frame = frm;
            
            frm = postCell.repostCount.frame;
            frm.origin.y = postCell.frame.size.height - 21;
            postCell.repostCount.frame = frm;
            frm = postCell.shareBackground.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.shareBackground.frame = frm;
            frm = postCell.shareButton.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.shareButton.frame = frm;
            
            frm = postCell.upvoteBackground.frame;
            frm.origin.y = postCell.frame.size.height - 3;
            postCell.upvoteBackground.frame = frm;
            
            frm = postCell.commentestIcon.frame;
            frm.origin.y = postCell.frame.size.height - 35;
            postCell.commentestIcon.frame = frm;
        
            frm = postCell.repostCount.frame;
            frm.origin.y = postCell.frame.size.height - 31;
            postCell.repostCount.frame = frm;
        
            //[postCell.playButton setHidden:YES];
       /* }
        else
        {
            //NSLog(@"not active");
            //cell.messageView = nil;
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = 386;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.y = 383;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.y = 389;
            postCell.numberOfCommentsLabel.frame = frm;
            
            frm = postCell.upvoteButton.frame;
            frm.origin.y = 383;
            postCell.upvoteButton.frame = frm;
            frm = postCell.upvoteCount.frame;
            frm.origin.y = 389;
            postCell.upvoteCount.frame = frm;
            frm = postCell.upthumb.frame;
            frm.origin.y = 386;
            postCell.upthumb.frame = frm;
            
            frm = postCell.downvoteButton.frame;
            frm.origin.y = 383;
            postCell.downvoteButton.frame = frm;
            frm = postCell.downthumb.frame;
            frm.origin.y = 386;
            postCell.downthumb.frame = frm;
            
            frm = postCell.repostCount.frame;
            frm.origin.y = 389;
            postCell.repostCount.frame = frm;
            frm = postCell.shareBackground.frame;
            frm.origin.y = 386;
            postCell.shareBackground.frame = frm;
            frm = postCell.shareButton.frame;
            frm.origin.y = 383;
            postCell.shareButton.frame = frm;
            
            frm = postCell.upvoteBackground.frame;
            frm.origin.y = 417;
            postCell.upvoteBackground.frame = frm;
            [postCell.playButton setHidden:NO];
            
            frm = postCell.commentestIcon.frame;
            frm.origin.y = 383;
            postCell.commentestIcon.frame = frm;
        }
        */
        if ([[post valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
        {
            NSLog(@"pulling image for row %ld", (long)indexPath.row);
            NSLog(@"codekey is %@",[post valueForKey:@"posthash"]);
            UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(postCell.frame.size.width, 250),NO,0.0);
            [unlocked drawInRect:CGRectMake((postCell.frame.size.width/2)-17, 125, 35, 35)];
            CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
            UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [postCell.playButton setImage:resizedUnlock forState:UIControlStateNormal];
            //[postCell.cellFace setImage:nil];
            /*
             if ([[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
             {
             UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
             UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
             [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
             CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
             UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             [postCell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
             if ([[postCell.cellButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] == 0)
             {
             //[postCell.cellButton removeTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             [postCell.cellButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             }
             }
             */
        }
        
        [postCell.imagePostView setFrame:CGRectMake(0, 47, 320, 332)];
        
        /*
        if (indexPath == self.cellWithMessageView)
        {
            if ([postCell.textpostview isHidden])
            {
                    NSLog(@"must blur");
                    float blurRadius = 1.0f;
                    int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                    CGImageRef rawImage = postCell.imagePostView.image.CGImage;
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
                    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(postCell.imagePostView.image.CGImage));
                    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                    NSData *blurredImage = UIImageJPEGRepresentation(returnImage, 0.6);
                    //clean up
                    CGContextRelease(ctx);
                    CGColorSpaceRelease(colorSpace);
                    free(pixelBuffer);
                    CFRelease(inBitmapData);
                    CGImageRelease(imageRef);
                    
                    [postCell.messageView.backgroundImageView setImage:returnImage];
                
               // [postCell.messageView.backgroundImageView setImage:returnImage];
                postCell.messageView.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
                
                postCell.messageView.messageCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
                postCell.messageView.messageCollectionView.backgroundView.alpha = 0;
            }
            else
            {
                [postCell.contentView bringSubviewToFront:postCell.messageView];
                postCell.messageView.messageCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                postCell.messageView.messageCollectionView.backgroundView.alpha = 0;
            }
        }
         */
        
        NSDictionary *posterInfo;
        if (self.selectedSortType == 0)
        {
            posterInfo = [[[postListNew objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:0];
        }
        if (self.selectedSortType == 1)
        {
            posterInfo = [[[postListTop objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:0];
        }
        
        if ([[post valueForKey:@"description"] isEqualToString:@""])
        {
            //[postCell.postDescription setHighlighted:YES];
            [postCell.postDescription setHidden:YES];
        }
        else
        {
            //[postCell.postDescription setHighlighted:NO];
            [postCell.postDescription setHidden:NO];
            postCell.postDescription.text = [NSString stringWithFormat:@"%@",[post valueForKey:@"description"]];
        }
        
        postCell.nameLabel.text = [posterInfo objectForKey:@"fullname"];
        NSString *profilehash = [posterInfo objectForKey:@"profilehash"];
        [postCell.profilePicture.layer setCornerRadius:postCell.profilePicture.frame.size.height/2];
        [postCell.profilePicture.layer setMasksToBounds:YES];
        if ([profilehash isEqualToString:@""])
        {
            postCell.profilePicture.image = [UIImage imageNamed:@"iconwhite200.png"];
            postCell.profilePicture.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {

            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            UIImage *image = [[UIImage alloc] init];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [postCell.profilePicture setImage:image];
            }
            else
            {
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = profilehash;
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.profilePicture setImage:dlthumb];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"could not load image exception executor %@",exception);
                        }
                        @finally {
                            NSLog(@"ran through try block executor");
                        }
                    } else {
                        NSLog(@"completed download");
                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                        [postCell.profilePicture setImage:dlthumb];
                        if (isTextPost)
                        {
                            float blurRadius = 1.0f;
                            int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
                            CGImageRef rawImage = postCell.profilePicture.image.CGImage;
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
                            CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(postCell.profilePicture.image.CGImage));
                            CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
                            UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
                            //clean up
                            postCell.imagePostView.image = returnImage;
                            CGContextRelease(ctx);
                            CGColorSpaceRelease(colorSpace);
                            free(pixelBuffer);
                            CFRelease(inBitmapData);
                            CGImageRelease(imageRef);
                        }
                    }
                    return nil;
                }];
            }
        }
        
        postCell.rotateval = 0;
        //if ([postCell.colorRotater isEqual:nil])
        //{
        // postCell.colorRotater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotateWithCell) userInfo:postCell repeats:YES];
        //}
        postCell.playButton.tag = indexPath.row;
        [postCell.playButton addTarget:self action:@selector(magnifyCell:) forControlEvents:UIControlEventTouchUpInside];
        
        return postCell;
    }
    else
    {
        DOJOPersonCell *personCell = (DOJOPersonCell *)[tableView dequeueReusableCellWithIdentifier:@"personCell" forIndexPath:indexPath];
        NSDictionary *posterInfo = [[postListRoster objectAtIndex:indexPath.row] objectAtIndex:0];
        
        personCell.pointsLabel.text = [NSString stringWithFormat:@"%@ points",[[postListRoster objectAtIndex:indexPath.row] objectAtIndex:1]];
        
        personCell.nameLabel.text = [posterInfo objectForKey:@"fullname"];
        NSString *profilehash = [posterInfo objectForKey:@"profilehash"];
        [personCell.profileView.layer setCornerRadius:personCell.profileView.frame.size.height/2];
        [personCell.profileView.layer setMasksToBounds:YES];
        if ([profilehash isEqualToString:@""])
        {
            personCell.profileView.image = [UIImage imageNamed:@"iconwhite200.png"];
            personCell.profileView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {
            
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            UIImage *image = [[UIImage alloc] init];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [personCell.profileView setImage:image];
            }
            else
            {
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = profilehash;
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [personCell.profileView setImage:dlthumb];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"could not load image exception executor %@",exception);
                        }
                        @finally {
                            NSLog(@"ran through try block executor");
                        }
                    } else {
                        NSLog(@"completed download");
                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                        [personCell.profileView setImage:dlthumb];
                    }
                    return nil;
                }];
            }
        }
        return personCell;
    }
}

-(void)magnifyCell:(UIButton *)button
{
    NSLog(@"magnify the cell for button %ld",(long)button.tag);
    //DOJORevoCell *tempCell;
    
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:iPath];
/*
    if ([[self.revoTableView visibleCells] count] == 0)
    {
        tempCell = [[self.revoTableView visibleCells] objectAtIndex:0];
    }
 */
    
    NSDictionary *post;
    if (self.selectedSortType == 0)
    {
        post = [[postListNew objectAtIndex:postCell.indexPath.row] objectAtIndex:0];
    }
    if (self.selectedSortType == 1)
    {
        post = [[postListTop objectAtIndex:postCell.indexPath.row] objectAtIndex:0];
    }
    NSLog(@"pulling image for row %ld, the post is \n%@", (long)postCell.indexPath.row, post);
    if ([[post valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
    {
        if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
        {
            [postCell.moviePlayer pause];
            [postCell.playButton setTitle:@"paused" forState:UIControlStateNormal];
            [postCell.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
        {
            [postCell.moviePlayer play];
            [postCell.playButton setTitle:@"" forState:UIControlStateNormal];
        }
        else
        {
            
            NSLog(@"codekey is %@",[post valueForKey:@"posthash"]);
            //[postCell.cellFace setImage:nil];
            NSString *picNameCache = [NSString stringWithFormat:@"downloaded.mov"];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:picPath error:nil];
            }
            [postCell.playButton setTitle:@"loading" forState:UIControlStateNormal];
            [postCell.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [postCell.playButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            /*if ([[postCell.cellButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] != 0)
             {
             [postCell.cellButton removeTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             //[postCell.cellButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             }*/
            
            self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
            self.downloadRequest.bucket = @"dojopicbucket";
            self.downloadRequest.key = [post valueForKey:@"posthash"];
            self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
            NSLog(@"about to download a movie pirate bryan");
            __weak DOJORevoViewController *weakSelf = self;
            self.pathOfDownloadingCell = postCell.indexPath;
            self.downloadRequest.downloadProgress =  ^(int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update progress.
                    DOJORevoViewController *strongSelf = weakSelf;
                    [strongSelf updateProgessOfDownload:bytesReceived totalBytesReceived:totalBytesReceived totalBytesExpectedToReceive:totalBytesExpectedToReceive];
                });};
            __weak DOJORevoCell *postCellWeak = postCell;
            [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                } else {
                    
                    if ([[self.revoTableView indexPathsForVisibleRows] containsObject:postCellWeak.indexPath])
                    {
                        NSLog(@"completed download");
                        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[temporaryDirectory stringByAppendingPathComponent:@"downloaded.mov"]];
                        [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, 0, 100)];
                        postCell.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:selectedPath];
                        [postCell.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
                        [postCell.moviePlayer.view setContentMode:UIViewContentModeScaleAspectFill];
                        [postCell.moviePlayer prepareToPlay];
                        postCell.moviePlayer.controlStyle = MPMovieControlStyleNone;
                        [postCell.moviePlayer.view setFrame:CGRectMake(0, postCell.imagePostView.frame.origin.y, 320, postCell.imagePostView.frame.size.height)];
                        //[self.view sen:moviePlayer.view];
                        //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                        [postCell.contentView addSubview:postCell.moviePlayer.view];
                        [postCell.contentView bringSubviewToFront:postCell.playButton];
                        [postCell.moviePlayer play];
                        [postCell.playButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
                return nil;
            }];
        }
    }
    else
    {
        /*self.selectedPostInfo = post;
        self.selectedImage = postCell.imagePostView.image;
        [self.storyboard instantiateViewControllerWithIdentifier:@"deepVC"];
        [self performSegueWithIdentifier:@"toDeepPost" sender:self];*/
        
        self.magnifiedView.magnifiedImage.image = postCell.imagePostView.image;
        self.magnifiedView.magnifiedImage.contentMode = UIViewContentModeScaleAspectFit;
        self.magnifiedView.delegate = self;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view bringSubviewToFront:self.magnifiedView];
            [self.magnifiedView setAlpha:1];
        }];
    }
}

-(void)tapDetected
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.view sendSubviewToBack:self.magnifiedView];
        [self.magnifiedView setAlpha:0];
    }];
}

-(void)updateProgessOfDownload:(int64_t)bytesReceived totalBytesReceived:(int64_t)totalBytesReceived totalBytesExpectedToReceive:(int64_t) totalBytesExpectedToReceieve
{
    NSLog(@"bytes received %ld, totalByes received %ld, totalBytesExpected to receive %ld",(long)bytesReceived,(long)totalBytesReceived,(long)totalBytesExpectedToReceieve);
    @try {
        double newWidth = floor(320.0*((float)totalBytesReceived/(float)totalBytesExpectedToReceieve));
        NSLog(@"newHeight is %f",newWidth);
        DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:self.pathOfDownloadingCell];
       [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, newWidth, 100)];
        postCell.postDescriptionBack.backgroundColor = [UIColor colorWithHue:(fmodf(newWidth/3.2,100))/100 saturation:0.8 brightness:1 alpha:1];
    }
    @catch (NSException *exception) {
        NSLog(@"AWS DOWNLOADER PROGRESS EXCEPTION exception was %@",exception);
    }
    @finally {
        NSLog(@"ran through anim block");
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 101)
    {
        CGRect frm = segControl.frame;
        frm.origin.y = self.startOffset.y - scrollView.contentOffset.y;
        segControl.frame = frm;
        frm = notiBubble.frame;
        frm.origin.y = self.startOffset.y - scrollView.contentOffset.y + 8;
        notiBubble.frame = frm;
        
        frm = self.createPostButton.frame;
        frm.origin.y = - scrollView.contentOffset.y - 110;
        self.createPostButton.frame = frm;
        
        frm = self.openCameraButton.frame;
        frm.origin.y = - scrollView.contentOffset.y - 110;
        self.openCameraButton.frame = frm;
        
        [self.createPostButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:((frm.origin.y)/90.0)] forState:UIControlStateNormal];
        self.createPostButton.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:((frm.origin.y)/90.0)];
        
        [self.openCameraButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:((frm.origin.y)/90.0)] forState:UIControlStateNormal];
        self.openCameraButton.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:((frm.origin.y)/90.0)];
        
        if (scrollView.contentOffset.y < 26)
        if (self.wasBrowsing)
        {
            self.wasBrowsing = NO;
            [self setScrollDownIcon];
        }
    }
    /*
    if (!self.chatOpenSomewhere)
    {
        if (self.cellWithMessageView == nil)
        {
            if (scrollView.tag == 101)
            {
                if (scrollView.contentOffset.y > 42)
                {
                    self.customHeaderView.alpha = 0;
                    [self setNeedsStatusBarAppearanceUpdate];
                }
                else
                {
                    if (scrollView.contentOffset.y < -30)
                    {
                        self.customHeaderView.alpha = 0;
                        [self setNeedsStatusBarAppearanceUpdate];
                        return;
                    }
                    else
                    {
                        self.customHeaderView.alpha = 1;
                        [self setNeedsStatusBarAppearanceUpdate];
                    }
                }
            }
        }
    }

    if (self.isGoingUp)
    {
        self.customHeaderView.alpha = 1;
        [self setNeedsStatusBarAppearanceUpdate];
    }
               */
}

-(void)colorRotateWithCell
{
    //NSLog(@"rotate");
    DOJORevoCell *cell;
    for (cell in [self.revoTableView visibleCells])
    {
        float originalval = cell.rotateval;
        originalval = (originalval + 1);
        originalval = fmodf(originalval, 100);
        [cell.imagePostView setBackgroundColor:[UIColor colorWithHue:(originalval/100) saturation:0.8 brightness:1.0 alpha:1]];
        cell.rotateval = originalval;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.chatOpenSomewhere)
    {
        NSDictionary *posterInfo;
        if (self.selectedSortType == 0)
        {
            posterInfo = [[[postListNew objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:0];
        }
        if (self.selectedSortType == 1)
        {
            posterInfo = [[[postListTop objectAtIndex:indexPath.row] objectAtIndex:1] objectAtIndex:0];
        }
        if (self.selectedSortType == 3)
        {
            posterInfo = [[postListRoster objectAtIndex:indexPath.row] objectAtIndex:0];
        }
        selectedPerson = posterInfo;
        NSLog(@"selected person is %@",selectedPerson);
        [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
        [self performSegueWithIdentifier:@"toPersonVC" sender:self];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(IBAction)upvote:(UIButton *)button
{
    NSDictionary *post = [[postListNew objectAtIndex:button.tag] objectAtIndex:0];
    [self.apiBot upvoteAPost:post];
}

-(IBAction)downvote:(UIButton *)button
{
    NSDictionary *post = [[postListNew objectAtIndex:button.tag] objectAtIndex:0];
    [self.apiBot downvoteAPost:post];
}

-(IBAction)deleteAPost:(UIButton *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete this Post?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    self.selectedPost = button.tag;
    [alert show];
}

-(void)deletedDojo
{
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deletedPost
{
    [self.apiBot loadDojo:self.dojoInfo];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"button %ld",buttonIndex);
    if (alertView.tag ==0)
    {
        if (buttonIndex == 1)
        {
            @try {
                //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
                // Pass any objects to the view controller here, like...
                [self.apiBot deleteADojo:[self.dojoInfo objectForKey:@"dojohash"]];
            }
            @catch (NSException *exception)
            {
                NSLog(@"delete issue with %@",exception);
            }
            @finally
            {
                
            }
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            NSDictionary *post;
            if (self.selectedSortType == 0)
            {
                post = [[postListNew objectAtIndex:self.selectedPost] objectAtIndex:0];
            }
            if (self.selectedSortType == 1)
            {
                post = [[postListTop objectAtIndex:self.selectedPost] objectAtIndex:0];
            }
            [self.apiBot deleteAPost:[post objectForKey:@"posthash"]];
        }
    }
}

-(IBAction)repostButton:(UIButton *)repostButton
{
    NSDictionary *post;
    if (self.selectedSortType == 0)
    {
        post = [[postListNew objectAtIndex:repostButton.tag] objectAtIndex:0];
    }
    if (self.selectedSortType == 1)
    {
        post = [[postListTop objectAtIndex:repostButton.tag] objectAtIndex:0];
    }
    self.selectedPostForMessageView = post;
    [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
    [self performSegueWithIdentifier:@"toSendfromRevo" sender:self];
}

-(IBAction)favoriteDojo:(id)sender
{
    if (self.revoTableView.contentOffset.y > 26)
    {
        [self customScrollToTop];
        return;
    }
    if (self.youAreCreator)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this Dojo?" message:[NSString stringWithFormat:@"Delete %@?",[dojoInfo objectForKey:@"dojo"]]  delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else
    {
        self.rotater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotate) userInfo:nil repeats:YES];
        [self.apiBot followADojo:dojoInfo];
    }
}

-(void)followedADojo:(NSArray *)fetchedData
{
    if (self.youAreCreator)
    {
        return;
    }
    if ([[fetchedData objectAtIndex:0] isEqualToString:@"following"])
    {
        NSLog(@"evaluated correctly");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rotater invalidate];
            self.rotater = nil;
            [self.sortButton setTintColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
            [self.followLabel setTextColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
            [self.followLabel setText:@"Following"];
            
            [UIView animateWithDuration:0.1 animations:^{
                self.followingLoudLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    self.followingLoudLabel.alpha = 0;
                }];
            }];
        });
    }
    if ([[fetchedData objectAtIndex:0] isEqualToString:@"unfollow"])
    {
        NSLog(@"evaluated correctly");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rotater invalidate];
            self.rotater = nil;
            [self.sortButton setTintColor:[UIColor whiteColor]];
            [self.followLabel setTextColor:[UIColor whiteColor]];
            [self.followLabel setText:@"Follow"];
        });
    }
}

-(void)colorRotate
{
    self.rotateVal = (self.rotateVal + 2);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.sortButton setTintColor:[UIColor colorWithHue:(self.rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
}

-(void)colorRotateSendButton
{
    self.rotateVal = (self.rotateVal + 2);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.sendButton setBackgroundColor:[UIColor colorWithHue:(self.rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
}


-(void)cellSelected
{
    /*
    if ([self.messageField isFirstResponder])
    {
        [self.messageField resignFirstResponder];
        [self.view sendSubviewToBack:self.fieldContainer];
    }
    else
    {
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.messageField becomeFirstResponder];
    }
     */
}


-(void)customScrollToRow:(NSIndexPath *)cellPath
{
    NSArray *visiCells = [self.revoTableView visibleCells];
    CGFloat scrollTotal = 0;
    NSLog(@"this many visible cells %ld",(long)[[self.revoTableView visibleCells] count]);
    /*
    for (int i=0;i<[[self.revoTableView visibleCells] count];i++)
    {
        cell = [visiCells objectAtIndex:i];
        if (i == 0)
        {
            scrollTotal = cell.frame.origin.y;
        }
        //scrollTotal = scrollTotal + cell.frame.size.height;
        scrollTotal = cell.frame.origin.y;
    }
     */
    NSLog(@"INTENDED SCROLL PATH IS %@",cellPath);
    //scrollTotal = [self.revoTableView cellForRowAtIndexPath:cellPath].frame.origin.y;
    scrollTotal = 420.0 * cellPath.row;
    NSLog(@"scroll total is %f",scrollTotal);
    if (cellPath.row == ([self.postListNew count]-1))
    {
        NSLog(@"swagrow");
        [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 60)];
    }
    /*
    if (cellPath.row != 0)
    {
        scrollTotal = scrollTotal - 20;
    }
    */
    //NSLog(@"total distance to scroll is %f",scrollTotal);
    DOJORevoCell *cell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:cellPath];
    [UIView animateWithDuration:0.1 animations:^{
        [self.revoTableView setContentOffset:CGPointMake(0, scrollTotal)];
    } completion:^(BOOL finished) {
        cell.userInteractionEnabled = YES;
    }];
}

-(void)selectCell:(NSIndexPath *)cellPath
{
    //NSLog(@"select cell");
    if (!self.chatOpenSomewhere)
    {
        if (self.cellWithMessageView == nil)
        {
            [self tableView:self.revoTableView didSelectRowAtIndexPath:cellPath];
        }
    }
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([platform isEqualToString:@"i386"])         return [UIDevice currentDevice].model;
    if ([platform isEqualToString:@"x86_64"])       return [UIDevice currentDevice].model;
    
    return platform;
}

-(void)chatEngaged:(NSIndexPath *)cellPath
{
    NSString *platformIs = [self platformString];
   // if (([platformIs rangeOfString:@"5 "].location != NSNotFound) || ([platformIs rangeOfString:@"5C"].location != NSNotFound))
   // {
        NSLog(@"IS NOT 64 BIT");
        DOJORevoCell *cell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:cellPath];
        //cell.userInteractionEnabled = NO;
        NSDictionary *post;
        if (self.selectedSortType == 0)
        {
            post = [[postListNew objectAtIndex:cell.indexPath.row] objectAtIndex:0];
        }
        if (self.selectedSortType == 1)
        {
            post = [[postListTop objectAtIndex:cell.indexPath.row] objectAtIndex:0];
        }
        self.selectedPostForMessageView = post;
        self.selectedPostInfo = post;
        self.selectedImage = [[UIImage alloc] initWithCGImage:cell.imagePostView.image.CGImage];
    
        [self.storyboard instantiateViewControllerWithIdentifier:@"commentVC"];
        [self performSegueWithIdentifier:@"toCommentControllerFromRevo" sender:self];
        
        return;
   // }
    /*
    [self.messageField resignFirstResponder];
    [self.view sendSubviewToBack:self.fieldContainer];
    //NSLog(@"HOME cell path is %@",cellPath);
    //[self.tableView scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //[self.tableView deselectRowAtIndexPath:cellPath animated:YES];
    DOJORevoCell *cell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:cellPath];
    //cell.userInteractionEnabled = NO;
    NSDictionary *post;
    if (self.selectedSortType == 0)
    {
        post = [[postListNew objectAtIndex:cell.indexPath.row] objectAtIndex:0];
    }
    if (self.selectedSortType == 1)
    {
        post = [[postListTop objectAtIndex:cell.indexPath.row] objectAtIndex:0];
    }
    if (self.chatOpenSomewhere)
    {
        if (cellPath != self.cellWithMessageView)
        {
            return;
        }
    }
    if (self.cellWithMessageView != nil)
    {
        //NSLog(@"SETTING TO NIL");
        [self.messageField setUserInteractionEnabled:NO];
        self.chatOpenSomewhere = NO;
        self.cellWithMessageView = nil;
        cell.isRunningActiveMessageView = NO;
        [self.revoTableView setScrollEnabled:YES];
        //cell.userInteractionEnabled = YES;
        [cell.messageView.bongReloader invalidate];
        cell.messageView.bongReloader = nil;
        [cell.messageView setHidden:YES];
        [self.fieldContainer setHidden:YES];
        //[self.tableView reloadData];
        [self.revoTableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.revoTableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
        NSIndexPath *iPath;
        if (self.selectedSortType == 0)
        {
            if ([postListNew count] != (cellPath.row + 1))
            {
                iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
                DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:iPath];
                postCell.contentView.alpha = 1;
                postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:cellPath];
                [postCell.commentestIcon setHidden:YES];
            }
        }
        if (self.selectedSortType == 1)
        {
            if ([postListTop count] != (cellPath.row + 1))
            {
                iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
                DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:iPath];
                postCell.contentView.alpha = 1;
                postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:cellPath];
                [postCell.commentestIcon setHidden:YES];
            }
        }
        
        [self.view sendSubviewToBack:self.fieldContainer];
    }
    else
    {
        //NSLog(@"CREATING THE SWAG");
        [self.messageField setUserInteractionEnabled:YES];
        self.chatOpenSomewhere = YES;
        cell.isRunningActiveMessageView = YES;
        self.cellWithMessageView = cellPath;
        [self.revoTableView setScrollEnabled:NO];
        //[self.tableView reloadData];
        [cell.messageView setHidden:YES];
        [self.revoTableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.fieldContainer setHidden:NO];
        [self customScrollToRow:cellPath];
        NSIndexPath *iPath;
        if (self.selectedSortType == 0)
        {
            if ([postListNew count] != (cellPath.row + 1))
            {
                iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
                DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:iPath];
                postCell.contentView.alpha = 0;
            }
        }
        if (self.selectedSortType == 1)
        {
            if ([postListTop count] != (cellPath.row + 1))
            {
                iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
                DOJORevoCell *postCell = (DOJORevoCell *)[self.revoTableView cellForRowAtIndexPath:iPath];
                postCell.contentView.alpha = 0;
            }
        }
        [self.customHeaderView setAlpha:0];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    */
    //self.messageView.delegate = self;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"toPersonVC"])
    {
        DOJOProfileViewController *vc = [segue destinationViewController];
        vc.personInfo = selectedPerson;
        vc.previousType = @"dojo";
        vc.previousInfo = self.dojoInfo;
    }
    if ([[segue identifier] isEqualToString:@"toSendfromRevo"])
    {
        DOJOSendViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.postHash = [self.selectedPostForMessageView objectForKey:@"posthash"];
        vc.postDescription = [self.selectedPostForMessageView objectForKey:@"description"];
        vc.isRepost = YES;
        
        NSLog(@"applying properties");
        NSLog(@"in prepare for segue");
    }
    if ([[segue identifier] isEqualToString:@"toCommentControllerFromRevo"])
    {
        DOJO32BitMessageView *vc = [segue destinationViewController];
        vc.postInfo = self.selectedPostForMessageView;
    }
    if ([[segue identifier] isEqualToString:@"toDeepPost"])
    {
        DOJODeepPostViewController *targetVC = [segue destinationViewController];
        targetVC.postImageview.image = self.selectedImage;
        targetVC.postDescription = [self.selectedPostInfo objectForKey:@"description"];
    }
}


@end
