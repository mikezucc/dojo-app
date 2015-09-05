//
//  DOJODojoPageViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJODojoPageViewController.h"
#import "DOJOCellButton.h"

@interface DOJODojoPageViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, scrolled, CellButtonTouchEventDelegate>

@end

@implementation DOJODojoPageViewController

@synthesize latestCollectionView, dojoPageData, dojoPostList, selectedTag, tappedData, trackOfLoaded, dojoData, selectedSection, selectedPost, magnifyVC, messageButton, downloadRequest, messageReceivedArr, dojoSettingsVC, messageViewBox, receivedDataArray, readButton, fieldContainer, messageField, blurredView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"before super view did load");
    [super viewDidLoad];
    NSLog(@"after super view did load");
    // Do any additional setup after loading the view.
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    trackOfLoaded = [[NSMutableArray alloc] init];
    
    //perform pre segue property application here
    UICollectionViewFlowLayout *latestLayout = [[UICollectionViewFlowLayout alloc] init];
    [latestLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [latestLayout setMinimumInteritemSpacing:0];
    [latestLayout setMinimumLineSpacing:0];
    latestCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) collectionViewLayout:latestLayout];
    latestCollectionView.backgroundColor = [UIColor whiteColor];
    // [latestCollectionView registerClass:[CustomCellClass class] forCellWithReuseIdentifier:@"collectCell"];
    [latestCollectionView setDelegate:self];
    [latestCollectionView setDataSource:self];
    latestCollectionView.tag = 1;
    [latestCollectionView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"collectCell"];
    //latestCollectionView.alwaysBounceHorizontal = YES;
    //latestCollectionView.alwaysBounceVertical = YES;
    latestCollectionView.pagingEnabled = YES;
    [self.view addSubview:latestCollectionView];
    
    //set navigation controller title
    NSString *dojoName = [[NSString alloc] initWithFormat:@"%@",[dojoData valueForKey:@"dojo"]];
    [self.navigationItem setTitle:dojoName];
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
    NSLog(@"dojoData being written is %@",dojoData);
    [dojoData writeToFile:plistPath atomically:YES];
    
    
    UIImage *infoButton = [UIImage imageNamed:@"info-butt.png"];
    UIImageView *infoButtonFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    infoButtonFrame.image = infoButton;
    // [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadCollectionViewSelector)] animated:YES];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.messageViewBox.dojoData = dojoData;
    self.messageViewBox = [self.messageViewBox initWithFrame:CGRectMake(20, 260, 280, 190)];
    self.preventJumping = NO;
    
    self.messageViewBox.delegate = self;
    //[self.fieldContainer.layer setCornerRadius:10];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *virginityPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"virginity.plist"]];
    NSMutableDictionary *virginDict = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:virginityPath])
    {
        virginDict = [[NSMutableDictionary alloc] initWithContentsOfFile:virginityPath];
        NSLog(@"virgindict is %@",virginDict);
        if ([[virginDict valueForKey:@"DojoVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. You made it! This is a Dojo. Tap the chat to push a message or tap the images to see a post. You can change the name, passcode, privacy, and add friends through Settings. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"DojoVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. You made it! This is a Dojo. Tap the chat to push a message or tap the images to see a post. You can change the name, passcode, privacy, and add friends through Settings. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"DojoVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [messageViewBox.bongReloader invalidate];
    messageViewBox.bongReloader = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[dojoData valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[dojoData valueForKey:@"dojohash"]] forKeys:@[@"email",@"dojohash"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoPostList.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        receivedDataArray = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        dojoPostList = [receivedDataArray objectAtIndex:0];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"GET POST LIST IS \n%@",dojoPostList);
        NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        
        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojopostALL.plist"]];
        [dojoPostList writeToFile:plistPath atomically:YES];
        
        [self.latestCollectionView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue");
    }
    @finally {
    }
    @try {
        [self.messageViewBox reloadTheBoard];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"hmm" message:@"reload the messageboard" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through reload board block");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"collectiontag == %ld",(long)collectionView.tag);
    if ([dojoPostList count] > 0)
    {
        // for the latest view collection
        return [dojoPostList count];
    }
    else
    {
        return 1;
    }
}

-(DOJOPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    postCell.tag = indexPath.row;
    postCell.indexPath = indexPath;
    postCell.clipsToBounds = YES;
    DOJOPostCollectionViewCell *tempCell;
    postCell.cellButton.touchEventDelegate = self;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error;
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[dojoData valueForKey:@"dojohash"]);
        NSString *picID = [[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[dojoData valueForKey:@"dojohash"], picID] forKeys:@[@"email",@"dojohash",@"posthash"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssetPostToSeen.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            @try {
                NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"SET POST TO SEEN RETURNED: %@",dataFromRequest);
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through asynch");
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through try set post to seen");
    }
    for (tempCell in [collectionView visibleCells])
    {
        [tempCell.moviePlayer stop];
    }
    if ([dojoPostList count] >0)
    {
        NSLog(@"returning cell for %@",indexPath);
        NSLog(@"POSTHASH is %@",[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
        UIImage *image = [[UIImage alloc] init];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
        NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
        postCell.cellFace.frame = collectionView.frame;
        postCell.cellButton.frame = collectionView.frame;
        NSLog(@"clip location %lu",(unsigned long)[[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location);
        if ([fileManager fileExistsAtPath:picPath])
        {
            [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
            //load this instead
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
            [postCell.cellFace setImage:image];
            if ([[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
            {
                UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
                [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
                CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [postCell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
            }
            else
            {
                [postCell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
            if ([[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
            {
                [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
                NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
                NSLog(@"code key is %@",codekeythumb);
                AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = codekeythumb;
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.cellFace setImage:dlthumb];
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
                        [postCell.cellFace setImage:dlthumb];
                    }
                    return nil;
                }];
                UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
                [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
                CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [postCell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
                
            }
            else
            {
                AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = [[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"];
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.cellFace setImage:dlthumb];
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
                        [postCell.cellFace setImage:dlthumb];
                    }
                    return nil;
                }];
                [postCell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            }
            
        }
        if ([[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
        {
            NSLog(@"pulling image for row %ld", (long)indexPath.row);
            NSLog(@"codekey is %@",[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
            UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
            [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
            CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
            UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [postCell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
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
        
        [postCell.cellFace setContentMode:UIViewContentModeScaleAspectFill];
        postCell.cellButton.tag = indexPath.row;
        [postCell.cellButton setTitle:[NSString stringWithFormat:@"%ld",(long)collectionView.tag] forState:UIControlStateNormal];
        [postCell.contentView bringSubviewToFront:postCell.cellButton];
        
        NSString *annotateString = [[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"description"];
        
        if (postCell.frame.size.height == self.view.frame.size.height)
        {
            postCell.cellDescription = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
            postCell.cellDescription.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1.0 alpha:1];
            postCell.cellDescription.textColor = [UIColor whiteColor];
            postCell.cellDescription.textAlignment = NSTextAlignmentNatural;
            [postCell.cellDescription setFont:[UIFont fontWithName:@"Avenir Next" size:14]];
            [postCell.cellDescription setEditable:NO];
            
            @try {
                NSError *error;
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[[dojoPostList objectAtIndex:indexPath.row] valueForKey:@"email"]] forKeys:@[@"email"]];
                NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetUserInfo.php",SERVERADDRESS]]];
                
                //customize request information
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:result];
                
                error = nil;
                
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                    NSString *firstName;
                    @try {
                        NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                        NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
                        
                        firstName = [[dataFromRequest objectAtIndex:0] valueForKey:@"firstname"];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"exception is %@",exception);
                        firstName = @"A friend:";
                    }
                    @finally {
                        NSLog(@"ran through asynch block");
                    }
                    [postCell.cellDescription setText:[NSString stringWithFormat:@"%@: %@",firstName, annotateString]];
                }];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@", exception);
            }
            @finally {
                NSLog(@"ran through name poster retrieval block");
            }
            
            [postCell.contentView addSubview:postCell.cellDescription];
        }
        else
        {
            [postCell.contentView sendSubviewToBack:postCell.cellDescription];
        }
        postCell.cellButton.tag = indexPath.row;
        //[postCell.cellButton addTarget:self action:@selector(magnifyCell:) forControlEvents:UIControlEventTouchDown];
        [postCell.cellButton setTitle:@"" forState:UIControlStateNormal];
        return postCell;
    }
    else
    {
        [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [postCell.cellButton setTitle:@"no posts!" forState:UIControlStateNormal];
        [postCell.cellButton setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1]];
        return postCell;
    }
}

-(void)playMovie:(UIButton *)button
{
    NSLog(@"pulling image for row %ld", (long)button.tag);
    NSLog(@"codekey is %@",[[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //[postCell.cellFace setImage:nil];
    NSString *picNameCache = [NSString stringWithFormat:@"downloaded.mov"];
    NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:picPath error:nil];
    }
    
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[latestCollectionView cellForItemAtIndexPath:iPath];
    if ([[[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
    {
        if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
        {
            [postCell.moviePlayer pause];
            [postCell.cellButton setTitle:@"paused" forState:UIControlStateNormal];
            [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
        {
            [postCell.moviePlayer play];
            [postCell.cellButton setTitle:@"" forState:UIControlStateNormal];
            [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [postCell.cellButton setTitle:@"loading" forState:UIControlStateNormal];
            [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [postCell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            /*if ([[postCell.cellButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] != 0)
             {
             [postCell.cellButton removeTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             //[postCell.cellButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
             }*/
            
            NSData *data = [[NSData alloc] init];
            UIImage *image = [[UIImage alloc] init];
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            
            self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
            self.downloadRequest.bucket = @"dojopicbucket";
            self.downloadRequest.key = [[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"];
            self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
            NSLog(@"about to download a movie pirate bryan");
            __weak DOJOPostCollectionViewCell *postCellWeak = postCell;
            [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                } else {
                    
                    if ([[self.latestCollectionView indexPathsForVisibleItems] containsObject:postCellWeak.indexPath])
                    {
                        NSLog(@"completed download");
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"downloaded.mov"]];
                        postCell.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:selectedPath];
                        [postCell.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
                        [postCell.moviePlayer prepareToPlay];
                        postCell.moviePlayer.controlStyle = MPMovieControlStyleNone;
                        [postCell.moviePlayer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-70)];
                        //[self.view sen:moviePlayer.view];
                        //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                        [postCell.contentView addSubview:postCell.moviePlayer.view];
                        [postCell.contentView bringSubviewToFront:postCell.cellButton];
                        [postCell.moviePlayer play];
                        [postCell.contentView bringSubviewToFront:postCell.cellDescription];
                        [postCell.cellButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
                return nil;
            }];
        }
    }
}

-(void)cellSelected
{
    [self magnifyMessageBoard];
}

-(void)swipeUpEvent:(NSInteger)selectedButton
{
    NSLog(@"button swipe up event from %ld",(long)selectedButton);
}

-(void)plagnifyEvent:(NSInteger)selectedButton withSection:(NSInteger)section
{
    NSLog(@"button plagnify event from %ld",(long)selectedButton);
    UIButton *button = [[UIButton alloc] init];
    button.tag = selectedButton;
    [self magnifyCell:button];
}

-(void)magnifyMessageBoard
{
    NSLog(@"DOJO magnify THAT shit");
    if (messageViewBox.bounds.size.height > 350)
    {
        [UIView animateWithDuration:0.6 animations:^{
            [self.view addSubview:self.messageViewBox];
            [self.blurredView setAlpha:0];
            [self.latestCollectionView setAlpha:1];
            /*
             UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)messageViewBox.messageCollectionView.collectionViewLayout;
             //flow.itemSize = CGSizeMake(self.view.frame.size.width, 250);
             UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
             new = flow;
             [latestCollectionView.collectionViewLayout invalidateLayout];
             [latestCollectionView setCollectionViewLayout:new];
             */
            messageViewBox.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [messageViewBox.messageCollectionView setBackgroundColor:[UIColor whiteColor]];
            [messageViewBox setFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height-300)];
            [messageViewBox.messageCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, messageViewBox.frame.size.height)];
            [fieldContainer setHidden:YES];
            [messageField resignFirstResponder];
            //[self.blurredView setImage:[UIImage imageNamed:@"invisible.png"]];
            [messageViewBox.messageCollectionView reloadData];
        } completion:^(BOOL completed){
        }];
        //[messageViewBox setFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height-300)];
    }
    else
    {
        self.blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width+15, self.view.frame.size.height)];
        DOJOPostCollectionViewCell *tempCell;
        for (tempCell in [latestCollectionView visibleCells])
        {
            [tempCell.moviePlayer stop];
        }
        if ([[latestCollectionView visibleCells] count] == 1)
        {
            tempCell = [[latestCollectionView visibleCells] objectAtIndex:0];
        }
        UIImage *uiBeginImage = (UIImage *)tempCell.cellFace.image;
        UIImageOrientation originalOrientation = uiBeginImage.imageOrientation;
        CIImage *inputImage = [[CIImage alloc] initWithCGImage:[uiBeginImage CGImage]];
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setDefaults];
        [blurFilter setValue:inputImage forKey:@"inputImage"];
        [blurFilter setValue:[NSNumber numberWithDouble:6.00f] forKey:@"inputRadius"];
        CIImage *blurredImage = [blurFilter outputImage];
        CIContext* context = [CIContext contextWithOptions:nil];
        CGImageRef imgRef = [context createCGImage:blurredImage fromRect:self.view.frame] ;
        UIImage* img = [[UIImage alloc] initWithCGImage:imgRef scale:0.5 orientation:originalOrientation];
        CGImageRelease(imgRef);
        self.blurredView.image = img;
        [self.blurredView setAlpha:0];
        [UIView animateWithDuration:0.6 animations:^{
            [self.view addSubview:self.messageViewBox];
            [self.blurredView setAlpha:1];
            [self.latestCollectionView setAlpha:0];
            /*
             UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)messageViewBox.messageCollectionView.collectionViewLayout;
             //flow.itemSize = CGSizeMake(self.view.frame.size.width, 250);
             UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
             new = flow;
             [latestCollectionView.collectionViewLayout invalidateLayout];
             [latestCollectionView setCollectionViewLayout:new];*/
            [self.view addSubview:self.blurredView];
            [messageViewBox.messageCollectionView setBackgroundColor:[UIColor clearColor]];
            [messageViewBox setBackgroundColor:[UIColor clearColor]];
            [messageViewBox setFrame:CGRectMake(0, 0, 288, self.view.frame.size.height-87)];
            [messageViewBox.messageCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, messageViewBox.frame.size.height)];
            [self.view addSubview:self.messageViewBox];
            [fieldContainer setHidden:NO];
            [self.view addSubview:self.fieldContainer];
            [messageViewBox.messageCollectionView reloadData];
        } completion:^(BOOL completed){
        }];
    }
}

-(void)magnifyCell:(UIButton *)button
{
    NSLog(@"magnify the cell");
    DOJOPostCollectionViewCell *tempCell;
   /* for (tempCell in [latestCollectionView visibleCells])
    {
        [tempCell.moviePlayer stop];
    }
    */

    NSIndexPath *iPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
    DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[latestCollectionView cellForItemAtIndexPath:iPath];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [postCell.cellButton addGestureRecognizer:swipeGesture];
    
    if ([[latestCollectionView visibleCells] count] == 0)
    {
        tempCell = [[latestCollectionView visibleCells] objectAtIndex:0];
    }
    if (latestCollectionView.bounds.size.height == self.view.frame.size.height)
    {
        if ([[[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
        {
            if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
            {
                [postCell.moviePlayer pause];
                [postCell.cellButton setTitle:@"paused" forState:UIControlStateNormal];
                [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else if (postCell.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
            {
                [postCell.moviePlayer play];
                [postCell.cellButton setTitle:@"" forState:UIControlStateNormal];
            }
            else
            {
                NSLog(@"pulling image for row %ld", (long)button.tag);
                NSLog(@"codekey is %@",[[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"]);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                //[postCell.cellFace setImage:nil];
                NSString *picNameCache = [NSString stringWithFormat:@"downloaded.mov"];
                NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:picPath error:nil];
                }
                [postCell.cellButton setTitle:@"loading" forState:UIControlStateNormal];
                [postCell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [postCell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                /*if ([[postCell.cellButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] != 0)
                 {
                 [postCell.cellButton removeTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
                 //[postCell.cellButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
                 }*/
                
                NSData *data = [[NSData alloc] init];
                UIImage *image = [[UIImage alloc] init];
                AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = [[dojoPostList objectAtIndex:button.tag] valueForKey:@"posthash"];
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                NSLog(@"about to download a movie pirate bryan");
                __weak DOJOPostCollectionViewCell *postCellWeak = postCell;
                [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                    } else {
                        
                        if ([[self.latestCollectionView indexPathsForVisibleItems] containsObject:postCellWeak.indexPath])
                        {
                            NSLog(@"completed download");
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"downloaded.mov"]];
                            postCell.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:selectedPath];
                            [postCell.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
                            [postCell.moviePlayer prepareToPlay];
                            postCell.moviePlayer.controlStyle = MPMovieControlStyleNone;
                            [postCell.moviePlayer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-70)];
                            //[self.view sen:moviePlayer.view];
                            //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                            [postCell.contentView addSubview:postCell.moviePlayer.view];
                            [postCell.contentView bringSubviewToFront:postCell.cellButton];
                            [postCell.moviePlayer play];
                            [postCell.contentView bringSubviewToFront:postCell.cellDescription];
                            [postCell.cellButton setTitle:@"" forState:UIControlStateNormal];
                        }
                    }
                    return nil;
                }];
            }
        }
    }
    else
    {
        [self.view addSubview:self.latestCollectionView];
        UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)latestCollectionView.collectionViewLayout;
        flow.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
        new = flow;
        [latestCollectionView.collectionViewLayout invalidateLayout];
        [latestCollectionView setCollectionViewLayout:new];
        [UIView animateWithDuration:0.2 animations:^{
            [latestCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [latestCollectionView reloadData];
        } completion:^(BOOL completed){
        }];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSLog(@"user email is %@",[dojoData valueForKey:@"dojohash"]);
    NSString *picID = [[dojoPostList objectAtIndex:tempCell.tag] valueForKey:@"posthash"];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[dojoData valueForKey:@"dojohash"], picID] forKeys:@[@"email",@"dojohash",@"posthash"]];
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssetPostToSeen.php",SERVERADDRESS]]];
    
    //customize request information
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:result];
    
    NSURLResponse *response = nil;
    error = nil;
    
    //fire the request and wait for response
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        @try {
            NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"SET POST TO SEEN RETURNED: %@",dataFromRequest);
        }
        @catch (NSException *exception) {
            NSLog(@"exception is %@", exception);
        }
        @finally {
            NSLog(@"ran through asynch block");
        }
    }];
}

-(void)shrinkCell:(UISwipeGestureRecognizer *)swipeGesture
{
    DOJOPostCollectionViewCell *tempCell;
    for (tempCell in [latestCollectionView visibleCells])
    {
        [self.downloadRequest cancel];
        [tempCell.moviePlayer stop];
    }
    [self.view addSubview:self.latestCollectionView];
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)latestCollectionView.collectionViewLayout;
    flow.itemSize = CGSizeMake(self.view.frame.size.width, 300);
    UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
    new = flow;
    [latestCollectionView.collectionViewLayout invalidateLayout];
    [latestCollectionView setCollectionViewLayout:new];
    [UIView animateWithDuration:0.2 animations:^{
        [latestCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        [latestCollectionView reloadData];
    } completion:^(BOOL completed){
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOPostCollectionViewCell *postCell;
    for (int i; i<[latestCollectionView numberOfItemsInSection:0]; i++)
    {
        NSIndexPath *iPath = [NSIndexPath indexPathForRow:i inSection:0];
        postCell = (DOJOPostCollectionViewCell *)[self.latestCollectionView cellForItemAtIndexPath:iPath];
        [postCell.moviePlayer stop];
    }
}

-(BOOL)textShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self scrollDown];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if ([textView.text isEqualToString:@""])
        {
            
        }
        else
        {
            //post message
            NSString *hash = [self generateCode];
            NSLog(@"dojoData read as %@",dojoData);
            NSError *error;
            
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh-mm"];
            NSString *resultString = [dateFormatter stringFromDate: currentTime];
            NSLog(@"time posted is %@",resultString);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoData objectForKey:@"dojohash"],[userProperties objectForKey:@"userEmail"],hash,textView.text, resultString] forKeys:@[@"dojohash",@"email",@"messagehash",@"message",@"made"]];
            NSLog(@"dictionary is :%@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSLog(@"encoded json is %@",result);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssubmitMessage.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
            NSLog(@"data .count is %ld", (long)dataDict.count);
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            error = nil;
            
            //fire the request and wait for response
            result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"%@",result);
            NSLog(@"%@",dataConv);
            NSLog(@"%@",decodedString);
            if ([decodedString rangeOfString:@"posted"].location == NSNotFound)
            {
                // not posted
                NSLog(@"exception message is %@",decodedString);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"could not post!" message:@"send us this error report" delegate:self cancelButtonTitle:@"nah" otherButtonTitles:@"sure", nil];
                [av show];
            }
            else
            {
                [messageField setText:@""];
            }
            [messageViewBox reloadTheBoard];
            return NO;
        }
    }
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 200 || returnKey;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%dx %dy prevent:%@", (int)fieldContainer.frame.origin.x, (int)fieldContainer.frame.origin.y,self.preventJumping);
    NSLog(@"BEGINcenter is %fl",self.fieldContainer.center.y);
    if (self.fieldContainer.center.y > 300)
    {
        if ([self.messageField.text isEqualToString:@"type something..."])
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
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"couldnt post ur messg" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"did end editing ran through block");
    }
}

-(void)detectedTapInMessageView
{
    NSLog(@"detected tap in message view dojo page");
    [self magnifyMessageBoard];
}

-(void)messageViewWasScrolled
{
    NSLog(@"scrolllllld");
    [messageField resignFirstResponder];
    //[self scrollDown];
}

-(void)scrollUp
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, -220));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.fieldContainer setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1.0]];
    [UIView commitAnimations];
}

-(void)scrollDown
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, 220));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    [self.fieldContainer setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [UIView commitAnimations];
}

- (NSString *)generateCode
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
    NSLog(@"s-->%@",s);
    return s;
}

-(IBAction)reloadCollectionViewSelector
{
   // [latestCollectionView reloadData];
   // [previousCollectionView reloadData];
    
    [self.storyboard instantiateViewControllerWithIdentifier:@"settingsVC"];
    [self performSegueWithIdentifier:@"toSettings" sender:self];
}

/*
// old protocol
-(void)magnifyImage:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"button tag is %ld",(long)button.tag);
    selectedTag = button.tag;
    selectedSection = button.titleLabel.text;
    NSLog(@"title is %@",selectedSection);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojopostALL.plist"]];
    NSArray *loadedPostList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSLog(@"loadedPostList at index %ld is %@",(long)selectedTag, loadedPostList);
    selectedPost = [loadedPostList objectAtIndex:(long)selectedTag];
    NSLog(@"selectedPost at index %ld is %@",(long)selectedTag, selectedPost);
    
    magnifyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"magnifyVC"];
    [self performSegueWithIdentifier:@"toMagnifyVC" sender:self];
}
 */

-(IBAction)showMessageController:(id)sender
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"messageBoard"];
    [self performSegueWithIdentifier:@"toMessageBoard" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isMovie;
    if ([[[segue destinationViewController] class] isEqual:[DOJOMessageBoardViewController class]])
    {
        NSLog(@"is of the same class");
        DOJOMessageBoardViewController *vc = [segue destinationViewController];
        vc.dojoData = dojoData;
    }
    else if ([[segue identifier] isEqualToString:@"toSettings"])
    {
        dojoSettingsVC = [segue destinationViewController];
        dojoSettingsVC.dojoData = dojoData;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
