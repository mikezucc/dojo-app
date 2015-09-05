//
//  DOJOPageSettingsViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/24/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOMembersTableViewBox.h"
#import "DOJOMembersViewController.h"
#import "networkConstants.h"

@interface DOJOPageSettingsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) DOJOMembersTableViewBox *dojoFriendTable;

@property (strong, nonatomic) IBOutlet UITextField *changeDojoNameField;
@property (strong, nonatomic) IBOutlet UITextField *changeDojoCodeField;

@property (strong, nonatomic) NSDictionary *dojoData;

@property (strong, nonatomic) IBOutlet UISwitch *searchSwitch;

-(IBAction)switchSecretState:(id)sender;

-(IBAction)toMembers:(id)sender;

-(IBAction)changeDojoName:(id)sender;

-(IBAction)changeDojoCode:(id)sender;

-(IBAction)leaveDojo:(id)sender;

@end
