//
//  DOJOHomeTableViewBox.m
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOHomeTableViewBox.h"
#import "DOJOHomeViewController.h"
#import "DOJOCellButton.h"
#import "DOJOInviteButton.h"

@interface DOJOHomeTableViewBox () <CellButtonTouchEventDelegate, HomeViewDelegate>

@end

@implementation DOJOHomeTableViewBox
{
    DOJOHomeViewController *homeVC;
}

@synthesize dojoTableView, dojoCell, userEmail, indexOfSelectedButton, dojoTableViewData, isSearching, downloadRequest, lastOffset, downards, gestureRecTap, rowTapped, didTapMessage, swipeGesture, selectedHomeType, currentLocation, dojoSearchBar, searchTableViewData, locationTableViewData, searchCell, homeLoadMask;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dojoTableView = [[UITableView alloc] init];
        [self.dojoTableView setDelegate:self];
        [self.dojoTableView setDataSource:self];
        
        NSLog(@"INIT WITH FRAME >> SWITCHING TO SEARCHING STATE >> OFF");
        [self.dojoTableView registerClass:[DOJOHomeTableViewCell class] forCellReuseIdentifier:@"myDojoCell"];
        self.dojoTableView.tag = 1;
        
        self.isSearching = NO;
        
        self.dojoTableViewData = [[NSArray alloc] init];
        
        self.selectedHomeType = 0;
        self.homeLoadMask = 0;
        
    }
    return self;
}

-(void)loadDojoHomeNotSearching
{
    self.sampleView = [[DOJOSampleView alloc] initWithFrame:CGRectMake(0, 0, 640, 900)];
    self.sampleView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.sampleView];
    [self bringSubviewToFront:self.sampleView];
    //[self.sampleView setHidden:YES];
    self.didTapMessage = NO;
    self.dojoTableView.delegate = self;
    @try {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"]] forKeys:@[@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoHomeList.php",SERVERADDRESS]]];
        
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
            NSError *localError;
            @try {
                dojoTableViewData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&localError];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
                NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                UIResponder *responder = self;
                while ([responder isKindOfClass:[UIView class]])
                {
                    responder = [responder nextResponder];
                }
                homeVC = (DOJOHomeViewController *)responder;
                homeVC.dojoTableViewData = dojoTableViewData;
                [self.dojoTableView reloadData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"HOME TABLE VIEW problem load: %@",exception);
    }
    @finally {
        NSLog(@"ran through home table view network request block");
    }
    lastOffset.x = 0;
    lastOffset.y = 0;
}

-(void)reloadTheSearchData
{
    self.dojoTableView.delegate = self;
    if (self.isSearching)
    {
        NSLog(@"by name");
        @try {
            NSString *searchText = dojoSearchBar.text;
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
            NSLog(@"dacia sandero 2 is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchForDojo.php",SERVERADDRESS]]];
            
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
            searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
            NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
            
            [self.dojoTableView reloadData];
            
        }
        @catch (NSException *exception) {
            NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
            UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [networkFailure show];
        }
        @finally {
            NSLog(@"elev8");
        }
    }
    else
    {
        NSLog(@"by location");
        @try {
            NSString *searchText = dojoSearchBar.text;
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
            NSLog(@"dacia sandero is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchByLocation.php",SERVERADDRESS]]];
            NSLog(@"SERVERUPDATE %@",[NSString stringWithFormat:@"%ssearchForDojo.php",SERVERADDRESS]);
            
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
            locationTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"GET SEARCH LIST IS \n%@",locationTableViewData);
            NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
            
            [self.dojoTableView reloadData];
        }
        @catch (NSException *exception) {
            NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
            UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [networkFailure show];
        }
        @finally {
            NSLog(@"elev8");
        }
    }
    
}

-(void)didChangeHomeType:(UISegmentedControl *)segControl
{
    NSLog(@"within home view %ld",(long)segControl.selectedSegmentIndex);
    self.selectedHomeType = segControl.selectedSegmentIndex;
    if (self.selectedHomeType == 0)
    {
        [self.dojoSearchBar setHidden:NO];
        [self reloadTheSearchData];
        /*
        if (!(self.homeLoadMask & 0x01))
        {
            [self.dojoTableView setContentOffset:CGPointMake(0, 10) animated:YES];
            self.homeLoadMask = self.homeLoadMask | 0x01;
        }
         */
    }
    if (self.selectedHomeType == 1)
    {
        [self.dojoSearchBar setHidden:YES];
        [self.dojoTableView reloadData];
        /*
        if (!(self.homeLoadMask & 0x02))
        {
            [self.dojoTableView setContentOffset:CGPointMake(0, 10) animated:YES];
            self.homeLoadMask = self.homeLoadMask | 0x02;
        }
         */
    }
    if (self.selectedHomeType == 2)
    {
        [self.dojoSearchBar setHidden:YES];
        [self loadDojoHomeNotSearching];
        /*
        if (!(self.homeLoadMask & 0x04))
        {
            [self.dojoTableView setContentOffset:CGPointMake(0, 20) animated:YES];
            self.homeLoadMask = self.homeLoadMask | 0x04;
        }
         */
    }
    else
    {
        
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    @try {
        NSString *searchText = searchBar.text;
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:currentLocation.coordinate.latitude], [NSNumber numberWithDouble:currentLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchForDojo.php",SERVERADDRESS]]];
        
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
        searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
        NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        
        [self.dojoTableView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"swanky swank");
    }
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[self.storyboard instantiateViewControllerWithIdentifier:@"dojoSearchController"];
    //[self performSegueWithIdentifier:@"toSearchController" sender:self];
    //[self.navigationController pushViewController:searchController animated:YES];
    self.isSearching = YES;
    [self.dojoTableView reloadData];
    self.dojoSearchBar.showsCancelButton = YES;
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.isSearching = NO;
    [self.dojoTableView reloadData];
    self.dojoSearchBar.showsCancelButton = NO;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"did reach the top");
    if (self.selectedHomeType == 0)
    {
        [self.dojoTableView setContentOffset:CGPointMake(0, 45) animated:YES];
    }
    if (self.selectedHomeType == 1)
    {
        [self.dojoSearchBar setHidden:YES];
        [self.dojoTableView setContentOffset:CGPointMake(0, 45) animated:YES];
    }
    if (self.selectedHomeType == 2)
    {
        [self.dojoSearchBar setHidden:YES];
        if ([dojoTableViewData count] > 0) {
            [self.dojoTableView setContentOffset:CGPointMake(0, 120) animated:YES];
        }
        else
        {
            [self.dojoTableView setContentOffset:CGPointMake(0, 45) animated:YES];
        }
        
    }
    else
    {
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.selectedHomeType == 0)
    {
        if (self.isSearching)
        {
            return 1;
        }
        else
        {
            return 5;
        }
    }
    if (self.selectedHomeType == 1)
    {
        return 1;
    }
    if (self.selectedHomeType == 2)
    {
        //[self loadDojoHomeNotSearching];
        int numberOfSections = 0;
        
        NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:0];
        //NSLog(@"dojoAllArray contains %@", dojoAllArray);
        if ([dojoAllArray count] > 0) {
            numberOfSections = numberOfSections + 1;
        }
        dojoAllArray = [dojoTableViewData objectAtIndex:1];
        //NSLog(@"dojoAllArray contains %@", dojoAllArray);
        if ([dojoAllArray count] > 0) {
            numberOfSections = numberOfSections + 1;
        }
        NSLog(@"number of sections is %ld",(long)numberOfSections);
        return 2;

    }
    else
    {
        return 0;
    }
}
/*
if (self.selectedHomeType == 0)
{
 
}
if (self.selectedHomeType == 1)
{
 
}
if (self.selectedHomeType == 2)
{
 
}
else
{
 
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedHomeType == 0)
    {
        return 250;
    }
    if (self.selectedHomeType == 1)
    {
        return 50;
    }
    if (self.selectedHomeType == 2)
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                return 90;
            }
            else
            {
                NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
                //NSLog(@"dojoAllArray contains %@", dojoAllArray);
                NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:(indexPath.row-1)];
                //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
                NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
                if ([[dojoDictMinor objectForKey:@"code"] isEqualToString:@""])
                {
                    if ([[dojoDictMajor objectAtIndex:3] count] >0)
                    {
                        return 250;
                    }
                    else
                    {
                        return 90;
                    }
                }
                else
                {
                    return 90;
                }
            }
        }
        else
        {
            
            return 250;
        }
    }
    else
    {
        return 50;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.selectedHomeType == 0)
    {
        if (self.isSearching)
        {
            return [searchTableViewData count];
        }
        else
        {
            NSLog(@"number of locations results %ld",(long)[locationTableViewData count]);
            if ([locationTableViewData count] == 0)
            {
                return [locationTableViewData count];
            }
            else
            {
                switch (section) {
                    case 0:
                        NSLog(@"number of rows %ld for section %ld",(long)[[locationTableViewData objectAtIndex:0] count],section);
                        return [[locationTableViewData objectAtIndex:0] count];
                        break;
                    case 1:
                        NSLog(@"number of rows %ld for section %ld",(long)[[locationTableViewData objectAtIndex:1] count],section);
                        return [[locationTableViewData objectAtIndex:1] count];
                        //return 2;
                        break;
                    case 2:
                        NSLog(@"number of rows %ld for section %ld",(long)[[locationTableViewData objectAtIndex:2] count],section);
                        return [[locationTableViewData objectAtIndex:2] count];
                        //return 1;
                        break;
                    case 3:
                        NSLog(@"number of rows %ld for section %ld",(long)[[locationTableViewData objectAtIndex:3] count],section);
                        return [[locationTableViewData objectAtIndex:3] count];
                        break;
                    case 4:
                        NSLog(@"number of rows %ld for section %ld",(long)[[locationTableViewData objectAtIndex:4] count],section);
                        return [[locationTableViewData objectAtIndex:4] count];
                        break;
                        
                    default:
                        return 0;
                        break;
                }
            }
        }
    }
    if (self.selectedHomeType == 1)
    {
        return 0;
    }
    if (self.selectedHomeType == 2)
    {
        int numberOfRows = 0;
        if (section == 0)
        {
            if ([dojoTableViewData count] > 0) {
                numberOfRows = (int)[[dojoTableViewData objectAtIndex:1] count];
            }
        }
        if (section == 1)
        {
            if ([dojoTableViewData count] > 0) {
                numberOfRows = (int)[[dojoTableViewData objectAtIndex:0] count];
            }
        }
        NSLog(@"number of Rows for section %ld is %ld",(long)section,(long)numberOfRows);
        return numberOfRows;
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleHeader;
    if (self.selectedHomeType == 0)
    {
        if (self.isSearching)
        {
            return @"";
        }
        else
        {
            switch (section) {
                case 0:
                    return @"campus (<0.5 miles)";
                    break;
                case 1:
                    return @"close (<4 miles)";
                    break;
                case 2:
                    return @"nearby (<7 miles)";
                    break;
                case 3:
                    return @"around (<15 miles)";
                    break;
                case 4:
                    return @"city";
                    break;
                    
                default:
                    return @"somewhere";
                    break;
            }
        }

    }
    if (self.selectedHomeType == 1)
    {
        return @"";
    }
    if (self.selectedHomeType == 2)
    {
        if (section == 0) {
            titleHeader = @"invited/requested";
        }
        if (section == 1) {
            titleHeader = @"joined";
        }
        return titleHeader;
    }
    else
    {
        return @"";
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == 9999)
    {
        if (self.downards)
        {
            [UIView animateWithDuration:0.6 animations:^{
                [homeVC.navigationController.navigationBar setAlpha:0];
                homeVC.navigationController.navigationBar.frame = CGRectMake(homeVC.navigationController.navigationBar.frame.origin.x, -homeVC.navigationController.navigationBar.frame.size.height + 20, homeVC.navigationController.navigationBar.frame.size.width, homeVC.navigationController.navigationBar.frame.size.height);
                homeVC.cameraButton.frame = CGRectMake((self.frame.size.width/2)-32, self.frame.size.height, 65, 65);
            } completion:nil];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //scrollView.
    if (scrollView.tag == 9999)
    {
        NSLog(self.downards ? @"DOWNWARD YES" : @"DOWNWARDS NO");
        if (!self.downards)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [homeVC.navigationController.navigationBar setAlpha:1];
                homeVC.navigationController.navigationBar.frame = CGRectMake(homeVC.navigationController.navigationBar.frame.origin.x,20,homeVC.navigationController.navigationBar.frame.size.width, homeVC.navigationController.navigationBar.frame.size.height);
                homeVC.cameraButton.frame = CGRectMake((self.frame.size.width/2)-32, self.frame.size.height-75, 65, 65);
            } completion:nil];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 9999)
    {
        CGPoint currentOffset = scrollView.contentOffset;
        if (currentOffset.y > lastOffset.y)
        {
            self.downards = YES;
        }
        else
        {
            self.downards = NO;
            if (self.isSearching)
            {
                [self.dojoSearchBar resignFirstResponder];
            }
        }
        /*
         if (currentOffset.y > lastOffset.y)
         {
         // Downward
         NSLog(@"downward");
         if ((homeVC.navigationController.navigationBar.frame.origin.y - 1) > -homeVC.navigationController.navigationBar.frame.size.height)
         {
         homeVC.navigationController.navigationBar.frame = CGRectMake(0,
         homeVC.navigationController.navigationBar.frame.origin.y - 1,
         homeVC.navigationController.navigationBar.frame.size.width,
         homeVC.navigationController.navigationBar.frame.size.height);
         }
         }
         else
         {
         // Upward
         NSLog(@"upward");
         if ((homeVC.navigationController.navigationBar.frame.origin.y + 1) < 20)
         {
         homeVC.navigationController.navigationBar.frame = CGRectMake(0,
         homeVC.navigationController.navigationBar.frame.origin.y + 1,
         homeVC.navigationController.navigationBar.frame.size.width,
         homeVC.navigationController.navigationBar.frame.size.height);
         }
         }
         */
        lastOffset = currentOffset;
        scrollView.contentOffset = currentOffset;
    }
}

-(void)revealTheMessage:(UITapGestureRecognizer *)tapGest
{
    UIView *messageView = (UIView *)tapGest.view;
    NSLog(@"detected tap from row %d",messageView.tag);
    rowTapped = messageView.tag;
    self.didTapMessage = YES;
    [dojoTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowTapped inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedHomeType == 0)
    {
        searchCell = (DOJOSearch4DojoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        [searchCell.alphaBar setAlpha:0.9];
        //[searchCell.picView setFrame:CGRectMake(0, 0, searchCell.frame.size.width, searchCell.frame.size.height)];
        searchCell.picView.backgroundColor = [UIColor orangeColor];
        
        UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
        [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [horizontal setMinimumInteritemSpacing:0];
        [horizontal setMinimumLineSpacing:0];
        searchCell.picView = [[DOJOPicView alloc] initWithFrame:CGRectMake(0, 0, searchCell.contentView.frame.size.width, 250) collectionViewLayout:horizontal];
        [searchCell.picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"searchPostCell"];
        searchCell.picView.alwaysBounceHorizontal = YES;
        [searchCell.picView setDelegate:self];
        [searchCell.picView setDataSource:self];
        searchCell.picView.section = indexPath.section;
        searchCell.addButton.section = indexPath.section;
        searchCell.picView.pagingEnabled = YES;
        searchCell.picView.tag = indexPath.row;
        searchCell.picView.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1 alpha:1];
        NSLog(@"the searchpicview %@ section is %ld, number %ld",indexPath,searchCell.picView.section, (long)searchCell.picView.tag);
        [searchCell.picView reloadData];
        
        if (isSearching)
        { /*
           array_push($interim, $distanceApprox);
           array_push($interim, $dojo);
           array_push($interim, $numOfSenpai);
           array_push($interim, $interval);
           array_push($interim, $backgroundPhotos);
           array_push($finalArr, $interim);
           */
            
            NSArray *resultData = [searchTableViewData objectAtIndex:indexPath.row];
            NSString *numOfMembers = [NSString stringWithFormat:@"%@ members",[resultData objectAtIndex:2]];
            NSDictionary *dojodict = [resultData objectAtIndex:1];
            
            searchCell.dojoLabel.text = [dojodict objectForKey:@"dojo"];
            searchCell.nameLabel.text = numOfMembers;
            searchCell.distanceLabel.text = [resultData objectAtIndex:0];
            
            searchCell.tag = indexPath.row;
            searchCell.addButton.tag = indexPath.row;
            searchCell.addButton.searchType = 0;
        }
        else
        {
            /*
             array_push($interim, $aDojo);
             $approxDistance = sqrt((pow(abs($dojoLongi - $longi),2)) + (pow(abs($dojoLati - $lati),2)));
             array_push($interim, $approxDistance);
             array_push($interim, $selectResults[0]);
             array_push($interim, $numOfSenpai);
             array_push($interim, $interval);
             array_push($interim, $backgroundPhotos);
             array_push($distanceClose, $interim);
             */
            NSArray *resultData = [[locationTableViewData objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
            NSString *numOfMembers = [NSString stringWithFormat:@"%@ members",[resultData objectAtIndex:3]];
            NSDictionary *dojodict = [resultData objectAtIndex:2];
            
            searchCell.dojoLabel.text = [dojodict objectForKey:@"dojo"];
            searchCell.nameLabel.text = numOfMembers;
            /*
             NSDictionary *timeInfo = [resultData objectAtIndex:4];
             NSLog(@"timeInfo is %@",timeInfo);
             // week span USE WEEKEND FOR UNITS < <
             NSString *lastTime;
             if (([[timeInfo objectForKey:@"d"] integerValue] > 7) && ([[timeInfo objectForKey:@"d"] integerValue] < 29))
             {
             // this isnt necessary, just use # of weeks ez no date class needed
             lastTime = [NSString stringWithFormat:@"%fwks",floor([[timeInfo objectForKey:@"d"] integerValue]/7)];
             }
             else
             {
             // within week span
             if (([[timeInfo objectForKey:@"d"] integerValue] > 0) && ([[timeInfo objectForKey:@"d"] integerValue] < 7))
             {
             // get day name if in day span
             if ([[timeInfo objectForKey:@"d"] integerValue] == 1)
             {
             //just say yesterday
             lastTime = @"yesterday";
             }
             else
             {
             NSCalendar *gregorian = [NSCalendar currentCalendar];
             NSDate *adjustedWeekDate = [gregorian dateByAddingUnit:NSCalendarUnitDay value:[[timeInfo objectForKey:@"d"] integerValue] toDate:[NSDate date] options:NSCalendarMatchNextTime];
             NSDateFormatter *dateF = [NSDateFormatter new];
             [dateF setDateFormat:@"EEEE"];
             NSLog(@"dateF is %@",[dateF stringFromDate:adjustedWeekDate]);
             lastTime = [dateF stringFromDate:adjustedWeekDate];
             }
             }
             else
             {
             if ([[timeInfo objectForKey:@"h"] integerValue] > 0)
             {
             lastTime = [NSString stringWithFormat:@"%@h",[timeInfo objectForKey:@"h"]];
             }
             else
             {
             if ([[NSString stringWithFormat:@"%@m",[timeInfo objectForKey:@"m"]] isEqualToString:@"0m"])
             {
             lastTime = @"just now";
             }
             else
             {
             lastTime = [NSString stringWithFormat:@"%@m",[timeInfo objectForKey:@"m"]];
             }
             }
             }
             }
             */
            searchCell.distanceLabel.text = @"";
            searchCell.tag = indexPath.row;
            searchCell.addButton.tag = indexPath.row;
            searchCell.addButton.searchType = 1;
        }
        [searchCell.picView setScrollEnabled:NO];
        [searchCell.contentView addSubview:searchCell.picView];
        [searchCell.contentView addSubview:searchCell.alphaBar];
        [searchCell.contentView addSubview:searchCell.dojoLabel];
        [searchCell.contentView addSubview:searchCell.nameLabel];
        [searchCell.contentView addSubview:searchCell.distanceLabel];
        [searchCell.contentView addSubview:searchCell.addButton];
        return searchCell;
    }
    if (self.selectedHomeType == 1)
    {
        
    }
    if (self.selectedHomeType == 2)
    {
        NSLog(@"START OF index path is %@", indexPath);
        dojoCell = (DOJOHomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"myDojoCell" forIndexPath:indexPath];
        [dojoCell.datButton setBackgroundImage:[UIImage imageNamed:@"whiteovalbutton.png"] forState:UIControlStateNormal];
        dojoCell.picView.pagingEnabled = YES;
        [dojoCell.alphaBar setAlpha:0.9];
        dojoCell.alphaBar.backgroundColor = [UIColor whiteColor];
        
        //[dojoCell.messageBox setBackgroundColor:[UIColor whiteColor]];
        
        dojoCell.dojoNameLabel.textAlignment = NSTextAlignmentLeft;
        [dojoCell.dojoNameLabel setFrame:CGRectMake(15, 4, 211, 22)];
        [dojoCell.dojoNameLabel setTextColor:[UIColor blackColor]];
        if (indexPath.section == 0)
        {
            [dojoCell.datButton setHidden:NO];
            // invited
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:(indexPath.row-1)];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            dojoCell.dojoNameLabel.text = [dojoDictMinor valueForKey:@"dojo"];
            [dojoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            @try {
                [dojoCell.activeMemberLabel setText:[NSString stringWithFormat:@"%@ members",[dojoDictMajor objectAtIndex:1]]];
            }
            @catch (NSException *exception) {
                [dojoCell.activeMemberLabel setText:@"nobody yet"];
            }
            @finally {
                NSLog(@"ran through invited section block");
            }
            if ([[dojoDictMinor objectForKey:@"code"] isEqualToString:@""])
            {
                [dojoCell.datButton setFrame:CGRectMake(254, 13, 40, 40)];
                [dojoCell.alphaBar setFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 60)];
                UIImage *unlocked = [UIImage imageNamed:@"unlocked.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 30),NO,0.0);
                [unlocked drawInRect:CGRectMake(9, 0, 22, 25)];
                CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.8);
                UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [dojoCell.datButton setImage:resizedUnlock forState:UIControlStateNormal];
                NSLog(@"invited list count is %i",[[dojoDictMajor objectAtIndex:3] count]);
                if ([[dojoDictMajor objectAtIndex:3] count] > 0)
                {
                    [dojoCell.picView setHidden:NO];
                    if (dojoCell.picView == nil)
                    {
                        UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
                        [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                        [horizontal setMinimumInteritemSpacing:0];
                        [horizontal setMinimumLineSpacing:0];
                        dojoCell.picView = [[DOJOPicView alloc] initWithFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 250) collectionViewLayout:horizontal];
                        [dojoCell.picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"postCell"];
                        dojoCell.picView.alwaysBounceHorizontal = YES;
                    }
                    UICollectionViewFlowLayout *flowLay = (UICollectionViewFlowLayout *)dojoCell.picView.collectionViewLayout;
                    [flowLay setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                    [flowLay setMinimumInteritemSpacing:0];
                    [flowLay setMinimumLineSpacing:0];
                    [dojoCell.picView setCollectionViewLayout:flowLay];
                    dojoCell.picView.collectionViewLayout = flowLay;
                    [dojoCell.picView setDelegate:self];
                    [dojoCell.picView setDataSource:self];
                    dojoCell.picView.tag = indexPath.row;
                    dojoCell.picView.backgroundColor = [UIColor clearColor];
                    [dojoCell.picView reloadData];
                }
                else
                {
                    [dojoCell.picView setHidden:YES];
                }
            }
            else
            {
                [dojoCell.datButton setFrame:CGRectMake(254, 19, 40, 40)];
                [dojoCell.alphaBar setFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 90)];
                UIImage *locked = [UIImage imageNamed:@"locked.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 30),NO,0.0);
                [locked drawInRect:CGRectMake(9, 0, 22, 25)];
                UIImage *resizedLock = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [dojoCell.datButton setImage:resizedLock forState:UIControlStateNormal];
                [dojoCell.picView setHidden:YES];
            }
            [dojoCell.datButton setTitle:@"0" forState:UIControlStateNormal];
            //[dojoCell.picView removeFromSuperview];
            dojoCell.picView.section = 0;
            [dojoCell.picView setScrollEnabled:NO];
            [dojoCell.timeStamp setText:@""];
            [dojoCell.invitationType setHidden:NO];
            dojoCell.invitationType.text = (NSString *)[dojoDictMajor objectAtIndex:2];
        }
        if (indexPath.section == 1) {
            [dojoCell.invitationType setHidden:YES];
            [dojoCell.timeStamp setText:@""];
            [dojoCell.picView setHidden:NO];
            [dojoCell.datButton setHidden:NO];
            dojoCell.picView.section = 1;
            [dojoCell.datButton setFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 44)];
            [dojoCell.alphaBar setFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 44)];
            // joined
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:0];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:indexPath.row];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            //NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            dojoCell.dojoNameLabel.text = [dojoDictMinor valueForKey:@"dojo"];
            NSArray *freshestMajor = [dojoDictMajor objectAtIndex:1];
            NSArray *freshestFlag = [dojoDictMajor objectAtIndex:4];
            if ([freshestFlag count] > 0)
            {
                [dojoCell.timeStamp setText:@"new posts!"];
            }
            else
            {
                NSString *lastTime;
                NSDictionary *timeInfo = [dojoDictMajor objectAtIndex:3];
                if ([freshestFlag count]>0)
                {
                    
                    NSLog(@"timeInfo is %@",timeInfo);
                    // week span USE WEEKEND FOR UNITS < <
                    if (([[timeInfo objectForKey:@"d"] integerValue] > 7) && ([[timeInfo objectForKey:@"d"] integerValue] < 29))
                    {
                        // this isnt necessary, just use # of weeks ez no date class needed
                        lastTime = [NSString stringWithFormat:@"%ldwks",(long)floor([[timeInfo objectForKey:@"d"] integerValue]/7)];
                    }
                    else
                    {
                        // within week span
                        if (([[timeInfo objectForKey:@"d"] integerValue] > 0) && ([[timeInfo objectForKey:@"d"] integerValue] < 7))
                        {
                            // get day name if in day span
                            if ([[timeInfo objectForKey:@"d"] integerValue] == 1)
                            {
                                //just say yesterday
                                lastTime = @"yesterday";
                            }
                            else
                            {
                                NSCalendar *gregorian = [NSCalendar currentCalendar];
                                NSDate *adjustedWeekDate = [gregorian dateByAddingUnit:NSCalendarUnitDay value:[[timeInfo objectForKey:@"d"] integerValue] toDate:[NSDate date] options:NSCalendarMatchNextTime];
                                NSDateFormatter *dateF = [NSDateFormatter new];
                                [dateF setDateFormat:@"EEEE"];
                                NSLog(@"dateF is %@",[dateF stringFromDate:adjustedWeekDate]);
                                lastTime = [dateF stringFromDate:adjustedWeekDate];
                            }
                        }
                        else
                        {
                            if ([[timeInfo objectForKey:@"h"] integerValue] > 0)
                            {
                                lastTime = [NSString stringWithFormat:@"%@h",[timeInfo objectForKey:@"h"]];
                            }
                            else
                            {
                                if ([[NSString stringWithFormat:@"%@m",[timeInfo objectForKey:@"m"]] isEqualToString:@"0m"])
                                {
                                    lastTime = @"just now";
                                }
                                else
                                {
                                    lastTime = [NSString stringWithFormat:@"%@m",[timeInfo objectForKey:@"m"]];
                                }
                            }
                        }
                    }
                    /*
                     lastTime = [messageString stringByAppendingFormat:@"last active: %lds, %ldm, %ldh, %@d\n",
                     labs([[timeInfo objectForKey:@"s"] integerValue] - 60),
                     labs([[timeInfo objectForKey:@"i"] integerValue] - 60),
                     labs([[timeInfo objectForKey:@"h"] integerValue] - 6),
                     [timeInfo objectForKey:@"d"]];
                     */
                    NSLog(@"last hour is %ld",(long)[[timeInfo objectForKey:@"h"] integerValue]);
                    NSLog(@"last time is %@",lastTime);
                    [dojoCell.timeStamp setText:lastTime];
                }
                else
                {
                    [dojoCell.timeStamp setText:@""];
                }
            }
            @try {
                NSArray *userList = [[[dojoTableViewData objectAtIndex:0] objectAtIndex:indexPath.row] objectAtIndex:2];
                NSString *aName = @"";
                for (int i = 0; i<[userList count]; i++) {
                    //NSLog(@"for, with user %@",[userList objectAtIndex:i]);
                    if (i==([userList count]-1))
                    {
                        aName = [aName stringByAppendingString:[NSString stringWithFormat:@"%@",[[userList objectAtIndex:i] valueForKey:@"firstname"]]];
                    }
                    else
                    {
                        aName = [aName stringByAppendingString:[NSString stringWithFormat:@"%@, ",[[userList objectAtIndex:i] valueForKey:@"firstname"]]];
                    }
                }
                //NSLog(@"a name is %@", aName);
                [dojoCell.activeMemberLabel setText:aName];
            }
            @catch (NSException *exception) {
                NSLog(@"except here");
                [dojoCell.activeMemberLabel setText:@"nobody yet"];
            }
            @finally {
                NSLog(@"ran through the active member try block");
            }
            UIImage *img = [UIImage imageNamed:@"invisible.png"];
            [dojoCell.datButton setBackgroundImage:img forState:UIControlStateNormal];
            [dojoCell.datButton setNeedsDisplay];
            UIImage *unlocked = [UIImage imageNamed:@"invisible.png"];
            [dojoCell.datButton setImage:unlocked forState:UIControlStateNormal];
            [dojoCell.datButton setTitle:@"1" forState:UIControlStateNormal];
            if (dojoCell.picView == nil)
            {
                UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
                [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [horizontal setMinimumInteritemSpacing:0];
                [horizontal setMinimumLineSpacing:0];
                dojoCell.picView = [[DOJOPicView alloc] initWithFrame:CGRectMake(0, 0, dojoCell.contentView.frame.size.width, 250) collectionViewLayout:horizontal];
                [dojoCell.picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"postCell"];
                //dojoCell.picView.alwaysBounceHorizontal = YES;
            }
            UICollectionViewFlowLayout *flowLay = (UICollectionViewFlowLayout *)dojoCell.picView.collectionViewLayout;
            [flowLay setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            [flowLay setMinimumInteritemSpacing:0];
            [flowLay setMinimumLineSpacing:0];
            [dojoCell.picView setCollectionViewLayout:flowLay];
            dojoCell.picView.collectionViewLayout = flowLay;
            [dojoCell.picView setDelegate:self];
            [dojoCell.picView setDataSource:self];
            dojoCell.picView.tag = indexPath.row;
            dojoCell.picView.backgroundColor = [UIColor clearColor];
            [dojoCell.picView reloadData];
            [dojoCell.picView setScrollEnabled:NO];
        }
        //NSLog(@"END OF index path is %@", indexPath);
        if (indexPath.section == 0)
        {
            dojoCell.datButton.tag = (indexPath.row-1);
        }
        else
        {
            dojoCell.datButton.tag = indexPath.row;
        }
        [dojoCell.contentView bringSubviewToFront:dojoCell.datButton];
        self.didTapMessage = NO;
        return dojoCell;
    }
    else
    {
        
    }
}

-(void)tapBegan:(NSInteger)selectedPost withSectionMajor:(NSInteger)sectionMajor withSectionMinor:(NSInteger)sectionMinor
{
    NSLog(@"DISPLAYING SAMPLE VIEW: section Major: %ld, section Minor: %ld, post: %ld",(long)sectionMajor,(long)sectionMinor, (long)selectedPost);
    NSArray *postList = [[NSArray alloc] init];
    if (self.selectedHomeType == 0)
    {
        if (self.isSearching)
        {
            postList = [[searchTableViewData objectAtIndex:sectionMinor] objectAtIndex:4];
        }
        else
        {
            @try {
                if ([[[locationTableViewData objectAtIndex:sectionMajor] objectAtIndex:sectionMinor] count] != 0)
                {
                    //NSLog(@"count is %ld", (long)[[[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5] count]);
                    postList = [[[locationTableViewData objectAtIndex:sectionMajor] objectAtIndex:sectionMinor] objectAtIndex:5];
                }
                else
                {
                    return;
                }
            }
            @catch (NSException *exception) {
                NSLog(@"empty array chunk for dojo location section %ld",sectionMajor);
            }
            @finally {
                NSLog(@"ran through attempt to load dojo post cells");
            }
        }
    }
    if (self.selectedHomeType == 1)
    {
        
    }
    if (self.selectedHomeType == 2)
    {
        
    }
    
    NSString *postType = [[NSString alloc] init];
    switch ([[[postList objectAtIndex:selectedPost] valueForKey:@"posthash"] rangeOfString:@"clip"].location) {
        case (0):
            postType = @"movie";
            break;
        case (NSNotFound):
            postType=@"image";
            break;
        default:
            break;
    }
    
    self.sampleView = [[DOJOSampleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.sampleView.backgroundColor = [UIColor greenColor];
    self.sampleView.selectedPostInfo = [postList objectAtIndex:selectedPost];
    self.sampleView.dojoPostList = postList;
    self.sampleView.postType = postType;
    [self.sampleView loadAPost];
    [self addSubview:self.sampleView];
    [self bringSubviewToFront:self.sampleView];
    [self.sampleView setHidden:NO];
}

-(void)tapEnded
{
    NSLog(@"HIDING SAMPLE VIEW");
    [self.sampleView setHidden:YES];
}

-(NSInteger)collectionView:(DOJOPicView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.selectedHomeType == 0)
    {
        NSLog(@"section %ld attempting to load for collection section %ld for row %ld",(long)section, (long)collectionView.section,(long)collectionView.tag);
        NSArray *postArray;
        if (self.isSearching)
        {
            postArray = [[searchTableViewData objectAtIndex:collectionView.tag] objectAtIndex:4];
            if ([postArray count] == 0)
            {
                return 1;
            }
        }
        else
        {
            @try {
                if ([[locationTableViewData objectAtIndex:collectionView.section] count] != 0)
                {
                    //NSLog(@"count is %ld", (long)[[[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5] count]);
                    postArray = [[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5];
                    if ([postArray count] == 0)
                    {
                        return 1;
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"empty array chunk for dojo location section %ld",collectionView.section);
                return 0;
            }
            @finally {
                NSLog(@"ran through attempt to load dojo post cells");
            }
        }
        return [postArray count];
    }
    if (self.selectedHomeType == 1)
    {
        return 0;
    }
    if (self.selectedHomeType == 2)
    {
        if (collectionView.section == 0)
        {
            // joined
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:collectionView.tag];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            //NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            //NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            NSArray *freshestMajor = [dojoDictMajor objectAtIndex:3];
            NSLog(@"%d in section %d",[freshestMajor count],section);
            return [freshestMajor count];
        }
        else
        {
            // joined
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:0];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:collectionView.tag];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            //NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            //NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            NSArray *freshestMajor = [dojoDictMajor objectAtIndex:1];
            NSLog(@"%d in section %d",[freshestMajor count],section);
            return [freshestMajor count];
        }
    }
    else
    {
        return 0;
    }
}

-(void)plagnifyEvent:(NSInteger)selectedButton withSection:(NSInteger)section
{
    NSLog(@"in home viewbox");
    UIButton *button = [[UIButton alloc] init];
    button.tag = selectedButton;
    button.titleLabel.text = [NSString stringWithFormat:@"%li",(long)section];
    [homeVC magnifyCell:button];
}

-(DOJOPostCollectionViewCell *)collectionView:(DOJOPicView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedHomeType == 0)
    {
        DOJOPostCollectionViewCell *cell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"searchPostCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1 alpha:1];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        cell.cellButton.touchEventDelegate = self;
        cell.cellButton.tag = indexPath.row;
        cell.cellButton.sectionMinor = collectionView.tag;
        cell.cellButton.sectionMajor = collectionView.section;
        
        NSArray *postArray;
        if (self.isSearching)
        {
            postArray = [[searchTableViewData objectAtIndex:collectionView.tag] objectAtIndex:4];
            if ([postArray count] == 0)
            {
                
                return cell;
            }
        }
        else
        {
            NSLog(@"data is %@, for section %ld",[locationTableViewData objectAtIndex:collectionView.section], (long)collectionView.section);
            postArray = [[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5];
            if ([postArray count] == 0)
            {

                return cell;
            }
        }
        
        NSLog(@"row %ld, postArray contains %@",(long)indexPath.row,postArray);
        
        if ([postArray count] > 0)
        {
            NSDictionary *postDict = [postArray objectAtIndex:indexPath.row];
            NSLog(@"POSTHASH is %@",[postDict valueForKey:@"posthash"]);
            //latest
            UIImage *image = [[UIImage alloc] init];
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[postDict valueForKey:@"posthash"]];
            NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
            NSString *posthash = [postDict valueForKey:@"posthash"];
            if ([fileManager fileExistsAtPath:picPath])
            {
                //load this instead
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [cell.cellFace setImage:image];
                if ([posthash rangeOfString:@"clip"].location == 0)
                {
                    UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
                    [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
                    CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                    UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [cell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
                }
                else
                {
                    [cell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                }

            }
            else
            {
                NSLog(@"pulling image for row %ld", (long)indexPath.row);
                NSLog(@"codekey is %@",posthash);
                if ([posthash rangeOfString:@"clip"].location == 0)
                {
                    UIImage *unlocked = [UIImage imageNamed:@"playbuttonwhite.png"];
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(collectionView.frame.size.width, 250),NO,0.0);
                    [unlocked drawInRect:CGRectMake((collectionView.frame.size.width/2)-17, 125, 35, 35)];
                    CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.7);
                    UIImage *resizedUnlock = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [cell.cellButton setImage:resizedUnlock forState:UIControlStateNormal];
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",posthash];
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
                                [cell.cellFace setImage:dlthumb];
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
                            [cell.cellFace setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
                else
                {
                    [cell.cellButton setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
                    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
                    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                    
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = @"dojopicbucket";
                    self.downloadRequest.key = posthash;
                    self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        if (task.error != nil) {
                            NSLog(@"Error: [%@]", task.error);
                            @try {
                                UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                [cell.cellFace setImage:dlthumb];
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
                            [cell.cellFace setImage:dlthumb];
                        }
                        return nil;
                    }];
                }
            }
        }
        cell.cellFace.contentMode = UIViewContentModeScaleAspectFill;
        return cell;
    }
    if (self.selectedHomeType == 1)
    {
        
    }
    if (self.selectedHomeType == 2)
    {
        DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"postCell" forIndexPath:indexPath];
        postCell.backgroundColor = [UIColor clearColor];
        postCell.cellButton.touchEventDelegate = self;
        if (collectionView.section == 0)
        {
            NSLog(@"returning cell for %@",indexPath);
            //freshest array
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:collectionView.tag];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            //NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            //NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            
            NSArray *freshestMajor = [dojoDictMajor objectAtIndex:3];
            NSLog(@"SECTION 0 POSTHASH is %@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
            //latest
            UIImage *image = [[UIImage alloc] init];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
            NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
            
            if ([fileManager fileExistsAtPath:picPath])
            {
                //load this instead
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [postCell.cellFace setImage:image];
                if ([[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
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
                NSLog(@"pulling image for row %ld", (long)indexPath.row);
                NSLog(@"codekey is %@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
                if ([[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
                {
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
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
                    self.downloadRequest.key = [[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"];
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
            [postCell.cellFace setContentMode:UIViewContentModeScaleAspectFill];
            //postCell.layer.cornerRadius = 42.0f;
            //postCell.layer.borderWidth = 1.0f;
            postCell.layer.borderColor = [UIColor clearColor].CGColor;
            postCell.layer.masksToBounds = YES;
            [postCell.contentView bringSubviewToFront:postCell.cellButton];
        }
        else
        {
            NSLog(@"returning cell for %@",indexPath);
            //freshest array
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:0];
            //NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:collectionView.tag];
            //NSLog(@"dojoDictMajor contains %@",dojoDictMajor);
            //NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            //NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            
            NSArray *freshestMajor = [dojoDictMajor objectAtIndex:1];
            NSLog(@"POSTHASH is %@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
            //latest
            UIImage *image = [[UIImage alloc] init];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
            NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
            
            if ([fileManager fileExistsAtPath:picPath])
            {
                //load this instead
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [postCell.cellFace setImage:image];
                if ([[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
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
                NSLog(@"pulling image for row %ld", (long)indexPath.row);
                NSLog(@"codekey is %@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]);
                if ([[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"] rangeOfString:@"clip"].location == 0)
                {
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",[[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"]];
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
                    self.downloadRequest.key = [[freshestMajor objectAtIndex:indexPath.row] valueForKey:@"posthash"];
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
            [postCell.cellFace setContentMode:UIViewContentModeScaleAspectFill];
            //postCell.layer.cornerRadius = 42.0f;
            //postCell.layer.borderWidth = 1.0f;
            postCell.layer.borderColor = [UIColor clearColor].CGColor;
            postCell.layer.masksToBounds = YES;
            [postCell.contentView bringSubviewToFront:postCell.cellButton];
        }
        //[postCell.contentView insertSubview:postCell.cellButton atIndex:([[postCell.contentView subviews] count] -1)];
        [postCell.contentView addSubview:postCell.cellButton];
        return postCell;
    }
    else
    {
        DOJOPostCollectionViewCell *postCell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"postCell" forIndexPath:indexPath];
        return postCell;
    }
}

- (CGSize)collectionView:(DOJOPicView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}
/*
// THIS ONLY GOES IN SUBCLASSED FLOW LAYOUT WHATEVER
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(dojoCell.picView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, dojoCell.picView.bounds.size.width, dojoCell.picView.bounds.size.height);
    NSArray* array = [dojoCell.picView.superclass layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSLog(@"select the create button");
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [homeVC toCreateGroup];
    }
    if (self.isSearching == NO)
    {
        if (indexPath.section == 1)
        {
            //UIButton *button = [[UIButton alloc] init];
            //button.tag = (NSInteger)indexPath.row;
        }
    }
    else
    {
        
    }
}



-(IBAction)acceptInvitation:(UIButton *)button
{
    @try {
        if ([button.titleLabel.text isEqualToString:@"0"])
        {
            NSLog(@"button selector setting with button number %ld",(long)button.tag);
            indexOfSelectedButton = button.tag;
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
            NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:indexOfSelectedButton];
            NSLog(@"dojoDictMajor contains %@", dojoDictMajor);
            NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            
            if ([[dojoDictMajor objectAtIndex:2] isEqualToString:@"invited"])
            {
                // dojo is open
                NSError *error;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], [dojoDictMinor valueForKey:@"dojohash"], @"correct"] forKeys:@[@"email", @"dojohash",@"correct"]];
                NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfollowDojo.php",SERVERADDRESS]]];
                
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
                //dojoTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
                NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                [self loadDojoHomeNotSearching];
            }
            else
            {
                if ([[dojoDictMinor valueForKey:@"code"] isEqualToString:@""])
                {
                    // dojo is open
                    NSError *error;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], [dojoDictMinor valueForKey:@"dojohash"], @"correct"] forKeys:@[@"email", @"dojohash",@"correct"]];
                    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfollowDojo.php",SERVERADDRESS]]];
                    
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
                    //dojoTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
                    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                    //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
                    NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                    [self loadDojoHomeNotSearching];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[dojoDictMinor valueForKey:@"dojo"] message:@"Code?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join",@"Reject", nil];
                    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *codeTextField = [alertView textFieldAtIndex:0];
                    alertView.tag = 2;
                    [alertView show];
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@", exception);
    }
    @finally {
        NSLog(@"ran through the accept invitiation block");
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        NSLog(@"alert view button pressed is %ld",(long)buttonIndex);
        if (alertView.tag == 2)
        {
            NSLog(@"selected row is %ld, entered pass is %@", (long)indexOfSelectedButton, [alertView textFieldAtIndex:0].text);
            NSString *enteredCode = [alertView textFieldAtIndex:0].text;
            NSArray *dojoAllArray = [dojoTableViewData objectAtIndex:1];
            NSLog(@"dojoAllArray contains %@", dojoAllArray);
            NSArray *dojoDictMajor = [dojoAllArray objectAtIndex:indexOfSelectedButton];
            NSLog(@"dojoDictMajor contains %@", dojoDictMajor);
            NSDictionary *dojoDictMinor = [[dojoDictMajor objectAtIndex:0] objectAtIndex:0];
            NSLog(@"dojoDictMinor contains %@",dojoDictMinor);
            if (buttonIndex == 1)
            {
                if ([[dojoDictMinor valueForKey:@"code"] isEqualToString:enteredCode])
                {
                    // correct code was entered
                    NSLog(@"correct code was entered");
                    NSError *error;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], [dojoDictMinor valueForKey:@"dojohash"], @"correct"] forKeys:@[@"email", @"dojohash",@"correct"]];
                    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfollowDojo.php",SERVERADDRESS]]];
                    
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
                    //dojoTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
                    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                    //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
                    NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                    [self loadDojoHomeNotSearching];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[dojoDictMinor valueForKey:@"dojo"] message:@"nah, try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join",@"Reject", nil];
                    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *codeTextField = [alertView textFieldAtIndex:0];
                    alertView.tag = 2;
                    [alertView show];
                }
            }
            else if (buttonIndex == 0)
            {
                NSLog(@"closed alert view");
            }
            else if (buttonIndex == 2)
            {
                // correct code was entered
                NSLog(@"correct code was entered");
                NSError *error;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], [dojoDictMinor valueForKey:@"dojohash"]] forKeys:@[@"email", @"dojohash"]];
                NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%srejectInvite.php",SERVERADDRESS]]];
                
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
                //dojoTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
                NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                [self loadDojoHomeNotSearching];
            }
            else
            {
                NSLog(@"bad code was entered");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong code, Try again" message:@"Code?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                UITextField *codeTextField = [alertView textFieldAtIndex:0];
                alertView.tag = 2;
                [alertView show];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"wonky wonk");
    }
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
