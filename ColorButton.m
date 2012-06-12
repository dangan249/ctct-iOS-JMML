//
//  ColorButton.m
//  JMML
//

#import "ColorButton.h"


@implementation ColorButton

@synthesize selected,showCheckmark;

// new default constructor
- (id) init {
    self = [super initWithItems:[NSArray arrayWithObject:@""]];
    [self setSegmentedControlStyle:UISegmentedControlStyleBar];
    showCheckmark = YES;
    return self;
}

// color methods that mimic UIButton
-(UIColor *) color {
    return [self tintColor];
}

- (void) setColor: (UIColor *) c {
    [self setTintColor: c];
}
                                  
                        
- (void) drawRect:(CGRect) rect {
    [super drawRect:rect];
    if (selected && showCheckmark) {
        if (checkmark ==nil) {
            checkmark = [UIImage imageNamed:@"checkmark.png"];
        }
        [self setImage:checkmark forSegmentAtIndex:0];
    }else{
        [self setImage:nil forSegmentAtIndex:0];

    }
        
}


- (void) setSelected:(BOOL)s {
    selected = s;
    [self setNeedsDisplay];
    
}

- (BOOL) selected {
    
    return [self selected];
    
}

@end
