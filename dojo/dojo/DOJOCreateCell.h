//
//  DOJOCreateCell.h
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateCellDelegate <NSObject>

@required
-(void)swipeStarted;
-(void)swipeIsMoving:(NSNumber *)distance;
-(void)swipeLetGoforRow:(NSInteger)row;
-(void)swipeCanceled;
@end

@interface DOJOCreateCell : UITableViewCell

@property (weak, nonatomic) id<CreateCellDelegate> delegate;
@property (nonatomic) CGPoint startPoint;

@property (strong, nonatomic) IBOutlet UILabel *payloadLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dojoIconView;
@property (strong, nonatomic) IBOutlet UILabel *dojoName;
@property (strong, nonatomic) IBOutlet UILabel *postNumber;
@property (strong, nonatomic) IBOutlet UILabel *followerNumber;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *customDivider;

@property (strong, nonatomic) IBOutlet UIButton *shitbutton;

@end
