//
//  DOJODrawToolButton.h
//  dojo
//
//  Created by Michael Zuccarino on 1/15/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawButtonDelegate <NSObject>

@required
-(void)activatedInDrawButton:(UITouch *)startTouch;
-(void)movingInDrawButton:(UITouch *)currentTouch;
-(void)releasedInDrawButton:(UITouch *)lastTouch;

@end

@interface DOJODrawToolButton : UIButton

@property (nonatomic) CGPoint startPoint;

@property (strong, nonatomic) id<DrawButtonDelegate> drawDelegate;

@end
