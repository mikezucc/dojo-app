//
//  DOJOHomeTableViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOHomeTableViewController.h"
#import "DOJORevoViewController.h"
#import "DOJOProfileViewController.h"
#import "DOJOAppDelegate.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <MapboxGL/MapboxGL.h>
#import "DOJOMapAnno.h"

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

@interface DOJOHomeTableViewController () <PeekDelegate, Swagdelete, scrolled, UITextViewDelegate, UIAlertViewDelegate, UISearchBarDelegate, NotiDelegate, MGLMapViewDelegate>

@property dispatch_queue_t profileQueue;
@property dispatch_queue_t uploadQueue;
@property (nonatomic, strong) AWSS3TransferManager *tm;

@property (strong, nonatomic) NSMutableArray *heightArray;

//@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
//@property (strong, nonatomic) MGLMapView *mapBoxView;

@end

@implementation DOJOHomeTableViewController

@synthesize segControl, settingsIcon, createIcon, colorList, sampleView, dojoTableViewData, locationTableViewData, searchTableViewData, isSearching, currentLocation, locManager, dojoSearchBar, firsTimeBoot, locUpdateCount, usableLocations, downloadRequest, refresh, storePeek, containerBanana, notificationFeedData, selectedDojoInfo, cellWithMessageView, fieldContainer, sendButton, messageField, chatOpenSomewhere,documentsDirectory, fileManager, tm, cameraVC, didLoadCamera, cameraContainer, notificationsContainer, notiVC, didLoadNotiVC, startTouch, leftHeaderLabel, rightHeaderLabel, headerTitle, didMoveTheRow, settingsHeaderButton, selectedPerson, statusBarHide, numberUndeadLabel, topHeaderView, loadingdojoview, apiBot, selectedHashForDojo, heightArray, didStartCameraSession, forwardCameraString, temporaryDirectory;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorList = [[NSMutableArray alloc] initWithArray:@[
            [UIColor colorWithRed:188.0/255.0 green:216.0/255.0 blue:156.0/255.0 alpha:1],
            [UIColor colorWithRed:229.0/255.0 green:145.0/255.0 blue:246.0/255.0 alpha:1],
            [UIColor colorWithRed:247.0/255.0 green:239.0/255.0 blue:133.0/255.0 alpha:1],
            [UIColor colorWithRed:178.0/255.0 green:113.0/255.0 blue:234.0/255.0 alpha:1],
            [UIColor colorWithRed:246.0/255.0 green:88.0/255.0 blue:108.0/255.0 alpha:1],
            [UIColor colorWithRed:88.0/255.0 green:230.0/255.0 blue:246.0/255.0 alpha:1],
            [UIColor colorWithRed:134.0/255.0 green:156.0/255.0 blue:182.0/255.0 alpha:1],
            ]];
    
    self.forwardToCamera = NO;
    
    self.didMoveTheRow = NO;
    
    self.firsTimeBoot = YES;
    self.isSearching = NO;
    self.locUpdateCount = 0;
    
    self.didStartCameraSession = NO;
    
    self.dojoSearchBar = [[UISearchBar alloc] init];
    self.dojoSearchBar.text = @"";
    self.dojoSearchBar.placeholder = @"Search Friends or Dojos";
    
    usableLocations = [[NSMutableArray alloc] init];
    
    self.storePeek = [[DOJOPeekButton alloc] init];
    [self.storePeek setHidden:YES];
    
    self.messageField.delegate = self;
    
    self.selectedHashForDojo = @"";
    
    [self.navigationController.navigationBar setHidden:YES];
    
    self.profileQueue = dispatch_queue_create("swag", DISPATCH_QUEUE_SERIAL);
    self.uploadQueue = dispatch_queue_create("uploadQueue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    self.tm = [AWSS3TransferManager defaultS3TransferManager];
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    self.tm = [AWSS3TransferManager defaultS3TransferManager];
    
    self.chatOpenSomewhere = NO;
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    fileManager = [NSFileManager defaultManager];
    temporaryDirectory = NSTemporaryDirectory();
    
    //[self.cameraContainer setFrame:CGRectMake(0, 0, 320, 400)];
    //[self.notificationsContainer setFrame:CGRectMake(0, 0, 320, 400)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.touchDelegate = self;
    self.tableView.homeMainView = self.view;
    self.tableView.canCancelContentTouches = NO;
    
    //adding in child view controllers
    
    DOJOCameraViewController *camVC = [self.storyboard instantiateViewControllerWithIdentifier:@"hackedCam"];
    self.cameraContainer.frame = CGRectMake(320, 0, 320, 580);
    camVC.view.frame = self.cameraContainer.bounds;
    [camVC.view.layer setMasksToBounds:YES];
    [self.cameraContainer addSubview:camVC.view];
    [self addChildViewController:camVC];
    [camVC didMoveToParentViewController:self];
    //[camVC viewDidLoad];
    //[camVC viewWillAppear:YES];
    //[camVC viewDidAppear:YES];
    self.cameraContainer.backgroundColor = [UIColor orangeColor];
    camVC.parentHash = @"";
    self.cameraVC = camVC;
    self.cameraVC.delegate = self;
    self.didLoadCamera = NO;
    
    DOJONotificationViewController *notifVC = [self.storyboard instantiateViewControllerWithIdentifier:@"notiVC"];
    self.notificationsContainer.frame = CGRectMake(-320, 52, 320, 516);
    notifVC.view.frame = self.notificationsContainer.bounds;
    [self.notificationsContainer addSubview:notifVC.view];
    [self addChildViewController:notifVC];
    [notifVC didMoveToParentViewController:self];
    //notifVC.view.backgroundColor = [UIColor blackColor];
    self.notiVC = notifVC;
    self.notiVC.delegate = self;
    self.didLoadNotiVC = NO;
    
    self.cameraHeaderButton.alpha = 1.0;
    //self.cameraHeaderButton.alpha = (fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100);
    
    self.settingsHeaderButton.alpha = 0;
    self.settingsHeaderButton.enabled = NO;
    
    [self.messageField setUserInteractionEnabled:NO];
    
    UIImage *segmentImage = [UIImage imageNamed:@"dojoheaderwithplus.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(87, 45),NO,0.0);
    [segmentImage drawInRect:CGRectMake(18, 12, 60, 16)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.rightHeaderLabel setImage:resizedImage forState:UIControlStateNormal];
    [self.rightHeaderLabel setTintColor:[UIColor whiteColor]];
    
    segmentImage = [UIImage imageNamed:@"inbox.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(62, 45),NO,0.0);
    [segmentImage drawInRect:CGRectMake(10, 6, 25, 20)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.leftHeaderLabel setImage:resizedImage forState:UIControlStateNormal];
    [self.leftHeaderLabel setTintColor:[UIColor whiteColor]];
    
    segmentImage = [UIImage imageNamed:@"user420.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(62, 45),NO,0.0);
    [segmentImage drawInRect:CGRectMake(10, 6, 20, 20)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.settingsHeaderButton setImage:resizedImage forState:UIControlStateNormal];
    [self.settingsHeaderButton setTintColor:[UIColor whiteColor]];
    
    [self.numberUndeadLabel.layer setCornerRadius:5];
    [self.numberUndeadLabel setClipsToBounds:YES];
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
    
    self.statusBarHide = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return self.statusBarHide;
}

-(void)updateProgessOfUpload:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t) totalBytesExpectedToSend
{
    NSLog(@"bytes sent %ld, totalByes sent %ld, totalBytesExpected to send %ld",(long)bytesSent,(long)totalBytesSent,(long)totalBytesExpectedToSend);
}

-(void)addToUploadQueue:(AWSS3TransferManagerUploadRequest *)uploadRequest
{
    NSLog(@"queueing the upload");
    dispatch_sync(self.uploadQueue, ^{
        __weak DOJOHomeTableViewController *weakSelf = self;
        uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update progress.
                DOJOHomeTableViewController *strongSelf = weakSelf;
                [strongSelf updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
            });};
        [[self.tm upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                } else {
                    NSLog(@"completed upload");
                }
            });
            return nil;
        }];
    });
}

- (void)keyboardFrameDidShow:(NSNotification *)notification
{
    
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
   
    NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
    CGRect frm = self.fieldContainer.frame;
    frm.origin.y = (keyboardFrame.origin.y < 320 ? 262 : 292);
    self.fieldContainer.frame = frm;
    NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
}

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGRect keyboardFrame;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
    CGRect frm = self.fieldContainer.frame;
    frm.origin.y = (keyboardFrame.origin.y < 320 ? 262 : 292);
    self.fieldContainer.frame = frm;
    NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"profileViewer"];
    
    if (self.firsTimeBoot)
    {
        [self.view bringSubviewToFront:self.loadingdojoview];
    }

    /*if (self.mapBoxView == nil)
    {
        [self.tableView setContentInset:UIEdgeInsetsMake(self.mapViewContainer.bounds.size.height, 0, 0, 0)];
        CGRect frm = self.tableView.frame;
        frm.size.height = self.view.frame.size.height - self.topHeaderView.frame.size.height;
        self.tableView.frame = frm;
        
        self.mapBoxView = [[MGLMapView alloc] initWithFrame:self.mapViewContainer.bounds styleURL:[NSURL URLWithString:@"asset://styles/mapbox-streets-v7.json"]];
        
        //self.mapBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // set the map's center coordinate and zoom level
        [self.mapBoxView setCenterCoordinate:CLLocationCoordinate2DMake(40.7326808, -73.9843407)
                                   zoomLevel:12
                                    animated:NO];
        
        // [self.mapBoxView setUserTrackingMode:MGLUserTrackingModeFollow];
        
        self.mapBoxView.delegate = self;
        //[self.mapBoxView setShowsUserLocation:YES];
        
        [self.mapViewContainer addSubview:self.mapBoxView];
    }*/
}

/*
-(void)mapView:(MGLMapView *)mapView didUpdateUserLocation:(MGLUserLocation *)userLocation
{
    [self.mapBoxView setCenterCoordinate:self.mapBoxView.userLocation.coordinate zoomLevel:12 animated:NO];
    //[self.mapBoxView setUserTrackingMode:MGLUserTrackingModeNone];
    [self.mapBoxView setShowsUserLocation:NO];
}*/

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.didStartCameraSession)
    {
        [self.cameraVC stopCameraSession];
        self.didStartCameraSession = NO;
    }
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    return YES;
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation
{
    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"dojo"];
    
    if ( ! annotationImage)
    {
        // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
        UIImage *image = [UIImage imageNamed:@"entrance2copy"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
        [image drawInRect:CGRectMake(0, 0, 30, 30)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        annotationImage = [MGLAnnotationImage annotationImageWithImage:resizedImage reuseIdentifier:@"dojo"];
    }
    
    return annotationImage;
}

-(void)mapView:(MGLMapView * __nonnull)mapView didSelectAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
   //
    int foundIdx;
    int foundSection;
    NSString *targetHash = ((DOJOMapGLAnnotation *)annotation).dojohash;
    for (int i = 0; i < usableLocations.count; i++)
    {
        NSArray *usableSection = [locationTableViewData objectAtIndex:((NSNumber *)[usableLocations objectAtIndex:i]).integerValue];
        for (int k = 0; k< usableSection.count; k++)
        {
            NSArray *mapPoint = [usableSection objectAtIndex:k];
            if ([[mapPoint objectAtIndex:5] isEqualToString:targetHash])
            {
                [UIView animateWithDuration:0.3 animations:^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                } completion:^(BOOL finished) {
                    DOJOSwagCell *cell = (DOJOSwagCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:i]];
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:184.0/255.0 green:233.0/255.0 blue:134.0/255.0 alpha:1.0]];
                    [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                    } completion:^(BOOL finished) {
                        //
                    }];
                }];
                break;
            }
        }
    }
}

-(nullable UIView *)mapView:(MGLMapView * __nonnull)mapView leftCalloutAccessoryViewForAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [newView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
    [newView setClipsToBounds:YES];
    newView.tag = ((DOJOMapGLAnnotation *)annotation).tag;
    
    NSArray *mapPoints = [locationTableViewData objectAtIndex:6];
    NSArray *mapPoint = [mapPoints objectAtIndex:newView.tag];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 6, newView.frame.size.width - 8, 20) ];
    [nameLabel setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
    [nameLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    nameLabel.text = [mapPoint objectAtIndex:4];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 30, newView.frame.size.width - 8, 20) ];
    [subLabel setFont:[UIFont fontWithName:@"Avenir" size:13.0]];
    [subLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
    subLabel.text = [NSString stringWithFormat:@"%@ senpai",[mapPoint objectAtIndex:2]];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedAnno:)];
    [tapGest setNumberOfTapsRequired:1.0];
    [tapGest setNumberOfTouchesRequired:1.0];

    [newView addSubview:nameLabel];
    [newView addSubview:subLabel];
    [newView addGestureRecognizer:tapGest];
    
    return newView;
}

-(void)selectedAnno:(id)sender
{
    UITapGestureRecognizer *tapGest = (UITapGestureRecognizer *)sender;
    UIView *sup = tapGest.view;
    
    NSArray *mapPoints = [locationTableViewData objectAtIndex:6];
    NSArray *mapPoint = [mapPoints objectAtIndex:sup.tag];
    
    NSDictionary *temporarydict = @{@"dojohash":[mapPoint objectAtIndex:5], @"dojo":[mapPoint objectAtIndex:4]};
    self.selectedDojoInfo = temporarydict;
    [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
    [self performSegueWithIdentifier:@"toRevo" sender:self];
}

-(void)forceLoad
{
    if (![self.loadingdojoview isHidden])
    {
        locUpdateCount = 0;
        self.locManager = [[CLLocationManager alloc] init];
        [self.locManager setDelegate:self];
        [self.locManager requestWhenInUseAuthorization];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW DID APPEAR DELICIOUS");
    //NSTimer *sweg = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(forceLoad) userInfo:nil repeats:NO];
    //[sweg fire];
    
    // open keys, if no keys, leave this here
    
    DOJOAppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.shouldOpenWithChat = NO;
    
    if (app.shouldLogout)
    {
        NSError *error;
        NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:temporaryDirectory error:&error];
        //NSLog(@"these are the directory contents %@",directoryContents);
        NSString *match = @"*.jpeg";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
        NSArray *results = [directoryContents filteredArrayUsingPredicate:predicate];
        //NSLog(@"FILTERED RESULTS \n%@",results);
        for (int i=0;i<[results count];i++)
        {
            NSString *plistPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
            if([fileManager removeItemAtPath:plistPath error:&error])
            {
                NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
            }
            else
            {
                NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
            }
        }
        
        match = @"*.mov";
        predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
        results = [directoryContents filteredArrayUsingPredicate:predicate];
        //NSLog(@"FILTERED RESULTS \n%@",results);
        for (int i=0;i<[results count];i++)
        {
            NSString *plistPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
            if([fileManager removeItemAtPath:plistPath error:&error])
            {
                NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
            }
            else
            {
                NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
            }
        }
        
        match = @"*.plist";
        predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
        results = [[fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error] filteredArrayUsingPredicate:predicate];
        //NSLog(@"FILTERED RESULTS \n%@",results);
        for (int i=0;i<[results count];i++)
        {
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
            if([fileManager removeItemAtPath:plistPath error:&error])
            {
                NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
            }
            else
            {
                NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
            }
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }

    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:keysPath])
    {
        NSDictionary *keysDict = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"SEEN VC the keys are %@",keysDict);
        if ([[keysDict objectForKey:@"result"] isEqualToString:@"made"])
        {
            // made a new account
            [[[UIAlertView alloc] initWithTitle:@"Welcome To Dojo!" message:@"Set up Profile now?"delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Ok",nil] show];
        }
    }
    
    if (self.firsTimeBoot)
    {
        self.refresh = [[UIRefreshControl alloc] init];
        [self.refresh setBackgroundColor:[UIColor whiteColor]];
        [self.refresh setTintColor:self.topHeaderView.backgroundColor];
        [self.refresh addTarget:self action:@selector(genericRefresh) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refresh];
        
        self.notiVC.refresh.backgroundColor = self.topHeaderView.backgroundColor;
        
        [self.view bringSubviewToFront:self.notificationsContainer];
        [self.view bringSubviewToFront:self.cameraContainer];
        
        
        @try {
            NSString *stringPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"location.plist"]];
            if ([fileManager fileExistsAtPath:stringPath])
            {
                NSLog(@"swag swag");
                NSDictionary *coordDict = [[NSDictionary alloc] initWithContentsOfFile:stringPath];
                NSNumber *lati = [coordDict objectForKey:@"lati"];
                NSNumber *longi = [coordDict objectForKey:@"longi"];
                [self.apiBot getHomeDataWithLongitude:longi.doubleValue latitude:lati.doubleValue];
                //[self.tableView reloadData];
                [self.view sendSubviewToBack:self.loadingdojoview];
                [self.loadingdojoview setHidden:YES];
            }
            else
            {
                locUpdateCount = 0;
                self.locManager = [[CLLocationManager alloc] init];
                [self.locManager setDelegate:self];
                [self.locManager requestWhenInUseAuthorization];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"old reload attempt is %@",exception);
        }
        @finally {
            NSLog(@"finally super hyper swag *****");
        }
    }
    
    if (self.firsTimeBoot)
    {
        self.firsTimeBoot = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        if (!self.notiVC.isSearching)
        {
            [self.notiVC genericRefresh];
        }
    }
    else
    {
        [self.refresh endRefreshing];
        if (self.forwardToCamera)
        {
            self.cameraVC.forwardCameraString = self.forwardCameraString;
            [self scrollToCamera:self];
            self.forwardToCamera = NO;
        }
        else
        {
            if (!self.notiVC.isSearching)
            {
                [self.notiVC genericRefresh];
            }
            @try {
                if (self.didLoadCamera)
                {
                    [self.cameraVC startCameraSession];
                    self.didStartCameraSession = YES;
                }
                else
                {
                    if (self.didStartCameraSession)
                    {
                        [self.cameraVC stopCameraSession];
                        self.didStartCameraSession = NO;
                    }
                }
                if (self.selectedDojoInfo != nil)
                {
                    [self loadDojoPage:self.selectedDojoInfo];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"location error is %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // user allowed
        [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locManager startUpdatingLocation];
        //NSLog(@"authorization status is %d",status);
        //NSLog(@"authorized");
    }
    //NSLog(@"authorization status did change");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"array of locations is %@",locations);
    CLLocation *location;
    CLLocation *winningLocation;
    CLLocation *testLocation;
    winningLocation = (CLLocation *)[locations objectAtIndex:0];
    if ([locations count] > 1)
    {
        for (location in locations)
        {
            //NSLog(@"lat %f, long %f",location.coordinate.latitude, location.coordinate.longitude);
            testLocation = location;
            if (((NSTimeInterval)[testLocation.timestamp timeIntervalSinceDate:winningLocation.timestamp]) > 0)
            {
                winningLocation = testLocation;
            }
        }
    }
    currentLocation = winningLocation;
    //[self.mapBoxView setCenterCoordinate:currentLocation.coordinate zoomLevel:12 animated:NO];
    NSLog(@"current location is latitude %f, longitude %f",(float)currentLocation.coordinate.latitude, (float)currentLocation.coordinate.longitude);
    NSDictionary *coordDict = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithDouble:currentLocation.coordinate.latitude],[NSNumber numberWithDouble:currentLocation.coordinate.longitude]] forKeys:@[@"lati",@"longi"]];
    NSString *stringPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"location.plist"]];
    [coordDict writeToFile:stringPath atomically:YES];
    if (locUpdateCount == 5)
    {
        [self.locManager stopUpdatingLocation];
    }
    locUpdateCount++;
    NSLog(@"current location coordinate is %@",currentLocation);
    if (currentLocation.coordinate.longitude == 0)
    {
        [self.apiBot getHomeDataWithLongitude:currentLocation.coordinate.longitude latitude:currentLocation.coordinate.latitude];
        //[self.tableView reloadData];
        //[self.apiBot getHomeDataWithLongitude:longi.doubleValue latitude:lati.doubleValue];
        //[self.tableView reloadData];
        [self.view sendSubviewToBack:self.loadingdojoview];
        [self.loadingdojoview setHidden:YES];
        self.firsTimeBoot = NO;
        [self.refresh endRefreshing];
    }
}

-(void)genericRefresh
{
    [self.apiBot getHomeDataWithLongitude:currentLocation.coordinate.longitude latitude:currentLocation.coordinate.latitude];
}

-(void)receivedLocationData:(NSArray *)locationData
{
    //[self.mapBoxView removeAnnotations:self.mapBoxView.annotations];
    locationTableViewData = locationData;
    [self.view sendSubviewToBack:self.loadingdojoview];
    [self.loadingdojoview setHidden:YES];
    [self.tableView reloadData];
    [self.refresh endRefreshing];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locUpdateCount = 0;
        self.locManager = [[CLLocationManager alloc] init];
        [self.locManager setDelegate:self];
        [self.locManager requestWhenInUseAuthorization];
        [self.refresh endRefreshing];
    });
}
/*
-(void)loadMapPoints:(NSArray *)mapPoints
{
    NSLog(@"received %d map points", (int)mapPoints.count);
    @try {
        for (int i = 0; i < mapPoints.count; i ++)
        {
            NSArray *mapPoint = [mapPoints objectAtIndex:i];
            NSNumber *longi = [NSNumber numberWithDouble:((NSString *)[mapPoint objectAtIndex:8]).doubleValue];
            NSNumber *lati = [NSNumber numberWithDouble:((NSString *)[mapPoint objectAtIndex:9]).doubleValue];
            if (longi == 0 && lati == 0)
            {
                continue;
            }
            DOJOMapGLAnnotation *PANICATDISCO = [[DOJOMapGLAnnotation alloc] init];
            PANICATDISCO.coordinate = CLLocationCoordinate2DMake( lati.floatValue, longi.floatValue);
            PANICATDISCO.title = @" ";
            PANICATDISCO.subtitle = @" ";
            PANICATDISCO.tag = i;
            PANICATDISCO.dojohash = [mapPoint objectAtIndex:5];
            if (self.mapBoxView != nil)
            {
                NSLog(@"Adding in %@",PANICATDISCO);
                [self.mapBoxView addAnnotation:PANICATDISCO];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"map annotation point set error is %@",exception);
    }
    @finally {
        //
    }
}*/

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"mice";
    //NSLog(@"usablelocations is %@",usableLocations);
    NSNumber *swag = (NSNumber *)[usableLocations objectAtIndex:section];
    switch (swag.integerValue) {
        case 0:
            sectionTitle = @"Following";
            break;
        case 1:
            sectionTitle = @"Close";
            break;
        case 2:
            sectionTitle = @"Nearby";
            break;
        case 3:
            sectionTitle = @"Nearby (7 miles)";
            break;
        case 4:
            sectionTitle = @"Around (15 miles)";
            break;
        case 5:
            sectionTitle = @"Far";
            break;
            
        default:
            sectionTitle = @"Somewhere";
            break;
    }
    
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    vw.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:0.6];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, 20)];
    lab.text = sectionTitle;
    lab.font = [UIFont fontWithName:@"Avenir-Light" size:15];
    //lab.textColor = [UIColor colorWithRed:0.125 green:0.453 blue:1.0 alpha:1.0];
    lab.textColor = [UIColor whiteColor];
    lab.alpha = 0.9;
    lab.textAlignment = NSTextAlignmentCenter;
    [vw addSubview:lab];
    
    return  vw;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"determining number of sections");
    usableLocations = [[NSMutableArray alloc] init];
    for (int i=0; i<6; i++)
    {
        if ([[locationTableViewData objectAtIndex:i] count] >0)
        {
            [usableLocations addObject:[NSNumber numberWithInt:i]];
        }
    }
    
   /* if ([locationTableViewData count] > 0)
    {
        [self loadMapPoints:[locationTableViewData objectAtIndex:6]];
    }*/
    
    return [usableLocations count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"number of locations results %ld",(long)[locationTableViewData count]);
    if ([locationTableViewData count] == 0)
    {
        return [locationTableViewData count];
    }
    else
    {
        //NSLog(@"usablelocations is %@",usableLocations);
        NSNumber *swag = (NSNumber *)[usableLocations objectAtIndex:section];
        //NSLog(@"locationTableViewCount in NUMOFROWs is %ld",(long)[[locationTableViewData objectAtIndex:swag.integerValue] count]);
        return [[locationTableViewData objectAtIndex:swag.integerValue] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellWithMessageView == indexPath)
    {
        return 250;
    }
    else
    {
        return 106;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DOJOSwagCell *cell = (DOJOSwagCell *)[tableView dequeueReusableCellWithIdentifier:@"dojoCell" forIndexPath:indexPath];
    cell.peekButton.delegate = self;
    cell.peekButton.postNumber = indexPath.row;
    cell.peekButton.sectionMajor = indexPath.section;
    cell.poopdelegate = self;
    cell.cellPath = indexPath;
    
    cell.peekButton.imageView.image = [[UIImage alloc] init];
    
    NSString *labelText = @"";
    
    ////NSLog(@"usablelocations is %@",usableLocations);
    NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:indexPath.section];
    NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:indexPath.row];
    cell.dojoNameLabel.text = [dojoData objectAtIndex:4];;
    
    NSString *infoString =[NSString stringWithFormat:@"%@ followers, %@ posts",[dojoData objectAtIndex:2],[dojoData objectAtIndex:6]];
    
    
    NSRange followerRange = [infoString rangeOfString:@"followers"];
    NSRange postsRange = [infoString rangeOfString:@"posts"];
    
    NSMutableAttributedString *strAttName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",infoString]];
    [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Light" size:11.0] range:followerRange];
    [strAttName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Light" size:11.0] range:postsRange];

    cell.infoLabel.attributedText = strAttName;
    
    /*NSArray *notiSwag = [dojoData objectAtIndex:9];
    if ([notiSwag count])
    {
        if ([[[notiSwag objectAtIndex:0] objectForKey:@"seen"] isEqualToString:@"no"])
        {
            [cell.notiBubble setHidden:NO];
            CGRect frm = cell.dojoNameLabel.frame;
            frm.origin.x = 44;
            frm.size.width = 213;
            cell.dojoNameLabel.frame = frm;
        }
        else
        {
            [cell.notiBubble setHidden:YES];
            CGRect frm = cell.dojoNameLabel.frame;
            frm.origin.x = 23;
            frm.size.width = 234;
            cell.dojoNameLabel.frame = frm;
        }
    }*/
    /*
    if ([[dojoData objectAtIndex:5] count] > 0)
    {
        [cell.peekButton setHidden:NO];
        NSDictionary *postDict = [[dojoData objectAtIndex:5] objectAtIndex:0];
        labelText = [postDict objectForKey:@"description"];
        //NSLog(@"POSTHASH is %@",[postDict valueForKey:@"posthash"]);
        //latest
        NSString *posthash = [postDict valueForKey:@"posthash"];
        if ([posthash rangeOfString:@"text"].location != NSNotFound)
        {
            // is string
            UIImage *segmentImage = [UIImage imageNamed:@"convowhite.png"];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45),NO,0.0);
            [segmentImage drawInRect:CGRectMake(0, 15, 48, 34)];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [cell.peekButton setImage:resizedImage forState:UIControlStateNormal];
        }
        else
        {
            UIImage *image = [[UIImage alloc] init];
            NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",posthash];
            NSString *picPath = [[NSString alloc] initWithString:[temporaryDirectory stringByAppendingPathComponent:picNameCache]];
            if ([fileManager fileExistsAtPath:picPath])
            {
                //load this instead
                image = [[UIImage alloc] initWithContentsOfFile:picPath];
                [cell.peekButton setImage:image forState:UIControlStateNormal];
            }
            else
            {
                //NSLog(@"pulling image for row %ld", (long)indexPath.row);
                //NSLog(@"codekey is %@",posthash);
                if ([posthash rangeOfString:@"clip"].location == 0)
                {
                    NSString *codekeythumb = [[NSString alloc] initWithFormat:@"thumb-%@",posthash];
                    //NSLog(@"code key is %@",codekeythumb);
                    
                    
                    AWSS3TransferManagerDownloadRequest *downReq = [AWSS3TransferManagerDownloadRequest new];
                    downReq.bucket = @"dojopicbucket";
                    downReq.key = codekeythumb;
                    downReq.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    int rowNum = (int)indexPath.row;
                    [[self.tm download:downReq] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        if (task.error != nil) {
                            @try {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (rowNum == indexPath.row)
                                    {
                                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                        [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
                                    }
                                });
                            }
                            @catch (NSException *exception) {
                                //NSLog(@"exception executor %@",exception);
                            }
                            @finally {
                                //NSLog(@"ran through try block executor");
                            }
                        } else {
                            //NSLog(@"completed download");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (rowNum == indexPath.row)
                                {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
                                }
                            });
                        }
                        return nil;
                    }];
                }
                else
                {
                    AWSS3TransferManagerDownloadRequest *downReq = [AWSS3TransferManagerDownloadRequest new];
                    downReq.bucket = @"dojopicbucket";
                    downReq.key = posthash;
                    downReq.downloadingFileURL = [NSURL fileURLWithPath:picPath];
                    
                    int rowNum = (int)indexPath.row;
                    [[self.tm download:downReq] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                        if (task.error != nil) {
                            @try {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (rowNum == indexPath.row)
                                    {
                                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                        [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
                                    }
                                });
                            }
                            @catch (NSException *exception) {
                                //NSLog(@"exception executor %@",exception);
                            }
                            @finally {
                                //NSLog(@"ran through try block executor");
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (rowNum == indexPath.row)
                                {
                                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                                    [cell.peekButton setImage:dlthumb forState:UIControlStateNormal];
                                }
                            });
                        }
                        return nil;
                    }];
                }
            }
        }
    }
    else
    {
        [cell.peekButton setHidden:YES];
        NSLog(@"NO POSTS, so making friends");
        labelText = @"";
    }
    */
    
    if ([[dojoData objectAtIndex:7] count] > 0)
    {
        NSDictionary *postDict = [dojoData objectAtIndex:7];
        labelText = [postDict objectForKey:@"description"];
    }
    
    cell.postTextLabel.text = labelText;
    cell.postTextLabel.textColor = [UIColor colorWithWhite:0.4 alpha:0.8];
    cell.postTextLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:11.0];
    
    if ([labelText isEqualToString:@""])
    {
        CGRect frm = cell.dojoNameLabel.frame;
        frm.origin.y = 32;
        cell.dojoNameLabel.frame = frm;
        frm = cell.infoLabel.frame;
        frm.origin.y = 56;
        cell.infoLabel.frame = frm;
        frm = cell.notiBubble.frame;
        frm.origin.y = 33;
        cell.notiBubble.frame = frm;
    }
    else
    {
        CGRect frm = cell.dojoNameLabel.frame;
        frm.origin.y = 21;
        cell.dojoNameLabel.frame = frm;
        frm = cell.infoLabel.frame;
        frm.origin.y = 44;
        cell.infoLabel.frame = frm;
        frm = cell.notiBubble.frame;
        frm.origin.y = 24;
        cell.notiBubble.frame = frm;
    }
    return cell;
}

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([platform isEqualToString:@"i386"])         return [UIDevice currentDevice].model;
    if ([platform isEqualToString:@"x86_64"])       return [UIDevice currentDevice].model;
    
    return platform;
}

-(void)chatEngaged:(NSIndexPath *)cellPath
{
   // NSString *platformIs = [self platformString];
 //   if (([platformIs rangeOfString:@"5 "].location != NSNotFound) || ([platformIs rangeOfString:@"5C"].location != NSNotFound))
   // {
    NSDictionary *dojoInfo = [[NSDictionary alloc] init];
    NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:cellPath.section];
    NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:cellPath.row];
    ////NSLog(@"dojo data is %@",dojoData);
    self.selectedDojoInfo = [dojoData objectAtIndex:2];
        NSLog(@"IS NOT 64 BIT");
        self.shouldOpenWithChat = YES;
        self.forwardCameraString = @"";
        [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
        [self performSegueWithIdentifier:@"toRevo" sender:self];
        return;
    //}
    /*
    [self.messageField resignFirstResponder];
    [self.view sendSubviewToBack:self.fieldContainer];
    //NSLog(@"HOME cell path is %@",cellPath);
    //[self.tableView scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //[self.tableView deselectRowAtIndexPath:cellPath animated:YES];
    DOJOSwagCell *cell = (DOJOSwagCell *)[self.tableView cellForRowAtIndexPath:cellPath];
    //cell.userInteractionEnabled = NO;
    NSDictionary *dojoInfo = [[NSDictionary alloc] init];
    NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:cellPath.section];
    NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:cellPath.row];
    ////NSLog(@"dojo data is %@",dojoData);
    dojoInfo = [dojoData objectAtIndex:2];
    if (self.chatOpenSomewhere)
    {
        if (cellPath != self.cellWithMessageView)
        {
            return;
        }
    }
    if (self.cellWithMessageView != nil)
    {
        //NSLog(@"SETTING TO NIL");
        [self.messageField setUserInteractionEnabled:NO];
        self.chatOpenSomewhere = NO;
        self.cellWithMessageView = nil;
        cell.isRunningActiveMessageView = NO;
        [self.tableView setScrollEnabled:YES];
        //cell.userInteractionEnabled = YES;
        [cell.messageView.bongReloader invalidate];
        cell.messageView.bongReloader = nil;
        [cell.messageView setHidden:YES];
        //[self.tableView reloadData];
        [self.tableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationRight];
        //[self.tableView reloadData];
        [self.topHeaderView setAlpha:1.0];
    }
    else
    {
        //NSLog(@"CREATING THE SWAG");
        [self.messageField setUserInteractionEnabled:YES];
        self.chatOpenSomewhere = YES;
        cell.isRunningActiveMessageView = YES;
        self.cellWithMessageView = cellPath;
        [self.tableView setScrollEnabled:NO];
        //[self.tableView reloadData];
        [cell.messageView setHidden:YES];
        [self.tableView reloadRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationRight];
        [self customScrollToRow:cellPath];
        //[self.tableView reloadData];
        [self.topHeaderView setAlpha:0.5];
    }
*/
    //self.messageView.delegate = self;
}

-(void)cellSelected
{
    if ([self.messageField isFirstResponder])
    {
        [self.messageField resignFirstResponder];
        [self.view sendSubviewToBack:self.fieldContainer];
    }
    else
    {
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.messageField becomeFirstResponder];
    }
}

-(void)detectedTapInMessageView
{
    if ([self.messageField isFirstResponder])
    {
        [self.messageField resignFirstResponder];
        [self.view sendSubviewToBack:self.fieldContainer];
    }
    else
    {
        [self.view bringSubviewToFront:self.fieldContainer];
        [self.messageField becomeFirstResponder];
    }
}

-(void)messageViewWasScrolled
{
    
}

-(IBAction)submitMessage:(id)sender
{
    if ([self.messageField.text isEqualToString:@""])
    {
        
    }
    else
    {
        @try {
            //post message
            NSString *hash = [self generateCode];
            NSError *error;
            
            NSDictionary *dojoInfo = [[NSDictionary alloc] init];
            NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:self.cellWithMessageView.section];
            NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:self.cellWithMessageView.row];
            ////NSLog(@"dojo data is %@",dojoData);
            dojoInfo = [dojoData objectAtIndex:2];
            [self.apiBot submitMessage:dojoInfo withText:self.messageField.text];
        }
        @catch (NSException *sexception)
        {
            NSLog(@"its like inception but sexception %@",sexception);
        }
        @finally
        {
            NSLog(@"what the **** is the point of this block");
        }
    }
}

-(void)sentMessage:(NSString *)decodeString
{
    if ([decodeString rangeOfString:@"posted"].location == NSNotFound)
    {
        NSLog(@"posted");
        [self.sendButton setBackgroundColor:[UIColor colorWithRed:155.0/255.0 green:250.0/255.0 blue:70.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.messageField setText:@""];
        [self.sendButton setBackgroundColor:[UIColor colorWithRed:155.0/255.0 green:250.0/255.0 blue:70.0/255.0 alpha:1.0]];
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
    //NSLog(@"s-->%@",s);
    return s;
}

-(BOOL)textShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    //NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 200 || returnKey;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@" YO YO YO");
    if ([self.messageField.text isEqualToString:@"Say something to this group"])
    {
        [self.messageField setText:@""];
    }
}

-(void)customScrollToRow:(NSIndexPath *)cellPath
{
    /*
    NSArray *visiCells = [self.tableView visibleCells];
    DOJOSwagCell *cell;
    for (int i=0;i<[[self.tableView visibleCells] count];i++)
    {
        cell = [visiCells objectAtIndex:i];
        if (cell.cellPath == cellPath)
        {
            if (i == 0)
            {
                return;
            }
            else
            {
                break;
            }
        }
        if (i == 0)
        {
            scrollTotal = cell.frame.origin.y;
        }
        scrollTotal = scrollTotal + cell.frame.size.height;
    }
    if (cellPath.row != 0)
    {
        scrollTotal = scrollTotal - 20;
    }
     */
    NSLog(@"BOMBA intended scroll path is %@",cellPath);
    CGFloat scrollTotal = 0;
    //[self.tableView scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (cellPath.row == 0 && cellPath.section == 0)
    {
        return;
    }
    DOJOSwagCell *cell = (DOJOSwagCell *)[self.tableView cellForRowAtIndexPath:cellPath];
    scrollTotal = cell.frame.origin.y;
    NSLog(@"scrollTotal is %f", scrollTotal);
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y - 20.0)];
        //[self.tableView setContentOffset:CGPointMake(0, 564)];
    } completion:^(BOOL finished) {
        cell.userInteractionEnabled = YES;
    }];
    /*if (cellPath.section != 0 || (cellPath.row != 0))
    {
        
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y)];
        } completion:^(BOOL finished) {
            cell.userInteractionEnabled = YES;
        }];
    }
     */
    //NSLog(@"total distance to scroll is %f",scrollTotal);
}

-(void)selectCell:(NSIndexPath *)cellPath
{
    //NSLog(@"select cell");
    if (!self.chatOpenSomewhere)
    {
        [self tableView:self.tableView didSelectRowAtIndexPath:cellPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (self.segControl.selectedSegmentIndex == 0)
    {
        //selectedDojoInfo =
        NSArray *interim = [notificationFeedData objectAtIndex:indexPath.row];
        ////NSLog(@"interm is %@",interim);
        NSDictionary *userData = [interim objectAtIndex:1];
        NSString *feedType = [interim objectAtIndex:0];
        NSDictionary *target = [interim objectAtIndex:2];
        if ([feedType isEqualToString:@"post"])
        {
            
        }
        else if ([feedType isEqualToString:@"create"])
        {
            selectedDojoInfo = target;
            [self loadDojoPage:selectedDojoInfo];
        }
        else if ([feedType isEqualToString:@"friend"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Request" message:[NSString stringWithFormat:@"%@ added you as a friend",[[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"fullname"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Cool", nil];
            alert.tag = indexPath.row;
            [alert show];
        }
        else if ([feedType isEqualToString:@"person"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Request" message:[NSString stringWithFormat:@"Add %@ as a friend",[[[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1] objectForKey:@"fullname"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Cool", nil];
            alert.tag = indexPath.row;
            [alert show];
        }
        else if ([feedType isEqualToString:@"dojo"])
        {
            selectedDojoInfo = [[notificationFeedData objectAtIndex:indexPath.row] objectAtIndex:1];
            [self loadDojoPage:selectedDojoInfo];
        }
            
    }
    if (self.segControl.selectedSegmentIndex == 1)
    {
        NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:indexPath.section];
        NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:indexPath.row];
        ////NSLog(@"dojo data is %@",dojoData);
        NSDictionary *dojoDict = [dojoData objectAtIndex:2];
        selectedDojoInfo = dojoDict;
        [self loadDojoPage:selectedDojoInfo];
    }
    if (self.segControl.selectedSegmentIndex == 2)
    {
        NSArray *dojoData;
        if ([[dojoTableViewData objectAtIndex:1] count]>0)
        {
           dojoData = [[dojoTableViewData objectAtIndex:(1-indexPath.section)] objectAtIndex:indexPath.row];
        }
        else
        {
            dojoData = [[dojoTableViewData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        
        
        ////NSLog(@"dojo data is %@",dojoData);
        NSDictionary *dojoDict = [[dojoData objectAtIndex:0] objectAtIndex:0];
        selectedDojoInfo = dojoDict;
        [self loadDojoPage:selectedDojoInfo];
    }
     */
    NSLog(@"detected cell tap");
    NSNumber *sectionInData = (NSNumber *)[usableLocations objectAtIndex:indexPath.section];
    NSArray *dojoData = [[locationTableViewData objectAtIndex:sectionInData.integerValue] objectAtIndex:indexPath.row];
    ////NSLog(@"dojo data is %@",dojoData);
    
    selectedDojoInfo = @{@"dojo":[dojoData objectAtIndex:4], @"dojohash":[dojoData objectAtIndex:5]};
    //[self loadDojoPage:selectedDojoInfo];
    self.forwardCameraString = @"";
    [self.storyboard instantiateViewControllerWithIdentifier:@"dojoPage"];
    [self performSegueWithIdentifier:@"toDojo" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert view clicked is %d",(int)buttonIndex);
    if ((int)buttonIndex == 1)
    {
        NSError *error;
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        self.selectedPerson = meInfo;
        self.forwardCameraString = @"";
        [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
        [self performSegueWithIdentifier:@"toPersonFromHome" sender:self];
    }
    /*
    if ((int)buttonIndex == 1)
    {
        //TAKE RIGHT EMAIL BASED OFF TAG
        NSString *selectedEmail = @"";
        if (self.isSearching)
        {
            selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        }
        else
        {
           selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        }
        //NSLog(@"selected email is %@", selectedEmail);
        
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],selectedEmail] forKeys:@[@"user1",@"user2"]];
        //NSLog(@"ALERT>> dacia sandero is %@",dataDict);
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
        //NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
        //NSLog(@"DECODED STRING IS %@", decodedString);
        
        if (!self.isSearching)
        {
            [self reloadNotificationFeed];
        }
        else
        {
            [self mixedSearch];
        }
        
    }
    if ((int)buttonIndex == 0)
    {
        //TAKE RIGHT EMAIL BASED OFF TAG
        NSString *selectedEmail = [[[notificationFeedData objectAtIndex:alertView.tag] objectAtIndex:1] objectForKey:@"email"];
        //NSLog(@"selected email is %@", selectedEmail);
        
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],selectedEmail] forKeys:@[@"email1",@"email2"]];
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
        //NSLog(@"SEARCH QUERY RETURNED: %@",dataFromRequest);
        //NSLog(@"DECODED STRING IS %@", decodedString);
        
        [self reloadNotificationFeed];
    }
    */
}

-(void)loadDojoPage:(NSDictionary *)dojoInfo
{
    self.forwardCameraString = @"";
    [self.storyboard instantiateViewControllerWithIdentifier:@"dojoPage"];
    [self performSegueWithIdentifier:@"toDojo" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toDojo"])
    {
        DOJOPage *vc = [segue destinationViewController];
        vc.dojoInfo = selectedDojoInfo;
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        vc.userEmail = [userProperties objectForKey:@"userEmail"];
        self.forwardCameraString = @"";
    }
    if ([[segue identifier] isEqualToString:@"toCameraFromHome"])
    {
        DOJOCameraViewController *vc = [segue destinationViewController];
        vc.parentHash = @"";
    }
    if ([[segue identifier] isEqualToString:@"toRevo"])
    {
        DOJORevoViewController *vc = [segue destinationViewController];
        vc.dojoInfo = selectedDojoInfo;
        vc.previousType = @"home";
        if (self.didLoadNotiVC)
        {
            vc.selectedHashForDojo = self.selectedHashForDojo;
        }
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        vc.userEmail = [userProperties objectForKey:@"userEmail"];
        vc.shouldOpenWithChat = self.shouldOpenWithChat;
        
        self.forwardCameraString = @"";
    }
    if ([[segue identifier] isEqualToString:@"toPersonFromHome"])
    {
        DOJOProfileViewController *vc = [segue destinationViewController];
        vc.personInfo = selectedPerson;
        vc.previousType = @"home";
        
        self.forwardCameraString = @"";
    }
}

-(void)goToProfileVC:(NSDictionary *)selectedSelf
{
    NSLog(@"swag hatter mad");
    self.selectedPerson = selectedSelf;
    self.forwardCameraString = @"";
    [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
    [self performSegueWithIdentifier:@"toPersonFromHome" sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(IBAction)toRevoView:(id)sender
{
    self.forwardCameraString = @"";
    [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
    [self performSegueWithIdentifier:@"toRevo" sender:self];
}

-(void)tapBegan:(NSInteger)selectedPost withSectionMajor:(NSInteger)sectionMajor withSectionMinor:(NSInteger)sectionMinor
{
    self.storePeek.postNumber = selectedPost;
    self.storePeek.sectionMajor = sectionMajor;
    self.storePeek.sectionMinor = sectionMinor;
    self.didMoveTheRow = NO;
    //NSLog(@"DISPLAYING SAMPLE VIEW: section Major: %ld, section Minor: %ld, post: %ld",(long)sectionMajor,(long)sectionMinor, (long)selectedPost);
    NSArray *postList = [[NSArray alloc] init];
    if (self.segControl.selectedSegmentIndex == 1)
    {
        //NSLog(@"usablelocations is %@",usableLocations);
        NSNumber *swag = (NSNumber *)[usableLocations objectAtIndex:sectionMajor];
        @try {
            if ([[[locationTableViewData objectAtIndex:swag.integerValue] objectAtIndex:selectedPost] count] != 0)
            {
                ////NSLog(@"count is %ld", (long)[[[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5] count]);
                postList = [[[locationTableViewData objectAtIndex:swag.integerValue] objectAtIndex:selectedPost] objectAtIndex:5];
                selectedDojoInfo = [[[locationTableViewData objectAtIndex:swag.integerValue] objectAtIndex:selectedPost] objectAtIndex:2];
            }
            else
            {
                return;
            }
        }
        @catch (NSException *exception) {
            //NSLog(@"empty array chunk for dojo location section %ld",sectionMajor);
        }
        @finally {
            //NSLog(@"ran through attempt to load dojo post cells");
        }
     
    }
    if (self.segControl.selectedSegmentIndex == 0)
    {
        postList = @[[[notificationFeedData objectAtIndex:selectedPost] objectAtIndex:3]];
    }
    if (self.segControl.selectedSegmentIndex == 2)
    {
        if ([[dojoTableViewData objectAtIndex:1] count] > 0)
        {
            postList = [[[dojoTableViewData objectAtIndex:(1-sectionMajor)] objectAtIndex:selectedPost] objectAtIndex:3];
            selectedDojoInfo = [[[dojoTableViewData objectAtIndex:(1-sectionMajor)] objectAtIndex:selectedPost] objectAtIndex:0];
        }
        else
        {
            postList = [[[dojoTableViewData objectAtIndex:sectionMajor] objectAtIndex:selectedPost] objectAtIndex:3];
            selectedDojoInfo = [[[dojoTableViewData objectAtIndex:sectionMajor] objectAtIndex:selectedPost] objectAtIndex:0];
        }
    }
    if ([postList count]>0)
    {
        /*
        self.sampleView = [[DOJOSampleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //[self.sampleView initMinor];
        //[self.sampleView setFrame:CGRectMake(0, (self.tableView.contentOffset.y)/2, self.view.frame.size.width, self.view.frame.size.height)];
        //self.sampleView.backgroundColor = [UIColor greenColor];
        self.sampleView.zoomable = NO;
        self.sampleView.selectedPostInfo = [postList objectAtIndex:0];
        self.sampleView.dojoPostList = postList;
        //self.sampleView.frame = self.view.frame;
        [self.sampleView setHidden:NO];
        [self.view addSubview:self.sampleView];
        [self.sampleView loadAPost];
        //[self.view bringSubviewToFront:self.sampleView];
         */
    }
}

-(void)tapMovedPeek
{
    self.didMoveTheRow = YES;
}

-(void)tapEnded
{
    if (!self.didMoveTheRow)
    {
        self.forwardCameraString = @"";
        [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
        [self performSegueWithIdentifier:@"toRevo" sender:self];
    }
    /*
    [self.sampleView setHidden:YES];
    [self.sampleView.videoPlayer stop];
    //self.sampleView.videoPlayer = nil;
    //NSLog(@"tap Ended");
    [self.sampleView setHidden:YES];
    if (self.segControl.selectedSegmentIndex == 1)
    {
        [self.dojoSearchBar setHidden:YES];
        [self reloadTheSearchDataLight];
        
    }
    if (self.segControl.selectedSegmentIndex == 0)
    {
        //[self.dojoSearchBar setHidden:YES];
        //[self reloadNotificationFeedLight];
        
    }
    if (self.segControl.selectedSegmentIndex == 2)
    {
        [self.dojoSearchBar setHidden:YES];
        [self loadDojoHomeNotSearchingLight];
    }
    else
    {
        
    }
     */
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    searchBar.placeholder = @"Search Friends or Dojos";
    [searchBar resignFirstResponder];
    self.isSearching = NO;
    self.notiVC.isSearching = NO;
    NSLog(@"cancel clicked from home");
    //[self.notiVC reloadNotificationFeed];
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    self.isSearching = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.dojoSearchBar resignFirstResponder];
    /*if (self.segControl.selectedSegmentIndex == 0)
    {
        DOJOSwagCell *cell;
        NSArray *visibleCells = [self.tableView visibleCells];
        for (int i = 0; i < [[self.tableView visibleCells] count];i++)
        {
            cell = [visibleCells objectAtIndex:i];
            cell.peekButton.backgroundColor = [UIColor colorWithHue:(fmodf((self.tableView.contentOffset.y/3)+50,100))/100 saturation:0.8 brightness:1 alpha:1];
        }
    }
    if (self.segControl.selectedSegmentIndex == 1)
    {
        
    }
    if (self.segControl.selectedSegmentIndex == 2)
    {
        
    }*/
}

-(void)touchBeginning:(NSIndexPath *)cellTag
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    self.didMoveTheRow = NO;
    //NSLog(@"usablelocations is %@",usableLocations);
    NSNumber *swag = (NSNumber *)[usableLocations objectAtIndex:cellTag.section];
    @try {
        if ([[[locationTableViewData objectAtIndex:swag.integerValue] objectAtIndex:cellTag.row] count] != 0)
        {
            ////NSLog(@"count is %ld", (long)[[[[locationTableViewData objectAtIndex:collectionView.section] objectAtIndex:collectionView.tag] objectAtIndex:5] count]);
            NSArray *mapPoint = [[locationTableViewData objectAtIndex:swag.integerValue] objectAtIndex:cellTag.row];
            selectedDojoInfo = @{@"dojo":[mapPoint objectAtIndex:4],@"dojohash":[mapPoint objectAtIndex:5]};
        }
        else
        {
            return;
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"empty array chunk for dojo location section %ld",sectionMajor);
    }
    @finally {
        //NSLog(@"ran through attempt to load dojo post cells");
    }
}

-(void)touchSwiping:(NSNumber *)distanceMoved
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    self.didMoveTheRow = YES;
    NSLog(@"moved:");
    if ((self.notificationsContainer.frame.origin.x <= 0) && (self.cameraContainer.frame.origin.x >= 0))
    {
        if (!self.didLoadNotiVC)
        {
            if (self.didLoadCamera)
            {
                self.statusBarHide = YES;
                [self setNeedsStatusBarAppearanceUpdate];
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (distanceMoved.floatValue) - 640;
                if (rf.origin.x >= -640)
                {
                    self.notificationsContainer.frame = rf;
                }
            }
            else
            {
                self.statusBarHide = NO;
                [self setNeedsStatusBarAppearanceUpdate];
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (distanceMoved.floatValue) - 320;
                self.notificationsContainer.frame = rf;
                
                if (rf.origin.x < -325)
                {
                    if (!self.didStartCameraSession)
                    {
                        NSLog(@"START CAMERA");
                        [self.cameraVC startCameraSession];
                        self.didStartCameraSession = YES;
                    }
                }
            }
        }
        else
        {
            self.statusBarHide = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            CGRect rf = self.notificationsContainer.frame;
            rf.origin.x = (distanceMoved.floatValue);
            self.notificationsContainer.frame = rf;
        }
    }
    CGRect rf = self.cameraContainer.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
    self.cameraContainer.frame = rf;
    rf = self.tableView.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
    self.tableView.frame = rf;
    rf = self.cameraHeaderButton.frame;
    rf.origin.x = self.tableView.frame.origin.x + 282;
    //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
    //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
    self.cameraHeaderButton.frame = rf;
    //self.cameraHeaderButton.alpha = 1;
    rf = self.rightHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 110 > 220 )
    {
        rf.origin.x = 218;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 110;
    }
    self.rightHeaderLabel.frame = rf;
    rf = self.leftHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 8 > 133 )
    {
        rf.origin.x = 133;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 8;
    }
    self.leftHeaderLabel.frame = rf;
    self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
    rf = self.numberUndeadLabel.frame;
    rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
    self.numberUndeadLabel.frame = rf;
}

-(void)touchSwipeCancelled
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    if (!self.didMoveTheRow)
    {
        NSLog(@"didnt move");
        self.forwardCameraString = @"";
        [self.storyboard instantiateViewControllerWithIdentifier:@"revoVC"];
        [self performSegueWithIdentifier:@"toRevo" sender:self];
        return;
    }
    NSLog(@"touch swipe ended");
    if (self.notificationsContainer.frame.origin.x > (self.didLoadCamera ? -230 : -130))
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = 0;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = YES;
        }];
        self.didLoadNotiVC = YES;
        self.didLoadCamera = NO;
    }
    else if (self.notificationsContainer.frame.origin.x < (self.didLoadCamera ? -550 : -410))
    {
        self.statusBarHide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -640;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = YES;
    }
    else
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -320;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
            rf = self.numberUndeadLabel.frame;
            rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
            self.numberUndeadLabel.frame = rf;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = NO;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    self.startTouch = [[touches anyObject] locationInView:self.view];
    NSLog(@"startedtouch at a %ld",(long)self.startTouch.x);
    //CGPoint currPoint = [[touches anyObject] locationInView:self.view];
    //CGRect rf = self.notificationsContainer.frame;
    //rf.size.height = 400;
    //self.notificationsContainer.frame = rf;
    //self.notiVC.notiTableView.frame = self.notificationsContainer.bounds;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    if ((self.notificationsContainer.frame.origin.x <= 0) && (self.cameraContainer.frame.origin.x >= 0))
    {
        if (!self.didLoadNotiVC)
        {
            if (self.didLoadCamera)
            {
                //[self prefersStatusBarHidden];
                CGPoint currPoint = [[touches anyObject] locationInView:self.view];
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (currPoint.x - self.startTouch.x) - 640;
                if (rf.origin.x >= -640)
                {
                    self.notificationsContainer.frame = rf;
                }
            }
            else
            {
                CGPoint currPoint = [[touches anyObject] locationInView:self.view];
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (currPoint.x - self.startTouch.x) - 320;
                self.notificationsContainer.frame = rf;
                
                if (rf.origin.x < -325)
                {
                    if (!self.didStartCameraSession)
                    {
                        NSLog(@"START CAMERA");
                        [self.cameraVC startCameraSession];
                        self.didStartCameraSession = YES;
                    }
                }
            }
        }
        else
        {
            CGPoint currPoint = [[touches anyObject] locationInView:self.view];
            CGRect rf = self.notificationsContainer.frame;
            rf.origin.x = (currPoint.x - self.startTouch.x);
            self.notificationsContainer.frame = rf;
        }
    }
    CGRect rf = self.cameraContainer.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
    self.cameraContainer.frame = rf;
    rf = self.tableView.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
    self.tableView.frame = rf;
    rf = self.cameraHeaderButton.frame;
    rf.origin.x = self.tableView.frame.origin.x + 282;
    //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
    //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
    self.cameraHeaderButton.frame = rf;
    self.cameraHeaderButton.alpha = 1;
    rf = self.rightHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 110 > 220 )
    {
        rf.origin.x = 218;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 110;
    }
    self.rightHeaderLabel.frame = rf;
    rf = self.leftHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 8 > 133 )
    {
        rf.origin.x = 133;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 8;
    }
    self.leftHeaderLabel.frame = rf;
    self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
    rf = self.numberUndeadLabel.frame;
    rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
    self.numberUndeadLabel.frame = rf;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"touch swipe ended");
    if (self.notificationsContainer.frame.origin.x > (self.didLoadCamera ? -230 : -90))
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = 0;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = YES;
        }];
        self.didLoadNotiVC = YES;
        self.didLoadCamera = NO;
    }
    else if (self.notificationsContainer.frame.origin.x < (self.didLoadCamera ? -550 : -410))
    {
        self.statusBarHide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -640;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 220;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = YES;
    }
    else
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -320;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
            rf = self.numberUndeadLabel.frame;
            rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
            self.numberUndeadLabel.frame = rf;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = NO;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"touch swipe cancelled");
    if (self.notificationsContainer.frame.origin.x > (self.didLoadCamera ? -230 : -130))
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = 0;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = YES;
        }];
        self.didLoadNotiVC = YES;
        self.didLoadCamera = NO;
    }
    else if (self.notificationsContainer.frame.origin.x < (self.didLoadCamera ? -550 : -410))
    {
        self.statusBarHide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -640;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = YES;
    }
    else
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -320;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
            rf = self.numberUndeadLabel.frame;
            rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
            self.numberUndeadLabel.frame = rf;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = NO;
    }
}

-(void)swipeStartedMAJOR
{
    //self.startTouch = [[touches anyObject] locationInView:self.view];
    //NSLog(@"startedtouch at a %ld",(long)self.startTouch.x);
    if (self.cellWithMessageView != nil)
    {
        return;
    }
}

-(void)swipeIsMovingMAJOR:(NSNumber *)distance
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"new location of swag is %f",self.notificationsContainer.frame.origin.x+distance.floatValue);
    if (self.notificationsContainer.frame.origin.x+distance.floatValue <= 0)
    {
        NSLog(@"is able to move");
        if (!self.didLoadNotiVC)
        {
            if (self.didLoadCamera)
            {
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (rf.origin.x+distance.floatValue);
                if (rf.origin.x >= -640)
                {
                    self.notificationsContainer.frame = rf;
                }
            }
            else
            {
                CGRect rf = self.notificationsContainer.frame;
                rf.origin.x = (rf.origin.x+distance.floatValue);
                self.notificationsContainer.frame = rf;
                
                if (rf.origin.x < -325)
                {
                    if (!self.didStartCameraSession)
                    {
                        NSLog(@"START CAMERA");
                        [self.cameraVC startCameraSession];
                        self.didStartCameraSession = YES;
                    }
                }
            }
        }
        else
        {
            CGRect rf = self.notificationsContainer.frame;
            rf.origin.x = (rf.origin.x+distance.floatValue);
            self.notificationsContainer.frame = rf;
        }
    }
    else
    {
        NSLog(@"couldnt move");
    }
    CGRect rf = self.cameraContainer.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
    self.cameraContainer.frame = rf;
    rf = self.tableView.frame;
    rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
    self.tableView.frame = rf;
    rf = self.cameraHeaderButton.frame;
    rf.origin.x = self.tableView.frame.origin.x + 282;
    //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
    //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
    self.cameraHeaderButton.frame = rf;
    self.cameraHeaderButton.alpha = 1;
    rf = self.rightHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 110 > 220 )
    {
        rf.origin.x = 218;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 110;
    }
    self.rightHeaderLabel.frame = rf;
    rf = self.leftHeaderLabel.frame;
    if (self.tableView.frame.origin.x + 8 > 133 )
    {
        rf.origin.x = 133;
    }
    else
    {
        rf.origin.x = self.tableView.frame.origin.x + 8;
    }
    self.leftHeaderLabel.frame = rf;
    self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x + 50)/2;
    rf = self.numberUndeadLabel.frame;
    rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
    self.numberUndeadLabel.frame = rf;
}

-(void)swipeLetGoMAJOR
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"touch swipe ended");
    if (self.notificationsContainer.frame.origin.x > (self.didLoadCamera ? -230 : -130))
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = 0;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = YES;
        }];
        self.didLoadNotiVC = YES;
        self.didLoadCamera = NO;
    }
    else if (self.notificationsContainer.frame.origin.x < (self.didLoadCamera ? -550 : -410))
    {
        self.statusBarHide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -640;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            [self.numberUndeadLabel setHidden:YES];
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = YES;
    }
    else
    {
        self.statusBarHide = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        CGRect rf = self.notificationsContainer.frame;
        rf.origin.x = -320;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
            rf = self.numberUndeadLabel.frame;
            rf.origin.x = self.leftHeaderLabel.frame.origin.x + 8;
            self.numberUndeadLabel.frame = rf;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = NO;
    }
}

-(void)homeTableViewTouchStarted:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    [self touchesBegan:touches withEvent:event];
}

-(void)homeTableViewTouchSwiping:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    [self touchesMoved:touches withEvent:event];
    [self.tableView setScrollEnabled:NO];
}

-(void)homeTableViewTouchCancelled
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"touch swipe ended");
    [self touchesEnded:nil withEvent:nil];
    [self.tableView setScrollEnabled:YES];
}
/*
 THIS ONE IS FOR NOTI
 */
-(void)homeTableViewTouchStarted2:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    
    [self touchesBegan:touches withEvent:event];
}

-(void)homeTableViewTouchSwiping2:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    [self touchesMoved:touches withEvent:event];
}

-(void)homeTableViewTouchCancelled2
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    NSLog(@"touch swipe ended");
    [self touchesEnded:nil withEvent:nil];
}

-(IBAction)scrollToNoti:(id)sender
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    self.statusBarHide = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    CGRect rf = self.notificationsContainer.frame;
    rf.origin.x = 0;
    rf.origin.y = 52;
    [UIView animateWithDuration:0.3 animations:^{
        [self.numberUndeadLabel setHidden:YES];
        self.notificationsContainer.frame = rf;
        CGRect rf = self.cameraContainer.frame;
        rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
        self.cameraContainer.frame = rf;
        rf = self.tableView.frame;
        rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
        self.tableView.frame = rf;
        rf = self.cameraHeaderButton.frame;
        rf.origin.x = self.tableView.frame.origin.x + 262;
        //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
        //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
        self.cameraHeaderButton.frame = rf;
        self.cameraHeaderButton.alpha = 1;
        rf = self.rightHeaderLabel.frame;
        if (self.tableView.frame.origin.x + 110 > 220 )
        {
            rf.origin.x = 218;
        }
        else
        {
            rf.origin.x = self.tableView.frame.origin.x + 110;
        }
        //rf.origin.x = self.tableView.frame.origin.x + 110;
        self.rightHeaderLabel.frame = rf;
        rf = self.leftHeaderLabel.frame;
        if (self.tableView.frame.origin.x + 8 > 133 )
        {
            rf.origin.x = 133;
        }
        else
        {
            rf.origin.x = self.tableView.frame.origin.x + 8;
        }
        self.leftHeaderLabel.frame = rf;
        self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
        self.settingsHeaderButton.enabled = YES;
    }];
    self.didLoadNotiVC = YES;
    self.didLoadCamera = NO;
}

-(IBAction)scrollToMain:(id)sender
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    self.statusBarHide = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    CGRect rf = self.notificationsContainer.frame;
    if (rf.origin.x == -320)
    {
        self.forwardCameraString = @"";
        [self performSegueWithIdentifier:@"toCreate" sender:self];
    }
    else
    {
        rf.origin.x = -320;
        rf.origin.y = 52;
        [UIView animateWithDuration:0.3 animations:^{
            self.notificationsContainer.frame = rf;
            CGRect rf = self.cameraContainer.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
            self.cameraContainer.frame = rf;
            rf = self.tableView.frame;
            rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
            self.tableView.frame = rf;
            rf = self.cameraHeaderButton.frame;
            rf.origin.x = self.tableView.frame.origin.x + 282;
            //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
            //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
            self.cameraHeaderButton.frame = rf;
            self.cameraHeaderButton.alpha = 1;
            rf = self.rightHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 110 > 220 )
            {
                rf.origin.x = 218;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 110;
            }
            //rf.origin.x = self.tableView.frame.origin.x + 110;
            self.rightHeaderLabel.frame = rf;
            rf = self.leftHeaderLabel.frame;
            if (self.tableView.frame.origin.x + 8 > 133 )
            {
                rf.origin.x = 133;
            }
            else
            {
                rf.origin.x = self.tableView.frame.origin.x + 8;
            }
            self.leftHeaderLabel.frame = rf;
            self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/20;
            self.settingsHeaderButton.enabled = NO;
        }];
        self.didLoadNotiVC = NO;
        self.didLoadCamera = NO;
    }
}

-(IBAction)scrollToCamera:(id)sender
{
    if (self.cellWithMessageView != nil)
    {
        return;
    }
    
    if (!self.didStartCameraSession)
    {
        [self.cameraVC startCameraSession];
        self.didStartCameraSession = YES;
    }
    
    self.statusBarHide = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    CGRect rf = self.notificationsContainer.frame;
    rf.origin.x = -640;
    rf.origin.y = 52;
    [UIView animateWithDuration:0.3 animations:^{
        [self.numberUndeadLabel setHidden:YES];
        self.notificationsContainer.frame = rf;
        CGRect rf = self.cameraContainer.frame;
        rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
        self.cameraContainer.frame = rf;
        rf = self.tableView.frame;
        rf.origin.x = self.notificationsContainer.frame.origin.x + 320;
        self.tableView.frame = rf;
        rf = self.cameraHeaderButton.frame;
        rf.origin.x = self.tableView.frame.origin.x + 262;
        //rf.origin.y = 13 - (50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5))/2;
        //rf.size = (self.cameraHeaderButton.frame.origin.x < 160  ? CGSizeMake(60, 60) : CGSizeMake(50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5), 50 * ((fmodf((320 - self.cameraHeaderButton.frame.origin.x),262)/100)+0.5)));
        self.cameraHeaderButton.frame = rf;
        self.cameraHeaderButton.alpha = 1;
        rf = self.rightHeaderLabel.frame;
        if (self.tableView.frame.origin.x + 110 > 220 )
        {
            rf.origin.x = 218;
        }
        else
        {
            rf.origin.x = self.tableView.frame.origin.x + 110;
        }
        //rf.origin.x = self.tableView.frame.origin.x + 110;
        self.rightHeaderLabel.frame = rf;
        rf = self.leftHeaderLabel.frame;
        if (self.tableView.frame.origin.x + 8 > 133 )
        {
            rf.origin.x = 133;
        }
        else
        {
            rf.origin.x = self.tableView.frame.origin.x + 8;
        }
        self.leftHeaderLabel.frame = rf;
        self.settingsHeaderButton.alpha = (self.notificationsContainer.frame.origin.x+50)/2000;
        self.settingsHeaderButton.enabled = NO;
    }];
    self.didLoadNotiVC = NO;
    self.didLoadCamera = YES;
}



-(void)cameraDidStartZooming
{
    CGRect rf = self.notificationsContainer.frame;
    rf.origin.x = -640;
    rf.origin.y = 52;
    [UIView animateWithDuration:0.3 animations:^{
        self.notificationsContainer.frame = rf;
        CGRect rf = self.cameraContainer.frame;
        rf.origin.x = self.notificationsContainer.frame.origin.x + 640;
        self.cameraContainer.frame = rf;
    }];
    self.didLoadNotiVC = NO;
    self.didLoadCamera = YES;
}

-(IBAction)toSettings:(id)sender
{
    //NSLog(@"to SEttings");
    //[self performSegueWithIdentifier:@"toSettingsFromHome" sender:self];
    NSError *error;
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    self.selectedPerson = meInfo;
    self.forwardCameraString = @"";
    [self.storyboard instantiateViewControllerWithIdentifier:@"personVC"];
    [self performSegueWithIdentifier:@"toPersonFromHome" sender:self];
}

-(IBAction)openTheCamera:(id)sender
{
    [self performSegueWithIdentifier:@"toCameraFromHome" sender:self];
}

@end
