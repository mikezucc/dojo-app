//
//  DOJOProfileViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 1/5/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOProfileViewController.h"
#import "DOJORevoViewController.h"
#import "DOJOSendViewController.h"
#import "DOJOPerformAPIRequest.h"
#import <Accelerate/Accelerate.h>
#import "DOJOAccountViewController.h"
#import "DOJO32BitMessageView.h"

@interface DOJOProfileViewController () <UITableViewDataSource, UITableViewDelegate, touchdelegate, selectdelegate, RevolDelegate, UITextViewDelegate, scrolled, MagnifiedDelegate, UIAlertViewDelegate, APIRequestDelegate, DSVDelegate>

@property (nonatomic) dispatch_queue_t profileQueue;

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@property (strong, nonatomic) AWSS3TransferManager *transferManager;

@property (strong, nonatomic) UIVisualEffectView *bluredEffectView;

@property (strong, nonatomic) NSMutableArray *heightArray;

@end

@implementation DOJOProfileViewController

@synthesize profilePicView, profileTableView, postsLabel, dojoHeader, followersLabel, sortButton, tableType, documentsDirectory, fileManager, personInfo, postArray, followerArray, customSelectSegment, startPoint, postStartPoint, followerStartPoint, didMove, rotater, rotateVal, pathOfDownloadingCell, noPostLabel, votesLabel, peoplesLabel, followView, apiBot, transferManager, previousType, previousInfo, backTypeImageView, personBio, uppaView, userProperties, isGoingUp, bluredEffectView, dsv3000, dsv300Container, followingLoudLabel, heightArray, isYou, temporaryDirectory;

-(BOOL)prefersStatusBarHidden
{
    if (self.profileTableView.contentOffset.y < -260 || self.profileTableView.contentOffset.y > 0 || self.chatOpenSomewhere)
    {
        if (self.isGoingUp && !(self.profileTableView.contentOffset.y < -260))
        {
            return NO;
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.followingLoudLabel.layer setCornerRadius:4.0];
    self.followingLoudLabel.alpha = 0;
    [self.followingLoudLabel setClipsToBounds:YES];
    
    self.isYou = NO;
    
    self.heightArray = [[NSMutableDictionary alloc] init];
    
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
    
    self.tableType = 0;
    self.sortSelectType = 0;
    
    [self.postsLabel setAlpha:1.0];
    [self.followersLabel setAlpha:0.6];
    
    fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    temporaryDirectory = NSTemporaryDirectory();
    
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    self.userProperties = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    self.profileQueue = dispatch_queue_create("profile fetcher", DISPATCH_QUEUE_SERIAL);
    
    self.customSelectSegment.selectdelegate = self;
    
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePicView.layer setMasksToBounds:YES];
    [self.profilePicView setClipsToBounds:YES];
    
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
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [bluredEffectView setFrame:self.view.bounds];
    
    [self.view insertSubview:bluredEffectView aboveSubview:self.profilePicView];
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    [self.profileTableView setScrollsToTop:YES];
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    self.isGoingUp = NO;
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
    [UIView animateWithDuration:0.4 animations:^{
        self.dsv300Container.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.dsv300Container];
    }];
}

-(void)didLoadTheDSV3000
{
    NSLog(@"Time to show it now");
    
}

-(IBAction)customScrollToTop
{
    [self.profileTableView setContentOffset:CGPointMake(0, -208) animated:YES];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (int i=0; i< [self.profileTableView indexPathsForVisibleRows].count;i++)
    {
        DOJORevoCell *cell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:[[self.profileTableView indexPathsForVisibleRows] objectAtIndex:i]];
        @try {
            [cell.messageView endLoadSesh];
        }
        @catch (NSException *exception) {
            NSLog(@"oh for ****s sake");
        }
        @finally {
            NSLog(@"SUPER YOLO HAHA )");
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadedProfile:(NSArray *)profileData
{
    postArray = [profileData objectAtIndex:0];
    if ([postArray count] > 0)
    {
        [self.noPostLabel setHidden:YES];
        [self.view sendSubviewToBack:self.noPostLabel];
    }
    else
    {
        [self.noPostLabel setHidden:NO];
        [self.view bringSubviewToFront:self.noPostLabel];
    }
    
    UITextView *textymessyView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 235)];
    textymessyView.font = [UIFont fontWithName:@"Avenir-Light" size:19.0];
    textymessyView.textAlignment = NSTextAlignmentLeft;
    
    NSDictionary *post;
    self.heightArray = [[NSMutableArray alloc] init];
    for (int i=0;i<[postArray count];i++)
    {
        NSLog(@"looping");
        post = [[postArray objectAtIndex:i] objectAtIndex:0];
        if ([[post objectForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
        {
            //is text
            textymessyView.text = [post objectForKey:@"description"];
            CGSize sizeOfTheThing = [textymessyView sizeThatFits:CGSizeMake(textymessyView.frame.size.width, textymessyView.contentSize.height)];
            CGFloat puffer = ((160 - sizeOfTheThing.height) > 0 ?  220 : 220 + (sizeOfTheThing.height - 160));
            [self.heightArray addObject:[NSNumber numberWithFloat:puffer]];
        }
        else
        {
            [self.heightArray addObject:[NSNumber numberWithFloat:420.0f]];
        }
    }
    
    followerArray = [profileData objectAtIndex:1];
    [self.profileTableView reloadData];
    NSString *strang = [NSString stringWithFormat:@"%@ points",[[profileData objectAtIndex:2] objectAtIndex:0]];
    self.votesLabel.text = strang;
    strang = [NSString stringWithFormat:@"%@ followers",[[profileData objectAtIndex:2] objectAtIndex:1]];
    self.peoplesLabel.text = strang;
    
    [self.dojoHeader setText:[[[profileData objectAtIndex:3] objectAtIndex:0] objectForKey:@"fullname"]];
    
    self.personBio.text = [[[profileData objectAtIndex:3] objectAtIndex:0] objectForKey:@"bio"];
    if ([self.personBio.text isEqualToString:@""])
    {
        [self.personBio setHidden:YES];
    }
    [self.personBio sizeToFit];
    CGRect frm = self.personBio.frame;
    frm.size.width = 320;
    frm.origin.y = self.customSelectSegment.frame.origin.y-frm.size.height;
    self.personBio.frame = frm;
    
    NSString *profilehash = [[[profileData objectAtIndex:3] objectAtIndex:0] objectForKey:@"profilehash"];
    if ([profilehash isEqualToString:@""])
    {
        profilePicView.image = [UIImage imageNamed:@"iconwhite200.png"];
        profilePicView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
        NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
        UIImage *image = [[UIImage alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
        {
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
            [profilePicView setImage:image];
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
                        [self.profilePicView setImage:dlthumb];
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
                    [self.profilePicView setImage:dlthumb];
                }
                return nil;
            }];
        }
    }
}

-(void)checkedSomeoneOut:(NSArray *)resultData
{
    @try {
        if ([[resultData objectAtIndex:0] isEqualToString:@"following"])
        {
            NSLog(@"evaluated correctly");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.followView setTintColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
                [self.followLabel setTextColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
                [self.followLabel setText:@"Following"];
                //[self.sortButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            });
        }
        if ([[resultData objectAtIndex:0] isEqualToString:@"not"])
        {
            NSLog(@"evaluated correctly");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.followView setTintColor:[UIColor whiteColor]];
                [self.followLabel setTextColor:[UIColor whiteColor]];
                [self.followLabel setText:@"Follow"];
                //[self.sortButton setTitle:@"Follow" forState:UIControlStateNormal];
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran thorugh dojo info retrieval");
        [self.rotater invalidate];
        self.rotater = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.chatOpenSomewhere)
    {
        [self.profileTableView setFrame:CGRectMake(0, 0, 320, 568)];
        [self.profileTableView setContentInset:UIEdgeInsetsMake(233, 0, 0, 0)];
        [self.profileTableView setBackgroundColor:[UIColor clearColor]];
        
        self.didMove = NO;
        
        self.profileTableView.touchDelegate = self;
        self.profileTableView.canCancelContentTouches = NO;
        [self.profileTableView setCanCancelContentTouches:NO];
        //self.profileTableView.backgroundView.userInteractionEnabled = NO;
        
        [self.apiBot loadProfiledata:personInfo];
        
        [self.personBio sizeToFit];
        CGRect frm = self.personBio.frame;
        frm.size.width = 320;
        frm.origin.y = self.customSelectSegment.frame.origin.y-frm.size.height;
        self.personBio.frame = frm;
        
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"user email is %@",[personInfo valueForKey:@"username"]);
        if ([[meInfo objectForKey:@"username"] isEqualToString:[personInfo objectForKey:@"username"]])
        {
            NSLog(@"this is me");
            self.isYou = YES;
            [self.sortButton setTitle:@"" forState:UIControlStateNormal];
            //[self.sortButton setEnabled:NO];
            
            UIImage *segmentImage = [UIImage imageNamed:@"newsettings.png"];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
            [segmentImage drawInRect:CGRectMake(10, 7, 27, 35)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.followView setImage:segmentImage];
            [self.followView setTintColor:[UIColor whiteColor]];
            
            [self.followLabel setText:@""];
        }
        else
        {
            UIImage *flashImage = [UIImage imageNamed:@"diamondlove.png"];
            flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 31),NO,0.0);
            [flashImage drawInRect:CGRectMake(0, 0, 32, 31)];
            UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.followView setImage:flashImage];
            [self.followView setTintColor:[UIColor whiteColor]];
            self.isYou = NO;
            [self.apiBot checkSomeoneOut:personInfo];
        }
        
        [self.dojoHeader setText:[personInfo objectForKey:@"fullname"]];
        NSString *profilehash = [personInfo objectForKey:@"profilehash"];
        if ([profilehash isEqualToString:@""])
        {
            profilePicView.image = [UIImage imageNamed:@"iconwhite200.png"];
            profilePicView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {
            
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            UIImage *image = [[UIImage alloc] init];
            if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
            {
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [profilePicView setImage:image];
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
                            [self.profilePicView setImage:dlthumb];
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
                        [self.profilePicView setImage:dlthumb];
                    }
                    return nil;
                }];
            }
        }
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

    }//customSelectSegment = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self.profileTableView setContentOffset:CGPointMake(0, 146) animated:YES];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:keysPath])
    {
        NSMutableDictionary *keysDict = [[NSMutableDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"SEEN VC the keys are %@",keysDict);
        if ([[keysDict objectForKey:@"result"] isEqualToString:@"made"])
        {
            // made a new account
            [[[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Would you like to change your profile picture and bio?"delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Ok",nil] show];
            [keysDict setObject:@"success" forKey:@"result"];
            [keysDict writeToFile:keysPath atomically:YES];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableType == 0)
    {
        return  [[self.heightArray objectAtIndex:indexPath.row] floatValue];
    }
    else
    {
        return 50;
    }
    return 420;
}

/*
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (self.selectedSortType != 3)
 {
 NSDictionary *post;
 if (self.selectedSortType == 0)
 {
 post = [[postListNew objectAtIndex:indexPath.row] objectAtIndex:0];
 }
 if (self.selectedSortType == 1)
 {
 post = [[postListTop objectAtIndex:indexPath.row] objectAtIndex:0];
 }
 if ([[post objectForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
 {
 //is text
 return 220;
 }
 return 420;
 }
 else
 {
 return 50;
 }
 return 420;
 }
 
 
 
 */

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableType == 0)
    {
        return [postArray count];
    }
    else
    {
        if ([followerArray count] == 0)
        {
            return 5;
        }
        else
        {
            return [followerArray count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableType == 0)
    {
        NSLog(@"DOING THE DIDGEREDOO");
        DOJORevoCell *postCell = (DOJORevoCell *)[tableView dequeueReusableCellWithIdentifier:@"revoCell" forIndexPath:indexPath];
        postCell.indexPath = indexPath;
        postCell.imagePostView.contentMode = UIViewContentModeScaleAspectFill;
        [postCell.imagePostView setClipsToBounds:YES];
        postCell.cellPath = indexPath;
        postCell.indexPath = indexPath;
        postCell.delegate = self;
        
        /*
        CGRect frm = postCell.contentView.frame;
        frm.size.width = self.view.frame.size.width - 20;
        frm.origin.x = frm.origin.x + 10;
        postCell.contentView.frame = frm;
        [postCell.contentView setClipsToBounds:YES];
        [postCell.contentView.layer setMasksToBounds:YES];
         */
        
        postCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [postCell.moviePlayer.view removeFromSuperview];
        
        postCell.upvoteButton.tag = indexPath.row;
        postCell.downvoteButton.tag = indexPath.row;
        postCell.shareButton.tag = indexPath.row;
        postCell.deleteButton.tag = indexPath.row;
        
        [postCell.moviePlayer stop];
        postCell.moviePlayer = nil;
        
        [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, 0, 100)];
        
        NSDictionary *post = [[postArray objectAtIndex:indexPath.row] objectAtIndex:0];
        
        postCell.profilePicture.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
        /*
        if (indexPath == self.cellWithMessageView)
        {
            postCell.messageView = [[DojoPageMessageView alloc] initWithFrame:CGRectMake(0, 47, 320, 430)];
            
            CGPoint bottomOffset = CGPointMake(0, postCell.messageView.messageCollectionView.contentSize.height -
                                               postCell.messageView.messageCollectionView.bounds.size.height);
            if (bottomOffset.y >= 0.0)
            {
                [postCell.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
            }
            
            postCell.messageView.refreshSwag.backgroundColor = postCell.profilePicture.backgroundColor;
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
        }
        else
        {
            //NSLog(@"not active");
            //cell.messageView = nil;
            [postCell.messageView setHidden:YES];
            postCell.isRunningActiveMessageView = NO;
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = 383;
            frm.origin.x = 163;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.x = 156;
            frm.origin.y = 379;
            frm.size.width = 70;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.x = 193;
            frm.origin.y = 386;
            frm.size.width = 21;
            postCell.numberOfCommentsLabel.frame = frm;
        }
        */
        
        if ([[post objectForKey:@"username"] isEqualToString:[self.userProperties objectForKey:@"username"]])
        {
            [postCell.deleteButton setHidden:NO];
            [postCell.deleteIcon setHidden:NO];
        }
        else
        {
            [postCell.deleteButton setHidden:YES];
            [postCell.deleteIcon setHidden:YES];
        }
        
        //NSNumberFormatter *numformattere = [[NSNumberFormatter alloc] init];
        NSNumber *upvoteNumber = [[postArray objectAtIndex:indexPath.row] objectAtIndex:1];
        NSNumber *downvoteNumber = [[postArray objectAtIndex:indexPath.row] objectAtIndex:2];
        
        postCell.upvoteCount.text = [NSString stringWithFormat:@"%@",[[postArray objectAtIndex:indexPath.row] objectAtIndex:1]];
        //postCell.downvoteCount.text = [NSString stringWithFormat:@"%0.0f%%",((float)upvoteNumber.floatValue/(float)(upvoteNumber.floatValue+downvoteNumber.floatValue))*100];
        postCell.downvoteCount.text = [NSString stringWithFormat:@"%@",[[postArray objectAtIndex:indexPath.row] objectAtIndex:6]];
        
        postCell.numberOfCommentsLabel.text = [NSString stringWithFormat:@"%@",[[postArray objectAtIndex:indexPath.row] objectAtIndex:7]];
        
        postCell.repostCount.text = [NSString stringWithFormat:@"%@",[[postArray objectAtIndex:indexPath.row] objectAtIndex:8]];
        
        BOOL isTextPost = NO;
        [postCell.textpostview setText:@""];
        if ([[post valueForKey:@"posthash"] rangeOfString:@"text"].location != NSNotFound)
        {
            //postCell.textpostview.attributedText = [[NSMutableAttributedString alloc] initWithString:@"" attributes:nil];
            postCell.textpostview.dataDetectorTypes = UIDataDetectorTypeNone;
            
            [postCell.textpostview setEditable:YES];
            postCell.textpostview.text = [NSString stringWithFormat:@"%@",[post valueForKey:@"description"]];
            [postCell.contentView bringSubviewToFront:postCell.textpostview];
            CGSize newsize = [postCell.textpostview sizeThatFits:CGSizeMake(294, postCell.textpostview.contentSize.height)];
            CGRect frame = CGRectMake(13, 48, 294, newsize.height);
            postCell.textpostview.frame = frame;
            isTextPost = YES;
            postCell.textpostview.dataDetectorTypes = UIDataDetectorTypeLink;
            [postCell.textpostview setEditable:NO];
            
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
                    
                    [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
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
                    
                    [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
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
                    [postCell.playButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                }
            }
        }
        
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
        /*
        if (isTextPost)
        {
         
            CGRect frm = postCell.commentIcon.frame;
            frm.origin.y = 185;
            postCell.commentIcon.frame = frm;
            frm = postCell.commentButton.frame;
            frm.origin.y = 185;
            postCell.commentButton.frame = frm;
            frm = postCell.numberOfCommentsLabel.frame;
            frm.origin.y = 189;
            postCell.numberOfCommentsLabel.frame = frm;
            frm = postCell.upvoteButton.frame;
            frm.origin.y = 185;
            postCell.upvoteButton.frame = frm;
            frm = postCell.upvoteCount.frame;
            frm.origin.y = 189;
            postCell.upvoteCount.frame = frm;
            frm = postCell.upthumb.frame;
            frm.origin.y = 185;
            postCell.upthumb.frame = frm;
            
            frm = postCell.downvoteButton.frame;
            frm.origin.y = 180;
            postCell.downvoteButton.frame = frm;
            frm = postCell.downthumb.frame;
            frm.origin.y = 185;
            postCell.downthumb.frame = frm;
            
            frm = postCell.repostCount.frame;
            frm.origin.y = 189;
            postCell.repostCount.frame = frm;
            frm = postCell.shareBackground.frame;
            frm.origin.y = 185;
            postCell.shareBackground.frame = frm;
            frm = postCell.shareButton.frame;
            frm.origin.y = 185;
            postCell.shareButton.frame = frm;
            
            frm = postCell.upvoteBackground.frame;
            frm.origin.y = 217;
            postCell.upvoteBackground.frame = frm;
            
            [postCell.playButton setHidden:YES];
        }
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
            postCell.numberOfCommentsLabel.text = @"close";
            @try {
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
                //clean up
                CGContextRelease(ctx);
                CGColorSpaceRelease(colorSpace);
                free(pixelBuffer);
                CFRelease(inBitmapData);
                CGImageRelease(imageRef);
                
                [postCell.messageView.backgroundImageView setImage:returnImage];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                
            }
            
            postCell.messageView.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
            
            postCell.messageView.messageCollectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            postCell.messageView.messageCollectionView.backgroundView.alpha = 0;
        }
        */
        if ([[[postArray objectAtIndex:indexPath.row] objectAtIndex:4] count])
        {
            NSString *voteString = [[[[postArray objectAtIndex:indexPath.row] objectAtIndex:4] objectAtIndex:0] objectForKey:@"vote"];
            NSLog(@"vote array is %@",[[postArray objectAtIndex:indexPath.row] objectAtIndex:4]);
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
        
        [postCell.imagePostView setFrame:CGRectMake(0, 47, 320, 332)];
        
        NSDictionary *posterInfo = personInfo;
        
        if ([[NSString stringWithFormat:@"%@",[post valueForKey:@"description"]] isEqualToString:@""])
        {
            [postCell.postDescription setHidden:YES];
        }
        else
        {
            postCell.postDescription.text = [NSString stringWithFormat:@"%@",[post valueForKey:@"description"]];
            [postCell.postDescription setHidden:NO];
        }
        
        postCell.nameLabel.text = [[[[postArray objectAtIndex:indexPath.row] objectAtIndex:5] objectAtIndex:0] objectForKey:@"dojo"];
        postCell.profilePicture.image = [UIImage imageNamed:@"dojoarches.png"];
        [postCell.profilePicture.layer setCornerRadius:19];
        postCell.profilePicture.clipsToBounds = YES;
        postCell.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
        [postCell.profilePicture setFrame:CGRectMake(10, 7, 38, 38)];
        /*
        NSString *profilePicture = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",[posterInfo objectForKey:@"username"]]]];
        NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        NSRange rangeAgain = [[posterInfo objectForKey:@"username"] rangeOfCharacterFromSet:s];
        if (rangeAgain.location == NSNotFound)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:profilePicture])
            {
                UIImage *fbImage = [UIImage imageWithContentsOfFile:profilePicture];
                postCell.profilePicture.image = fbImage;
                [postCell.profilePicture.layer setCornerRadius:19];
                postCell.profilePicture.clipsToBounds = YES;
                postCell.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
                [postCell.profilePicture setFrame:CGRectMake(10, 7, 38, 38)];
            }
            else
            {
                dispatch_async(self.profileQueue, ^{
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [posterInfo objectForKey:@"username"]]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                        UIImage *fbImage = [UIImage imageWithData:imageData];
                        imageData = UIImageJPEGRepresentation(fbImage, 1.0);
                        [imageData writeToFile:profilePicture atomically:YES];
                        postCell.profilePicture.image = fbImage;
                        [postCell.profilePicture.layer setCornerRadius:19];
                        postCell.profilePicture.clipsToBounds = YES;
                        postCell.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
                    });
                });
            }
        }
        else
        {
            postCell.profilePicture.image = [UIImage imageNamed:@"doji120.png"];
            [postCell.profilePicture.layer setCornerRadius:10];
            postCell.profilePicture.clipsToBounds = YES;
            postCell.profilePicture.layer.masksToBounds = YES;
            postCell.profilePicture.contentMode = UIViewContentModeScaleAspectFit;
        }
         */
        
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
        if ([followerArray count] == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell" forIndexPath:indexPath];
            return cell;
        }
        NSLog(@"HELL NAW THE DIDGEREDOO");
        DOJOPersonCell *personCell = (DOJOPersonCell *)[tableView dequeueReusableCellWithIdentifier:@"personCell" forIndexPath:indexPath];
        NSDictionary *posterInfo = [[[followerArray objectAtIndex:indexPath.row] objectAtIndex:0] objectAtIndex:0];
        
        personCell.pointsLabel.text = [NSString stringWithFormat:@"%@ points",[[followerArray objectAtIndex:indexPath.row] objectAtIndex:1]];
        
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

-(IBAction)repostButton:(UIButton *)repostButton
{
    self.selectedPostForMessageView = [[postArray objectAtIndex:repostButton.tag] objectAtIndex:0];
    [self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
    [self performSegueWithIdentifier:@"toSendfromProfile" sender:self];
}

-(IBAction)deleteAPost:(UIButton *)button
{
    if (self.chatOpenSomewhere)
    {
        [self chatEngaged:self.cellWithMessageView];
        return;
    }
    NSLog(@"deleted post index %ld",(long)button.tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this Post?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    self.selectedPost = button.tag;
    alert.delegate = self;
    [alert show];
}

-(void)deletedPost
{
    [self.apiBot loadProfiledata:self.personInfo];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"button %ld",buttonIndex);
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            NSDictionary *post = [[postArray objectAtIndex:self.selectedPost] objectAtIndex:0];
            NSLog(@"smuggled post is %@",post);
            [self.apiBot deleteAPost:[post objectForKey:@"posthash"]];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            DOJOAccountViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"profileViewer"];
            vc.profileVC = self;
            [self performSegueWithIdentifier:@"toSettingsFromProfile" sender:self];
        }
    }
}

-(void)magnifyCell:(UIButton *)button
{
    NSLog(@"magnify the cell for button %ld",(long)button.tag);
    DOJORevoCell *tempCell;
    
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    DOJORevoCell *postCell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:iPath];
    self.pathOfDownloadingCell = iPath;
    BOOL found = false;
    for (tempCell in [self.profileTableView visibleCells])
    {
        if (tempCell == postCell)
        {
            found = YES;
        }
    }
    if (!found)
    {
        postCell.moviePlayer = nil;
    }
    
    NSDictionary *post = [[postArray objectAtIndex:postCell.indexPath.row] objectAtIndex:0];
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
            
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            
            self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
            self.downloadRequest.bucket = @"dojopicbucket";
            self.downloadRequest.key = [post valueForKey:@"posthash"];
            self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
            NSLog(@"about to download a movie pirate bryan");
            __weak DOJOProfileViewController *weakSelf = self;
            self.downloadRequest.downloadProgress =  ^(int64_t bytesReceived, int64_t totalBytesReceived, int64_t totalBytesExpectedToReceive){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update progress.
                    DOJOProfileViewController *strongSelf = weakSelf;
                    [strongSelf updateProgessOfDownload:bytesReceived totalBytesReceived:totalBytesReceived totalBytesExpectedToReceive:totalBytesExpectedToReceive];
                });};
            __weak DOJORevoCell *postCellWeak = postCell;
            [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                }
                else
                {
                    if ([[self.profileTableView indexPathsForVisibleRows] containsObject:postCellWeak.indexPath])
                    {
                        NSLog(@"completed download");
                        [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, 0, 100)];
                        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[temporaryDirectory stringByAppendingPathComponent:@"downloaded.mov"]];
                        postCell.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:selectedPath];
                        [postCell.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
                        [postCell.moviePlayer prepareToPlay];
                        postCell.moviePlayer.controlStyle = MPMovieControlStyleNone;
                        [postCell.moviePlayer.view setFrame:CGRectMake(0, postCell.imagePostView.frame.origin.y, 320, postCell.imagePostView.frame.size.height)];
                        //[self.view sen:moviePlayer.view];
                        //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                        postCell.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
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
        DOJORevoCell *postCell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:self.pathOfDownloadingCell];
        [postCell.postDescriptionBack setFrame:CGRectMake(0, 0, newWidth, 100)];
        postCell.postDescriptionBack.backgroundColor = [UIColor colorWithHue:(fmodf(newWidth/3.2,100))/100 saturation:0.8 brightness:1 alpha:0.7];
    }
    @catch (NSException *exception) {
        NSLog(@"AWS DOWNLOADER PROGRESS EXCEPTION exception was %@",exception);
    }
    @finally {
        NSLog(@"ran through anim block");
    }
}

-(IBAction)upvote:(UIButton *)button
{
    NSDictionary *post = [[postArray objectAtIndex:button.tag] objectAtIndex:0];
    [self.apiBot upvoteAPost:post];
}

-(IBAction)downvote:(UIButton *)button
{
    NSDictionary *post = [[postArray objectAtIndex:button.tag] objectAtIndex:0];
    [self.apiBot downvoteAPost:post];
}

-(void)voteReported:(NSArray *)reportData
{
    [self reloadAfterVote];
}

-(void)reloadAfterVote
{
    [self.apiBot loadProfiledata:personInfo];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*if (self.tableType == 0)
    {
        for (int i=0; i< [self.profileTableView indexPathsForVisibleRows].count;i++)
        {
            DOJORevoCell *cell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:[[self.profileTableView indexPathsForVisibleRows] objectAtIndex:i]];
            cell.profilePicture.backgroundColor = [UIColor colorWithHue:(fmodf(cell.frame.origin.y + self.profileTableView.contentOffset.y/10,100))/100 saturation:0.8 brightness:1 alpha:1];
        }
    }*/
    
    NSLog(@"scroll view content offset is %f",scrollView.contentOffset.y);
    
    CGRect frm = self.postsLabel.frame;
    frm.origin.y = -32 - scrollView.contentOffset.y;
    self.postsLabel.frame = frm;
    frm = self.followersLabel.frame;
    frm.origin.y = -32 - scrollView.contentOffset.y;
    self.followersLabel.frame = frm;
    
    frm = self.customSelectSegment.frame;
    frm.origin.y = -38 - scrollView.contentOffset.y;
    self.customSelectSegment.frame = frm;
    
    if (self.customSelectSegment.frame.origin.y >= 0)
    {
        CGRect frm = self.profilePicView.frame;
        frm.size.height = self.customSelectSegment.frame.origin.y;
        self.profilePicView.frame = frm;
    }
    
    self.bluredEffectView.alpha = ( scrollView.contentOffset.y > -280 ? 0.90 : 0.90 + ((scrollView.contentOffset.y + 280)/ 82));
    [self.bluredEffectView setNeedsDisplay];
    
    frm = self.personBio.frame;
    frm.origin.y = self.customSelectSegment.frame.origin.y - self.personBio.frame.size.height;
    self.personBio.frame = frm;
    
    if (scrollView.contentOffset.y > 0)
    {
        [self setScrollUpIcon];
        if (self.isGoingUp)
        {
            self.uppaView.alpha = 1;
            [self setNeedsStatusBarAppearanceUpdate];
            self.votesLabel.alpha = 0;
            self.peoplesLabel.alpha = 0;
        }
        else
        {
            self.uppaView.alpha = 0;
            [self setNeedsStatusBarAppearanceUpdate];
            self.votesLabel.alpha = 0;
            self.peoplesLabel.alpha = 0;
        }
    }
    else
    {
        [self setScrollDownIcon];
        if (scrollView.contentOffset.y < -260)
        {
            NSLog(@"reached far enough");
            self.uppaView.alpha = 0;
            [self setNeedsStatusBarAppearanceUpdate];
            self.votesLabel.alpha = ( scrollView.contentOffset.y > -280 ? 1.0 : 1 + ((scrollView.contentOffset.y + 280)/ 82));
            self.peoplesLabel.alpha = ( scrollView.contentOffset.y > -280 ? 1.0 : 1 + ((scrollView.contentOffset.y + 280)/ 82));
            [self.noPostLabel setAlpha:0];
        }
        else
        {
            [self.noPostLabel setAlpha:1];
            if (scrollView.contentOffset.y > -180)
            {
                self.votesLabel.alpha = 0;
                self.peoplesLabel.alpha = 0;
            }
            else
            {
                self.votesLabel.alpha = ( scrollView.contentOffset.y > -280 ? 1.0 : 1 + ((scrollView.contentOffset.y + 280)/ 82));
                self.peoplesLabel.alpha = ( scrollView.contentOffset.y > -280 ? 1.0 : 1 + ((scrollView.contentOffset.y + 280)/ 82));
            }
            self.uppaView.alpha = 1;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    /*
        if (self.tableType == 0)
        {
            //if ([self.profileTableView numberOfRowsInSection:0] > 0)
            //{
                //DOJORevoCell *cell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            
            //}
        }
        else
        {
            //if ([self.profileTableView numberOfRowsInSection:0] > 0)
            //{
                //DOJOPersonCell *cell = (DOJOPersonCell *)[self.profileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                if (1 - scrollView.contentOffset.y >= 0)
                {
                    CGRect frm = self.profilePicView.frame;
                    frm.size.height = self.customSelectSegment.frame.origin.y - 10;
                    self.profilePicView.frame = frm;
                }
            //}
        }
     */
    //}
    
    //[self.customSelectSegment setNeedsDisplay];
}

-(void)setScrollDownIcon
{
    if (self.isYou)
    {
        //[self.sortButton setEnabled:NO];
        
        UIImage *segmentImage = [UIImage imageNamed:@"newsettings.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
        [segmentImage drawInRect:CGRectMake(10, 7, 27, 35)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.followView setImage:segmentImage];
        
        [self.followLabel setText:@""];
        [self.followView setNeedsDisplay];
    }
    else
    {
        UIImage *flashImage = [UIImage imageNamed:@"diamondlove.png"];
        flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 31),NO,0.0);
        [flashImage drawInRect:CGRectMake(0, 0, 32, 31)];
        UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.followView setImage:flashImage];
        [self.followView setNeedsDisplay];
    }
}

-(void)setScrollUpIcon
{
    NSLog(@"you are creator");
    UIImage *flashImage = [UIImage imageNamed:@"returnToTop.png"];
    //flashImage = [flashImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
    [flashImage drawInRect:CGRectMake(0, 8, 45, 29)];
    UIImage *resizedFlash = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.followView setImage:resizedFlash];
    [self.followLabel setHidden:YES];
    [self.followView setNeedsDisplay];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (scrollView.contentOffset.y < -260)
    {
        NSLog(@"END DRAGGIN reached far enough");
        [self.profileTableView setContentInset:UIEdgeInsetsMake(362, 0, 0, 0)];
        [UIView animateWithDuration:0.2 animations:^{
            [self.uppaView setAlpha:0];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
    else
    {
        [self.profileTableView setContentInset:UIEdgeInsetsMake(234, 0, 0, 0)];
 /*       [UIView animateWithDuration:0.2 animations:^{
            [self.uppaView setAlpha:1.0];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
  */
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.chatOpenSomewhere)
    {
        if (self.tableType == 0)
        {
            NSDictionary *post = [[postArray objectAtIndex:indexPath.row] objectAtIndex:3];
            DOJORevoViewController *revoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
            revoVC.dojoInfo = post;
            revoVC.previousType = @"person";
            revoVC.previousInfo = self.personInfo;
            [self.navigationController pushViewController:revoVC animated:YES];
        }
        else
        {
            if ([followerArray count] == 0)
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            NSDictionary *person = [[[followerArray objectAtIndex:indexPath.row] objectAtIndex:0] objectAtIndex:0];
            DOJOProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
            profileVC.personInfo = person;
            profileVC.previousType = @"person";
            profileVC.previousInfo = personInfo;
            [self.navigationController pushViewController:profileVC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    CGRect frm = self.profilePicView.frame;
    frm.origin.x = [[touches anyObject] locationInView:self.view].x - frm.size.width/2;
    self.profilePicView.frame = frm;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"moved");
    CGRect frm = self.profilePicView.frame;
    frm.origin.x = [[touches anyObject] locationInView:self.view].x - frm.size.width/2;
    self.profilePicView.frame = frm;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"ended");
    CGRect frm = self.customSelectSegment.frame;
    frm.origin.x = [[touches anyObject] locationInView:self.view].x - frm.size.width/2;
    if (self.customSelectSegment.frame.origin.x <= 160)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.customSelectSegment.frame;
            frm.origin.x = 16;
            customSelectSegment.frame = frm;
        }];
    }
    else
    {
        CGRect frm = self.customSelectSegment.frame;
        frm.origin.x = 176;
        customSelectSegment.frame = frm;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect frm = self.customSelectSegment.frame;
    frm.origin.x = [[touches anyObject] locationInView:self.view].x - frm.size.width/2;
    if (self.customSelectSegment.frame.origin.x <= 160)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.customSelectSegment.frame;
            frm.origin.x = 16;
            customSelectSegment.frame = frm;
        }];
    }
    else
    {
        CGRect frm = self.customSelectSegment.frame;
        frm.origin.x = 176;
        customSelectSegment.frame = frm;
    }
}
 
 if ([[resultData objectAtIndex:0] isEqualToString:@"following"])
 {
 NSLog(@"evaluated correctly");
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.followView setTintColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
 [self.followLabel setTextColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
 [self.followLabel setText:@"Following"];
 //[self.sortButton setTitle:@"Unfollow" forState:UIControlStateNormal];
 });
 }
 if ([[resultData objectAtIndex:0] isEqualToString:@"not"])
 {
 NSLog(@"evaluated correctly");
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.followView setTintColor:[UIColor whiteColor]];
 [self.followLabel setTextColor:[UIColor whiteColor]];
 [self.followLabel setText:@"Follow"];
 //[self.sortButton setTitle:@"Follow" forState:UIControlStateNormal];
 });
 }
*/

-(void)followedPerson:(NSArray *)fetchedData
{
    if ([[fetchedData objectAtIndex:0] isEqualToString:@"following"])
    {
        NSLog(@"evaluated correctly");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rotater invalidate];
            self.rotater = nil;
            [self.followView setTintColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
            [self.followLabel setTextColor:[UIColor colorWithRed:248.0/255.0 green:231.0/255.0 blue:28.0/255.0 alpha:1]];
            [self.followLabel setText:@"Following"];
            
            [UIView animateWithDuration:0.1 animations:^{
                self.followingLoudLabel.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    self.followingLoudLabel.alpha = 0;
                }];
            }];
            //[self.sortButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        });
    }
    if ([[fetchedData objectAtIndex:0] isEqualToString:@"unfollow"])
    {
        NSLog(@"evaluated correctly");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rotater invalidate];
            self.rotater = nil;
            [self.followView setTintColor:[UIColor whiteColor]];
            [self.followLabel setTextColor:[UIColor whiteColor]];
            [self.followLabel setText:@"Follow"];
            //[self.sortButton setTitle:@"Follow" forState:UIControlStateNormal];
        });
    }
}

-(IBAction)switchFollowState:(id)sender
{
    if (self.profileTableView.contentOffset.y > 0)
    {
        [self customScrollToTop];
        return;
    }
    
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    NSLog(@"user name is %@",[personInfo valueForKey:@"username"]);
    if ([[meInfo objectForKey:@"username"] isEqualToString:[personInfo objectForKey:@"username"]])
    {
        DOJOAccountViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"profileViewer"];
        vc.profileVC = self;
        [self performSegueWithIdentifier:@"toSettingsFromProfile" sender:self];
    }
    else
    {
        self.rotater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotate) userInfo:nil repeats:YES];
        [self.apiBot followSomeone:personInfo];
    }
}

-(void)colorRotate
{
    self.rotateVal = (self.rotateVal + 2);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.followView setTintColor:[UIColor colorWithHue:(self.rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
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
    //NSArray *visiCells = [self.profileTableView visibleCells];
    CGFloat scrollTotal = 0;
    //DOJORevoCell *cell;
    /*
    NSLog(@"this many visible cells %ld",(long)[[self.profileTableView visibleCells] count]);
    for (int i=0;i<[[self.profileTableView visibleCells] count];i++)
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
    /*
     if (cellPath.row != 0)
     {
     scrollTotal = scrollTotal - 20;
     }
     */
    //NSLog(@"total distance to scroll is %f",scrollTotal);
    [UIView animateWithDuration:0.2 animations:^{
        [self.profileTableView setContentOffset:CGPointMake(0, scrollTotal)];
        [self.uppaView setAlpha:0];
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        DOJORevoCell *cell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:cellPath];
        cell.userInteractionEnabled = YES;
    }];
}

-(void)selectCell:(NSIndexPath *)cellPath
{
    //NSLog(@"select cell");
    if (!self.chatOpenSomewhere)
    {
        if (self.cellWithMessageView != nil)
        {
            [self tableView:self.profileTableView didSelectRowAtIndexPath:cellPath];
        }
    }
}

-(void)chatEngaged:(NSIndexPath *)cellPath
{
    NSLog(@"IS NOT 64 BIT");
    //cell.userInteractionEnabled = NO;
    NSDictionary *post = [[postArray objectAtIndex:cellPath.row] objectAtIndex:0];
    self.selectedPostForMessageView = post;
    
    [self.storyboard instantiateViewControllerWithIdentifier:@"commentVC"];
    [self performSegueWithIdentifier:@"toCommentControllerFromProfile" sender:self];
    
    return;
    /*
    [self.messageField resignFirstResponder];
    [self.view sendSubviewToBack:self.fieldContainer];
    //NSLog(@"HOME cell path is %@",cellPath);
    //[self.tableView scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //[self.tableView deselectRowAtIndexPath:cellPath animated:YES];
    DOJORevoCell *cell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:cellPath];
    //cell.userInteractionEnabled = NO;
    self.selectedPostForMessageView = [[postArray objectAtIndex:cell.indexPath.row] objectAtIndex:0];
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
        [self.profileTableView setScrollEnabled:YES];
        //cell.userInteractionEnabled = YES;
        [cell.messageView.bongReloader invalidate];
        cell.messageView.bongReloader = nil;
        [cell.messageView setHidden:YES];
        [self.fieldContainer setHidden:YES];
        //[self.tableView reloadData];
        [self.profileTableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.view sendSubviewToBack:self.fieldContainer];
        NSIndexPath *iPath;
        if ([postArray count] != (cellPath.row + 1))
        {
            iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
            DOJORevoCell *postCell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:iPath];
            postCell.contentView.alpha = 1;
        }
    }
    else
    {
        //NSLog(@"CREATING THE SWAG");
        [self.messageField setUserInteractionEnabled:YES];
        self.chatOpenSomewhere = YES;
        cell.isRunningActiveMessageView = YES;
        self.cellWithMessageView = cellPath;
        [self.profileTableView setScrollEnabled:NO];
        //[self.tableView reloadData];
        [cell.messageView setHidden:YES];
        [self.profileTableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.fieldContainer setHidden:NO];
        [self customScrollToRow:cellPath];
        NSIndexPath *iPath;
        if ([postArray count] != (cellPath.row + 1))
        {
            iPath = [NSIndexPath indexPathForItem:cellPath.row+1 inSection:0];
            DOJORevoCell *postCell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:iPath];
            postCell.contentView.alpha = 0;
        }
    }
    */
    //self.messageView.delegate = self;
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

-(void)colorRotateSendButton
{
    self.rotateVal = (self.rotateVal + 2);
    self.rotateVal = fmodf(self.rotateVal, 100);
    [self.sendButton setBackgroundColor:[UIColor colorWithHue:(self.rotateVal/100) saturation:0.8 brightness:1.0 alpha:1]];
}

-(IBAction)submitMessage:(id)sender
{
    if ([self.messageField.text isEqualToString:@""])
    {
        
    }
    else
    {
        self.sendRotater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(colorRotateSendButton) userInfo:nil repeats:YES];
        /*
         if (self.chatOpenSomewhere && self.selectedSortType != 3)
         {
         [self.apiBot submitAComment:self.selectedPostForMessageView withText:self.messageField.text];
         }
         else
         {
         [self.apiBot submitMessage:dojoInfo withText:self.messageField.text];
         }
         */
        if (self.chatOpenSomewhere)
        {
            [self.apiBot submitAComment:self.selectedPostForMessageView withText:self.messageField.text];
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
    NSLog(@"%dx %dy prevent:%@", (int)self.fieldContainer.frame.origin.x, (int)self.fieldContainer.frame.origin.y,self.preventJumping);
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
        
        if (self.chatOpenSomewhere)
        {
            DOJORevoCell *swagcell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:self.cellWithMessageView];
            
            frm = swagcell.messageView.messageCollectionView.frame;
            frm.size.height = 245;
            swagcell.messageView.messageCollectionView.frame = frm;
            
            CGPoint bottomOffset = CGPointMake(0, swagcell.messageView.messageCollectionView.contentSize.height -
                                       swagcell.messageView.messageCollectionView.bounds.size.height);
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
        
        if (self.chatOpenSomewhere)
        {
            DOJORevoCell *swagcell = (DOJORevoCell *)[self.profileTableView cellForRowAtIndexPath:self.cellWithMessageView];
            
            frm = swagcell.messageView.messageCollectionView.frame;
            frm.size.height = 430;
            swagcell.messageView.messageCollectionView.frame = frm;
            
            CGPoint bottomOffset = CGPointMake(0, swagcell.messageView.messageCollectionView.contentSize.height -
                                               swagcell.messageView.messageCollectionView.bounds.size.height);
            if (bottomOffset.y >= 0.0)
            {
                [swagcell.messageView.messageCollectionView setContentOffset:bottomOffset animated:YES];
            }
        }
    }];
}


-(void)tableTouchBegin:(CGPoint)location
{
    NSLog(@"touch began");
    self.startPoint = location;
    self.postStartPoint = self.postsLabel.frame.origin;
    self.followerStartPoint = self.followersLabel.frame.origin;
    self.didMove = NO;
}

-(void)tableTouchMoved:(CGPoint)location
{
    NSLog(@"moved");
    float adjust = 0;
    switch (self.tableType) {
        case 0:
            adjust = 50;
            break;
        case 1:
            adjust = 132;
            break;
            
        default:
            break;
    }
    CGRect frm = self.postsLabel.frame;
    frm.origin.x = (location.x - self.startPoint.x) + self.postStartPoint.x + adjust;// - frm.size.width/2;
    self.postsLabel.frame = frm;
    frm = self.followersLabel.frame;
    frm.origin.x = (location.x - self.startPoint.x) + self.followerStartPoint.x + adjust;// - frm.size.width/2;
    self.followersLabel.frame = frm;
    
    self.didMove = YES;
}

-(void)tableTouchCancelled:(CGPoint)location
{
    if (self.postsLabel.center.x <= 130)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 112;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 7;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
            [self.postsLabel setAlpha:0.6];
            [self.followersLabel setAlpha:1.0];
        }];
        self.tableType = 1;
        [self.profileTableView reloadData];
        if ([followerArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Followers!";
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 216;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 112;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
            
            [self.postsLabel setAlpha:1.0];
            [self.followersLabel setAlpha:0.6];
        }];
        self.tableType = 0;
        [self.profileTableView reloadData];
        if ([postArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Posts!";
        }
    }
    
    if (self.didMove)
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
    }
    else
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
    }
}

-(void)tableTouchEnded:(CGPoint)location
{
    NSLog(@"ended");
    if (self.postsLabel.center.x <= 130)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 112;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 7;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
            [self.postsLabel setAlpha:0.6];
            [self.followersLabel setAlpha:1.0];
        }];
        self.tableType = 1;
        [self.profileTableView reloadData];
        if ([followerArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Followers!";
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 216;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 112;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
            [self.postsLabel setAlpha:1.0];
            [self.followersLabel setAlpha:0.6];
        }];
        self.tableType = 0;
        [self.profileTableView reloadData];
        if ([postArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Posts!";
        }
    }
    
    if (self.didMove)
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
    }
    else
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
    }
}

-(void)selectTouchBegin:(CGPoint)location
{
    NSLog(@"touch began");
    self.startPoint = location;
    self.postStartPoint = self.postsLabel.frame.origin;
    self.followerStartPoint = self.followersLabel.frame.origin;
    self.didMove = NO;
}

-(void)selectTouchMoved:(UITouch *)location
{
    NSLog(@"moved");
    CGRect frm = self.postsLabel.frame;
    frm.origin.x = ([location locationInView:self.customSelectSegment].x - self.startPoint.x) + self.postStartPoint.x;// - frm.size.width/2;
    self.postsLabel.frame = frm;
    frm = self.followersLabel.frame;
    frm.origin.x = ([location locationInView:self.customSelectSegment].x - self.startPoint.x) + self.followerStartPoint.x;// - frm.size.width/2;
    self.followersLabel.frame = frm;
    
    if (self.followersLabel.frame.origin.x > self.customSelectSegment.frame.size.width/2)
    {
        //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
        [self.postsLabel setAlpha:1.0];
        [self.followersLabel setAlpha:0.6];
    }
    else
    {
        //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
        [self.postsLabel setAlpha:0.6];
        [self.followersLabel setAlpha:1.0];
    }
    
    /*
    CGPoint dicktits = self.profileTableView.contentOffset;
    dicktits.y = self.profileTableView.contentOffset.y + [location locationInView:self.view].y;
    self.profileTableView.contentOffset = dicktits;
     */
    
    self.didMove = YES;
}

-(void)selectTouchCancelled:(CGPoint)location
{
    if (self.postsLabel.center.x <= 130)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 112;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 7;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
            [self.postsLabel setAlpha:0.6];
            [self.followersLabel setAlpha:1.0];
        }];
        self.tableType = 1;
        [self.profileTableView reloadData];
        if ([followerArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Followers!";
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 216;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 112;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
            [self.postsLabel setAlpha:1.0];
            [self.followersLabel setAlpha:0.6];
        }];
        self.tableType = 0;
        [self.profileTableView reloadData];
        if ([postArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Posts!";
        }
    }
    
    if (self.didMove)
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
    }
    else
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
    }
}

-(void)selectTouchEnded:(CGPoint)location
{
    NSLog(@"ended");
    if (self.postsLabel.center.x <= 130)
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 112;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 7;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
            
            [self.postsLabel setAlpha:0.6];
            [self.followersLabel setAlpha:1.0];
        }];
        self.tableType = 1;
        [self.profileTableView reloadData];
        if ([followerArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Followers!";
        }
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frm = self.followersLabel.frame;
            frm.origin.x = 216;
            self.followersLabel.frame = frm;
            
            frm = self.postsLabel.frame;
            frm.origin.x = 112;
            self.postsLabel.frame = frm;
            
            //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
            
            [self.postsLabel setAlpha:1.0];
            [self.followersLabel setAlpha:0.6];
        }];
        self.tableType = 0;
        [self.profileTableView reloadData];
        if ([postArray count] > 0)
        {
            [self.noPostLabel setHidden:YES];
            [self.view sendSubviewToBack:self.noPostLabel];
        }
        else
        {
            [self.noPostLabel setHidden:NO];
            [self.view bringSubviewToFront:self.noPostLabel];
            self.noPostLabel.text = @"No Posts!";
        }
    }
    
    if (self.didMove)
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
    }
    else
    {
        if (self.postsLabel.center.x <= 110)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 216;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 112;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:145.0/255.0 blue:255.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:1.0];
                [self.followersLabel setAlpha:0.6];
            }];
            self.tableType = 0;
            [self.profileTableView reloadData];
            if ([postArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Posts!";
            }
            return;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frm = self.followersLabel.frame;
                frm.origin.x = 112;
                self.followersLabel.frame = frm;
                
                frm = self.postsLabel.frame;
                frm.origin.x = 7;
                self.postsLabel.frame = frm;
                
                //self.customSelectSegment.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1];
                
                [self.postsLabel setAlpha:0.6];
                [self.followersLabel setAlpha:1.0];
            }];
            self.tableType = 1;
            [self.profileTableView reloadData];
            if ([followerArray count] > 0)
            {
                [self.noPostLabel setHidden:YES];
                [self.view sendSubviewToBack:self.noPostLabel];
            }
            else
            {
                [self.noPostLabel setHidden:NO];
                [self.view bringSubviewToFront:self.noPostLabel];
                self.noPostLabel.text = @"No Followers!";
            }
            return;
        }
    }
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


-(IBAction)removeYoself:(id)sender
{
    [self.dsv3000.dsvWebView loadHTMLString:@"" baseURL:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"toSendfromProfile"])
    {
        DOJOSendViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.postHash = [self.selectedPostForMessageView objectForKey:@"posthash"];
        vc.postDescription = [self.selectedPostForMessageView objectForKey:@"description"];
        vc.isRepost = YES;
        
        NSLog(@"applying properties");
        NSLog(@"in prepare for segue");
    }
    if ([[segue identifier] isEqualToString:@"toSettingsFromProfile"])
    {
        DOJOAccountViewController *vc = [segue destinationViewController];
        vc.profileVC = self;
    }
    if ([[segue identifier] isEqualToString:@"toCommentControllerFromProfile"])
    {
        DOJO32BitMessageView *vc = [segue destinationViewController];
        vc.postInfo = self.selectedPostForMessageView;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
