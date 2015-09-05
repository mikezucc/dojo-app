//
//  DOJOUpdateSettingsViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOUpdateSettingsViewController.h"

@interface DOJOUpdateSettingsViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property dispatch_queue_t profileQueue;

@end

@implementation DOJOUpdateSettingsViewController

@synthesize dojoCodeField, dojoNameField, userEmail, locationSwitch, secretSwitch, createButton, codeSwitch, friendTableView, friendList, selectedList, colorList, dojoInfo, allDatas, addSumoList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //load user email lols
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [loadedDict valueForKey:@"userEmail"];
    
    //[createButton.layer setCornerRadius:10];
    //createButton.layer.masksToBounds = YES;
    //createButton.clipsToBounds = YES;
    
    self.friendList = [[NSArray alloc] init];
    self.selectedList  = [[NSMutableArray alloc] init];
    self.colorList = [[NSMutableArray alloc] initWithArray:@[
                                                             [UIColor colorWithRed:188.0/255.0 green:216.0/255.0 blue:156.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:229.0/255.0 green:145.0/255.0 blue:246.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:247.0/255.0 green:239.0/255.0 blue:133.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:178.0/255.0 green:113.0/255.0 blue:234.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:246.0/255.0 green:88.0/255.0 blue:108.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:88.0/255.0 green:230.0/255.0 blue:246.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:134.0/255.0 green:156.0/255.0 blue:182.0/255.0 alpha:1],
                                                             ]];
    
    self.profileQueue = dispatch_queue_create("swag", DISPATCH_QUEUE_SERIAL);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)toggleCode:(id)sender
{
    if ([self.codeSwitch isOn])
    {
        [self.dojoCodeField setHidden:NO];
        [self.dojoCodeField becomeFirstResponder];
    }
    else
    {
        [self.dojoCodeField setHidden:YES];
        [self.dojoCodeField resignFirstResponder];
    }
}

-(NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 3; i++) {
        uint32_t r;
        
        // Append 2 random letters:
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        
        // Append 2 random digits:
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        
    }
    NSLog(@"s-->%@",s);
    return s;
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
        if ([[virginDict valueForKey:@"DojoSettingsVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Here you can change the Dojo name and code if you are the creator. You can also set the dojo to private in case last night got a little too live. See who's in on it by looking into Members. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"DojoSettingsVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Here you can change the Dojo name and code if you are the creator. You can also set the dojo to private in case last night got a little too live. See who's in on it by looking into Members. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"DojoSettingsVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    NSLog(@"PAGE SETTINGS >> dojoData is %@", dojoInfo);
    
    [self refreshMemberList];
}

-(void)refreshMemberList
{
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoInfo objectForKey:@"dojohash"], userEmail] forKeys:@[@"dojohash",@"email"]];
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
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSError *error;
            if (data)
            {
                allDatas = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                //NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"SEARCH QUERY RETURNED: %@",allDatas);
                //NSLog(@"DECODED STRING IS %@", decodedString);
                
                friendList = [allDatas objectAtIndex:0];
                addSumoList = [allDatas objectAtIndex:1];
                
                [self.friendTableView reloadData];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"data paremeter failed");
    }
    @finally {
        NSLog(@"ran through the network request block in members table view");
    }
}

-(IBAction)leaveDojo:(id)sender
{
    UIAlertView *wantToLeave = [[UIAlertView alloc] initWithTitle:@"u sure" message:@"leave now n hold peace frevr" delegate:self cancelButtonTitle:@"nah" otherButtonTitles:@"kk", nil];
    [wantToLeave show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        if (buttonIndex == 0)
        {
            //cancel button
        }
        if (buttonIndex == 1)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
            NSDictionary *currentdojo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSString *dojohash = [currentdojo valueForKey:@"dojohash"];
            plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSLog(@"PRESSED LEAVE DOJO");
            NSError *error;
            NSLog(@"dojohash is %@",dojohash);
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],dojohash] forKeys:@[@"email",@"dojohash"]];
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sleaveDojo.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
            NSLog(@"data .count is %ld", (long)dataDict.count);
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            error = nil;
            
            //fire the request and wait for response
            result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"%@",decodedString);
            
            if ([decodedString isEqualToString:@"\"removed\""])
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"alertview page settings is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"something went wrong" message:@"try refreshing the home page" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through try bock at dojopage settings alert view clicked button");
    }
}



-(IBAction)changeDojoName:(id)sender
{
    NSLog(@"change name");
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
        NSDictionary *currentdojo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *dojohash = [currentdojo valueForKey:@"dojohash"];
        
        NSString *newDojoName = dojoNameField.text;
        if (!([newDojoName isEqualToString:@""]))
        {
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[newDojoName,dojohash,[userProperties objectForKey:@"userEmail"]] forKeys:@[@"newname",@"dojohash",@"email"]];
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%schangeDojoName.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
            NSLog(@"data .count is %ld", (long)dataDict.count);
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            error = nil;
            
            //fire the request and wait for response
            result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            NSLog(@"%@",decodedString);
            
            if ([decodedString isEqualToString:@"true"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"done" message:@"changed name successfully" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                self.dojoNameField.text = @"";
                NSLog(@"it worked!");
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"something went wrong" message:@"try refreshing the home page" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through rename try block");
    }
}

-(IBAction)changeDojoCode:(id)sender
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
        NSDictionary *currentdojo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *dojohash = [currentdojo valueForKey:@"dojohash"];
        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSString *newDojoName = dojoCodeField.text;
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[newDojoName,dojohash,[userProperties objectForKey:@"userEmail"]] forKeys:@[@"newcode",@"dojohash",@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%schangeDojoCode.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        NSLog(@"data .count is %ld", (long)dataDict.count);
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",decodedString);
        
        if ([decodedString isEqualToString:@"true"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"done" message:@"changed code successfully" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            self.dojoNameField.text = @"";
            NSLog(@"it worked!");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"something went wrong" message:@"try refreshing the home page" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through rename try block");
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.friendList count];
    }
    else
    {
        return [self.addSumoList count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Followers";
            break;
        case 1:
            return @"Invite More Friends";
            break;
            
        default:
            break;
    }
    return @"";
}

-(DOJOFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOFriendCell *cell = (DOJOFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        //NSString *email = [[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"email"];
        if ([[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"status"])
        {
            cell.colorBar.backgroundColor = [self.colorList objectAtIndex:(indexPath.row % 7)];
        }
        else
        {
            cell.colorBar.backgroundColor = [UIColor whiteColor];
        }
        
        [cell.profView setFrame:CGRectMake(19, 7, 38, 38)];
        
        cell.nameLabel.text = [[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"fullname"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *profilePicture = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",[[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"username"]]]];
        NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        NSRange rangeAgain = [[[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"username"] rangeOfCharacterFromSet:s];
        if (rangeAgain.location == NSNotFound)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:profilePicture])
            {
                UIImage *fbImage = [UIImage imageWithContentsOfFile:profilePicture];
                cell.profView.image = fbImage;
                [cell.profView.layer setCornerRadius:19];
                cell.profView.clipsToBounds = YES;
                cell.profView.contentMode = UIViewContentModeScaleAspectFill;
                [cell.profView setFrame:CGRectMake(19, 7, 38, 38)];
            }
            else
            {
                dispatch_async(self.profileQueue, ^{
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[[self.friendList objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"username"]]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                        UIImage *fbImage = [UIImage imageWithData:imageData];
                        imageData = UIImageJPEGRepresentation(fbImage, 1.0);
                        [imageData writeToFile:profilePicture atomically:YES];
                        cell.profView.image = fbImage;
                        [cell.profView.layer setCornerRadius:19];
                        cell.profView.clipsToBounds = YES;
                        cell.profView.contentMode = UIViewContentModeScaleAspectFill;
                    });
                });
            }
        }
        else
        {
            cell.profView.image = [UIImage imageNamed:@"doji58.png"];
            [cell.profView.layer setCornerRadius:19];
            cell.profView.clipsToBounds = YES;
            cell.profView.layer.masksToBounds = YES;
            cell.profView.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        return cell;
    }
    else
    {
        //NSString *email = [[[self.addSumoList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"email"];
        cell.colorBar.backgroundColor = [UIColor whiteColor];
        
        [cell.profView setFrame:CGRectMake(19, 7, 38, 38)];
        
        cell.nameLabel.text = [[[self.addSumoList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"fullname"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *profilePicture = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",[[[self.addSumoList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"]]]];
        NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        NSRange rangeAgain = [[[[self.addSumoList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"] rangeOfCharacterFromSet:s];
        if (rangeAgain.location == NSNotFound)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:profilePicture])
            {
                UIImage *fbImage = [UIImage imageWithContentsOfFile:profilePicture];
                cell.profView.image = fbImage;
                [cell.profView.layer setCornerRadius:19];
                cell.profView.clipsToBounds = YES;
                cell.profView.contentMode = UIViewContentModeScaleAspectFill;
                [cell.profView setFrame:CGRectMake(19, 7, 38, 38)];
            }
            else
            {
                dispatch_async(self.profileQueue, ^{
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[[self.addSumoList objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"]]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                        UIImage *fbImage = [UIImage imageWithData:imageData];
                        imageData = UIImageJPEGRepresentation(fbImage, 1.0);
                        [imageData writeToFile:profilePicture atomically:YES];
                        cell.profView.image = fbImage;
                        [cell.profView.layer setCornerRadius:19];
                        cell.profView.clipsToBounds = YES;
                        cell.profView.contentMode = UIViewContentModeScaleAspectFill;
                    });
                });
            }
        }
        else
        {
            cell.profView.image = [UIImage imageNamed:@"doji58.png"];
            [cell.profView.layer setCornerRadius:19];
            cell.profView.clipsToBounds = YES;
            cell.profView.layer.masksToBounds = YES;
            cell.profView.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
    }
    else
    {
        @try {
            
            NSInteger rowNum = indexPath.row;
            NSLog(@"WENT THRU HERE");
            NSString *dojohash = [dojoInfo valueForKey:@"dojohash"];
            NSError *error;
            NSDictionary *inviteInfo = [[self.addSumoList objectAtIndex:rowNum] objectAtIndex:0];
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
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSError *error;
                NSArray *swag = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"swag is %@",swag);
                [self refreshMemberList];
            }];
            
            //RELOAD TABLE VIEW BUT WITHOUT A NETWORK REQUEST
            //[self.friendTableView reloadData];
        }
        @catch (NSException *exception) {
            UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
            [unable show];
        }
        @finally {
            NSLog(@"invite to dojo n stuff");
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





@end
