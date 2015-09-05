//
//  DOJOSendTableViewBox.h
//  dojo
//
//  Created by Michael Zuccarino on 7/20/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOSendTableViewCell.h"
#import "networkConstants.h"
#import <CoreLocation/CoreLocation.h>

@interface DOJOSendTableViewBox : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet UITableView *searchTableView;

@property (strong, nonatomic) DOJOSendTableViewCell *sendCell;

@property BOOL isSearching;

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSArray *nameList;
@property (strong, nonatomic) NSArray *dataConv;
@property (strong, nonatomic) NSMutableArray *selectedList;
@property (strong, nonatomic) NSMutableArray *usableLocations;
@property (strong, nonatomic) NSString *posthash;
@property (nonatomic) BOOL isRepost;

@property (strong, nonatomic) NSArray *dojoTableViewData;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *documentsDirectory;

-(IBAction)addDojoToList:(UIButton *)button;
-(void)reloadTheSwag;

@end
