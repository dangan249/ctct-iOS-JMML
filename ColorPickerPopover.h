//
//  ColorPickerPopover.h
//  JMML
//
//  Created by John Walsh on 6/10/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate
- (void)colorSelected:(NSString *)color sender:(id)button;
@end


@interface ColorPickerController : UITableViewController {
    NSMutableArray *colors;
    id<ColorPickerDelegate> delegate;
	id buttonID;
}

@property (nonatomic, retain) NSMutableArray *colors;
@property (nonatomic, assign) id<ColorPickerDelegate> delegate;
@property (nonatomic, assign) id buttonID;

@end
