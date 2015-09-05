//
//  DOJOHomeTableViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPicView.h"

@interface DOJOHomeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dojoNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *activeMemberLabel;
@property (strong, nonatomic) IBOutlet UIButton *datButton;
@property (strong, nonatomic) IBOutlet DOJOPicView *picView;
@property (strong, nonatomic) IBOutlet UIImageView *alphaBar;
@property (strong, nonatomic) IBOutlet UILabel *timeStamp;
@property (strong, nonatomic) IBOutlet UILabel *invitationType;

-(IBAction)tapRow:(id)sender; //could be overridden by :didSelectRowAtIndexPath
-(IBAction)holdRow:(id)sender;
-(IBAction)swipeRight:(id)sender; //all of these will get overridden with their actual gesture receivers

@end
