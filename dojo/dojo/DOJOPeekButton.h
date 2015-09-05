//
//  DOJOPeekButton.h
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PeekDelegate <NSObject>

@required
-(void)tapBegan:(NSInteger)selectedPost withSectionMajor:(NSInteger)sectionMajor withSectionMinor:(NSInteger)sectionMinor;
-(void)tapMovedPeek;
-(void)tapEnded;

@end

@interface DOJOPeekButton : UIButton

@property (nonatomic, weak) id<PeekDelegate> delegate;
@property (nonatomic) CGPoint initialTouchLocation;

@property (nonatomic) NSInteger postNumber;
@property (nonatomic) NSInteger sectionMajor;
@property (nonatomic) NSInteger sectionMinor;

@end
