//
//  MyUIImage.h
//  JMML
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 

@interface UIImage (MyUIImage)

-(UIImage*)scaleWithMaxSize:(size_t)maxSize;

@end
