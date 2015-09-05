//
//  DOJOPageSettingsViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/24/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOPageSettingsViewController.h"

@interface DOJOPageSettingsViewController () <UIAlertViewDelegate>

@end

@implementation DOJOPageSettingsViewController

@synthesize changeDojoNameField, dojoData, searchSwitch, changeDojoCodeField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)switchSecretState:(id)sender
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfo.plist"]];
        NSDictionary *currentdojo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *dojohash = [currentdojo valueForKey:@"dojohash"];
        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"PRESSED LEAVE DOJO");
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],dojohash] forKeys:@[@"email",@"dojohash"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sswitchSearchState.php",SERVERADDRESS]]];
        
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
        //NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",decodedString);
        
        if ([decodedString isEqualToString:@"\"could not update status\""])
        {
            
        }
    }
    @catch (NSException *exception) {
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through dojopage settings view");
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"PAGE SETTINGS >> dojoData is %@", dojoData);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfonotfucked.plist"]];
    [dojoData writeToFile:plistPath atomically:YES];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSLog(@"file exists in the page settings");
    }
    else
    {
        NSLog(@"file DOES NOT in the page settings");
    }
    
    if ([[dojoData objectForKey:@"memonly"] isEqualToString:@"no"])
    {
        [searchSwitch setOn:NO];
    }
    else
    {
        [searchSwitch setOn:YES];
    }
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (!label)
    {
        label = [[UILabel alloc] init];
    }
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    label.text = @"Settings";
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    [label sizeToFit];
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
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Here you can change the Dojo name and code if you are the creator. You can also set the dojo to private in case last night got a little too live. See who's in on it by looking into Members. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            //[alertView show];
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
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Here you can change the Dojo name and code if you are the creator. You can also set the dojo to private in case last night got a little too live. See who's in on it by looking into Members. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        //[alertView show];
        [virginDict setValue:@"no" forKey:@"DojoSettingsVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    NSLog(@"PAGE SETTINGS >> dojoData is %@", dojoData);
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"currentdojoinfonotfucked.plist"]];
    [dojoData writeToFile:plistPath atomically:YES];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSLog(@"file exists in the page settings");
    }
    else
    {
        NSLog(@"file DOES NOT in the page settings");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)toMembers:(id)sender
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"membersVC"];
    [self performSegueWithIdentifier:@"toMembers" sender:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
        
        NSString *newDojoName = changeDojoNameField.text;
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
                self.changeDojoCodeField.text = @"";
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
        
        NSString *newDojoName = changeDojoCodeField.text;
        
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
            self.changeDojoNameField.text = @"";
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toMembers"])
    {
        _dojoFriendTable.currentdojoinfo = dojoData;
    }
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
