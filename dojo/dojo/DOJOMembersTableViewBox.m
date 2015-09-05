//
//  DOJOMembersTableViewBox.m
//  dojo
//
//  Created by Michael Zuccarino on 7/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMembersTableViewBox.h"

@implementation DOJOMembersTableViewBox

@synthesize nameCell, nameTableView, isSearching, userEmail, memberList, currentdojoinfo, allDatas, sumoList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.nameTableView = [[UITableView alloc] init];
        [self.nameTableView setDelegate:self];
        [self.nameTableView setDataSource:self];
        [self.nameTableView registerClass:[DOJOMembersTableViewCell class] forCellReuseIdentifier:@"nameCell"];
    }
    self.isSearching = NO;

    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //load user email lols
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [loadedDict valueForKey:@"userEmail"];

    NSString *newPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfonotfucked.plist"]];
    currentdojoinfo = [[NSDictionary alloc] initWithContentsOfFile:newPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        NSLog(@"file exists at %@",newPath);
    }
    else
    {
        NSLog(@"file DONT exist at %@",newPath);
    }
    NSLog(@"currentdojoinfo is %@",currentdojoinfo);
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[currentdojoinfo objectForKey:@"dojohash"], userEmail] forKeys:@[@"dojohash",@"email"]];
        NSLog(@"dataDict is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoMemberList.php",SERVERADDRESS]]];
        
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
        allDatas = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"SEARCH QUERY RETURNED: %@",allDatas);
        NSLog(@"DECODED STRING IS %@", decodedString);
        
        memberList = [allDatas objectAtIndex:0];
        sumoList = [allDatas objectAtIndex:1];
        
        return 2;

    }
    @catch (NSException *exception) {
        NSLog(@"data paremeter failed");
        return 0;
    }
    @finally {
        NSLog(@"ran through the network request block in members table view");
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((int)section == 0)
    {
        return @"alreddy members";
    }
    if ((int)section == 1)
    {
        return @"add su mo";
    }
    else
    {
        return @"";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((int)section == 0)
    {
        return [memberList count];;
    }
    if ((int)section == 1)
    {
        return [sumoList count];
    }
    else
    {
        return 0;
    }
    NSLog(@"number of members is %d",(int)[memberList count]);
}

-(DOJOMembersTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    nameCell = (DOJOMembersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
    if ((int)indexPath.section == 0)
    {
        //UIImage *check = [UIImage imageNamed:@"accept.png"];
        NSDictionary *inviteInfo = [[memberList objectAtIndex:indexPath.row] objectAtIndex:0];
        if ([[inviteInfo objectForKey:@"status"] isEqualToString:@"invited"])
        {
            UIImage *check = [UIImage imageNamed:@"checked-purps.png"];
            [nameCell.checkImage setImage:check];
            [nameCell.checkImage setAlpha:0.3];
            UIImage *acceptinvite = [UIImage imageNamed:@"sent.png"];
            [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
            [nameCell.friendButton setEnabled:NO];
        }
        if ([[inviteInfo objectForKey:@"status"] isEqualToString:@"joined"])
        {
            UIImage *check = [UIImage imageNamed:@"checkedSelected.png"];
            [nameCell.checkImage setImage:check];
            [nameCell.friendButton setEnabled:YES];
            UIImage *acceptinvite = [UIImage imageNamed:@"invisible.png"];
            [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
        }
        if ([[inviteInfo objectForKey:@"status"] isEqualToString:@"requested"])
        {
            UIImage *check = [UIImage imageNamed:@"checked-purps.png"];
            [nameCell.checkImage setImage:check];
            [nameCell.friendButton setEnabled:YES];
            UIImage *acceptinvite = [UIImage imageNamed:@"accept.png"];
            [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
        }
        
        NSDictionary *personInfo = [[memberList objectAtIndex:indexPath.row] objectAtIndex:1];
        NSLog(@"person is %@",personInfo);
        [nameCell.nameLabel setText:[personInfo objectForKey:@"fullname"]];
        NSLog(@"namelabel is %@ with fullbame %@",nameCell.nameLabel,[personInfo objectForKey:@"fullname"]);
        
        /*
        NSDictionary *personStatus = [[memberList objectAtIndex:indexPath.row] objectAtIndex:2];
        NSLog(@"personStatus is %@",personStatus);
        if ([[personStatus objectForKey:@"status"] isEqualToString:@"requested1"])
        {
            if ([[personStatus objectForKey:@"user1"] isEqualToString:userEmail])
            {
                [nameCell.friendButton setEnabled:YES];
                UIImage *acceptinvite = [UIImage imageNamed:@"accept.png"];
                [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
            }
            else
            {
                UIImage *acceptinvite = [UIImage imageNamed:@"sent.png"];
                [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
                [nameCell.friendButton setEnabled:NO];
            }
        }
        else
        {
            UIImage *acceptFriendImage = [[UIImage alloc] init];
            acceptFriendImage = [UIImage imageNamed:@"invisible.png"];
            [nameCell.friendButton setBackgroundImage:acceptFriendImage forState:UIControlStateNormal];
            [nameCell.friendButton setEnabled:NO];
        }
        if ([[personStatus objectForKey:@"status"] isEqualToString:@"requested2"])
        {
            if ([[personStatus objectForKey:@"user1"] isEqualToString:userEmail])
            {
                UIImage *acceptinvite = [UIImage imageNamed:@"sent.png"];
                [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
                [nameCell.friendButton setEnabled:NO];
            }
            else
            {
                [nameCell.friendButton setEnabled:YES];
                UIImage *acceptinvite = [UIImage imageNamed:@"accept.png"];
                [nameCell.friendButton setBackgroundImage:acceptinvite forState:UIControlStateNormal];
            }
        }
        */
        [nameCell.friendButton.titleLabel setText:@"0"];
        [nameCell.friendButton.titleLabel setTextColor:[UIColor clearColor]];
        nameCell.friendButton.tag = indexPath.row;
    }
    if ((int)indexPath.section == 1)
    {
        NSDictionary *personInfo = [[sumoList objectAtIndex:indexPath.row] objectAtIndex:0];
        NSLog(@"person is %@",personInfo);
        [nameCell.nameLabel setText:[personInfo objectForKey:@"fullname"]];
        NSLog(@"namelabel is %@ with fullbame %@",nameCell.nameLabel,[personInfo objectForKey:@"fullname"]);
        UIImage *acceptFriendImage = [[UIImage alloc] init];
        acceptFriendImage = [UIImage imageNamed:@"inviteimage.png"];
        [nameCell.friendButton setBackgroundImage:acceptFriendImage forState:UIControlStateNormal];
        nameCell.friendButton.tag = indexPath.row;
        [nameCell.friendButton setEnabled:YES];
        [nameCell.friendButton.titleLabel setText:@"1"];
        [nameCell.friendButton.titleLabel setTextColor:[UIColor clearColor]];
        UIImage *check = [UIImage imageNamed:@"invisible.png"];
        [nameCell.checkImage setImage:check];
    }
    return nameCell;
}

-(IBAction)inviteToDojo:(UIButton *)button
{
    @try {
        NSString *buttonText = button.titleLabel.text;
        if ([buttonText isEqualToString:@"0"])
        {
            NSInteger rowNum = (NSInteger)button.tag;
            NSLog(@"WENT THRU HERE");
            NSString *dojohash = [currentdojoinfo valueForKey:@"dojohash"];
            NSError *error;
            NSDictionary *inviteInfo = [[memberList objectAtIndex:rowNum] objectAtIndex:1];
            NSLog(@"person is %@",inviteInfo);
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[dojohash, [inviteInfo objectForKey:@"email"], @"member"] forKeys:@[@"dojohash",@"email",@"byWho"]];
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
            NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
            NSLog(@"DECODED STRING IS %@", decodedString);
            
            
            //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
            [nameTableView reloadData];
        }
        else if  ([buttonText isEqualToString:@"1"])
        {
            NSInteger rowNum = (NSInteger)button.tag;
            NSLog(@"WENT THRU HERE");
            NSString *dojohash = [currentdojoinfo valueForKey:@"dojohash"];
            NSError *error;
            NSDictionary *personInfo = [[sumoList objectAtIndex:rowNum] objectAtIndex:0];
            NSLog(@"person is %@",personInfo);
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[dojohash, [personInfo objectForKey:@"email"],@"member"] forKeys:@[@"dojohash",@"email",@"byWho"]];
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
            NSArray *dataFromRequest = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
            NSLog(@"DECODED STRING IS %@", decodedString);
            
            //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
            [nameTableView reloadData];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"invite to dojo n stuff");
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
