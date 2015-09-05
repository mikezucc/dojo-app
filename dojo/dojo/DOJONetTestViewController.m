//
//  DOJONetTestViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 7/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJONetTestViewController.h"

@interface DOJONetTestViewController ()

@end

@implementation DOJONetTestViewController

@synthesize DojoLabel, CodeLabel, hashLabel, timestampLabel, dataConv;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"array contains this %@", dataConv);
    NSLog(@"object at index 0 is %@", [dataConv objectAtIndex:0]);
    NSLog(@"value for dojo key is %@", [dataConv valueForKey:@"dojo"]);
    //NSDictionary *convDict = [[NSDictionary alloc] initWithObjectsAndKeys:dataConv, nil];
    
    NSString *dojoName = [[NSString alloc] initWithFormat:@"%@",[[dataConv valueForKey:@"dojo"] objectAtIndex:0]];
    NSString *code = [[NSString alloc] initWithFormat:@"%@",[[dataConv valueForKey:@"code"] objectAtIndex:0]];
    NSString *dojohash = [[NSString alloc] initWithFormat:@"%@",[[dataConv valueForKey:@"dojohash"] objectAtIndex:0]];
    NSString *timestamp = [[NSString alloc] initWithFormat:@"%@",[[dataConv valueForKey:@"made"] objectAtIndex:0]];
    /*    NSString *dojoName = [convDict valueForKey:@"dojo"];
     NSString *code = [convDict valueForKey:@"code"];
     NSString *dojohash = [convDict valueForKey:@"dojohash"];
     NSString *timestamp = [convDict valueForKey:@"made"];*/
    
    DojoLabel.text = dojoName;
    CodeLabel.text = code;
    hashLabel.text = dojohash;
    timestampLabel.text = timestamp;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
