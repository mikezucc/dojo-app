//
//  DOJOProfileTableView.h
//  dojo
//
//  Created by Michael Zuccarino on 1/5/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol touchdelegate <NSObject>

@required
-(void)tableTouchBegin:(CGPoint)location;
-(void)tableTouchMoved:(CGPoint)location;
-(void)tableTouchEnded:(CGPoint)location;
-(void)tableTouchCancelled:(CGPoint)location;

@end

@interface DOJOProfileTableView : UITableView

@property (weak, nonatomic) id<touchdelegate> touchDelegate;


@end
