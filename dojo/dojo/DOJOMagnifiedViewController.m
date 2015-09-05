//
//  DOJOMagnifiedViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMagnifiedViewController.h"
#import "DOJOCellButton.h"

@interface DOJOMagnifiedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CellButtonTouchEventDelegate>

@end

@implementation DOJOMagnifiedViewController

@synthesize fMan, totalPostList, dojoData, downloadRequest, latestCollectionView, userEmail, selectedPostIndex, playContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.playContent = NO;
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
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDaFreshest.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *knob;
                totalPostList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&knob];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"GET POST LIST IS \n%@",totalPostList);
                NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                
                NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojopostALL.plist"]];
                [totalPostList writeToFile:plistPath atomically:YES];
                
                [self.latestCollectionView reloadData];
                NSLog(@"selectedPostIndex is %ld",(long)selectedPostIndex);
                //[latestCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedPostIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue");
    }
    @finally {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [userProperties objectForKey:@"userEmail"];
    
    //perform pre segue property application here
    UICollectionViewFlowLayout *latestLayout = [[UICollectionViewFlowLayout alloc] init];
    [latestLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [latestLayout setMinimumInteritemSpacing:0];
    [latestLayout setMinimumLineSpacing:0];
    latestCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:latestLayout];
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
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"collectiontag == %ld",(long)collectionView.tag);
    // for the latest view collection
    return [totalPostList count];

}

-(DOJOPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
    postCell.tag = indexPath.row;
    postCell.clipsToBounds = YES;
    postCell.cellButton.touchEventDelegate = self;
    DOJOPostCollectionViewCell *tempCell;
    for (tempCell in [collectionView visibleCells])
    {
        [self.downloadRequest cancel];
        [tempCell.moviePlayer stop];
    }
    
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error;
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[dojoData valueForKey:@"dojohash"]);
        NSString *picID = [[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"];
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
    NSLog(@"POST RESUTS IS %@", [totalPostList objectAtIndex:indexPath.row]);
    NSString *annotateString = [[totalPostList objectAtIndex:indexPath.row] valueForKey:@"description"];
    
    postCell.cellDescription = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, self.view.frame.size.width, 70)];
    postCell.cellDescription.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1.0 alpha:1];
    postCell.cellDescription.textColor = [UIColor whiteColor];
    postCell.cellDescription.textAlignment = NSTextAlignmentNatural;
    [postCell.cellDescription setFont:[UIFont fontWithName:@"Avenir Next" size:14]];
    [postCell.cellDescription setEditable:NO];
    
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"email"]] forKeys:@[@"email"]];
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
            @try {
                NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
                
                NSString *firstName = [[dataFromRequest objectAtIndex:0] valueForKey:@"firstname"];
                [postCell.cellDescription setText:[NSString stringWithFormat:@"%@: %@",firstName, annotateString]];
                [postCell.contentView addSubview:postCell.cellDescription];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@", exception);
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@", exception);
    }
    @finally {
        NSLog(@"ran through name poster retrieval block");
    }
    

    if ([totalPostList count] >0)
    {
        NSLog(@"returning cell for %@",indexPath);
        NSLog(@"POSTHASH is %@",[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
        UIImage *image = [[UIImage alloc] init];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
        NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
        postCell.cellFace.frame = collectionView.frame;
        postCell.cellButton.frame = collectionView.frame;
        NSLog(@"clip location %lu",(unsigned long)[[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location);
        if ([fileManager fileExistsAtPath:picPath])
        {
            [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
            //load this instead
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
            [postCell.cellFace setImage:image];
            if ([[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
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
            if ([[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
            {
                
                [postCell.contentView sendSubviewToBack:postCell.moviePlayer.view];
                NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
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
                        [postCell.contentView addSubview:postCell.cellDescription];
                    }
                    return nil;
                }];
                
            }
            else
            {
                AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                
                self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                self.downloadRequest.bucket = @"dojopicbucket";
                self.downloadRequest.key = [[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"];
                self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                
                [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error != nil) {
                        NSLog(@"Error: [%@]", task.error);
                        @try {
                            UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                            [postCell.cellFace setImage:dlthumb];
                            [postCell.contentView addSubview:postCell.cellDescription];
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
                        [postCell.contentView addSubview:postCell.cellDescription];
                    }
                    return nil;
                }];
                //[postCell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            }
            
        }
        if ([[[totalPostList objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
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
        postCell.cellButton.tag = indexPath.row;
        [postCell.cellFace setContentMode:UIViewContentModeScaleAspectFill];
        
        [postCell.contentView addSubview:postCell.cellDescription];
        [postCell.contentView bringSubviewToFront:postCell.cellButton];
        postCell.indexPath = indexPath;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}

-(void)plagnifyEvent:(NSInteger)selectedButton withSection:(NSInteger)section
{
    UIButton *button = [[UIButton alloc] init];
    button.tag = selectedButton;
    [self playMovie:button];
}

-(void)playMovie:(UIButton *)button
{
    NSLog(@"pulling image for row %ld", (long)button.tag);
    NSLog(@"codekey is %@",[[totalPostList objectAtIndex:button.tag] valueForKey:@"posthash"]);
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
    if ([[[totalPostList objectAtIndex:button.tag] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
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
            self.downloadRequest.key = [[totalPostList objectAtIndex:button.tag] valueForKey:@"posthash"];
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
        if ([[virginDict valueForKey:@"MagnifyVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is Magnify, which lets you take a quick peek into the latest posts in a Dojo without opening it all the way up <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"MagnifyVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is Magnify, which lets you take a quick peek into the latest posts in a Dojo without opening it all the way up <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"MagnifyVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    NSLog(@"seleceted post index is %ld",(long)selectedPostIndex);
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:selectedPostIndex inSection:0];
    @try {
            [latestCollectionView scrollToItemAtIndexPath:iPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally {
        NSLog(@"cant be ****ing fancy these days");
    }
    NSLog(@"scroolll");
    //[latestCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:selectedPostIndex inSection:0]]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    DOJOPostCollectionViewCell *postCell;
    for (int i; i<[latestCollectionView numberOfItemsInSection:0]; i++)
    {
        NSIndexPath *iPath = [NSIndexPath indexPathForRow:i inSection:0];
        postCell = (DOJOPostCollectionViewCell *)[self.latestCollectionView cellForItemAtIndexPath:iPath];
        [postCell.moviePlayer stop];
    }
}

-(IBAction)tapRemoveController:(id)sender
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
