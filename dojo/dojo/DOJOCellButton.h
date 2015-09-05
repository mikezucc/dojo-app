//
//  DOJOCellButton.h
//  dojo
//
//  Created by Michael Zuccarino on 11/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellButtonTouchEventDelegate <NSObject>

@required
-(void)tapBegan:(NSInteger)selectedPost withSectionMajor:(NSInteger)sectionMajor withSectionMinor:(NSInteger)sectionMinor;
-(void)tapEnded;

@end

@interface DOJOCellButton : UIButton

@property (nonatomic, weak) id<CellButtonTouchEventDelegate> touchEventDelegate;
@property (nonatomic) CGPoint initialTouchLocation;

@property (nonatomic) NSInteger postNumber;
@property (nonatomic) NSInteger sectionMajor;
@property (nonatomic) NSInteger sectionMinor;

@end
