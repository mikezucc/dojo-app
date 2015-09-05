//
//  DOJOCreateGroupViewBox.m
//  dojo
//
//  Created by Michael Zuccarino on 7/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateGroupViewBox.h"

@implementation DOJOCreateGroupViewBox

@synthesize nameTableView, userEmail, tableViewList, statusSectionArray, friendSectionArray, rowSelected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.nameTableView = [[UITableView alloc] init];
        [self.nameTableView setDelegate:self];
        [self.nameTableView setDataSource:self];
        [self.nameTableView registerClass:[DOJOCreateGroupTableViewCell class] forCellReuseIdentifier:@"nameCell"];
    }
    
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //load user email lols
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
        NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        userEmail = [loadedDict valueForKey:@"userEmail"];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%selevate18/getUserFriendList.php",SERVERADDRESS]]];
        
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
        tableViewList = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"GET FRIEND LIST IS \n%@",tableViewList);
        NSLog(@"decodestring = GET FRIEND LIST IS %@",decodedString);
        return 2;

    }
    @catch (NSException *exception) {
        NSLog(@"exception at friend list load %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
        return 0;
    }
    @finally {
        NSLog(@"ran through friend load block");
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((int)section == 0)
    {
        return @"not yo frends yet";
    }
    else
    {
        return @"frends";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    statusSectionArray = [tableViewList objectAtIndex:0];
    friendSectionArray = [tableViewList objectAtIndex:1];
    if ((int)section == 0)
    {
        return [statusSectionArray count];
    }
    if ((int)section == 1)
    {
        return [friendSectionArray count];
    }
    else
    {
        return 0;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

-(DOJOCreateGroupTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOCreateGroupTableViewCell *nameCell = (DOJOCreateGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
    [nameCell.friendButton setFrame:CGRectMake(209, 13, 55, 18)];
    if ((int)indexPath.section == 0)
    {
        [nameCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [nameCell.inviteToDojoButton setEnabled:NO];
        UIImage *blankinvite = [UIImage imageNamed:@"invisible.png"];
        [nameCell.inviteToDojoButton setBackgroundImage:blankinvite forState:UIControlStateNormal];
        NSArray *personArray = [statusSectionArray objectAtIndex:indexPath.row];
        NSDictionary *personInfo = [personArray objectAtIndex:0];
        NSDictionary *personStatus = [personArray objectAtIndex:1];
        [nameCell.nameLabel setText:[personInfo objectForKey:@"fullname"]];
        if ([[personStatus objectForKey:@"status"] isEqualToString:@"requested1"])
        {
            if ([[personStatus objectForKey:@"user1"] isEqualToString:userEmail])
            {
                [nameCell.friendButton setEnabled:YES];
                UIImage *acceptinvite = [UIImage imageNamed:@"accept.png"];
                [nameCell.friendButton setImage:acceptinvite forState:UIControlStateNormal];
            }
            else
            {
                [nameCell.friendButton setEnabled:NO];
                UIImage *acceptinvite = [UIImage imageNamed:@"sent.png"];
                [nameCell.friendButton setImage:acceptinvite forState:UIControlStateDisabled];
            }
        }
        if ([[personStatus objectForKey:@"status"] isEqualToString:@"requested2"])
        {
            if ([[personStatus objectForKey:@"user1"] isEqualToString:userEmail])
            {
                [nameCell.friendButton setEnabled:NO];
                UIImage *acceptinvite = [UIImage imageNamed:@"sent.png"];
                [nameCell.friendButton setImage:acceptinvite forState:UIControlStateDisabled];
            }
            else
            {
                [nameCell.friendButton setEnabled:YES];
                UIImage *acceptinvite = [UIImage imageNamed:@"accept.png"];
                [nameCell.friendButton setImage:acceptinvite forState:UIControlStateNormal];
            }
        }
        [nameCell.friendButton setTitle:@"0" forState:UIControlStateNormal];
    }
    if ((int)indexPath.section == 1)
    {
        [nameCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [nameCell.friendButton setEnabled:YES];
        [nameCell.friendButton setTitle:@"1" forState:UIControlStateNormal];
        UIImage *acceptinvite = [UIImage imageNamed:@"removefriend.png"];
        NSLog(@"accept invite %@",acceptinvite);
        [nameCell.friendButton setImage:acceptinvite forState:UIControlStateNormal];
        [nameCell.friendButton setNeedsDisplay];
        [nameCell.inviteToDojoButton setEnabled:YES];
        UIImage *blankinvite = [UIImage imageNamed:@"invisible.png"];
        [nameCell.friendButton setBackgroundImage:blankinvite forState:UIControlStateNormal];
        NSArray *personArray = [friendSectionArray objectAtIndex:indexPath.row];
        NSDictionary *personInfo = [personArray objectAtIndex:0];
        [nameCell.nameLabel setText:[personInfo objectForKey:@"fullname"]];
        NSLog(@"PERSON INFO FRIEND IS \n%@",personInfo);
        
        //LOAD WHOLE RESULTS LIST
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //PERFORM CHECKED FILE OPERATION
    }
    nameCell.friendButton.tag = indexPath.row;
    nameCell.inviteToDojoButton.tag = indexPath.row;
    UIImage *blankinvite = [UIImage imageNamed:@"invisible.png"];
    [nameCell.inviteToDojoButton setImage:blankinvite forState:UIControlStateNormal];
    return nameCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    //LOAD WHOLE RESULTS LIST
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //TAKE RIGHT EMAIL BASED OFF TAG
    NSInteger rowNum = indexPath.row;
    NSArray *personArray = [friendSectionArray objectAtIndex:rowNum];
    NSDictionary *personInfo = [personArray objectAtIndex:0];
    NSString *selectedEmail = [personInfo objectForKey:@"email"];
    NSLog(@"selected email is %@", selectedEmail);
    
    //PERFORM CHECKED FILE OPERATION
    NSString *checkedListPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"checked.plist"]];
    
    if ([fileManager fileExistsAtPath:checkedListPath])
    {
        NSArray *checkedListArray = [[NSArray alloc] initWithContentsOfFile:checkedListPath];
        //NSLog(@"checked List Loaded contains ARRAY: %@", checkedListArray);
        NSInteger locationOfEmail = [checkedListArray indexOfObject:selectedEmail];
        NSLog(@"email at location %ld", (long)locationOfEmail);
        if (locationOfEmail >= 2147483647)
        {
            checkedListArray = [checkedListArray arrayByAddingObject:selectedEmail];
            NSLog(@"writing to file>> %@",checkedListArray);
            [checkedListArray writeToFile:checkedListPath atomically:YES];
        }
        else
        {
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:checkedListArray];
            [tempArr removeObject:selectedEmail];
            NSLog(@"removed array is now %@", tempArr);
            [tempArr writeToFile:checkedListPath atomically:YES];
        }
        
    }
    else
    {
        NSArray *arrayToWrite = @[selectedEmail];
        [arrayToWrite writeToFile:checkedListPath atomically:YES];
    }
    
    //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
    [nameTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowNum inSection:1]]withRowAnimation:UITableViewRowAnimationLeft];
     */
    [nameTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)inviteToDojo:(UIButton *)button
{
    //LOAD WHOLE RESULTS LIST
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //TAKE RIGHT EMAIL BASED OFF TAG
    NSInteger rowNum = button.tag;
    NSArray *personArray = [friendSectionArray objectAtIndex:rowNum];
    NSDictionary *personInfo = [personArray objectAtIndex:0];
    NSString *selectedEmail = [personInfo objectForKey:@"email"];
    NSLog(@"selected email is %@", selectedEmail);
    
    //PERFORM CHECKED FILE OPERATION
    NSString *checkedListPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"checked.plist"]];

    if ([fileManager fileExistsAtPath:checkedListPath])
    {
        NSArray *checkedListArray = [[NSArray alloc] initWithContentsOfFile:checkedListPath];
        NSLog(@"checked List Loaded contains ARRAY: %@", checkedListArray);
        NSInteger locationOfEmail = [checkedListArray indexOfObject:selectedEmail];
        NSLog(@"email at location %ld", (long)locationOfEmail);
        if (locationOfEmail >= 2147483647)
        {
            checkedListArray = [checkedListArray arrayByAddingObject:selectedEmail];
            NSLog(@"writing to file>> %@",checkedListArray);
            [checkedListArray writeToFile:checkedListPath atomically:YES];
        }
        else
        {
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:checkedListArray];
            [tempArr removeObject:selectedEmail];
            NSLog(@"removed array is now %@", tempArr);
            [tempArr writeToFile:checkedListPath atomically:YES];
        }
        
    }
    else
    {
        NSArray *arrayToWrite = @[selectedEmail];
        [arrayToWrite writeToFile:checkedListPath atomically:YES];
    }
    //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
    [nameTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowNum inSection:1]]withRowAnimation:UITableViewRowAnimationLeft];
}

-(IBAction)changeFriendRequestState:(UIButton *)button
{
    rowSelected = (NSInteger *)button.tag;
    if ([button.titleLabel.text isEqualToString:@"0"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Friend Request" message:@"Be my friend?" delegate:self cancelButtonTitle:@"Decide Later" otherButtonTitles:@"Yes",@"Reject", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else if ([button.titleLabel.text isEqualToString:@"1"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove this friend?" message:@"This will remove them from your friend list" delegate:self cancelButtonTitle:@"Keep" otherButtonTitles:@"Remove", nil];
        alertView.tag = 1;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        if (alertView.tag == 0)
        {
            if ((int)buttonIndex == 1)
            {
                //TAKE RIGHT EMAIL BASED OFF TAG
                NSArray *personArray = [statusSectionArray objectAtIndex:(int)rowSelected];
                NSDictionary *personInfo = [personArray objectAtIndex:0];
                NSString *selectedEmail = [personInfo objectForKey:@"email"];
                NSLog(@"selected email is %@", selectedEmail);
                
                NSError *error;
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[userEmail,selectedEmail] forKeys:@[@"user1",@"user2"]];
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
                NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
                NSLog(@"DECODED STRING IS %@", decodedString);
                
                [nameTableView reloadData];
            }
            if ((int)buttonIndex == 2)
            {
                //TAKE RIGHT EMAIL BASED OFF TAG
                NSArray *personArray = [statusSectionArray objectAtIndex:(int)rowSelected];
                NSDictionary *personInfo = [personArray objectAtIndex:0];
                NSString *selectedEmail = [personInfo objectForKey:@"email"];
                NSLog(@"selected email is %@", selectedEmail);
                
                NSError *error;
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[userEmail,selectedEmail] forKeys:@[@"email1",@"email2"]];
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
                NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
                NSLog(@"DECODED STRING IS %@", decodedString);
                
                [nameTableView reloadData];
            }
        }
        else if (alertView.tag == 1)
        {
            
            if ((int)buttonIndex == 1)
            {
                //TAKE RIGHT EMAIL BASED OFF TAG
                NSArray *personArray = [friendSectionArray objectAtIndex:(int)rowSelected];
                NSDictionary *personInfo = [personArray objectAtIndex:0];
                NSString *selectedEmail = [personInfo objectForKey:@"email"];
                NSLog(@"selected email is %@", selectedEmail);
                
                NSError *error;
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[userEmail,selectedEmail] forKeys:@[@"email1",@"email2"]];
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
                NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
                NSLog(@"DECODED STRING IS %@", decodedString);
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                //PERFORM CHECKED FILE OPERATION
                NSString *checkedListPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"checked.plist"]];
                if ([fileManager fileExistsAtPath:checkedListPath])
                {
                    NSError *error;
                    [fileManager removeItemAtPath:checkedListPath error:&error];
                }
                
                [nameTableView reloadData];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception in group view box friend accept %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"ran through add friend block");
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
