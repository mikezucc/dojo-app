//
//  DOJODSV3000.m
//  dojo
//
//  Created by Michael Zuccarino on 2/18/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJODSV3000.h"

@interface DOJODSV3000 () <UIWebViewDelegate>

@end

@implementation DOJODSV3000

@synthesize dsvBackButton,delegate,dsvButton, dsvForwardButton, dsvTitle, dsvURL, dsvWebView;

-(IBAction)removeTheDSV
{
    [self.delegate hideDSV3000];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dsvWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 52, 320, 464)];
    [self.view addSubview:self.dsvWebView];
}

-(void)loadThisSite:(NSString *)theSite
{
    [self.dsvWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:theSite]]];
}

-(void)loadThisSiteFromURL:(NSURL *)url
{
    [self.dsvWebView loadRequest:[NSURLRequest requestWithURL:url]];
    self.dsvWebView.scalesPageToFit = YES;
    NSLog(@"We finna load that shit now ok");
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate didLoadTheDSV3000];
}

-(IBAction)incrementBackward
{
    [self.dsvWebView goBack];
}

-(IBAction)incremenetForward
{
    [self.dsvWebView goForward];
}

-(IBAction)saveDSVForL8TR
{
    float blurRadius = 1.0f;
    int boxSize = (int)(blurRadius * 100); boxSize -= (boxSize % 2) + 1;
    
    CGSize imageSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-104);
    UIGraphicsBeginImageContextWithOptions(imageSize, self.view.opaque, 0.0);
    [self.dsvWebView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(screenImage,nil,nil,nil);
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved!" delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil] show];
}


@end
