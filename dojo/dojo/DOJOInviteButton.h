//
//  DOJOInviteButton.h
//  dojo
//
//  Created by Michael Zuccarino on 11/8/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MagnifyTouchDelegate <NSObject>

@required
-(void)tapBegan;
-(void)tapEnded;

@end

@interface DOJOInviteButton : UIButton

@property NSInteger section;
@property NSInteger searchType;

@property (nonatomic, weak) id<MagnifyTouchDelegate> magnifyDelegate;
@property (nonatomic) CGPoint initialTouchLocation;
@property (nonatomic) int numberOfActiveTouches;

@end
