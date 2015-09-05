//
//  DOJOCreateAccountViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 12/1/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "networkConstants.h"

@interface DOJOCreateAccountViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *numberField;
@property (strong, nonatomic) IBOutlet UITextField *passField;
@property (strong, nonatomic) IBOutlet UILabel *swag;

@property (strong, nonatomic) IBOutlet UIButton *createButton;

@end
