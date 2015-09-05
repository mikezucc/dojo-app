//
//  DOJONetTestViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJONetTestViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *DojoLabel;
@property (strong, nonatomic) IBOutlet UILabel *CodeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hashLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;

@property (strong, nonatomic) NSArray *dataConv;

@end
