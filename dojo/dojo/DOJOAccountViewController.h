//
//  DOJOAccountViewController.h
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "networkConstants.h"
#import "DOJOProfileViewController.h"

@interface DOJOAccountViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIButton *changeButton;

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureview;
@property (strong, nonatomic) NSDictionary *personInfo;

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextView *personBio;

@property (strong, nonatomic) IBOutlet UILabel *changePFPictureButton;

@property (strong, nonatomic) DOJOProfileViewController* profileVC;

@property (strong, nonatomic) IBOutlet UIButton *spreadButton;
           
-(IBAction)sendHelpEmail:(id)sender;

-(IBAction)clearCache:(id)sender;

-(IBAction)saveBio:(id)sender;

@end
