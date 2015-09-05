//
//  DOJOSearch4DojosViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 10/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSearch4DojosViewController.h"
#import "DOJOCellButton.h"

@interface DOJOSearch4DojosViewController () <CellButtonTouchEventDelegate>

@property NSInteger locUpdateCount;

@end

@implementation DOJOSearch4DojosViewController

@synthesize searchCell, searchTableView, dojoSearchBar, initialSearchString, searchTableViewData, modeSwitcha, dojoLocation, dojoLocationManager, locationTableViewData, downloadRequest, joinAlertView, selectedDojoInfo, foundLocationYet, sawFirstTime,locUpdateCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.dojoSearchBar = [[UISearchBar alloc] init];
    //self.dojoSearchBar.delegate = self;
    //[dojoSearchBar becomeFirstResponder];
    
    //self.searchTableView.estimatedRowHeight = 67.0;
    self.searchTableView.delegate = self;
    self.searchTableView.tag = 10000;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // user allowed
        [self.dojoLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.dojoLocationManager startUpdatingLocation];
        NSLog(@"authorization status is %d",status);
        NSLog(@"authorized");
    }
    NSLog(@"authorization status did change");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"array of locations is %@",locations);
    CLLocation *location;
    CLLocation *winningLocation;
    CLLocation *testLocation;
    winningLocation = (CLLocation *)[locations objectAtIndex:0];
    
    if ([locations count] > 1)
    {
        for (location in locations)
        {
            NSLog(@"lat %f, long %f",location.coordinate.latitude, location.coordinate.longitude);
            testLocation = location;
            if (((NSTimeInterval)[testLocation.timestamp timeIntervalSinceDate:winningLocation.timestamp]) > 0)
            {
                winningLocation = testLocation;
            }
        }
    }
    dojoLocation = winningLocation;
    if (!self.foundLocationYet)
    {
        self.foundLocationYet = YES;
        @try {
            [self reloadTheSearchData];
        }
        @catch (NSException *exception) {
            NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
        }
        @finally {
            NSLog(@"couldnt load the page because network");
        }
    }
    //NSLog(@"current location is latitude %f, longitude %f",(float)newLocation.coordinate.latitude, (float)newLocation.coordinate.longitude);
    if (locUpdateCount == 5)
    {
        [self.dojoLocationManager stopUpdatingLocation];
    }
    locUpdateCount++;
}

-(BOOL)prefersStatusBarHidden
{
    return  YES;
}

-(IBAction)inviteYourself:(DOJOInviteButton *)button
{
    @try {
        if (button.searchType == 0)
        {
            NSLog(@"search type is 0");
            NSLog(@"button search type %ld, button search section %ld, button search section %ld",(long)button.searchType, (long)button.section, (long)button.tag);
            
            selectedDojoInfo = [[searchTableViewData objectAtIndex:button.tag] objectAtIndex:1];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
            [selectedDojoInfo writeToFile:plistPath atomically:YES];
            NSLog(@"selectedDojoInfo is %@",selectedDojoInfo);
            if ([[selectedDojoInfo objectForKey:@"code" ] isEqualToString:@""])
            {
                [self toDojoPage];
            }
            else
            {
                joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[selectedDojoInfo objectForKey:@"dojo"] message:@"This dojo has a password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open",@"Follow",@"Request", nil];
                joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                joinAlertView.selectedDojoMeta = selectedDojoInfo;
                [joinAlertView show];
            }
        }
        else
        {
            NSLog(@"search type is 1");
            NSLog(@"button search type %ld, button search section %ld, button search section %ld",(long)button.searchType, (long)button.section, (long)button.tag);
            
            selectedDojoInfo = [[[locationTableViewData objectAtIndex:button.section] objectAtIndex:button.tag] objectAtIndex:2];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
            [selectedDojoInfo writeToFile:plistPath atomically:YES];
            NSLog(@"selectedDojoInfo is %@",selectedDojoInfo);
            if ([[selectedDojoInfo objectForKey:@"code" ] isEqualToString:@""])
            {
                [self toDojoPage];
            }
            else
            {
                NSString *dojohash = [selectedDojoInfo objectForKey:@"dojohash"];
                NSError *error;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash",@"byWho"]];
                NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%scheckIfFollow.php",SERVERADDRESS]]];
                
                //customize request information
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:result];
                
                //NSURLResponse *response = nil;
                error = nil;
                
                //fire the request and wait for response
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"FOLLOWSTATUS %@",decodedString);
                    if ([decodedString isEqualToString:@"not"])
                    {
                        //do nothing
                        joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[selectedDojoInfo objectForKey:@"dojo"] message:@"This dojo has a password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open",@"Follow",@"Request", nil];
                        joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        joinAlertView.selectedDojoMeta = selectedDojoInfo;
                        joinAlertView.section = button.section;
                        [joinAlertView show];
                    }
                    else
                    {
                        [self toDojoPage];
                    }
                }];
            }
        }
        /*
        NSArray *resultData = [searchTableViewData objectAtIndex:button.tag];
        NSDictionary *dojodict = [resultData objectAtIndex:1];
        NSString *dojohash = [dojodict objectForKey:@"dojohash"];
        
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash",@"byWho"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.193.25.91/dojo-site-api/elevate18/inviteUserToDojo.php"]]];
        
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
        //searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
        NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        
        [self reloadTheSearchData];
         */
    }
    @catch (NSException *exception) {
        NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"ran through invite YOSELF IBTCH");
    }
}

-(void)alertView:(DOJOSearchJoinAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button %ld, section %ld, row %ld, selected info %@",(long)buttonIndex,(long)alertView.section, (long)alertView.tag, alertView.selectedDojoMeta);
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        if ([[alertView.selectedDojoMeta objectForKey:@"code"] isEqualToString:@""])
        {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Cancel");
                    break;
                case 1:
                    NSLog(@"Open");
                    [self toDojoPage];
                    break;
                case 2:
                    NSLog(@"Follow");
                    [self followTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                case 3:
                    NSLog(@"Request");
                    [self requestTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                default:
                    break;
            }
        }
        else
        {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Cancel");
                    break;
                case 1:
                    NSLog(@"Open");
                    if ([[alertView textFieldAtIndex:0].text isEqualToString:[alertView.selectedDojoMeta objectForKey:@"code"]])
                    {
                        [self toDojoPage];
                    }
                    else
                    {
                        joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[alertView.selectedDojoMeta objectForKey:@"dojo"] message:@"That was not correct, try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", @"Follow",@"Request", nil];
                        joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        joinAlertView.selectedDojoMeta = alertView.selectedDojoMeta;
                        joinAlertView.section = alertView.section;
                        [joinAlertView show];
                    }
                    break;
                case 2:
                    NSLog(@"Follow");
                    if ([[alertView textFieldAtIndex:0].text isEqualToString:[alertView.selectedDojoMeta objectForKey:@"code"]])
                    {
                        [self followTheYellowBrickRoad:alertView.selectedDojoMeta];
                    }
                    else
                    {
                        joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[alertView.selectedDojoMeta objectForKey:@"dojo"] message:@"That was not correct, try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", @"Follow",@"Request", nil];
                        joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        joinAlertView.selectedDojoMeta = alertView.selectedDojoMeta;
                        joinAlertView.section = alertView.section;
                        [joinAlertView show];
                    }
                    break;
                case 3:
                    NSLog(@"Request");
                    [self requestTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                default:
                    break;
            }
        }
    }
    else
    {
        if ([[alertView.selectedDojoMeta objectForKey:@"code"] isEqualToString:@""])
        {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Cancel");
                    break;
                case 1:
                    NSLog(@"Open");
                    [self toDojoPage];
                    break;
                case 2:
                    NSLog(@"Follow");
                    [self followTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                case 3:
                    NSLog(@"Request");
                    [self requestTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                default:
                    break;
            }
        }
        else
        {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Cancel");
                    break;
                case 1:
                    NSLog(@"Open");
                    if ([[alertView textFieldAtIndex:0].text isEqualToString:[alertView.selectedDojoMeta objectForKey:@"code"]])
                    {
                        [self toDojoPage];
                    }
                    else
                    {
                        joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[alertView.selectedDojoMeta objectForKey:@"dojo"] message:@"That was not correct, try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", @"Follow",@"Request", nil];
                        joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        joinAlertView.selectedDojoMeta = alertView.selectedDojoMeta;
                        joinAlertView.section = alertView.section;
                        [joinAlertView show];
                    }
                    break;
                case 2:
                    NSLog(@"follow");
                    if ([[alertView textFieldAtIndex:0].text isEqualToString:[alertView.selectedDojoMeta objectForKey:@"code"]])
                    {
                        [self followTheYellowBrickRoad:alertView.selectedDojoMeta];
                    }
                    else
                    {
                        joinAlertView = [[DOJOSearchJoinAlertView alloc] initWithTitle:[alertView.selectedDojoMeta objectForKey:@"dojo"] message:@"That was not correct, try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", @"Follow",@"Request", nil];
                        joinAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                        joinAlertView.selectedDojoMeta = alertView.selectedDojoMeta;
                        joinAlertView.section = alertView.section;
                        [joinAlertView show];
                    }
                    break;
                case 3:
                    NSLog(@"request");
                    [self requestTheYellowBrickRoad:alertView.selectedDojoMeta];
                    break;
                default:
                    break;
            }
        }
    }
}

-(void)requestTheYellowBrickRoad:(NSDictionary *)selectedMeta
{
    NSString *dojohash = [selectedMeta objectForKey:@"dojohash"];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash",@"byWho"]];
    NSLog(@"dacia sandero is %@",dataDict);
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%srequestUserToDojo.php",SERVERADDRESS]]];
    
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
    //searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    //NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
    NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
    
    [self reloadTheSearchData];
}


-(void)followTheYellowBrickRoad:(NSDictionary *)selectedMeta
{
    NSString *dojohash = [selectedMeta objectForKey:@"dojohash"];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash",@"byWho"]];
    NSLog(@"dacia sandero is %@",dataDict);
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sinviteUserToDojo.php",SERVERADDRESS]]];
    
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
    //searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    //NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
    NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
    
    [self reloadTheSearchData];
}

-(void)toDojoPage
{
    NSLog(@"toDojoPage");
    //[[[UIApplication sharedApplication].windows objectAtIndex:0] makeKeyAndVisible];
    [self.storyboard instantiateViewControllerWithIdentifier:@"dojoSpecialPage"];
    [self performSegueWithIdentifier:@"fromSearchToDojoSpecial" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"fromSearchToDojoSpecial"])
    {
        DOJOSpecialDojoPageViewController *vc = [segue destinationViewController];
        vc.dojoData = selectedDojoInfo;
        NSLog(@"applying properties");
    }
}

-(IBAction)changeSearchType:(UISegmentedControl *)segmentedControl
{
    [dojoSearchBar resignFirstResponder];
    NSLog(@"search Type is %ld",(long)segmentedControl.selectedSegmentIndex);
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        [self.dojoSearchBar setHidden:NO];
        [self.searchTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else
    {
        [self.dojoSearchBar setHidden:YES];
        [self.searchTableView setContentOffset:CGPointMake(0, 43) animated:NO];
    }
    [self reloadTheSearchData];
}

-(IBAction)refreshSearch:(id)sender
{
    NSLog(@"refresh the search");
    [self reloadTheSearchData];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.sawFirstTime)
    {
        locUpdateCount = 0;
#ifdef __IPHONE_8_0
        
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            self.dojoLocationManager = [[CLLocationManager alloc] init];
            [self.dojoLocationManager setDelegate:self];
            [self.dojoLocationManager requestWhenInUseAuthorization];
            NSLog(@"requesting in use authorization");
        }
#else
        //register to receive notifications

#endif
        
        self.foundLocationYet = NO;
        
        [modeSwitcha setSelectedSegmentIndex:1];
        [self.dojoSearchBar setHidden:YES];
        
        //[dojoSearchBar setText:initialSearchString];
        NSLog(@"initial passed string is %@",initialSearchString);
        [dojoSearchBar showsCancelButton];
    }
    else
    {
        [self reloadTheSearchData];
    }
    /*
    @try {
        [self reloadTheSearchData];
    }
    @catch (NSException *exception) {
        NSLog(@"invite yourself serch4dojoproblem load: %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"couldnt load the page because network");
    }
     */
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,40)];
    tempView.backgroundColor=[UIColor colorWithRed:112.0/255.0 green:232.0/255.0 blue:70.0/255.0 alpha:1.0];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,10,320,25)];
    
    //tempLabel.backgroundColor=[UIColor clearColor];
    //tempLabel.shadowColor = [UIColor whiteColor];
    //tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
    tempLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    //tempLabel.font = [UIFont boldSystemFontOfSize:20];
    NSString *sectionTitle;
    if (modeSwitcha.selectedSegmentIndex == 1)
    {
        switch (section) {
            case 0:
                sectionTitle = @"campus";
                break;
            case 1:
                sectionTitle = @"close";
                break;
            case 2:
                sectionTitle = @"nearby";
                break;
            case 3:
                sectionTitle = @"around";
                break;
            case 4:
                sectionTitle = @"city";
                break;
                
            default:
                sectionTitle = @"somewhere";
                break;
        }
    }
    else
    {
        return nil;
    }

    tempLabel.text=sectionTitle;
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"did reach the top");
    if (modeSwitcha.selectedSegmentIndex == 1)
    {
        [self.searchTableView setContentOffset:CGPointMake(0, 45) animated:YES];
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
        if ([[virginDict valueForKey:@"SearchVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is where it gets hype. When you search by Location, you can see Dojos that are searchable by location. So anything in Campus is probably within a half mile or so. It goes out from there so you can probably see what's going on at a rival campus. Talk and hype with the community, and follow them if you want to post and keep track. When browsing, your abilities are limited, but if you follow a Dojo you get full access. Tap Search to refresh the community. <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"SearchVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is where it gets hype. When you search by Location, you can see Dojos that are searchable by location. So anything in Campus is probably within a half mile or so. It goes out from there so you can probably see what's going on at a rival campus. Talk and hype with the community, and follow them if you want to post and keep track. When browsing, your abilities are limited, but if you follow a Dojo you get full access. Tap Search to refresh the community. <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"SearchVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    if (!self.sawFirstTime)
    {
        [self.searchTableView setContentOffset:CGPointMake(0, 45) animated:YES];
    }
    //[self.searchTableView setSectionIndexColor:[UIColor whiteColor]];
    self.sawFirstTime = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)removeYoself:(id)sender
{
    [dojoLocationManager stopUpdatingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        return 1;
    }
    else if (modeSwitcha.selectedSegmentIndex == 1)
    {
        return 5;
    }
    else
    {
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        return @"";
    }
    if (modeSwitcha.selectedSegmentIndex == 1)
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
    else
    {
        return @"results";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        return [searchTableViewData count];
    }
    if (modeSwitcha.selectedSegmentIndex == 1)
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
    else
    {
        return 0;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [dojoSearchBar resignFirstResponder];
    NSLog(@"did reach the top, with tag %ld",(long)scrollView.tag);
    if (modeSwitcha.selectedSegmentIndex == 1)
    {
        if (scrollView.contentOffset.y == 0 && scrollView.tag == 10000)
        {
            [self.searchTableView setContentOffset:CGPointMake(0, 45) animated:YES];
        }
    }
}

-(DOJOSearch4DojoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    searchCell.picView.pagingEnabled = YES;
    searchCell.picView.tag = indexPath.row;
    searchCell.picView.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1 alpha:1];
    [searchCell.picView reloadData];
    
    if (modeSwitcha.selectedSegmentIndex == 0)
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
    searchCell.picView.section = indexPath.section;
    searchCell.addButton.section = indexPath.section;
    [searchCell.contentView addSubview:searchCell.picView];
    [searchCell.contentView addSubview:searchCell.alphaBar];
    [searchCell.contentView addSubview:searchCell.dojoLabel];
    [searchCell.contentView addSubview:searchCell.nameLabel];
    [searchCell.contentView addSubview:searchCell.distanceLabel];
    [searchCell.contentView addSubview:searchCell.addButton];
    return searchCell;
}

-(NSInteger)collectionView:(DOJOPicView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"section %ld attempting to load for collection view %ld",(long)section), (long)collectionView.section;
    NSArray *postArray;
    if (modeSwitcha.selectedSegmentIndex == 0)
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
            postArray = [[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5];
            if ([postArray count] == 0)
            {
                return 1;
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

-(NSInteger)numberOfSectionsInCollectionView:(DOJOPicView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(DOJOPicView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,250);
}

-(DOJOPostCollectionViewCell *)collectionView:(DOJOPicView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOPostCollectionViewCell *cell = (DOJOPostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"searchPostCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0 green:0.678 blue:1 alpha:1];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *postArray;
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        postArray = [[searchTableViewData objectAtIndex:collectionView.tag] objectAtIndex:4];
        if ([postArray count] == 0)
        {
            [cell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.cellButton setTitle:@"no posts!" forState:UIControlStateNormal];
            [cell.cellButton setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1]];
            return cell;
        }
    }
    else
    {
        postArray = [[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5];
        if ([postArray count] == 0)
        {
            [cell.cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.cellButton setTitle:@"no posts!" forState:UIControlStateNormal];
            [cell.cellButton setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1]];
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
        }
        else
        {
            NSLog(@"pulling image for row %ld", (long)indexPath.row);
            NSLog(@"codekey is %@",posthash);
            if ([posthash rangeOfString:@"clip"].location == 0)
            {
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

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

-(void)reloadTheSearchData
{
    NSLog(@"%ld",(long)modeSwitcha.selectedSegmentIndex);
    dojoLocation = dojoLocationManager.location;
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        NSLog(@"by name");
        @try {
            NSString *searchText = dojoSearchBar.text;
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:dojoLocation.coordinate.latitude], [NSNumber numberWithDouble:dojoLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
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
            
            [searchTableView reloadData];
            
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
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:dojoLocation.coordinate.latitude], [NSNumber numberWithDouble:dojoLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
            NSLog(@"dacia sandero is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchByLocation.php",SERVERADDRESS]]];
            
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
            
            [searchTableView reloadData];
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


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //    [dojoTableView reloadData];
    // [dojoTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationLeft];
    NSLog(@"%ld",(long)modeSwitcha.selectedSegmentIndex);
    NSLog(@"location is %@",dojoLocation);
    if (modeSwitcha.selectedSegmentIndex == 0)
    {
        NSLog(@"by name");
        @try {
            NSString *searchText = searchBar.text;
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:dojoLocation.coordinate.latitude], [NSNumber numberWithDouble:dojoLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
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
            
            [searchTableView reloadData];
            
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
    else
    {
        NSLog(@"by location");
        @try {
            NSString *searchText = searchBar.text;
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText, [NSNumber numberWithDouble:dojoLocation.coordinate.latitude], [NSNumber numberWithDouble:dojoLocation.coordinate.longitude]] forKeys:@[@"email", @"dojo",@"lati",@"longi"]];
            NSLog(@"dacia sandero is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchByLocation.php",SERVERADDRESS]]];
            
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
            
            [searchTableView reloadData];
            
        }
        @catch (NSException *exception) {
            NSLog(@"locations yourself serch4dojoproblem load: %@",exception);
            UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [networkFailure show];
        }
        @finally {
            NSLog(@"swanky swank");
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBarPassed
{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchTableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [dojoSearchBar resignFirstResponder];
    [dojoLocationManager stopUpdatingLocation];
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
