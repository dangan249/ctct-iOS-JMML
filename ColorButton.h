//
//  ColorButton.h
//  JMML
//

#import <Foundation/Foundation.h>


@interface ColorButton : UISegmentedControl {
    
    BOOL selected;
    UIImage *checkmark;
    BOOL showCheckmark;
}

@property (assign) BOOL selected;
@property (assign) BOOL showCheckmark; //default = YES

- (UIColor *) color;
- (void) setColor: (UIColor *) c;

@end
