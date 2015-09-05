//
//  DOJONavigationController.h
//  dojo
//
//  Created by Michael Zuccarino on 7/15/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOHomeViewController.h"

@interface DOJONavigationController : UINavigationController

@property (strong, nonatomic) DOJOHomeViewController *homeViewController;

@property (strong, nonatomic) NSString *email;

@end
