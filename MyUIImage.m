//
//  MyUIImage.m
//  JMML
//

#import "MyUIImage.h"


@implementation UIImage (MyUIImage)

-(UIImage*)scaleWithMaxSize:(size_t)maxSize
{
	
	if (maxSize <=0)
		maxSize= 1024;
	
    CGRect        bnds = CGRectZero;
    UIImage*      copy = nil;
    CGRect        orig = CGRectZero;
    CGFloat       rtio = 0.0;
	
    bnds.size = self.size;
    orig.size = self.size;
    rtio = orig.size.width / orig.size.height;
	
    if ((orig.size.width <= maxSize) && (orig.size.height <= maxSize))
    {
        return self;
    }
	
    if (rtio > 1.0)
    {
        bnds.size.width  = maxSize;
        bnds.size.height = maxSize / rtio;
    }
    else
    {
        bnds.size.width  = maxSize * rtio;
        bnds.size.height = maxSize;
    }
	UIGraphicsBeginImageContext(bnds.size); 
	[self drawInRect:bnds];
	copy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
    return copy;
}


@end
