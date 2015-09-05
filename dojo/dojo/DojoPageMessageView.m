//
//  DojoPageMessageView.m
//  dojo
//
//  Created by Michael Zuccarino on 10/29/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DojoPageMessageView.h"
#import "DOJOSpecialDojoPageViewController.h"
#import "DOJODojoPageViewController.h"
#import "DOJOPerformAPIRequest.h"

@interface DojoPageMessageView () <APIRequestDelegate>

@property DOJOSpecialDojoPageViewController *specialVC;
@property DOJODojoPageViewController *dojoVC;

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;
@property (strong, nonatomic) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) AWSS3TransferManager *transferManager;

@property (strong, nonatomic) NSMutableArray *heightArray;

@end

@implementation DojoPageMessageView

@synthesize messageCell, messageCollectionView, boardData, userEmail, dojoData, bongReloader, specialVC, delay, dojoVC, isMoving, tapRecog, initialTouchLocation, refreshSwag, isAPost, postDict, apiBot, downloadRequest, transferManager,backgroundImageView, isCustomReload, heightArray;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.messageCollectionView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.messageCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 15, 0)];
    self.messageCollectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];//[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0];
    // [latestCollectionView registerClass:[CustomCellClass class] forCellWithReuseIdentifier:@"collectCell"];
    [self.messageCollectionView setDelegate:self];
    [self.messageCollectionView setDataSource:self];
    self.messageCollectionView.tag = 2;
    [self.messageCollectionView registerClass:[DOJOMessageCell class] forCellReuseIdentifier:@"messageCellID"];
    self.messageCollectionView.alwaysBounceVertical = YES;
    [self.messageCollectionView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.delay = 0;
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.backgroundImageView setClipsToBounds:YES];
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.messageCollectionView];

    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
    
    self.boardData = [[NSArray alloc] init];
    [self.apiBot loadMessageBoard:dojoData];

    //self.bongReloader = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadTheBoard) userInfo:nil repeats:YES];
    
    self.isMoving = false;
    
    tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInMessageView)];
    tapRecog.delegate = self;
    [self.messageCollectionView addGestureRecognizer:tapRecog];
    /*
    self.refreshSwag = [[UIRefreshControl alloc] init];
    [self.refreshSwag setBackgroundColor:[UIColor colorWithRed:158.0/255.0 green:236.0/255.0 blue:120.0/255.0 alpha:1]];
    [self.refreshSwag setTintColor:[UIColor whiteColor]];
    [self.refreshSwag addTarget:self action:@selector(customReloadTheBoard) forControlEvents:UIControlEventValueChanged];
    [self.messageCollectionView addSubview:self.refreshSwag];
    */
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    return self;
}

-(void)loadedMessageBoard:(NSArray *)swagData
{
    self.boardData = swagData;
    self.heightArray = [[NSMutableArray alloc] init];
    for (int i=0;i<[self.boardData count];i++)
    {
        NSArray *messageArray = [swagData objectAtIndex:i];
        NSDictionary *messageDict = [messageArray objectAtIndex:1];
        NSUInteger strcount = [(NSString *)[messageDict objectForKey:@"message"] length];
        //NSLog(@"%ud is strcount",(unsigned int)strcount);
        CGFloat cellHeight;
        cellHeight = 50;
        
        UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(60, 20, 235, self.frame.size.height-20)];
        [sweg setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
        sweg.text = [messageDict objectForKey:@"message"];
        CGSize newsize = [sweg sizeThatFits:CGSizeMake(235, sweg.contentSize. height)];
        [self.heightArray addObject:[NSNumber numberWithFloat:(newsize.height + 20.0f)]];
    }
    //NSLog(@"board data %@",self.boardData);
    [self.messageCollectionView reloadData];
    [self.refreshSwag endRefreshing];
    //if (self.isCustomReload)
    //{
    if (self.messageCollectionView.contentSize.height > messageCollectionView.bounds.size.height)
    {
        CGPoint bottomOffset = CGPointMake(0, self.messageCollectionView.contentSize.height - self.messageCollectionView.bounds.size.height + 15);
        NSLog(@"BOTTOMOFFSET is %f",bottomOffset.y);
        [self.messageCollectionView setContentOffset:bottomOffset animated:NO];
    }
    //}
    self.isCustomReload = NO;
}

-(void)genericRefresh
{
    self.boardData = [[NSArray alloc] init];
    [self.apiBot loadMessageBoard:dojoData];
    self.delay = 0;
    //self.bongReloader = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadTheBoard) userInfo:nil repeats:YES];
}

-(void)endLoadSesh
{
    [self.bongReloader invalidate];
    self.bongReloader = nil;
}

-(void)initiateTheBongReloader
{
    //self.bongReloader = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reloadTheBoard) userInfo:nil repeats:YES];
}

-(void)tappedInMessageView
{
    [self.delegate detectedTapInMessageView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch event begin, count is %ld",(long) touches.count);
    UITouch *singleTouch = [touches anyObject];
    NSLog(@"single touch is %@",singleTouch);
    self.initialTouchLocation = [singleTouch locationInView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    NSLog(@"touch event ended with %@",aTouch);
    CGPoint currentTouchPosition = [aTouch locationInView:self];
    
    if (fabsf(self.initialTouchLocation.x - currentTouchPosition.x) <= 19 &&
             fabsf(self.initialTouchLocation.y - currentTouchPosition.y) <= 19)
    {
        NSLog(@"tap anywhere");
        // TAP
        [self tappedInMessageView];
        self.initialTouchLocation = CGPointZero;
    }
    
    
    //detect is tap anywhere
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.boardData count] == 0)
    {
        NSLog(@"self.boardData has 0 results");
        return 0;
    }
    else
    {
        return [self.boardData count];
    }
}

-(DOJOMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOMessageCell *cell = (DOJOMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"messageCellID" forIndexPath:indexPath];
    if ([self.boardData count] == 0)
    {
        /*
        //[messageCell setBackgroundColor:[UIColor lightGrayColor]];
        [cell.nameLabel setText:@"dojito"];
        [cell.messageBody setText:@"no messages yet"];
        //[messageCell.messageBody setFrame:CGRectMake(messageCell.frame.size.height, 18, messageCell.frame.size.width-messageCell.frame.size.height, messageCell.frame.size.height-20)];
        [cell.messageBody setScrollEnabled:NO];
        [cell.profPicture setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
        //[messageCell.posttime setFrame:CGRectMake(10, messageCell.frame.size.height-20, messageCell.frame.size.width, 20)];
        
        return cell;
         */
    }
    else
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        NSArray *messageArray = [self.boardData objectAtIndex:indexPath.row];
        NSDictionary *posterDict;
        @try {
            posterDict = [[messageArray objectAtIndex:0] objectAtIndex:0];
        }
        @catch (NSException *exception) {
            posterDict = [[NSDictionary alloc] initWithObjects:@[@"doji@getdojo.co",@"doji"] forKeys:@[@"username",@"fullname"]];
        }
        @finally {
            NSLog(@"finally n shit");
        }
        NSDictionary *messageDict = [messageArray objectAtIndex:1];
        //NSLog(@"user email %@, email is %@\nmade is %@\nmessage is %@",userEmail,[messageDict objectForKey:@"username"],[messageDict objectForKey:@"made"],[messageDict objectForKey:@"message"]);
        
        cell.nameLabel.text = [posterDict objectForKey:@"fullname"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //load user email lols
        NSFileManager *fMan = [NSFileManager defaultManager];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",[posterDict objectForKey:@"profilehash"]]]];
        //[cell.profPicture setFrame:CGRectMake(20, (cell.frame.size.height/2)-25, 40, 40)];
        if ([[posterDict objectForKey:@"username"] isEqualToString:@"doji@getdojo.co"])
        {
            [cell.profPicture setImage:[UIImage imageNamed:@"retweet2.png"]];
            [cell.profPicture setContentMode:UIViewContentModeScaleAspectFit];
        }
        if (([fMan fileExistsAtPath:plistPath]) && !([[posterDict objectForKey:@"username"] isEqualToString:@"doji@getdojo.co"]))
        {
            NSLog(@"picture exists");
            [cell.profPicture setImage:[UIImage imageWithContentsOfFile:plistPath]];
        }
        else
        {
            if ([[posterDict objectForKey:@"username"] isEqualToString:@"doji@getdojo.co"])
            {
                [cell.profPicture setImage:[UIImage imageNamed:@"retweet2.png"]];
                [cell.profPicture setContentMode:UIViewContentModeScaleAspectFit];
            }
            else
            {
                NSString *profilehash = [posterDict objectForKey:@"profilehash"];
                [cell.profPicture.layer  setCornerRadius:14];
                [cell.profPicture.layer setMasksToBounds:YES];
                if ([profilehash isEqualToString:@""])
                {
                    cell.profPicture.image = [UIImage imageNamed:@"whiteicon80.png"];
                    cell.profPicture.contentMode = UIViewContentModeScaleAspectFit;
                }
                else
                {
                    
                    NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                    NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
                    UIImage *image = [[UIImage alloc] init];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                    {
                        image = [[UIImage alloc] initWithContentsOfFile:picPath];
                        [cell.profPicture setImage:image];
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
                                    [cell.profPicture setImage:dlthumb];
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
                                [cell.profPicture setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                }
            }
        }
        
        [cell.messageBody setFrame:CGRectMake(60, 20, 235, cell.frame.size.height-15)];
        
        //[cell.nameLabel setFrame:CGRectMake(85, 10, cell.frame.size.width-110, 20)];
        [cell.nameLabel sizeToFit];
        
        [cell.messageBody setText:[messageDict objectForKey:@"message"]];
        [cell.messageBody setScrollEnabled:NO];

        CGSize newsize = [cell.messageBody sizeThatFits:CGSizeMake(235, cell.messageBody.contentSize. height)];
        [cell.messageBody setFrame:CGRectMake(60, 20, newsize.width, newsize.height)];
        
        NSLog(@"length is %ld",(long)[[messageDict objectForKey:@"message"] length]);
        if ([[messageDict objectForKey:@"message"] length] > ([[messageDict objectForKey:@"fullname"] length] + 20))
        {
            [cell.background setFrame:CGRectMake(55, 7,  cell.messageBody.frame.size.width+10, cell.frame.size.height-5)];
        }
        else
        {
            [cell.background setFrame:CGRectMake(55, 7, cell.nameLabel.frame.size.width+20, cell.frame.size.height-5)];
        }
        
        return cell;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select");
    //[dojoVC magnifyMessageBoard];
    //[specialVC magnifyMessageBoard];
    [self.delegate cellSelected];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%@>>CALL SIZE FOR CELL", indexPath);
    if ([self.boardData count] == 0)
    {
        return 80;
    }
    
    //CGSize secondSize = sweg.frame.size;
    
    
    return [[self.heightArray objectAtIndex:indexPath.row] floatValue];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

-(void)loadedCommentBoard:(NSArray *)commentData
{
    self.boardData = commentData;
    self.heightArray = [[NSMutableArray alloc] init];
    for (int i=0;i<[self.boardData count];i++)
    {
        NSArray *messageArray = [commentData objectAtIndex:i];
        NSDictionary *messageDict = [messageArray objectAtIndex:1];
        NSUInteger strcount = [(NSString *)[messageDict objectForKey:@"message"] length];
        //NSLog(@"%ud is strcount",(unsigned int)strcount);
        CGFloat cellHeight;
        cellHeight = 50;
        
        UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(60, 20, 235, self.frame.size.height-20)];
        [sweg setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
        sweg.text = [messageDict objectForKey:@"message"];
        CGSize newsize = [sweg sizeThatFits:CGSizeMake(235, sweg.contentSize. height)];
        [self.heightArray addObject:[NSNumber numberWithFloat:(newsize.height + 20.0f)]];
    }
    //NSLog(@"HEIGHT ARRAY IS %@",self.heightArray);
    
    [messageCollectionView reloadData];
    [messageCollectionView setScrollEnabled:YES];
    [self.refreshSwag endRefreshing];
    if (self.messageCollectionView.contentSize.height > messageCollectionView.bounds.size.height)
    {
        CGPoint bottomOffset = CGPointMake(0, self.messageCollectionView.contentSize.height - self.messageCollectionView.bounds.size.height +15);
        NSLog(@"BOTTOMOFFSET is %f",bottomOffset.y);
        [self.messageCollectionView setContentOffset:bottomOffset animated:YES];
    }
    self.isCustomReload = NO;
}

-(void)customReloadTheBoard
{
    NSLog(@"board reloaded");
    self.isCustomReload = YES;
    self.boardData = [[NSArray alloc] init];
    if (self.isAPost)
    {
        NSLog(@"SWAGSWAG IS A POST");
        [self.apiBot loadCommentBoard:self.postDict];
    }
    else
    {
        [self.apiBot loadMessageBoard:dojoData];
    }
}

-(void)reloadTheBoard
{
    if (self.delay < 2)
    {
        self.delay = self.delay + 1;
    }
    else
    {
        if (!self.isMoving)
        {
            self.isCustomReload = NO;
            NSLog(@"board reloaded");
            self.boardData = [[NSArray alloc] init];
            @try {
                if (self.isAPost)
                {
                    NSLog(@"SWAGSWAG IS A POST");
                    [self.apiBot loadCommentBoard:self.postDict];
                }
                else
                {
                    [self.apiBot loadMessageBoard:dojoData];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"auto reload the board test exception %@",exception);
            }
            @finally {
                
            }
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scroll view did scroll");
    self.isMoving = true;
    [self.delegate messageViewWasScrolled];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isMoving = false;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isMoving = false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
