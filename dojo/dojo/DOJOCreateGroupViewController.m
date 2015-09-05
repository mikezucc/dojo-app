//
//  DOJOCreateGroupViewController.m
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateGroupViewController.h"

@implementation DOJOCreateGroupViewController

@synthesize preventJumping, userEmail, dojoFriendTable;

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
    self.preventJumping = NO;
    
    //load user email lols
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [loadedDict valueForKey:@"userEmail"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *widePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"isWidescreen.plist"]];
    
    NSDictionary *widescreenDict = [[NSDictionary alloc] initWithContentsOfFile:widePath];
    
    NSString *wideString = [[NSString alloc] initWithString:[widescreenDict valueForKeyPath:@"widescreen"]];
    
    float adjustHeight;
    if ([wideString isEqualToString:@"not"])
    {
        adjustHeight = 120;
    }
    else
    {
        adjustHeight = 120;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction)removeScreen:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"dismissed create group controller");}];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.dojoFriendTable.changeStatus = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *checkedListPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"checked.plist"]];
    [fileManager removeItemAtPath:checkedListPath error:nil];
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
        if ([[virginDict valueForKey:@"FriendListVirgin"] isEqualToString:@"yes"])
        {
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Right now it probably looks pretty empty, but this is your friend list. Friends aren't necessary in Dojo, since you can connect with anyone around you. Personally, we add friends so that we can invite them to our Dojos so they can get in on the latest thing right away. By the way, add me: Michael Lorenzo <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            //[alertView show];
            [virginDict setValue:@"no" forKey:@"FriendListVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. Right now it probably looks pretty empty, but this is your friend list. Friends aren't necessary in Dojo, since you can connect with anyone around you. Personally, we add friends so that we can invite them to our Dojos so they can get in on the latest thing right away. By the way, add me: Michael Lorenzo <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        //[alertView show];
        [virginDict setValue:@"no" forKey:@"FriendListVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    [self.dojoFriendTable.nameTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self scrollDown];
    return YES;
}

/*
-(void)scrollUp
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.addFieldView.center = CGPointApplyAffineTransform(self.addFieldView.center, CGAffineTransformMakeTranslation(0, -215));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    self.addFieldView.backgroundColor = [UIColor whiteColor];
    [UIView commitAnimations];
}

-(void)scrollDown
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.addFieldView.center = CGPointApplyAffineTransform(self.addFieldView.center, CGAffineTransformMakeTranslation(0, 215));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    self.addFieldView.backgroundColor = [UIColor clearColor];
    [UIView commitAnimations];
}
 */

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
