//
//  ThemeSelectorCell.m
//  JMML
//

#import "ThemeSelectorCell.h"


@implementation ThemeSelectorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier: reuseIdentifier];
    return self;

}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.selected){
        
        CGRect contentRect = self.contentView.bounds;
        CGRect frame;
        frame= CGRectMake(contentRect.origin.x+2 ,contentRect.origin.y+2, contentRect.size.width-4,contentRect.size.height-4);
        self.imageView.frame = frame;
    }
    else {
        // [self.imageView setFrame:self.contentView.bounds];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//      [super setSelected:selected animated:animated];

    if (selected) {
        [UIView beginAnimations:@"cell animation" context:nil];
        [UIView setAnimationDuration:0.5f];
        [self.imageView setFrame:self.contentView.bounds];
        [UIView commitAnimations];
        [self setNeedsLayout];
    }
    else {
        [self setNeedsLayout];
    }
    
}

@end
