//
//  DOJOHomeViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOHomeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MobileCoreServices/UTCoreTypes.h"

@interface DOJOHomeViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property NSInteger locUpdateCount;

@end

@implementation DOJOHomeViewController

@synthesize dojoInfoPage, dataConv, dojoPage, userEmail, homeTableView, picker, originalImage, annotateController, sendController, imageData, videoData, mediaType, cameraButton, profileIcon, selectedDojoDict, downloadingShit, dojoTableViewData, cellTag, rowTag, orderedFreshest, locManager, currentLocation, searchController, selectedPostIndex, locUpdateCount, segmentControl, drawerButton, createDojoButton, firsTimeBoot;//, navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        self.dataConv = [[NSArray alloc] init];
        self.firsTimeBoot = YES;
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // user allowed
        [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locManager startUpdatingLocation];
        NSLog(@"authorization status is %d",status);
        NSLog(@"authorized");
    }
    NSLog(@"authorization status did change");
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
    currentLocation = winningLocation;
    //NSLog(@"current location is latitude %f, longitude %f",(float)newLocation.coordinate.latitude, (float)newLocation.coordinate.longitude);
    if (locUpdateCount == 5)
    {
        [self.locManager stopUpdatingLocation];
    }
    self.homeTableView.currentLocation = currentLocation;
    locUpdateCount++;
    if (self.firsTimeBoot)
    {
        NSLog(@"LOCATION DELEGATE reloading the search data");
        self.homeTableView.selectedHomeType = self.segmentControl.selectedSegmentIndex;
        [self.homeTableView reloadTheSearchData];
        self.firsTimeBoot = NO;
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
        if ([[virginDict valueForKey:@"HomeVirgin"] isEqualToString:@"yes"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is your Home. From here, you can add Friends, create a Dojo, search the community, and create photos/videos to share! Tap Create a Dojo to start a movement, a campus phenomenon, a party, or just a distraction from exams. To see if there's something going on around you, tap the Search. Don't cause us too much trouble. <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            [alertView show];
            [virginDict setValue:@"no" forKey:@"HomeVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. This is your Home. From here, you can add Friends, create a Dojo, search the community, and create photos/videos to share! Tap Create a Dojo to start a movement, a campus phenomenon, a party, or just a distraction from exams. To see if there's something going on around you, tap the Search. Don't cause us too much trouble. <3" delegate:nil cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        [alertView show];
        [virginDict setValue:@"no" forKey:@"HomeVirgin"];
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    locUpdateCount = 0;
#ifdef __IPHONE_8_0
    
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        self.locManager = [[CLLocationManager alloc] init];
        [self.locManager setDelegate:self];
        [self.locManager requestWhenInUseAuthorization];
    }
#else
    //register to receive notifications
    self.locManager = [[CLLocationManager alloc] init];
    [self.locManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locManager setDelegate:self];
    [self.locManager startUpdatingLocation];
#endif
    NSLog(@"called view did appear");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.segmentControl addTarget:self action:@selector(didChangeHomeType:) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentControl setWidth:45 forSegmentAtIndex:0];
    [self.segmentControl setWidth:45 forSegmentAtIndex:1];
    [self.segmentControl setWidth:45 forSegmentAtIndex:2];
    
    UIImage *segmentImage = [UIImage imageNamed:@"locationicon2x.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 33),NO,0.0);
    [segmentImage drawInRect:CGRectMake(3, 3, 25, 27)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.segmentControl setImage:resizedImage forSegmentAtIndex:0];
    segmentImage = [UIImage imageNamed:@"friendsicon2x.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 33),NO,0.0);
    [segmentImage drawInRect:CGRectMake(3, 3, 25, 27)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.segmentControl setImage:resizedImage forSegmentAtIndex:1];
    segmentImage = [UIImage imageNamed:@"homeicon2x.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 33),NO,0.0);
    [segmentImage drawInRect:CGRectMake(3, 3, 25, 27)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.segmentControl setImage:resizedImage forSegmentAtIndex:2];
    [self.segmentControl setCenter:CGPointMake((self.segmentControl.center.x+15), self.segmentControl.center.y)];
    
    segmentImage = [UIImage imageNamed:@"affamatics.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 50),NO,0.0);
    [segmentImage drawInRect:CGRectMake(12, 0, 22, 45)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.createDojoButton setImage:resizedImage];
    segmentImage = [UIImage imageNamed:@"optionsdrawericon.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(35, 35),NO,0.0);
    [segmentImage drawInRect:CGRectMake(-2, 2, 25, 25)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.drawerButton setImage:resizedImage];
    
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        self.homeTableView.selectedHomeType = self.segmentControl.selectedSegmentIndex;
        [self.homeTableView reloadTheSearchData];
    }
    if (self.segmentControl.selectedSegmentIndex == 1)
    {
        
    }
    if (self.segmentControl.selectedSegmentIndex == 2)
    {
        [self.homeTableView loadDojoHomeNotSearching];
    }
    
    @try {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"]] forKeys:@[@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoHomeList.php",SERVERADDRESS]]];
        
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
            NSError *localError;
            @try {
                dojoTableViewData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&localError];
            }
            @catch (NSException *exception) {
                NSLog(@"exception in asynch is %@",exception);
                dojoTableViewData = [[NSArray alloc] init];
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        //NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
        //NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"could not load home table in view will appear %@",exception);
    }
    @finally {
        NSLog(@"try block home load");
    }
}

-(void)didChangeHomeType:(UISegmentedControl *)segControl
{
    NSLog(@"selected index is %ld",(long)segControl.selectedSegmentIndex);
    [self.homeTableView didChangeHomeType:segControl];
}

-(IBAction)refreshHomePage:(id)sender
{
    NSLog(@"refresh home page");
    /*
    UIButton *tempButton = (UIButton *)[self.navigationItem.titleView.subviews objectAtIndex:0];
    NSLog(@"after temp");
    [tempButton setTitle:@"UPDATING" forState:UIControlStateNormal];
    [self.navigationItem setTitleView:tempButton];
    */
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.homeTableView loadDojoHomeNotSearching];
    @try {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"]] forKeys:@[@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoHomeList.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSError *localError;
            @try {
                dojoTableViewData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&localError];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        //NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
        //NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"could not load home table in view will appear %@",exception);
    }
    @finally {
        NSLog(@"try block home load");
    }
    /*
    tempButton = (UIButton *)[self.navigationItem.titleView.subviews objectAtIndex:0];
    [tempButton.titleLabel setText:@"DOJO"];
    [self.navigationItem setTitleView:tempButton];
    */
}

-(void)refreshHomePagePublic
{
    NSLog(@"refresh home page");
    /*
     UIButton *tempButton = (UIButton *)[self.navigationItem.titleView.subviews objectAtIndex:0];
     NSLog(@"after temp");
     [tempButton setTitle:@"UPDATING" forState:UIControlStateNormal];
     [self.navigationItem setTitleView:tempButton];
     */
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.homeTableView loadDojoHomeNotSearching];
    @try {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"]] forKeys:@[@"email"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoHomeList.php",SERVERADDRESS]]];
        
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
            NSError *localError;
            dojoTableViewData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&localError];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        //NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //NSLog(@"GET HOME LIST IS \n%@",dojoTableViewData);
        //NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"could not load home table in view will appear %@",exception);
    }
    @finally {
        NSLog(@"try block home load");
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    /*
     tempButton = (UIButton *)[self.navigationItem.titleView.subviews objectAtIndex:0];
     [tempButton.titleLabel setText:@"DOJO"];
     [self.navigationItem setTitleView:tempButton];
     */
}

- (void)viewDidLoad
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"hackedCam"];

    NSLog(@"email on home view is %@",userEmail);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [dictToStore objectForKey:@"userEmail"];
    NSLog(@"useremail loaded is %@",userEmail);
    //optimization
    //annotateController = [self.storyboard instantiateViewControllerWithIdentifier:@"annotateControllerSB"];
    //picker = [[UIImagePickerController alloc] init];
    //sendController = [[DOJOSendViewController alloc] init];
    
    mediaType = [[NSString alloc] init];

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
    
    self.firsTimeBoot = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)LoadDojoPage:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.navigationBar setAlpha:1];
        self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,20,self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        self.cameraButton.frame = CGRectMake((self.view.frame.size.width/2)-32, self.view.frame.size.height-75, 65, 65);
    } completion:nil];

    @try {
        NSLog(@"button text %@ tag %u",button.titleLabel.text, button.tag);
        if ([button.titleLabel.text isEqualToString:@"1"])
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            //Allocate in memory, and then initialize
            // dojoInfoPage = [[DOJONetTestViewController alloc] init];
            //dojoInfoPage = [self.storyboard instantiateViewControllerWithIdentifier:@"netTestSBViewController"];
            
            NSArray *joinedArray = [dojoTableViewData objectAtIndex:0];
            NSArray *dojoData = [joinedArray objectAtIndex:button.tag];
            selectedDojoDict = [[dojoData objectAtIndex:0] objectAtIndex:0];
            NSLog(@"dojoDict is %@",selectedDojoDict);
            
            rowTag = button.tag;
            NSLog(@"row %ld selected", (long)button.tag);
            NSLog(@"sending network request");
            
            //present the view controller
            dojoPage = [self.storyboard instantiateViewControllerWithIdentifier:@"dojoPage"];
            [self performSegueWithIdentifier:@"toDojoPage" sender:self];
            //[downloadingShit dismissWithClickedButtonIndex:0 animated:NO];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            /*[self.navigationController presentViewController:dojoInfoPage animated:YES completion:^{
             // start of script
             NSLog(@"called doPresentViewcontroller");
             dojoInfoPage.DojoLabel.text = dojoName;
             dojoInfoPage.CodeLabel.text = code;
             dojoInfoPage.hashLabel.text = dojohash;
             dojoInfoPage.timestampLabel.text = timestamp;
             //end of script
             }];
             */
            //[self.navigationController pushViewController:dojoInfoPage animated:YES];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [networkFailure show];
    }
    @finally {
        NSLog(@"ran through load dojo page try block");
    }
}

-(void)magnifyCell:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.navigationBar setAlpha:1];
        self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,20,self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        self.cameraButton.frame = CGRectMake((self.view.frame.size.width/2)-32, self.view.frame.size.height-75, 65, 65);
    } completion:nil];
    rowTag = button.titleLabel.text.integerValue;
    cellTag = button.tag;
    NSLog(@"rowTag: %ld, cellTag: %ld",(unsigned long)rowTag, (unsigned long)cellTag);
    orderedFreshest = [[[dojoTableViewData objectAtIndex:0] objectAtIndex:rowTag] objectAtIndex:1];
    selectedPostIndex = cellTag;
    NSLog(@"selected post hash is %@",[[orderedFreshest objectAtIndex:cellTag] valueForKey:@"posthash"]);
    [self.storyboard instantiateViewControllerWithIdentifier:@"magnifyVC"];
    [self performSegueWithIdentifier:@"magnifyCell" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"magnifyCell"])
    {
        DOJOMagnifiedViewController *magnifyVC = [segue destinationViewController];
        magnifyVC.dojoData = [[[[dojoTableViewData objectAtIndex:0] objectAtIndex:rowTag] objectAtIndex:0] objectAtIndex:0];
        magnifyVC.selectedPostIndex = selectedPostIndex;
    }
    if ([[segue identifier] isEqualToString:@"toDojoPage"])
    {
        dojoPage = [segue destinationViewController];
        NSArray *joinedArray = [dojoTableViewData objectAtIndex:0];
        NSArray *dojoData = [joinedArray objectAtIndex:rowTag];
        selectedDojoDict = [[dojoData objectAtIndex:0] objectAtIndex:0];
        NSLog(@"dojoDict is %@",selectedDojoDict);
        dojoPage.dojoData = selectedDojoDict;
        NSLog(@"applying properties");
    }
    if ([[segue identifier] isEqualToString:@"toAnnotate"])
    {
        
        // Get reference to the destination view controller
        DOJOAnnotateViewController *vc = [segue destinationViewController];
        
        NSLog(@"applying properties");
        
        vc.imageData = imageData;
        vc.mediaType = mediaType;
        vc.picImage = originalImage;
        vc.capturedMovie = videoData;
    }
    if ([[segue identifier] isEqualToString:@"toSearchController"])
    {
        DOJOSearch4DojosViewController *vc = [segue destinationViewController];
//        vc.initialSearchString = dojoSearchBar.text;
    }
}

-(IBAction)callCameraMethod:(UIButton *)sender
{
    /*
    NSLog(@"ran the camera call delegate method in the view controller");
    picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setVideoMaximumDuration:15];
    [picker setVideoQuality:UIImagePickerControllerQualityTypeMedium];
    [picker allowsEditing];
    [self presentViewController:picker animated:YES completion:^{NSLog(@"called doPresentViewcontroller");}];
     */
    //DOJOCameraViewController *camController = [[DOJOCameraViewController alloc] init];
    //[self presentViewController:camController animated:YES completion:^{NSLog(@"completed camera display");}];
    
    [self performSegueWithIdentifier:@"toCAM" sender:self];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"dismissed from cancel button press image controller handle");}];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    mediaType = [[NSString alloc] initWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaType]];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSLog(@"camera did finish picking media and selected VIDEO type");
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"VIDEOURL IS %@",videoURL);
        videoData = [[NSData alloc] initWithContentsOfURL:videoURL];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recorded.mov"]];
        [videoData writeToURL:selectedPath atomically:YES];
        
        //videoData = [NSData dataWithContentsOfURL:videoURL];
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"the view controller has been dismissed");
            
            // Save movie.
            int movieSize = (unsigned)videoData.length;
            NSLog(@"SIZE OF MOVIE: %i ", movieSize);
            mediaType = @"movie";
            //annotateController.capturedMovie = videoData;
            [self performSegueWithIdentifier:@"toAnnotate" sender:self];
        }];
        
        NSLog(@"run after segues");
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        NSLog(@"camera did finish picking media and selected IMAGE type");
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum (originalImage, nil, nil , nil);
        
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"the view controller has been dismissed");
            // Save image.
            imageData = UIImageJPEGRepresentation(originalImage, 0.2);
            int imageSize = (unsigned)imageData.length;
            NSLog(@"SIZE OF IMAGE: %i ", imageSize);
            
            //annotateController.imageData = imageData;
            mediaType = @"image";
            //annotateController.picImage = originalImage;
            [self performSegueWithIdentifier:@"toAnnotate" sender:self];
        }];
        NSLog(@"run after segues");
    }
    
}

-(IBAction)loadAccountPage:(id)sender
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"profileViewer"];
    [self performSegueWithIdentifier:@"toProfileViewer" sender:self];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"dojoSearchController"];
    [self performSegueWithIdentifier:@"toSearchController" sender:self];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)toCreateGroup
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"createRealVC"];
    [self performSegueWithIdentifier:@"toCreateReal" sender:self];
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
