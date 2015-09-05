//
//  DOJOSampleView.m
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSampleView.h"

@implementation DOJOSampleView

@synthesize linkViewer, postType, imagePost, videoPlayer, selectedPostInfo, userEmail, dojoPostList, postDescription, activeDownloads, activeMovieDownloads, currentPost, zoomable, touchedFirst, touchCount;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [userProperties objectForKey:@"userEmail"];
    
    self.imagePost = [[UIImageView alloc] initWithFrame:self.frame];
    self.imagePost.contentMode = UIViewContentModeScaleAspectFit;
    
    self.videoPlayer = [[MPMoviePlayerController alloc] init];
    
    self.activeDownloads = [[NSMutableArray alloc] init];
    self.activeMovieDownloads = [[NSMutableArray alloc] init];
    
    self.currentPost = [[NSNumber alloc] initWithInteger:0];
    
    self.postDescription = [[UITextView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y+self.frame.size.height-70, self.frame.size.width, 70)];
    
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.imagePost];
    [self addSubview:self.videoPlayer.view];
    [self addSubview:self.postDescription];
    
    self.multipleTouchEnabled = YES;
    
    return self;
}

-(void)initMinor
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [userProperties objectForKey:@"userEmail"];
    
    self.imagePost = [[UIImageView alloc] initWithFrame:self.frame];
    self.imagePost.contentMode = UIViewContentModeScaleAspectFit;
    
    self.activeDownloads = [[NSMutableArray alloc] init];
    self.activeMovieDownloads = [[NSMutableArray alloc] init];
    
    self.currentPost = [[NSNumber alloc] initWithInteger:0];
}

-(void)loadAPost
{
    @try {
        NSString *annotateString = [selectedPostInfo valueForKey:@"description"];
        self.postDescription.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1.0 alpha:1];
        self.postDescription.textColor = [UIColor whiteColor];
        self.postDescription.textAlignment = NSTextAlignmentCenter;
        [self.postDescription setFont:[UIFont fontWithName:@"Avenir Next" size:14]];
        [self.postDescription setEditable:NO];
        
        [self sendSubviewToBack:self.videoPlayer.view];
        
        @try {
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[selectedPostInfo valueForKey:@"email"]] forKeys:@[@"email"]];
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
                    [postDescription setText:[NSString stringWithFormat:@"%@: %@",firstName, annotateString]];
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
        
        
        NSLog(@"POSTHASH is %@",[selectedPostInfo valueForKey:@"posthash"]);
        UIImage *image = [[UIImage alloc] init];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[selectedPostInfo valueForKey:@"posthash"]];
        NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
        if ([fileManager fileExistsAtPath:picPath])
        {
            //load this instead
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
            [self.imagePost setImage:image];
            [self bringSubviewToFront:self.postDescription];
        }
        else
        {
            [self sendSubviewToBack:videoPlayer.view];
            if ([[selectedPostInfo valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
            {
                NSLog(@"well its a movie, downloading thumb");
                if ([self.activeDownloads indexOfObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]] == NSNotFound)
                {
                    NSLog(@"beginning download");
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[selectedPostInfo valueForKey:@"posthash"]];
                    [self.activeDownloads addObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                    NSLog(@"code key is %@",codekeythumb);
                    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                    
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = @"dojopicbucket";
                    self.downloadRequest.key = codekeythumb;
                    self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task)
                     {
                         [self.activeDownloads removeObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                         if (task.error != nil) {
                             NSLog(@"Error: [%@]", task.error);
                             @try {
                                 UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                 [self.imagePost setImage:dlthumb];
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
                             [self.imagePost setImage:dlthumb];
                             [self bringSubviewToFront:self.imagePost];
                             [self bringSubviewToFront:self.postDescription];
                         }
                         return nil;
                     }];
                }
                NSLog(@"nevermind already downloading, will wait");
            }
            else
            {
                if ([self.activeDownloads indexOfObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]] == NSNotFound)
                {
                    NSLog(@"beginning download of image");
                    [self.activeDownloads addObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                    
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = @"dojopicbucket";
                    self.downloadRequest.key = [selectedPostInfo valueForKey:@"posthash"];
                    self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        [self.activeDownloads removeObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                        if (task.error != nil) {
                            NSLog(@"Error: [%@]", task.error);
                            @try {
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [self.imagePost setImage:dlthumb];
                                [self bringSubviewToFront:self.imagePost];
                                [self bringSubviewToFront:self.postDescription];
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
                            [self.imagePost setImage:dlthumb];
                            [self bringSubviewToFront:self.postDescription];
                        }
                        return nil;
                    }];
                    
                }
                NSLog(@"nevermind already downloading image, will wait");
            }
        }
        if ([[selectedPostInfo valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
        {
            if (self.videoPlayer.playbackState == MPMoviePlaybackStatePaused )
            {
                if (!self.isHidden)
                {
                    //[self addSubview:self.videoPlayer.view];
                    [self bringSubviewToFront:self.videoPlayer.view];
                    [self.videoPlayer play];
                    [self bringSubviewToFront:self.postDescription];
                }
            }
            else
            {
                NSLog(@"beginning to load movie process");
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[selectedPostInfo valueForKey:@"posthash"]]]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:selectedPath.path])
                {
                    // init with the cached file
                    NSLog(@"it exists here");
                    self.videoPlayer.contentURL = selectedPath;
                    [self.videoPlayer.view setBackgroundColor:[UIColor blackColor]];
                    [self.videoPlayer prepareToPlay];
                    self.videoPlayer.controlStyle = MPMovieControlStyleNone;
                    [self.videoPlayer.view setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                    //[self.view sen:moviePlayer.view];
                    //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                    [self bringSubviewToFront:self.videoPlayer.view];
                    [self.videoPlayer play];
                    [self bringSubviewToFront:self.postDescription];
                }
                else
                {
                    NSLog(@"does not exist! will test download");
                    if ([self.activeMovieDownloads indexOfObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]] == NSNotFound)
                    {
                        NSLog(@"not currently downloading, now downloading");
                        [self.activeMovieDownloads addObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                        
                        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = [selectedPostInfo valueForKey:@"posthash"];
                        self.downloadRequest.downloadingFileURL = selectedPath;
                        NSLog(@"about to download a movie pirate bryan");
                        [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            [self.activeDownloads removeObject:(NSString *)[selectedPostInfo valueForKey:@"posthash"]];
                            if (task.error != nil)
                            {
                                NSLog(@"Error: [%@]", task.error);
                            } else {
                                NSLog(@"completed download");
                                self.videoPlayer.contentURL = selectedPath;
                                [self.videoPlayer.view setBackgroundColor:[UIColor blackColor]];
                                [self.videoPlayer prepareToPlay];
                                self.videoPlayer.controlStyle = MPMovieControlStyleNone;
                                [self.videoPlayer.view setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                                //[self.view sen:moviePlayer.view];
                                //moviePlayer.repeatMode = MPMovieRepeatModeOne;
                                [self bringSubviewToFront:self.videoPlayer.view];
                                [self.videoPlayer play];
                                [self bringSubviewToFront:self.postDescription];
                            }
                            return nil;
                        }];
                        
                    }
                    NSLog(@"nevermind already downloading, will wait");
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception in sample view load a post is %@",exception);
    }
    @finally {
        //
    }
}

-(void)showNext
{
    [self.videoPlayer stop];
    [self sendSubviewToBack:self.videoPlayer.view];
    NSLog(@"showing next");
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error;
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[selectedPostInfo valueForKey:@"dojohash"]);
        NSString *picID = [selectedPostInfo valueForKey:@"posthash"];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[selectedPostInfo valueForKey:@"dojohash"], picID] forKeys:@[@"email",@"dojohash",@"posthash"]];
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
    @try {
        self.currentPost = [NSNumber numberWithInteger:(self.currentPost.integerValue + 1)];
        if ([dojoPostList count] > self.currentPost.integerValue)
        {
            selectedPostInfo = [dojoPostList objectAtIndex:self.currentPost.integerValue];
            [self loadAPost];
        }
        else
        {
            NSLog(@"out of posts");
            //[self setHidden:YES];
            if ((self.frame.size.height < 90) || (self.frame.size.height > 400))
            {
                [self setHidden:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ayyyy we want some pussaaaaay %@",exception);
    }
    @finally {
        //
    }
}

-(void)play
{
    NSLog(@"DID PLAY");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchCount = self.touchCount + 1;
    NSLog(@"touch count is %ld", (long)self.touchCount);
    self.touchedFirst = [((UITouch *)[touches anyObject]) locationInView:self];
    if (self.zoomable)
    {
        [self.postDescription setHidden:NO];
        if (self.touchCount > 1)
        {
            [self showNext];
            [self.postDescription sizeToFit];
            [self bringSubviewToFront:self.postDescription];
        }
        else
        {
            [self.postDescription sizeToFit];
            [self bringSubviewToFront:self.postDescription];
        }
    }
    else
    {
        [self showNext];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchCount = self.touchCount - 1;
    CGPoint thisTouch = [((UITouch *)[touches anyObject]) locationInView:self];
    if ((thisTouch.y-self.touchedFirst.y) < 10)
    {
        if (self.zoomable)
        {
            [self.postDescription setHidden:YES];
            [self showNext];
        }
    }
    else
    {
        if (self.zoomable)
        {
            [self.postDescription setHidden:YES];
            self.imagePost.frame = CGRectMake(0, 0, 320, 232);
            self.videoPlayer.view.frame = CGRectMake(0, 0, 320, 232);
            self.postDescription.frame = CGRectMake(0, 205, 320, 27);
            [self.delegate didEndZooming];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.zoomable)
    {
        CGPoint currPoint = [((UITouch *)[touches anyObject]) locationInView:self];
        if (currPoint.y > 231)
        {
            NSLog(@"curr Point y is %ld",(long)currPoint.y);
            self.imagePost.frame = CGRectMake(0, 0, self.frame.size.width, currPoint.y-50);
            self.videoPlayer.view.frame = CGRectMake(0, 0, self.frame.size.width, currPoint.y-50);
            self.postDescription.frame = CGRectMake(0, currPoint.y-50, self.frame.size.width, self.postDescription.frame.size.height);
        }
    }
}

@end
