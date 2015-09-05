//
//  DOJOPersonCell.h
//  dojo
//
//  Created by Michael Zuccarino on 1/2/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOPersonCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@end
