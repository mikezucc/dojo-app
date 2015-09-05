//
//  DOJOTypeChooser.m
//  dojo
//
//  Created by Michael Zuccarino on 12/18/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOTypeChooser.h"

@interface DOJOTypeChooser () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation DOJOTypeChooser

@synthesize typeCollectionView, selectedCell, typeArray, typeNameArray, colorList;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.colorList = [[NSMutableArray alloc] initWithArray:@[
                                                             [UIColor colorWithRed:188.0/255.0 green:216.0/255.0 blue:156.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:229.0/255.0 green:145.0/255.0 blue:246.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:247.0/255.0 green:239.0/255.0 blue:133.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:178.0/255.0 green:113.0/255.0 blue:234.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:246.0/255.0 green:88.0/255.0 blue:108.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:88.0/255.0 green:230.0/255.0 blue:246.0/255.0 alpha:1],
                                                             [UIColor colorWithRed:134.0/255.0 green:156.0/255.0 blue:182.0/255.0 alpha:1],
                                                             ]];
    
    typeArray = [[NSMutableArray alloc] initWithArray:@[@"bomb228.png",@"music228.png",@"medal228.png",@"ribbon228.png",@"loudspeaker228.png",@"paperstack228.png",@"noodle.png",@"cup228.png",@"share228.png"]];
    typeNameArray = [[NSMutableArray alloc] initWithArray:@[@"Party",@"Music",@"Greek",@"Event Promo",@"Club",@"Study Group",@"Restaurant",@"Sport",@"None"]];
    NSLog(@"checkpoint");
    UICollectionViewFlowLayout *flowLay = [[UICollectionViewFlowLayout alloc] init];
    NSLog(@"checkpoint");
    flowLay.minimumInteritemSpacing = 1;
    flowLay.minimumLineSpacing = 1;
    flowLay.itemSize = CGSizeMake(105, 105);
    flowLay.scrollDirection = UICollectionViewScrollDirectionVertical;
    NSLog(@"checkpoint");
    typeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, 320, self.frame.size.height) collectionViewLayout:flowLay];
        NSLog(@"checkpoint");
    [typeCollectionView registerClass:[DOJOTypeCell class] forCellWithReuseIdentifier:@"typeCell"];
        NSLog(@"checkpoint");
    typeCollectionView.dataSource = self;
    typeCollectionView.delegate = self;
    typeCollectionView.collectionViewLayout = flowLay;
        NSLog(@"checkpoint");
    [typeCollectionView reloadData];
    NSLog(@"checkpoint");
    [self addSubview:typeCollectionView];
        NSLog(@"checkpoint");
    return self;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"RELOADING TYPE COLLECTION VIEW");
    return [self.typeArray count];
}

-(DOJOTypeCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"beginning cell process");
    DOJOTypeCell *cell = (DOJOTypeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"typeCell" forIndexPath:indexPath];
    if (!cell)
    {
        NSLog(@"INIT the CELLS");
        cell = [[DOJOTypeCell alloc] init];
    }
    
    //cell.typeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    cell.typeIcon.frame = CGRectMake(7, 10, 80, 60);
    //cell.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 20)];
    cell.typeLabel.frame = CGRectMake(0, 75, 105, 20);
    cell.typeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    cell.typeLabel.textColor = [UIColor whiteColor];
    cell.typeLabel.textAlignment = NSTextAlignmentCenter;
    
    
    if ([cell.contentView.subviews count] == 0)
    {
        NSLog(@"adding shit");
        //[cell.contentView addSubview:cell.typeIcon];
        //[cell.contentView addSubview:cell.typeLabel];
    }
    
    cell.typeIcon.image = [UIImage imageNamed:[self.typeArray objectAtIndex:indexPath.row]];
    cell.typeIcon.contentMode = UIViewContentModeScaleAspectFit;
    
    cell.typeLabel.text = [self.typeNameArray objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithHue:(fmodf(indexPath.row*10.0,100))/100 saturation:0.8 brightness:1 alpha:1];
    if (indexPath.row == 2)
    {
        cell.backgroundColor = [UIColor orangeColor];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DOJOTypeCell *cell = (DOJOTypeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedCell = indexPath;
    [self.delegate choseAType:[self.typeNameArray objectAtIndex:indexPath.row] selectedIndex:indexPath.row];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
