//
//  DOJODrawColorView.m
//  dojo
//
//  Created by Michael Zuccarino on 1/15/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJODrawColorView.h"

@implementation DOJODrawColorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize wheelSwag;

- (void)drawRect:(CGRect)rect
{
    /*
    CGSize size = CGSizeMake(rect.size.width, rect.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), YES, 0.0);
    [[UIColor clearColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    self.backgroundColor = [UIColor clearColor];
    int sectors = 180;
    float radius = MIN(size.width, size.height);
    float angle = (0.5*M_PI)/sectors;
    UIBezierPath *bezierPath;
    float thang = 0;
    for ( int i = 180; i < 360; i++)
    {
        CGPoint center = CGPointMake(size.width, 0);
        bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:i * angle endAngle:(i + 1) * angle clockwise:YES];
        [bezierPath addLineToPoint:center];
        [bezierPath closePath];
        UIColor *color = [UIColor colorWithHue:(thang)/sectors saturation:1. brightness:1. alpha:1];
        thang += 1;
        [color setFill];
        [color setStroke];
        [bezierPath fill];
        [bezierPath stroke];
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    wheelSwag = [[UIImageView alloc] initWithImage:img];
    [wheelSwag setFrame:rect];
    [self addSubview:wheelSwag];
    */
    /*
    int dim = self.bounds.size.width; // should always be square.
    CFDataRef bitmapData = CFDataCreateMutable(NULL, 0);
    CFDataSetLength(bitmapData, dim * dim * 4);
    generateColorWheelBitmap(CFDataGetMutableBytePtr(bitmapData), dim, 1.0);
    UIImage *image = createUIImageWithRGBAData(bitmapData, self.bounds.size.width, self.bounds.size.height);
    CFRelease(bitmapData);
    [image drawAtPoint:CGPointZero];
     */
}

void generateColorWheelBitmap(UInt8 *bitmap, int widthHeight, float l)
{
    // I think maybe you can do 1/3 of the pie, then do something smart to generate the other two parts, but for now we'll brute force it.
    for (int y = 0; y < widthHeight; y++)
    {
        for (int x = 0; x < widthHeight; x++)
        {
            float h, s, r, g, b, a;
            getColorWheelValue(widthHeight, x, y, &h, &s);
            if (s < 1.0)
            {
                // Antialias the edge of the circle.
                if (s > 0.99) a = (1.0 - s) * 100;
                else a = 1.0;
                
                HSL2RGB(h, s, l, &r, &g, &b);
            }
            else
            {
                r = g = b = a = 0.0f;
            }
            
            int i = 4 * (x + y * widthHeight);
            bitmap[i] = r * 0xff;
            bitmap[i+1] = g * 0xff;
            bitmap[i+2] = b * 0xff;
            bitmap[i+3] = a * 0xff;
        }
    }
}

void getColorWheelValue(int widthHeight, int x, int y, float *outH, float *outS)
{
    int c = widthHeight / 2;
    float dx = (float)(x - c) / c;
    float dy = (float)(y - c) / c;
    float d = sqrtf((float)(dx*dx + dy*dy));
    *outS = d;
    *outH = acosf((float)dx / d) / M_PI / 2.0f;
    if (dy < 0) *outH = 1.0 - *outH;
}

UIImage *createUIImageWithRGBAData(CFDataRef data, int width, int height)
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return image;
}

// Adapted from Apple sample code.  See http://en.wikipedia.org/wiki/HSV_color_space#Comparison_of_HSL_and_HSV
void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
    float temp1, temp2;
    float temp[3];
    int i;
    
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if(s == 0.0)
    {
        *outR = l;
        *outG = l;
        *outB = l;
        return;
    }
    
    // Test for luminance and compute temporary values based on luminance and saturation
    if(l < 0.5)
        temp2 = l * (1.0 + s);
    else
        temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
    
    // Compute intermediate values based on hue
    temp[0] = h + 1.0 / 3.0;
    temp[1] = h;
    temp[2] = h - 1.0 / 3.0;
    
    for(i = 0; i < 3; ++i)
    {
        // Adjust the range
        if(temp[i] < 0.0)
            temp[i] += 1.0;
        if(temp[i] > 1.0)
            temp[i] -= 1.0;
        
        
        if(6.0 * temp[i] < 1.0)
            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
        else {
            if(2.0 * temp[i] < 1.0)
                temp[i] = temp2;
            else {
                if(3.0 * temp[i] < 2.0)
                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
                else
                    temp[i] = temp1;
            }
        }
    }
    
    // Assign temporary values to R, G, B
    *outR = temp[0];
    *outG = temp[1];
    *outB = temp[2];
}

@end
