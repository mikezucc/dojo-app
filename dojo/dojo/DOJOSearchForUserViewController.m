//
//  DOJOSearchForUserViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 9/15/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSearchForUserViewController.h"

@interface DOJOSearchForUserViewController ()

@end

@implementation DOJOSearchForUserViewController

@synthesize searchBar, searchTableView, searchTableViewData, rowSelected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)prefersStatusBarHidden { return YES; }

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchTableViewData count];
}

-(DOJOSearchFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOSearchFriendCell *cell = (DOJOSearchFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"daCell" forIndexPath:indexPath];
    
    UIImage *acceptFriendImage = [[UIImage alloc] init];
    acceptFriendImage = [UIImage imageNamed:@"add.png"];
    [cell.requestFriendButton setBackgroundImage:acceptFriendImage forState:UIControlStateNormal];
    cell.requestFriendButton.tag = indexPath.row;
    
    NSDictionary *personInfo = [searchTableViewData objectAtIndex:indexPath.row];
    NSString *fullname = [personInfo objectForKey:@"fullname"];
    cell.friendName.text = fullname;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)SB
{
    @try {
        NSLog(@"clicked search button");
        NSString *searchText = SB.text;
        NSLog(@"search text is %@",searchText);
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchText] forKeys:@[@"email", @"nameChunk"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchForFriend.php",SERVERADDRESS]]];
        
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
        NSLog(@"decodestring = GET SEARCH LIST IS %@",decodedString);
        
        [searchTableView reloadData];

    }
    @catch (NSException *exception) {
        NSLog(@"SEARCH FOR USER BUTTON VIEW problem load: %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"ran through searchbar button clicked");
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowSelected = (NSInteger *)indexPath.row;
    NSLog(@"clicked change friend request button (ROW REQUEST) at row %d", (int)rowSelected);
    NSDictionary *personInfo = [searchTableViewData objectAtIndex:rowSelected];
    NSString *fullname = [personInfo objectForKey:@"fullname"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Add %@ as a friend?",fullname] delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes!", nil];
    [alertView show];
}

-(IBAction)changeFriendRequestStatus:(UIButton *)button
{
    rowSelected = (NSInteger *)button.tag;
    NSLog(@"clicked change friend request button at row %d", (int)rowSelected);
    NSDictionary *personInfo = [searchTableViewData objectAtIndex:rowSelected];
    NSString *fullname = [personInfo objectForKey:@"fullname"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Add %@ as a friend?",fullname] delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes!", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        NSLog(@"button index clicked is %d",(int)buttonIndex);
        if ((int)buttonIndex == 1)
        {
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            
            NSDictionary *personInfo = [searchTableViewData objectAtIndex:(int)rowSelected];
            NSString *friendEmail = [personInfo objectForKey:@"email"];
            
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], friendEmail] forKeys:@[@"user1", @"user2"]];
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
            //searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            //NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
            NSLog(@"decodestring = GET SEARCH LIST IS %@",decodedString);
            
            error = [[NSError alloc] init];
            dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], searchBar.text] forKeys:@[@"email", @"nameChunk"]];
            result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchForFriend.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:result];
            
            response = nil;
            error = nil;
            
            //fire the request and wait for response
            result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            searchTableViewData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"GET SEARCH LIST IS \n%@",searchTableViewData);
            NSLog(@"decodestring = GET SEARCH LIST IS %@",decodedString);
            
            [searchTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"SEARCH FOR USER alert VIEW problem load: %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"ran through alert view block");
    }
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBarPassed
{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        if ([[virginDict valueForKey:@"FindFriendVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Look up a friend by name. I guess it doesn't need an explanation. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"FindFriendVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Look up a friend by name. I guess it doesn't need an explanation. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"FindFriendVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    [searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)removeFromStack:(id)sender
{
    NSLog(@"removing from stack");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
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
