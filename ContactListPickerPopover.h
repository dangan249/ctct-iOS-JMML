//
//  ContactListPickerPopover.h
//  JMML
//
//  Created by John Walsh on 6/12/10.
//  Copyright 2010 Constant Contact. All rights reserved.
//

#import "Remove Me from the Project"
#import <UIKit/UIKit.h>

@protocol ContactListPickerDelegate
- (void)contactListSelected:(NSString *)contactListName link:(NSString *)contactListLink;
@end


@interface ContactListController : UITableViewController {
    id<ContactListPickerDelegate> delegate;
	NSMutableArray *Lists;
}

@property (nonatomic, assign) id<ContactListPickerDelegate> delegate;
@property (nonatomic,retain) NSMutableArray	*Lists;

@end
