//
//  DOJOSendTableViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 7/20/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOSendBugButtonFix.h"

@interface DOJOSendTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *selectedView;

@end
