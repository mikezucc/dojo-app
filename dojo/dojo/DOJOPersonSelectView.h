//
//  DOJOPersonSelectView.h
//  dojo
//
//  Created by Michael Zuccarino on 1/6/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectdelegate <NSObject>

@required
-(void)selectTouchBegin:(CGPoint)location;
-(void)selectTouchMoved:(UITouch *)location;
-(void)selectTouchEnded:(CGPoint)location;
-(void)selectTouchCancelled:(CGPoint)location;

@end

@interface DOJOPersonSelectView : UIView

@property (weak, nonatomic) id<selectdelegate> selectdelegate;

@end
