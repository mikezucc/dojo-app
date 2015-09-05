//
//  DOJOMembersViewController.m
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMembersViewController.h"

@interface DOJOMembersViewController ()

@end

@implementation DOJOMembersViewController

@synthesize userEmail, buttonMask, dojoData;

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
    
    //load user email lols
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [loadedDict valueForKey:@"userEmail"];
    
    buttonMask = [[UIButton alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (!label)
    {
        label = [[UILabel alloc] init];
    }
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    label.text = @"Members";
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    [label sizeToFit];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationItem setTitle:@"members"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)goDeeper:(id)sender
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"deepSettings"];
    [self performSegueWithIdentifier:@"toDeepSettings" sender:self];
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
