//
//  DOJOHomeViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOHomeTableViewBox.h"
#import "DOJONetTestViewController.h"
#import "DOJODojoPageViewController.h"
#import "DOJOAnnotateViewController.h"
#import "DOJOSendViewController.h"
#import "dojo/DOJOCameraViewController.h"
#import "DOJOSearch4DojosViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "networkConstants.h"

@protocol HomeViewDelegate <NSObject>

-(void)didChangeHomeType:(UISegmentedControl *)segControl;

@end

@interface DOJOHomeViewController : UIViewController <UIImagePickerControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, weak) id<HomeViewDelegate> homeDelegate;
@property (nonatomic) BOOL firsTimeBoot;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *drawerButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *createDojoButton;

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) UIAlertView *downloadingShit;

-(void)toCreateGroup;

@property (strong, nonatomic) DOJOSendViewController *sendController;
@property (strong, nonatomic) DOJONetTestViewController *dojoInfoPage;
@property (strong, nonatomic) DOJODojoPageViewController *dojoPage;
@property (strong, nonatomic) DOJOSearch4DojosViewController *searchController;
-(IBAction)LoadDojoPage:(UIButton *)button;
-(void)loadDojo:(NSInteger)row;
-(IBAction)addDojo:(UIButton *)button;
-(NSString *)generateCode;
-(void)magnifyCell:(UIButton *)button;
-(IBAction)refreshHomePage:(id)sender;
-(void)refreshHomePagePublic;

@property NSInteger rowTag;
@property NSInteger cellTag;

@property (strong, nonatomic) NSArray *dojoTableViewData;
@property (strong, nonatomic) NSArray *orderedFreshest;
@property (strong, nonatomic) NSArray *dataConv;

@property (strong, nonatomic) NSString *userEmail;

@property (strong, nonatomic) IBOutlet DOJOHomeTableViewBox *homeTableView;

//camera fun
@property (strong, nonatomic) UIImagePickerController *picker;
-(IBAction)callCameraMethod:(UIButton *)sender;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;

@property (strong, nonatomic) DOJOAnnotateViewController *annotateController;

@property (strong, nonatomic) NSData *videoData;
@property (strong, nonatomic) NSData *imageData;

@property (strong, nonatomic) NSString *mediaType;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *profileIcon;
-(IBAction)loadAccountPage:(id)sender;

@property (strong, nonatomic) NSDictionary *selectedDojoDict;
@property NSInteger selectedPostIndex;

@end
