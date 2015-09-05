//
//  DOJODeepPostViewController.m
//  Dojo
//
//  Created by Michael Zuccarino on 8/18/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJODeepPostViewController.h"

@interface DOJODeepPostViewController ()

@end

@implementation DOJODeepPostViewController

-(void)viewDidAppear:(BOOL)animated
{
    [self.view setNeedsDisplay];
}

-(void)likeThis
{
    
}

-(void)dislikeThis
{
    
}

-(void)repostThis
{
    
}

-(void)shareButton
{
    
}

-(void)closeMe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
