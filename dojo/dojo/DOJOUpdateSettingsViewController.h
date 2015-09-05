//
//  DOJOUpdateSettingsViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 12/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "networkConstants.h"
#import "DOJOFriendCell.h"

@interface DOJOUpdateSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//metea
@property (strong, nonatomic) IBOutlet UITextField *dojoNameField;
@property (strong, nonatomic) IBOutlet UITextField *dojoCodeField;
@property (strong, nonatomic) IBOutlet UISwitch *secretSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *codeSwitch;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSMutableArray *selectedList;
@property (strong, nonatomic) NSArray *colorList;

@property (strong, nonatomic) NSDictionary *dojoInfo;
@property (strong, nonatomic) NSArray *addSumoList;
@property (strong, nonatomic) NSArray *allDatas;

@end
