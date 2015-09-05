//
//  DOJOCaptureButton.h
//  dojo
//
//  Created by Michael Zuccarino on 12/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol captureDelegate <NSObject>

@required
-(void)touchedAt:(NSNumber *)index;
-(void)touchIsOfPercentage:(NSNumber *)index;
-(void)touchLiftedAt:(NSNumber *)index;

@end

@interface DOJOCaptureButton : UIButton

@property (nonatomic, weak) id<captureDelegate> delegate;

@end
