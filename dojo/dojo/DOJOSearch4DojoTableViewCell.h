//
//  DOJOSearch4DojoTableViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 10/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPicView.h"
#import "DOJOPostCollectionViewCell.h"
#import "DOJOInviteButton.h"

@interface DOJOSearch4DojoTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dojoLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet DOJOInviteButton *addButton;
@property (strong, nonatomic) IBOutlet DOJOPicView *picView;
@property (strong, nonatomic) IBOutlet UIImageView *alphaBar;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;


@end
