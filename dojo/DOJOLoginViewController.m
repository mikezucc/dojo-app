//
//  DOJOLoginViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/9/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOLoginViewController.h"
#import "DOJOAppDelegate.h"
/*
#include <sys/types.h>
#include <sys/sysctl.h>
*/
@interface DOJOLoginViewController ()

@end

@implementation DOJOLoginViewController

@synthesize dataConv, firstName, lastName, email, username, navigationMain, loginbutton, fullname,createAccountButton, dojoTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad:(BOOL)animated
{
    // Custom initialization
}

-(void)viewWillAppear:(BOOL)animated
{
    //[UIDevice currentDevice].
    //UIView *godammit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    DOJOAppDelegate *app = [[UIApplication sharedApplication] delegate];

    app.shouldLogout = NO;
    
    NSLog(@"IS WIDE SCREEN %f",[ [ UIScreen mainScreen ] bounds ].size.height);
    
    float screenHieght = [[UIScreen mainScreen] bounds].size.height;
    NSString *widescreen;
    if (screenHieght < 500)
    {
        widescreen = @"not";
        app.isIphone4 = YES;
    }
    else
    {
        widescreen = @"yes";
        app.isIphone4 = NO;
    }
    NSLog(@"widescreen is %@",widescreen);

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *widePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"isWidescreen.plist"]];
    
    NSDictionary *widescreenDict = [[NSDictionary alloc] initWithObjects:@[widescreen] forKeys:@[@"widescreen"]];
    [widescreenDict writeToFile:widePath atomically:YES];
  //  [self.view addSubview:godammit];
}

-(void)viewDidAppear:(BOOL)animated
{
    // open keys, if no keys, leave this here
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:keysPath])
    {
        NSDictionary *keysDict = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"SEEN VC the keys are %@",keysDict);
        if ([[keysDict objectForKey:@"result"] isEqualToString:@"success"] || [[keysDict objectForKey:@"result"] isEqualToString:@"made"])
        {
            if ([[keysDict objectForKey:@"result"] isEqualToString:@"made"])
            {
                if ([[keysDict objectForKey:@"firstTime"] isEqualToString:@"done"])
                {
                    [self.storyboard instantiateViewControllerWithIdentifier:@"homeNavController"];
                    [self performSegueWithIdentifier:@"toHomePage" sender:self];
                    //return;
                }
                else
                {
                    DOJOWelcomeSequence *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
                    [self presentViewController:vc animated:NO completion:nil];
                }
            }
            else
            {
                [self.storyboard instantiateViewControllerWithIdentifier:@"homeNavController"];
                [self performSegueWithIdentifier:@"toHomePage" sender:self];
            }
        }
    }
    else
    {
        // display the introduction pages
    }
    
    DOJOAppDelegate *app = [[UIApplication sharedApplication] delegate];
    if (app.isIphone4)
    {
        CGRect frm = self.loginbutton.frame;
        frm.origin.y = 300;
        [self.loginbutton setFrame:frm];
        frm = self.createAccountButton.frame;
        frm.origin.y = self.loginbutton.frame.origin.y + 54;
        [self.createAccountButton setFrame:frm];
        frm = self.dojoTitle.frame;
        frm.origin.y = self.loginbutton.frame.origin.y - 154;
        [self.dojoTitle setFrame:frm];
    }
    else
    {
        
    }
}

-(IBAction)createAccountWithEmail:(id)sender
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"createAccountVC"];
    [self performSegueWithIdentifier:@"fromLoginToCreate" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

/*
/// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        if (FBSession.activeSession.isOpen) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                 if (!error) {
                     NSLog(@"accesstoken %@",[NSString stringWithFormat:@"%@",session.accessTokenData]);
                     NSLog(@"user id %@",user.objectID);
                     NSLog(@"Email %@",[user objectForKey:@"email"]);
                     NSLog(@"User Name %@ %@",user.first_name, user.last_name);
                     NSLog(@"Name is %@",user.name);
                     
                     firstName = user.first_name;
                     lastName = user.last_name;
                     email = [user objectForKey:@"email"];
                     username = user.objectID;
                     fullname = user.name;
                     
                     
                     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                     NSString *documentsDirectory = [paths objectAtIndex:0];
                     NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
                     NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[email] forKeys:@[@"userEmail"]];
                     [dictToStore writeToFile:plistPath atomically:YES];
                     
                     @try {
                         NSError *error;
                         NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[firstName,lastName,email,username, fullname] forKeys:@[@"firstname",@"lastname",@"email",@"username",@"fullname"]];
                         NSLog(@"dictionary is :%@",dataDict);
                         NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                         NSLog(@"encoded json is %@",result);
                         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%saddUser.php",SERVERADDRESS]]];
                         
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
                         dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
                         NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                         NSLog(@"%@",result);
                         NSLog(@"%@",dataConv);
                         NSLog(@"%@",decodedString);
                         
                         //[self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
                         [self.storyboard instantiateViewControllerWithIdentifier:@"homeNavController"];
                         [self performSegueWithIdentifier:@"toHomePage" sender:self];
                     }
                     @catch (NSException *exception) {
                         UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"trouble with network" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
                         [unable show];
                     }
                     @finally {
                         NSLog(@"ran through the login sesion state changed");
                     }
                 }
             }];
        }
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            NSLog(@"%@, %@", alertTitle, alertText);
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                NSLog(@"%@, %@", alertTitle, alertText);
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                NSLog(@"%@, %@", alertTitle, alertText);
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        NSLog(@"user logged out");
    }
}
*/

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    //FBLoginView *loginView = [[FBLoginView alloc] init];
    //[self.view addSubview:loginView];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
