//
//  DOJOHomeTableSwagView.h
//  dojo
//
//  Created by Michael Zuccarino on 1/30/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeTableViewDelegate <NSObject>

@optional
-(void)homeTableViewTouchStarted:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)homeTableViewTouchSwiping:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)homeTableViewTouchCancelled;

@end

@interface DOJOHomeTableSwagView : UITableView

@property (strong, nonatomic) id<HomeTableViewDelegate> touchDelegate;
@property (nonatomic) CGPoint startTouch;
@property (strong, nonatomic) id homeMainView;

@end
