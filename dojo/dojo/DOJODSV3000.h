//
//  DOJODSV3000.h
//  dojo
//
//  Created by Michael Zuccarino on 2/18/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSVDelegate <NSObject>

@optional
-(void)hideDSV3000;
-(void)didLoadTheDSV3000;

@end

@interface DOJODSV3000 : UIViewController

@property (strong, nonatomic) id<DSVDelegate> delegate;

@property (strong, nonatomic) UIWebView *dsvWebView;
@property (strong, nonatomic) NSString *dsvURL;

@property (strong, nonatomic) NSString *dsvTitle;
@property (strong, nonatomic) IBOutlet UIButton *dsvBackButton;
@property (strong, nonatomic) IBOutlet UIButton *dsvForwardButton;
@property (strong, nonatomic) IBOutlet UIButton *dsvButton;

-(void)loadThisSite:(NSString *)theSite;

-(void)loadThisSiteFromURL:(NSURL *)url;
           
@end
