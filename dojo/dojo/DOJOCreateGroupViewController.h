//
//  DOJOCreateGroupViewController.h
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOCreateGroupViewBox.h"
#import "networkConstants.h"

@interface DOJOCreateGroupViewController : UIViewController


@property (strong, nonatomic) DOJOCreateGroupViewBox *dojoFriendTable;

@property (strong, nonatomic) IBOutlet UIButton *createButton;

-(IBAction)createDojo:(UIButton *)button;
-(IBAction)removeScreen:(id)sender;

-(void)scrollUp;
-(void)scrollDown;

@property BOOL preventJumping;

@property (strong, nonatomic) NSString *userEmail;

@end
