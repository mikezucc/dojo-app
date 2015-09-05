//
//  DOJOTypeChooser.h
//  dojo
//
//  Created by Michael Zuccarino on 12/18/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOTypeCell.h"

@protocol TypeChooseDelegate <NSObject>

@required
-(void)choseAType:(NSString *)type selectedIndex:(NSInteger)index;

@end

@interface DOJOTypeChooser : UIView

@property (nonatomic, weak) id<TypeChooseDelegate> delegate;

@property (strong, nonatomic) IBOutlet UICollectionView *typeCollectionView;
@property (strong, nonatomic) NSIndexPath *selectedCell;
@property (strong, nonatomic) NSMutableArray *typeArray;
@property (strong, nonatomic) NSMutableArray *typeNameArray;
@property (strong, nonatomic) NSMutableArray *colorList;

@end
