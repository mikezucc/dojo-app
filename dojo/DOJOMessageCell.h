//
//  DOJOMessageCell.h
//  dojo
//
//  Created by Michael Zuccarino on 9/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOMessageCell : UITableViewCell

@property (strong,nonatomic) UITextView *messageBody;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *posttime;
//@property (strong, nonatomic) UIButton *magnifyButton;
@property (strong, nonatomic) UIImageView *profPicture;
@property (strong, nonatomic) UIView *background;

@end
