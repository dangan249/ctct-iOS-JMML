//
//  Theme.h
//  JMML
//

#import <Foundation/Foundation.h>
#import "FontStyle.h"


#define thumbnail_size	200

@interface Theme : NSObject {

    NSString *image_name;
    FontStyle *fs1,*fs2,*fs3,*fs4;
    UIImage *image;
    UIImage *thumbnail;  
    NSString *themeString;
}


@property (retain) NSString *image_name;
@property (retain) FontStyle *fs1;
@property (retain) FontStyle *fs2;
@property (retain) FontStyle *fs3;
@property (retain) FontStyle *fs4;
@property (retain) UIImage *image;
@property (retain) UIImage *thumbnail;

- (id)initWithThemeString:(NSString *) ts;
- (NSString *) toThemeString;
- (void) saveImage;
- (void) loadImage;
@end
