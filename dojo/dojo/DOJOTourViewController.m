//
//  DOJOTourViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/1/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOTourViewController.h"
#import "DOJOTourCollectionViewCell.h"

@interface DOJOTourViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation DOJOTourViewController

@synthesize tourCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //perform pre segue property application here
    UICollectionViewFlowLayout *latestLayout = [[UICollectionViewFlowLayout alloc] init];
    [latestLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [latestLayout setMinimumInteritemSpacing:0];
    [latestLayout setMinimumLineSpacing:0];
    tourCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:latestLayout];
    tourCollectionView.backgroundColor = [UIColor whiteColor];
    // [latestCollectionView registerClass:[CustomCellClass class] forCellWithReuseIdentifier:@"collectCell"];
    [tourCollectionView setDelegate:self];
    [tourCollectionView setDataSource:self];
    tourCollectionView.tag = 1;
    [tourCollectionView registerClass:[DOJOTourCollectionViewCell class] forCellWithReuseIdentifier:@"collectCell"];
    //latestCollectionView.alwaysBounceHorizontal = YES;
    //latestCollectionView.alwaysBounceVertical = YES;
    tourCollectionView.pagingEnabled = YES;
    [self.view addSubview:tourCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
