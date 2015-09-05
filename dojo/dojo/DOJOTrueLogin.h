//
//  DOJOTrueLogin.h
//  dojo
//
//  Created by Michael Zuccarino on 1/27/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOTrueLogin : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
@property (strong, nonatomic) IBOutlet UITextField *numberLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordLabel;
@property (strong, nonatomic) IBOutlet UILabel *notRightLabel;

@end
