//
//  DOJOMembersViewController.h
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPageSettingsViewController.h"
#import "networkConstants.h"

@interface DOJOMembersViewController : UIViewController

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) IBOutlet UIButton *buttonMask;

@property (strong, nonatomic) NSDictionary *dojoData;

-(IBAction)goDeeper:(id)sender;

@end
