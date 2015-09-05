//
//  DOJONotificationViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/27/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJONotificationViewController.h"
#import "DOJOHomeTableViewController.h"
#import "DOJOCommentCell.h"
#import "DOJOCreateCell.h"
#import "DOJOFollowCell.h"
#import "DOJOPostCell.h"

@interface DOJONotificationViewController () <UITableViewDataSource, UITableViewDelegate, PeekDelegate, UISearchBarDelegate, CommentcellDelegate, CreateCellDelegate, FollowCellDelegate, PostCellDelegate, HomeTableViewDelegate>

@property dispatch_queue_t profileQueue;

@property (strong, nonatomic) AWSS3TransferManager *transferManager;

@property (strong, nonatomic) NSMutableArray *heightArray;
@property (strong, nonatomic) NSMutableArray *attributeArray;

@end

@implementation DOJONotificationViewController

@synthesize notiTableView, notificationFeedData, dojoSearchBar, fileManager, documentsDirectory, currentLocation, refresh, downloadRequest, delegate, startPoint, didPerformSwipeMovement, isSearching, apiBot, transferManager, heightArray, attributeArray, temporaryDirectory;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    temporaryDirectory = NSTemporaryDirectory();
    fileManager = [NSFileManager defaultManager];
    
    currentLocation = [[CLLocation alloc] init];
    
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh setTintColor:[UIColor whiteColor]];
    [self.refresh setBackgroundColor:((DOJOHomeTableViewController *)self.parentViewController).topHeaderView.backgroundColor];
    [self.refresh addTarget:self action:@selector(genericRefresh) forControlEvents:UIControlEventValueChanged];
    
    [self.notiTableView addSubview:refresh];
    self.notiTableView.canCancelContentTouches = NO;
    self.notiTableView.delegate = self;
    self.notiTableView.dataSource = self;
    self.notiTableView.touchDelegate = self;
    
    self.profileQueue = dispatch_queue_create("notiProfileQueue", DISPATCH_QUEUE_SERIAL);
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
    
    [self.refresh setBackgroundColor:((DOJOHomeTableViewController *)self.parentViewController).topHeaderView.backgroundColor];
    
    self.didPerformSwipeMovement = NO;
    self.isSearching = NO;
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)genericRefresh
{
    if (self.isSearching)
    {
        NSLog(@"SERACH TEXT is %@",self.dojoSearchBar.text);
        [self.apiBot getNotificationList:self.dojoSearchBar.text];
    }
    else
    {
        [self.apiBot getNotificationList:@""];
    }
}

-(void)reloadNotificationFeed
{
    //NSLog(@"by location");
    [self.refresh setBackgroundColor:((DOJOHomeTableViewController *)self.parentViewController).topHeaderView.backgroundColor];
    
    [self.refresh endRefreshing];
}

-(void)receivedSearchData:(NSArray *)searchData
{
    if ([self.dojoSearchBar.text isEqualToString:@""])
    {
        notificationFeedData = [searchData objectAtIndex:0];
        NSString *countString = [NSString stringWithFormat:@"%@",[searchData objectAtIndex:1]];
        DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)self.parentViewController;
        if ([countString isEqualToString:@"0"])
        {
            [homeVC.numberUndeadLabel setHidden:YES];
        }
        else
        {
            if (![countString isEqualToString:@"(null)"])
            {
                homeVC.numberUndeadLabel.text = [NSString stringWithFormat:@"%@ new",countString];
                [homeVC.numberUndeadLabel setHidden:NO];
            }
        }
        //NSLog(@"NOTIFICATION GET FEED LIST IS \n%@",notificationFeedData);
        
        self.heightArray = [[NSMutableArray alloc] init];
        self.attributeArray = [[NSMutableArray alloc] init];
        for (int i =0; i<[notificationFeedData count];i++)
        {
            NSArray *interim = [notificationFeedData objectAtIndex:i];
            CGFloat holder = 0;
            ////NSLog(@"interm is %@",interim);
            NSString *feedType = [[interim objectAtIndex:0] objectForKey:@"type"];
            NSLog(@"Feed type: %@, with interim: %@",feedType,interim);
            if ([feedType isEqualToString:@"comment"])
            {
                UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(57, 14, 197, 36)];
                NSString *stringterim = [[[interim objectAtIndex:3] objectAtIndex:0] objectForKey:@"message"];
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                
                NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",stringterim]];
                NSDictionary *attributesGray = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]};
                [bodyText addAttributes:attributesGray range:NSMakeRange(0, bodyText.length)];
                [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, bodyText.length)];
                
                [strAttName appendAttributedString:bodyText];
                sweg.attributedText = strAttName;
                CGSize newsize = [sweg sizeThatFits:CGSizeMake(197, sweg.contentSize. height)];
                CGSize secondSize = sweg.frame.size;
                holder = 69 + (newsize.height - 40);
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"bio"])
            {
                UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(57, 29, 193, 36)];
                NSString *stringterim = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"bio"];
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                
                NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",stringterim]];
                NSDictionary *attributesGray = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]};
                [bodyText addAttributes:attributesGray range:NSMakeRange(0, bodyText.length)];
                [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, bodyText.length)];
                
                [strAttName appendAttributedString:bodyText];
                sweg.attributedText = strAttName;
                CGSize newsize = [sweg sizeThatFits:CGSizeMake(193, sweg.contentSize. height)];
                CGSize secondSize = sweg.frame.size;
                holder = 69 + (newsize.height - 30);
                
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"message"])
            {
                UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(57, 14, 220, 36)];
                NSString *stringterim = [[[interim objectAtIndex:2] objectAtIndex:0] objectForKey:@"message"];
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                
                NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",stringterim]];
                NSDictionary *attributesGray = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]};
                [bodyText addAttributes:attributesGray range:NSMakeRange(0, bodyText.length)];
                [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, bodyText.length)];
                
                [strAttName appendAttributedString:bodyText];
                sweg.attributedText = strAttName;
                CGSize newsize = [sweg sizeThatFits:CGSizeMake(220, sweg.contentSize. height)];
                CGSize secondSize = sweg.frame.size;
                holder = 69 + (newsize.height - 40);
                
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"create"])
            {
                holder = 75;
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"post"])
            {
                UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(56, 9, 193, 36)];
                NSString *stringterim = [NSString stringWithFormat:@"%@",[[[interim objectAtIndex:3] objectAtIndex:0] objectForKey:@"description"]];
                
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                
                NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",stringterim]];
                NSDictionary *attributesGray = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]};
                [bodyText addAttributes:attributesGray range:NSMakeRange(0, bodyText.length)];
                [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, bodyText.length)];
                
                [strAttName appendAttributedString:bodyText];
                sweg.attributedText = strAttName;
                
                CGSize newsize = [sweg sizeThatFits:CGSizeMake(193, sweg.contentSize. height)];
                CGSize secondSize = sweg.frame.size;
                holder = 73 + (newsize.height - 40);
                
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"followyou"])
            {
                holder = 78;
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"repost"])
            {
                UITextView *sweg = [[UITextView alloc] initWithFrame:CGRectMake(56, 9, 193, 36)];
                NSString *stringterim = [NSString stringWithFormat:@"%@",[[[interim objectAtIndex:3] objectAtIndex:0] objectForKey:@"description"]];
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                
                NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",stringterim]];
                NSDictionary *attributesGray = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]};
                [bodyText addAttributes:attributesGray range:NSMakeRange(0, bodyText.length)];
                [bodyText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, bodyText.length)];
                
                [strAttName appendAttributedString:bodyText];
                sweg.attributedText = strAttName;
                
                CGSize newsize = [sweg sizeThatFits:CGSizeMake(193, sweg.contentSize. height)];
                CGSize secondSize = sweg.frame.size;
                holder = 69 + (newsize.height - 40);
                
                [self.attributeArray addObject:strAttName];
            }
            else if ([feedType isEqualToString:@"followdojo"])
            {
                // uses create cell
                holder = 78;
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                [self.attributeArray addObject:strAttName];
            }
            else
            {
                //return 55;
                holder = 55;
                
                NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
                
                NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
                [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
                NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
                [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
                
                NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
                [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
                
                [strAttName appendAttributedString:strRestString];
                [self.attributeArray addObject:strAttName];
            }
            [self.heightArray addObject:[NSNumber numberWithFloat:holder]];
        }
        
        [self.refresh endRefreshing];
        [self.notiTableView reloadData];
    }
    else
    {
        NSLog(@"is **** me");
        notificationFeedData = searchData;
        [self.notiTableView reloadData];
        [self.refresh endRefreshing];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notificationFeedData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)
    {
        NSLog(@"heightforsearch");
        return 81;
    }
    else
    {
        return  [[self.heightArray objectAtIndex:indexPath.row] floatValue];
    }
    //****ing objective C compiler is a ****ing tard sometimes
    return 55;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)
    {
        DOJONotificationCell *cell = (DOJONotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        cell.peekButton.delegate = self;
        cell.delegate = self;
        cell.peekButton.postNumber = indexPath.row;
        cell.peekButton.sectionMajor = indexPath.section;
        cell.peekButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.contentView.tag = indexPath.row;
        
        //[cell.contentView setUserInteractionEnabled:NO];
        
        NSArray *interim = [notificationFeedData objectAtIndex:indexPath.row];
        ////NSLog(@"interm is %@",interim);
        NSDictionary *userData = [interim objectAtIndex:1];
        NSString *feedType = [interim objectAtIndex:0];
        NSDictionary *target = [interim objectAtIndex:2];
        [cell.requestIcon setHidden:YES];
        
        if ([feedType isEqualToString:@"dojo"])
        {
            cell.majorLabel.text = [NSString stringWithFormat:@"%@",[[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"dojo"]];
            cell.majorLabel.frame = CGRectMake(70, 14, 250, 21);
            [cell.peekButton setFrame:CGRectMake(15, 14, 44, 44)];
            cell.postTextLabel.frame = CGRectMake(70, 29, 200, 43);
            cell.majorLabel.numberOfLines = 2;
            cell.postTextLabel.numberOfLines  = 2;
            cell.majorLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.postTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.requestIcon setHidden:NO];
            cell.postTextLabel.text = [NSString stringWithFormat:@"%@ members, %@ you know joined",[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:2],[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:3]];
            [cell.peekButton setImage:[UIImage imageNamed:@"dojoarches.png"] forState:UIControlStateNormal];
            [cell.peekButton setHidden:NO];
            [cell.peekButton.layer setCornerRadius:22];
            cell.peekButton.clipsToBounds = YES;
            cell.peekButton.layer.masksToBounds = YES;
            cell.peekButton.contentMode = UIViewContentModeScaleAspectFit;
            cell.peekButton.backgroundColor = [UIColor colorWithRed:0.123 green:0.467 blue:0.89 alpha:1.0];
        }
        else if ([feedType isEqualToString:@"person"])
        {
            cell.majorLabel.text = [NSString stringWithFormat:@"%@",[[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"fullname"]];
            cell.majorLabel.frame = CGRectMake(70, 14, 219, 21);
            [cell.peekButton setFrame:CGRectMake(15, 14, 44, 44)];
            cell.postTextLabel.frame = CGRectMake(70, 29, 200, 43);
            cell.majorLabel.numberOfLines = 2;
            cell.postTextLabel.numberOfLines  = 2;
            cell.majorLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.postTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.requestIcon setHidden:NO];
            [cell.peekButton setHidden:NO];
            [cell.peekButton.layer setCornerRadius:22];
            cell.peekButton.clipsToBounds = YES;
            cell.peekButton.layer.masksToBounds = YES;
            cell.peekButton.contentMode = UIViewContentModeScaleAspectFit;
            cell.postTextLabel.text = [NSString stringWithFormat:@"%@ followers, joined %@ dojos",[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:2],[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:3]];
            NSString *profilehash = [[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.peekButton setImage:[UIImage imageNamed:@"iconwhite120.png"] forState:UIControlStateNormal];
                cell.peekButton.contentMode = UIViewContentModeScaleAspectFit;
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.peekButton setImage:image forState:UIControlStateNormal];
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
                                [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
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
                            [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
                        }
                        return nil;
                    }];
                }
            }
        }
        else
        {
            cell.majorLabel.frame = CGRectMake(14, 2, 298, 36);
            cell.postTextLabel.frame = CGRectMake(14, 38, 219, 38);
            [cell.peekButton setFrame:CGRectMake(268, 3, 44, 44)];
            cell.majorLabel.numberOfLines = 2;
            cell.postTextLabel.numberOfLines  = 2;
            cell.majorLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.postTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.majorLabel sizeToFit];
            [cell.postTextLabel sizeToFit];
            [cell.peekButton setImage:[UIImage imageNamed:@"dojoarches.png"] forState:UIControlStateNormal];
            [cell.peekButton setHidden:NO];
            [cell.peekButton.layer setCornerRadius:22];
            cell.peekButton.clipsToBounds = YES;
            cell.peekButton.layer.masksToBounds = YES;
            cell.peekButton.contentMode = UIViewContentModeScaleAspectFit;
            cell.peekButton.backgroundColor = [UIColor colorWithRed:0.123 green:0.467 blue:0.89 alpha:1.0];
            NSString *posterName = [userData objectForKey:@"fullname"];
            NSString *actionString = ([feedType isEqualToString:@"post"] ?  @"posted to": @"created");
            NSString *targetString = [target objectForKey:@"dojo"];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@",posterName,actionString,targetString]];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0] range:NSMakeRange(0, posterName.length+1)];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0] range:NSMakeRange(posterName.length+1, actionString.length+1)];
            [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0] range:NSMakeRange(actionString.length+posterName.length+2,targetString.length)];
            cell.majorLabel.attributedText = str;
            cell.postTextLabel.text = @"";
            //[cell.peekButton setHidden:YES];
        }
        
        return cell;
    }
    else
    {
        NSArray *interim = [notificationFeedData objectAtIndex:indexPath.row];
        ////NSLog(@"interm is %@",interim);
        NSString *feedType = [[interim objectAtIndex:0] objectForKey:@"type"];
        if ([feedType isEqualToString:@"comment"])
        {
            DOJOCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
            //cell.commentLabel.text = [NSString stringWithFormat:@"\"%@\"",[[[interim objectAtIndex:3] objectAtIndex:0] objectForKey:@"message"]];
            
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.postPicView.alpha = 1;
            
            cell.postPicView.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            
            //cell.payloadLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;
            
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.commentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                cell.commentLabel.backgroundColor = [UIColor whiteColor];
            }*/
            
            cell.commentLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            CGSize newsize = [cell.commentLabel sizeThatFits:CGSizeMake(193, cell.commentLabel.contentSize.height)];
            CGRect frame = CGRectMake(57, 14, 193, newsize.height);
            cell.commentLabel.frame = frame;
            frame.size.height = cell.commentLabel.contentSize.height;
            cell.commentLabel.frame = frame;
            
            cell.timeLabel.text = [interim objectAtIndex:5];
            frame = cell.timeLabel.frame;
            frame.origin.y = cell.frame.size.height - frame.size.height - 5;
            cell.timeLabel.frame = frame;
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            
            
            NSString *posthash = [[[interim objectAtIndex:2] objectAtIndex:0] objectForKey:@"posthash"];
            if ([posthash rangeOfString:@"text"].location != NSNotFound)
            {
                // is string
                UIImage *segmentImage = [UIImage imageNamed:@"convowhite.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(54, 54),NO,0.0);
                [segmentImage drawInRect:CGRectMake(3, 20, 48, 35)];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [cell.postPicView setImage:resizedImage];
                
            }
            else
            {
                UIImage *image = [[UIImage alloc] init];
                
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",posthash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                if ([fileManager fileExistsAtPath:picPath])
                {
                    //load this instead
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.postPicView setImage:image];
                }
                else
                {
                    //NSLog(@"pulling image for row %ld", (long)indexPath.row);
                    //NSLog(@"codekey is %@",posthash);
                    if ([posthash rangeOfString:@"clip"].location == 0)
                    {
                        NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",posthash];
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = codekeythumb;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postPicView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postPicView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                    else
                    {
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = posthash;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postPicView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postPicView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                }
            }
            [cell.postPicView setFrame:CGRectMake(257, 12, 54, 54)];
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            frm = cell.commentLabel.frame;
            frm.size.width = 197;
            cell.commentLabel.frame = frm;
            frm = cell.payloadLabel.frame;
            frm.size.width = 197;
            cell.payloadLabel.frame = frm;
            return cell;
        }
        else if ([feedType isEqualToString:@"message"])
        {
            DOJOCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
            //cell.commentLabel.text = [NSString stringWithFormat:@"\"%@\"",[[[interim objectAtIndex:2] objectAtIndex:0] objectForKey:@"message"]];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.timeLabel.text = [interim objectAtIndex:4];
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            
            cell.postPicView.alpha = 0;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
            cell.commentLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            frm = cell.timeLabel.frame;
            frm.origin.y = cell.contentView.frame.size.height - cell.timeLabel.frame.size.height - 5;
            cell.timeLabel.frame = frm;
            
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.commentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                cell.commentLabel.backgroundColor = [UIColor whiteColor];
            }
            */
            CGSize newsize = [cell.commentLabel sizeThatFits:CGSizeMake(193, cell.commentLabel.contentSize.height)];
            CGRect frame = CGRectMake(57, 14, 193, newsize.height);
            cell.commentLabel.frame = frame;
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            frm = cell.commentLabel.frame;
            frm.size.width = 230;
            cell.commentLabel.frame = frm;
            frm = cell.payloadLabel.frame;
            frm.size.width = 230;
            cell.payloadLabel.frame = frm;
            return cell;
        }
        else if ([feedType isEqualToString:@"bio"])
        {
            DOJOCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
            //cell.commentLabel.text = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"bio"];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.postPicView.image = nil;
            
            cell.postPicView.backgroundColor = [UIColor whiteColor];
            
            //cell.commentLabel.textColor = [UIColor colorWithWhite:0.7 alpha:0.9];
            
            cell.timeLabel.text = [interim objectAtIndex:2];
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
        
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
            cell.commentLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;            
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.commentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                cell.commentLabel.backgroundColor = [UIColor whiteColor];
            }*/
            
            CGSize newsize = [cell.commentLabel sizeThatFits:CGSizeMake(193, cell.commentLabel.contentSize.height)];
            CGRect frame = CGRectMake(57, 14, 193, newsize.height);
            cell.commentLabel.frame = frame;
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            return cell;
        }
        else if ([feedType isEqualToString:@"create"])
        {
            DOJOCreateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.timeLabel.text = [interim objectAtIndex:5];
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
           cell.payloadLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;            
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            */
            
            cell.dojoName.text = [[[interim objectAtIndex:2] objectAtIndex:0] objectForKey:@"dojo"];
            cell.followerNumber.text = [NSString stringWithFormat:@"%@ followers",[interim objectAtIndex:3]];
            cell.postNumber.text = [NSString stringWithFormat:@"%@ posts",[interim objectAtIndex:4]];
            
            [cell.dojoIconView setFrame:CGRectMake(8, 15, 40, 40)];
            return cell;
        }
        else if ([feedType isEqualToString:@"post"])
        {
            DOJOPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.timeLabel.text = [interim objectAtIndex:4];
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            if (![payString isEqualToString:@""])
            {
                NSRange namearea = [payString rangeOfString:posterName];
                NSString *restOfString = payString;
                
                NSLog(@">>> NAME IS %@",posterName);
                NSLog(@">>> RESTOFSTRING IS %@",restOfString);
                
                cell.shitbutton.tag = indexPath.row;
            }
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            */
            
            NSDictionary *postDict = [[interim objectAtIndex:3] objectAtIndex:0];
            //NSLog(@"POSTHASH is %@",[postDict valueForKey:@"posthash"]);
            //latest
            
            cell.descriptionLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            //cell.descriptionLabel.text = [NSString stringWithFormat:@"\"%@\"",[postDict objectForKey:@"description"]];
            CGSize newsize = [cell.descriptionLabel sizeThatFits:CGSizeMake(193, cell.descriptionLabel.contentSize.height)];
            CGRect frame = CGRectMake(56, 9, 193, newsize.height);
            cell.descriptionLabel.frame = frame;
            //cell.descriptionLabel.textColor = [UIColor colorWithWhite:0.7 alpha:0.9];
            if (![payString isEqualToString:@""])
            {
                //cell.descriptionLabel.text = [NSString stringWithFormat:@"\"%@\"",[postDict objectForKey:@"description"]];
                CGRect frm = cell.descriptionLabel.frame;
                frm.origin.y = 9;
                cell.descriptionLabel.frame = frm;
            }
            else
            {
                CGRect frm = cell.descriptionLabel.frame;
                frm.origin.y = 13;
                cell.descriptionLabel.frame = frm;
            }
            
            NSString *posthash = [postDict valueForKey:@"posthash"];
            if ([posthash rangeOfString:@"text"].location != NSNotFound)
            {
                // is string
                UIImage *segmentImage = [UIImage imageNamed:@"convowhite.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(54, 54),NO,0.0);
                [segmentImage drawInRect:CGRectMake(3, 20, 48, 35)];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [cell.postView setImage:resizedImage];
            }
            else
            {
                UIImage *image = [[UIImage alloc] init];
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[postDict valueForKey:@"posthash"]];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory
                                                                      stringByAppendingPathComponent:picNameCache]];
                
                if ([fileManager fileExistsAtPath:picPath])
                {
                    //load this instead
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.postView setImage:image];
                }
                else
                {
                    //NSLog(@"pulling image for row %ld", (long)indexPath.row);
                    //NSLog(@"codekey is %@",posthash);
                    if ([posthash rangeOfString:@"clip"].location == 0)
                    {
                        NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",posthash];
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = codekeythumb;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                    else
                    {
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = posthash;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                }
            }
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            [cell.postView setFrame:CGRectMake(257, 12, 54, 54)];
            return cell;
        }
        else if ([feedType isEqualToString:@"followyou"])
        {
            DOJOFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            */
            
            cell.timeLabel.text = [interim objectAtIndex:5];
            
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
            cell.payloadLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;            
            cell.nameLabel.text = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            cell.pointNumber.text = [NSString stringWithFormat:@"%@ followers",[interim objectAtIndex:4]];
            cell.postNumber.text = [NSString stringWithFormat:@"%@ posts",[interim objectAtIndex:2]];
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            return cell;
        }
        else if ([feedType isEqualToString:@"repost"])
        {
            DOJOPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            cell.timeLabel.text = [interim objectAtIndex:4];
            
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            /*
            if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
            */
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSDictionary *postDict = [[interim objectAtIndex:3] objectAtIndex:0];
            //NSLog(@"POSTHASH is %@",[postDict valueForKey:@"posthash"]);
            //latest
            /*
            cell.descriptionLabel.text = [postDict objectForKey:@"description"];
            CGRect frame = cell.descriptionLabel.frame;
            frame.size.height = cell.descriptionLabel.contentSize.height;
            cell.descriptionLabel.frame = frame;
             */
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
            cell.descriptionLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;            
            //cell.descriptionLabel.text = [NSString stringWithFormat:@"\"%@\"",[postDict objectForKey:@"description"]];
            CGSize newsize = [cell.descriptionLabel sizeThatFits:CGSizeMake(193, cell.descriptionLabel.contentSize.height)];
            CGRect frame = CGRectMake(56, 9, 193, newsize.height);
            cell.descriptionLabel.frame = frame;
            //cell.descriptionLabel.textColor = [UIColor colorWithWhite:0.7 alpha:0.9];
            if ([payString rangeOfString:@"liked"].location == NSNotFound)
            {
                //cell.descriptionLabel.text = [NSString stringWithFormat:@"\"%@\"",[postDict objectForKey:@"description"]];
                CGRect frm = cell.descriptionLabel.frame;
                frm.origin.y = 9;
                cell.descriptionLabel.frame = frm;
            }
            else
            {
                CGRect frm = cell.descriptionLabel.frame;
                frm.origin.y = 13;
                cell.descriptionLabel.frame = frm;
            }
            
            NSString *posthash = [postDict valueForKey:@"posthash"];
            if ([posthash rangeOfString:@"text"].location != NSNotFound)
            {
                // is string
                UIImage *segmentImage = [UIImage imageNamed:@"convowhite.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(54, 54),NO,0.0);
                [segmentImage drawInRect:CGRectMake(3, 20, 48, 35)];
                UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [cell.postView setImage:resizedImage];
            }
            else
            {
                UIImage *image = [[UIImage alloc] init];
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[postDict valueForKey:@"posthash"]];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            
                if ([fileManager fileExistsAtPath:picPath])
                {
                    //load this instead
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.postView setImage:image];
                }
                else
                {
                    //NSLog(@"pulling image for row %ld", (long)indexPath.row);
                    //NSLog(@"codekey is %@",posthash);
                    if ([posthash rangeOfString:@"clip"].location == 0)
                    {
                        NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",posthash];
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = codekeythumb;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                    else
                    {
                        
                        self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        self.downloadRequest.bucket = @"dojopicbucket";
                        self.downloadRequest.key = posthash;
                        self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                        
                        [[self.transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                            if (task.error != nil) {
                                //NSLog(@"Error: [%@]", task.error);
                                @try {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.postView setImage:dlthumb];
                                }
                                @catch (NSException *exception) {
                                    //NSLog(@"exception executor %@",exception);
                                }
                                @finally {
                                    //NSLog(@"ran through try block executor");
                                }
                            } else {
                                //NSLog(@"completed download");
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.postView setImage:dlthumb];
                            }
                            return nil;
                        }];
                    }
                }
            }
            
            NSString *profilehash = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"profilehash"];
            if ([profilehash isEqualToString:@""])
            {
                [cell.profilePicView setImage:[UIImage imageNamed:@"whitedojoface90.png"]];
            }
            else
            {
                NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
                NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
                UIImage *image = [[UIImage alloc] init];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
                {
                    image = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [cell.profilePicView setImage:image];
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
                                [cell.profilePicView setImage:dlthumb];
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
                            [cell.profilePicView setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
            [cell.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
            [cell.postView setFrame:CGRectMake(257, 12, 54, 54)];
            return cell;
        }
        else if ([feedType isEqualToString:@"followdojo"])
        {
            // uses create cell
            DOJOCreateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.tag = indexPath.row;
            
            CGRect frm = cell.customDivider.frame;
            frm.origin.y = cell.contentView.frame.size.height - 2;
            cell.customDivider.frame = frm;
            
            /*if ((indexPath.row+1) % 2)
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            }
             */
            
            cell.timeLabel.text = [interim objectAtIndex:5];
            CGRect frame2 = cell.timeLabel.frame;
            frame2.origin.y = cell.frame.size.height - frame2.size.height - 5;
            cell.timeLabel.frame = frame2;
            
            NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
            
            NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
            NSRange namearea = [payString rangeOfString:posterName];
            NSString *restOfString = payString;
            
            NSLog(@">>> NAME IS %@",posterName);
            NSLog(@">>> RESTOFSTRING IS %@",restOfString);
            
            cell.payloadLabel.attributedText = [self.attributeArray objectAtIndex:indexPath.row];
            cell.shitbutton.tag = indexPath.row;            
            cell.dojoName.text = [[[interim objectAtIndex:2] objectAtIndex:0] objectForKey:@"dojo"];
            cell.followerNumber.text = [NSString stringWithFormat:@"%@ followers",[interim objectAtIndex:3]];
            cell.postNumber.text = [NSString stringWithFormat:@"%@ posts",[interim objectAtIndex:4]];
            
            [cell.dojoIconView setFrame:CGRectMake(8, 15, 40, 40)];
            return cell;
        }
        else
        {
            //return 55;
        }
    }
    
    UITableViewCell *cell;
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.dojoSearchBar isFirstResponder])
    {
        [self.dojoSearchBar resignFirstResponder];
    }
}

-(void)selectRow:(NSInteger)row
{
    NSLog(@"selected row %ld",(long)row);
}

/*
 -(void)swipeStarted;
 -(void)swipeIsMoving:(NSNumber *)distance;
 -(void)swipeLetGo;
 */

-(void)swipeStarted
{
    [self.delegate swipeStartedMAJOR];
    self.didPerformSwipeMovement = NO;
}

-(void)swipeIsMoving:(NSNumber *)distance
{
    NSLog(@"swipe is moving");
    //self.notiTableView.userInteractionEnabled = NO;
    [self.delegate swipeIsMovingMAJOR:distance];
    self.didPerformSwipeMovement = YES;
}

-(void)swipeLetGoforRow:(NSInteger)row
{
    NSLog(@"touch ended with noti VC");
    DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)self.parentViewController;
    if (self.isSearching)
    {
        NSLog(@"Allowed tap for searching");
        if (!self.didPerformSwipeMovement)
        {
            [self selectRow:row];
            DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)self.parentViewController;
            NSArray *interim = [notificationFeedData objectAtIndex:row];
            NSLog(@"interm is %@",interim);
            ////NSLog(@"interm is %@",interim);
            NSDictionary *userData = [interim objectAtIndex:1];
            NSString *feedType = [interim objectAtIndex:0];
            NSDictionary *target = [interim objectAtIndex:2];
            if ([feedType isEqualToString:@"create"])
            {
                homeVC.selectedDojoInfo = target;
                [homeVC performSegueWithIdentifier:@"toRevo" sender:homeVC];
            }
            else if ([feedType isEqualToString:@"friend"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Request" message:[NSString stringWithFormat:@"%@ added you as a friend",[[[notificationFeedData objectAtIndex:row]objectAtIndex:1] objectForKey:@"fullname"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Cool", nil];
                alert.tag = row;
                [alert show];
            }
            else if ([feedType isEqualToString:@"person"])
            {
                NSDictionary *selectedPerson = [[notificationFeedData objectAtIndex:row] objectAtIndex:1];
                NSLog(@"selected person is %@",selectedPerson);
                homeVC.selectedPerson = selectedPerson;
                [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
                [homeVC performSegueWithIdentifier:@"toPersonFromHome" sender:homeVC];
            }
            else if ([feedType isEqualToString:@"dojo"])
            {
                homeVC.selectedDojoInfo = [[notificationFeedData objectAtIndex:row] objectAtIndex:1];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:homeVC];
            }
        }
    }
    else
    {
        NSLog(@"Allowed tap for not searching");
        if (!self.didPerformSwipeMovement)
        {
            DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)self.parentViewController;
            NSArray *interim = [notificationFeedData objectAtIndex:row];
            ////NSLog(@"interm is %@",interim);
            NSString *feedType = [[interim objectAtIndex:0] objectForKey:@"type"];
            NSLog(@"feedType is %@",feedType);
            if ([feedType isEqualToString:@"comment"])
            {
                NSDictionary *dojo = [[interim objectAtIndex:4] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                homeVC.selectedHashForDojo = [[interim objectAtIndex:0] objectForKey:@"target"];
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
            else if ([feedType isEqualToString:@"bio"])
            {
                NSDictionary *person = [[interim objectAtIndex:1] objectAtIndex:0];
                homeVC.selectedPerson = person;
                [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
                [homeVC performSegueWithIdentifier:@"toPersonFromHome" sender:self];
            }
            else if ([feedType isEqualToString:@"message"])
            {
                NSDictionary *dojo = [[interim objectAtIndex:3] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
            else if ([feedType isEqualToString:@"create"])
            {
                NSDictionary *dojo = [[interim objectAtIndex:2] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
            else if ([feedType isEqualToString:@"post"])
            {
                NSDictionary *dojo = [[interim objectAtIndex:2] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                homeVC.selectedHashForDojo = [[interim objectAtIndex:0] objectForKey:@"subject"];
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
            else if ([feedType isEqualToString:@"followyou"])
            {
                NSDictionary *person = [[interim objectAtIndex:1] objectAtIndex:0];
                homeVC.selectedPerson = person;
                NSLog(@"selected person is %@",person);
                [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
                [homeVC performSegueWithIdentifier:@"toPersonFromHome" sender:homeVC];
            }
            else if ([feedType isEqualToString:@"repost"])
            {
                NSDictionary *dojo = [[interim objectAtIndex:2] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                homeVC.selectedHashForDojo = [[interim objectAtIndex:0] objectForKey:@"subject"];
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
            else if ([feedType isEqualToString:@"followdojo"])
            {
                // uses create cell
                NSDictionary *dojo = [[interim objectAtIndex:2] objectAtIndex:0];
                homeVC.selectedDojoInfo = dojo;
                [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
                [homeVC performSegueWithIdentifier:@"toRevo" sender:self];
            }
        }
    }
    //self.notiTableView.userInteractionEnabled = YES;
    self.didPerformSwipeMovement = NO;
    [self.delegate swipeLetGoMAJOR];
}

-(void)swipeCanceled
{
    self.didPerformSwipeMovement = NO;
}

-(void)homeTableViewTouchStarted:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate homeTableViewTouchStarted2:touches withEvent:event];
}

-(void)homeTableViewTouchSwiping:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate homeTableViewTouchSwiping2:touches withEvent:event];
    [self.notiTableView setScrollEnabled:NO];
    [self.dojoSearchBar resignFirstResponder];
}

-(void)homeTableViewTouchCancelled
{
    [self.delegate homeTableViewTouchCancelled2];
        [self.notiTableView setScrollEnabled:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((int)buttonIndex == 1)
    {
        //TAKE RIGHT EMAIL BASED OFF TAG
        NSString *selectedEmail = @"";
        if (self.isSearching)
        {
            selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        }
        else
        {
            selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        }
        //NSLog(@"selected email is %@", selectedEmail);
        
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],selectedEmail] forKeys:@[@"user1",@"user2"]];
        //NSLog(@"ALERT>> dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%schangeFriendRequestStatus.php",SERVERADDRESS]]];
        
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
        NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
        //NSLog(@"DECODED STRING IS %@", decodedString);
        
        [self genericRefresh];
        
    }
    if ((int)buttonIndex == 0)
    {
        //TAKE RIGHT EMAIL BASED OFF TAG
        NSString *selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        //NSLog(@"selected email is %@", selectedEmail);
        
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],selectedEmail] forKeys:@[@"email1",@"email2"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sremoveFriend.php",SERVERADDRESS]]];
        
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
        NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
        //NSLog(@"DECODED STRING IS %@", decodedString);
        
        [self genericRefresh];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCH BEGAIN IN NOTI VIEW CONTROLLER");
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.isSearching = NO;
    [self genericRefresh];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:@""])
    {
        [searchBar setShowsCancelButton:NO];
        //[self.notiTableView reloadData];
    }
    else
    {
        [searchBar setShowsCancelButton:YES];
    }
    return YES;
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isSearching = YES;
    [self genericRefresh];
}

-(IBAction)shitNameTap:(UIButton *)senderBender
{
    NSLog(@"clicked button is %d",(int)senderBender.tag);
    DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)self.parentViewController;

    
    NSArray *interim = [notificationFeedData objectAtIndex:senderBender.tag];
    CGFloat holder = 0;
    ////NSLog(@"interm is %@",interim);
    NSString *feedType = [[interim objectAtIndex:0] objectForKey:@"type"];
    NSLog(@"Feed type: %@, with interim: %@",feedType,interim);
    NSDictionary *selectedPerson= [[NSDictionary alloc] init];
    selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    /*
    if ([feedType isEqualToString:@"comment"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"bio"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"message"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"create"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"post"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"followyou"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
    }
    else if ([feedType isEqualToString:@"repost"])
    {
        selectedPerson = [[interim objectAtIndex:1] objectAtIndex:0];
        
    }
    else if ([feedType isEqualToString:@"followdojo"])
    {
        // uses create cell
        holder = 78;
        
        NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
        
        NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
        NSRange namearea = [payString rangeOfString:posterName];
        NSString *restOfString = payString;
        
        NSLog(@">>> NAME IS %@",posterName);
        NSLog(@">>> RESTOFSTRING IS %@",restOfString);
        
        NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
        [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
        NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
        [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
        
        NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
        [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
        
        [strAttName appendAttributedString:strRestString];
        [self.attributeArray addObject:strAttName];
    }
    else
    {
        //return 55;
        holder = 55;
        
        NSString *posterName = [[[interim objectAtIndex:1] objectAtIndex:0] objectForKey:@"fullname"];
        
        NSString *payString = [[interim objectAtIndex:0] objectForKey:@"payload"];
        NSRange namearea = [payString rangeOfString:posterName];
        NSString *restOfString = payString;
        
        NSLog(@">>> NAME IS %@",posterName);
        NSLog(@">>> RESTOFSTRING IS %@",restOfString);
        
        NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",posterName]];
        [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0] range:NSMakeRange(0, posterName.length)];
        NSDictionary *attributesBlue = @ {NSForegroundColorAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
        [strAttName addAttributes:attributesBlue range:NSMakeRange(0, posterName.length)];
        
        NSMutableAttributedString *strRestString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",restOfString]];
        [strRestString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0] range:NSMakeRange(0, restOfString.length)];
        
        [strAttName appendAttributedString:strRestString];
        [self.attributeArray addObject:strAttName];
    }
*/
    
    
    
    NSLog(@"selected person is %@",selectedPerson);
    homeVC.selectedPerson = selectedPerson;
    [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
    [homeVC performSegueWithIdentifier:@"toPersonFromHome" sender:homeVC];
}

/*
-(void)tapBegan:(NSInteger)selectedPost withSectionMajor:(NSInteger)sectionMajor withSectionMinor:(NSInteger)sectionMinor
{
    NSLog(@"tap began");
}

-(void)tapEnded
{
    NSLog(@"tap Ended");
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
