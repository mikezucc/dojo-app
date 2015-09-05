//
//  DOJOCreateGroupRealViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 11/4/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "networkConstants.h"
#import "DOJOFriendCell.h"
#import "DOJOTypeChooser.h"
#import <MapKit/MapKit.h>

@interface DOJOCreateGroupRealViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TypeChooseDelegate>

//metea
@property (strong, nonatomic) IBOutlet UITextField *dojoNameField;
@property (strong, nonatomic) IBOutlet UITextField *dojoCodeField;
@property (strong, nonatomic) IBOutlet UISwitch *secretSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *codeSwitch;
@property (strong, nonatomic) IBOutlet UIButton *typeButton;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeLogoView;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet DOJOTypeChooser *typeChooseWindow;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSMutableArray *selectedList;
@property (strong, nonatomic) NSArray *colorList;

// location info
@property (strong, nonatomic) CLLocation *dojoLocation;
@property (strong, nonatomic) CLLocationManager *dojoLocationManager;

@end
