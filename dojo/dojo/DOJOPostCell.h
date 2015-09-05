//
//  DOJOPostCell.h
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostCellDelegate <NSObject>

@required
-(void)swipeStarted;
-(void)swipeIsMoving:(NSNumber *)distance;
-(void)swipeLetGoforRow:(NSInteger)row;
-(void)swipeCanceled;
@end

@interface DOJOPostCell : UITableViewCell

@property (weak, nonatomic) id<PostCellDelegate> delegate;
@property (nonatomic) CGPoint startPoint;

@property (strong, nonatomic) IBOutlet UIImageView *postView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *payloadLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *customDivider;

@property (strong, nonatomic) IBOutlet UIButton *shitbutton;

@end
