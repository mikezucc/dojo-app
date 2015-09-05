//
//  DOJOSendTableViewBox.m
//  dojo
//
//  Created by Michael Zuccarino on 7/20/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSendTableViewBox.h"
#import "DOJOSendViewController.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOSendTableViewBox () <APIRequestDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOSendTableViewBox

@synthesize sendCell, searchTableView, userEmail, nameList, isSearching , dataConv, dojoTableViewData, selectedList, fileManager, usableLocations, documentsDirectory, isRepost, posthash, apiBot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*self.searchTableView = [[UITableView alloc] init];*/
        [self.searchTableView setDelegate:self];
        [self.searchTableView setDataSource:self];
        [self.searchTableView registerClass:[DOJOSendTableViewCell class] forCellReuseIdentifier:@"sendCell"];
    }
    self.isSearching = NO;
    
    self.selectedList = [[NSMutableArray alloc] init];
    self.fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    
    self.usableLocations = [[NSMutableArray alloc] init];

    
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //load user email lols
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    self.usableLocations = [[NSMutableArray alloc] init];
    if ([[dojoTableViewData objectAtIndex:0] count] > 0)
    {
        [self.usableLocations addObject:[NSNumber numberWithInt:0]];
    }
    if ([[dojoTableViewData objectAtIndex:1] count] > 0)
    {
        [self.usableLocations addObject:[NSNumber numberWithInt:1]];
    }
    NSLog(@"usable locations is %@",self.usableLocations);
    return [self.usableLocations count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle;
    switch ([[self.usableLocations objectAtIndex:section] integerValue]) {
        case 0:
            sectionTitle = @"Following";
            break;
        case 1:
            sectionTitle = @"Dojos Near Me";
            break;
            
        default:
            sectionTitle = @"Somewhere";
            break;
    }
    
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    vw.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:0.6];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, 20)];
    lab.text = sectionTitle;
    lab.font = [UIFont fontWithName:@"Avenir-Light" size:15];
    //lab.textColor = [UIColor colorWithRed:0.125 green:0.453 blue:1.0 alpha:1.0];
    lab.textColor = [UIColor whiteColor];
    lab.alpha = 0.9;
    lab.textAlignment = NSTextAlignmentCenter;
    [vw addSubview:lab];
    
    //[self.refresh endRefreshing];
    
    return  vw;
}

-(void)retrievedSendListForRepost:(NSArray *)sendList
{
    self.dojoTableViewData = sendList;
    [self.searchTableView reloadData];
}

-(void)retrievedSendList:(NSArray *)sendList
{
    NSLog(@"did reload some shit you know");
    self.dojoTableViewData = sendList;
    [self.searchTableView reloadData];
}

-(void)reloadTheSwag
{
    self.selectedList = [[NSMutableArray alloc] init];
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
    NSLog(@"before append");
    if (self.isRepost)
    {
        [self.apiBot retrieveSendListForRepost:self.posthash];
    }
    else
    {
        [self.apiBot retrieveSendList];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dojoTableViewData objectAtIndex:[[self.usableLocations objectAtIndex:section] integerValue]] count];
}

-(DOJOSendTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath is %@",indexPath);
    sendCell = (DOJOSendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sendCell" forIndexPath:indexPath];
    NSDictionary *dojoDictMinor = [[[dojoTableViewData objectAtIndex:[[self.usableLocations objectAtIndex:indexPath.section] integerValue]] objectAtIndex:indexPath.row] objectAtIndex:0];
    
    //sendCell.selectToDojo.tag = indexPath.row;
    sendCell.nameLabel.text = [dojoDictMinor objectForKey:@"dojo"];
    NSString *placeholder = [dojoDictMinor objectForKey:@"dojohash"];

    BOOL containsDojo = [selectedList containsObject:placeholder];
    if (containsDojo)
    {
        NSLog(@"this is selected");
        sendCell.selectedView.backgroundColor = [UIColor colorWithHue:(fmodf(indexPath.row*10.0,100))/100 saturation:0.8 brightness:1 alpha:1];
    }
    else
    {
        NSLog(@"this is NOT selected");
        sendCell.selectedView.backgroundColor = [UIColor whiteColor];
    }
    
    return sendCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DID SELECT");
    @try {
        //TAKE RIGHT EMAIL BASED OFF TAG
            NSDictionary *dojoDictMinor = [[[dojoTableViewData objectAtIndex:[[self.usableLocations objectAtIndex:indexPath.section] integerValue]] objectAtIndex:indexPath.row] objectAtIndex:0];
            
            NSInteger locationOfDojo = [selectedList indexOfObject:[dojoDictMinor objectForKey:@"dojohash"]];
            //NSLog(@"email at location %ld", (long)locationOfDojo);
            if ((long)locationOfDojo > 100000)
            {
                if (selectedList.count <= 5)
                {
                    [selectedList addObject:[dojoDictMinor objectForKey:@"dojohash"]];
                    NSLog(@"writing to file>> %@",selectedList);
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many selected" message:@"You can't send a post to more than 6 dojos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
            }
            else
            {
                [selectedList removeObject:[dojoDictMinor objectForKey:@"dojohash"]];
                NSLog(@"removed array is now %@", selectedList);
            }
            
            //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
            [searchTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]]withRowAnimation:UITableViewRowAnimationLeft];

    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        [searchTableView reloadData];
    }
    @finally {
        NSLog(@"finally");
    }
    [searchTableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
