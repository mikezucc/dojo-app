//
//  DOJOCreateGroupRealViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 11/4/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateGroupRealViewController.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOCreateGroupRealViewController () <CLLocationManagerDelegate, UIAlertViewDelegate, UITextFieldDelegate, MKMapViewDelegate, APIRequestDelegate>

@property dispatch_queue_t profileQueue;
@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOCreateGroupRealViewController

@synthesize dojoLocation, dojoLocationManager, dojoCodeField, dojoNameField, userEmail, locationSwitch, secretSwitch, createButton, codeSwitch, friendTableView, friendList, selectedList, colorList, typeButton, typeLabel, typeLogoView, typeChooseWindow, mapView, apiBot;

- (void)viewDidLoad {
    [super viewDidLoad];

    
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
    
    typeChooseWindow = [[DOJOTypeChooser alloc] initWithFrame:CGRectMake(0, 153, 320, 213)];
    typeChooseWindow.delegate = self;
    [self.view addSubview:typeChooseWindow];
    [typeChooseWindow setHidden:YES];
    
    self.mapView.delegate = self;
    
    [self.friendTableView setAlpha:0];
    [self.friendTableView setUserInteractionEnabled:NO];
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"array of locations is %@",locations);
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
    self.mapView.centerCoordinate = dojoLocation.coordinate;
    self.mapView.region = MKCoordinateRegionMake(dojoLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setUserInteractionEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    //NSLog(@"current location is latitude %f, longitude %f",(float)newLocation.coordinate.latitude, (float)newLocation.coordinate.longitude);
}

-(IBAction)removeScreen:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"dismissed create group controller");}];
}

-(IBAction)changeSecrecy:(UISwitch *)daSwitch
{
    if (daSwitch.isOn)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.friendTableView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.friendTableView setUserInteractionEnabled:YES];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.friendTableView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.friendTableView setUserInteractionEnabled:NO];
        }];
    }
}

-(IBAction)createDojo:(UIButton *)button
{
    if ([dojoNameField.text isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"No Dojo name, no konichiwa" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:nil];
        alertView.tag = 0;
        [alertView show];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"Create Dojo: %@",dojoNameField.text];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wait" message:message delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Do it", nil];
        alertView.tag = 1;
        [alertView show];
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        if (buttonIndex == 1)
        {
            NSString *dojoName = dojoNameField.text;
            [self.apiBot createDojoWithName:dojoName withLati:dojoLocation.coordinate.latitude withLongi:dojoLocation.coordinate.longitude];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"network failure at create group %@",exception);
    }
    @finally {
        NSLog(@"ran through create group block");
    }
}

-(void)createdDojo:(NSArray *)createData
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(IBAction)selectAdojoType:(id)sender
{
    
    
    //[self.typeChooseWindow setHidden:YES];
    
    
    NSLog(@"testing if hidden");
    if ([self.typeChooseWindow isHidden])
    {
        [self.typeChooseWindow setHidden:NO];
        NSLog(@"determined as hidden, unhiding now");
    }
    else
    {
        [self.typeChooseWindow setHidden:YES];
        NSLog(@"detected as shwon, hiding now");
    }
}

-(void)choseAType:(NSString *)type selectedIndex:(NSInteger)index
{
    NSLog(@"selected %@",type);
    [self selectAdojoType:self];
    typeLogoView.image = [UIImage imageNamed:[self.typeChooseWindow.typeArray objectAtIndex:index]];
    typeLogoView.backgroundColor = [UIColor colorWithHue:(fmodf(index*10.0,100))/100 saturation:0.8 brightness:1 alpha:1];
    if (index == 2)
    {
        typeLogoView.backgroundColor = [UIColor orangeColor];
    }
    typeLogoView.contentMode = UIViewContentModeScaleAspectFit;
    typeLabel.text = type;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is %@",error);
}

-(void)viewDidAppear:(BOOL)animated
{
    self.dojoLocationManager = [[CLLocationManager alloc] init];
    [self.dojoLocationManager setDelegate:self];
    [self.dojoLocationManager requestWhenInUseAuthorization];
    NSLog(@"requesting in use authorization");
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.friendList count] > 0)
    {
        return [[self.friendList objectAtIndex:1] count];
    }
    return  0;
}

-(DOJOFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOFriendCell *cell = (DOJOFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];

    NSString *email = [[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"email"];
    if ([self.selectedList containsObject:email])
    {
        cell.colorBar.backgroundColor = [self.colorList objectAtIndex:(indexPath.row % 7)];
    }
    else
    {
        cell.colorBar.backgroundColor = [UIColor whiteColor];
    }
    
    [cell.profView setFrame:CGRectMake(19, 4, 38, 38)];

    cell.nameLabel.text = [[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"fullname"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *profilePicture = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",[[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"]]]];
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSRange rangeAgain = [[[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"] rangeOfCharacterFromSet:s];
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
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"username"]]];
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

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *email = [[[[self.friendList objectAtIndex:1] objectAtIndex:indexPath.row] objectAtIndex:0] objectForKey:@"email"];
    if ([self.selectedList containsObject:email])
    {
        [self.selectedList removeObject:email];
    }
    else
    {
        [self.selectedList addObject:email];
    }
    [self.friendTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(IBAction)removeYoSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.dojoLocationManager stopUpdatingLocation];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    textField.placeholder = @"";
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        textField.font = [UIFont fontWithName:@"AvenirNext-Italic" size:17.0];
        textField.placeholder = @"Type a dojo name...";
    }
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
