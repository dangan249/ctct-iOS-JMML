//
//  FontTypeSelector.m
//  JMML
//

#import "FontTypeSelector.h"
#import "FontController.h"

@implementation FontTypeSelector

static NSMutableArray *fontlist = nil;

+ (void) initialize {   //is called when the CLASS is loaded
    [self loadFontList];
    
}

+ (NSMutableArray*) fontlist { // access to the static as a class variable
    return  fontlist;
}


// constructor
- (id) init {

    self = [super init];
    entryList = [FontTypeSelector fontlist]; // set the instance variable to the class variable;
                                             // because PopoverTableController uses the instance variable entrylist
    
    return self;
}



+ (void) loadFontList {
    
    if ([FontTypeSelector fontlist] == nil) {
		
		fontlist = [[NSMutableArray arrayWithCapacity:10] retain];	
        
		for (NSString *family in [UIFont familyNames]) {
			
			FontStyle *style = [[FontStyle alloc]init];
			[style setFamilyName:family];
			
			if ([style isEnglish:family]) {
                
                // IOS 5 supports more font types than this app; igore the others which will appear as dups
                BOOL bNormal = FALSE, bItalics = FALSE, bBold = FALSE, bBoldItalics = FALSE;
                NSMutableArray *fontNames = [NSMutableArray arrayWithArray:[UIFont fontNamesForFamilyName:family]];			
                
				for (NSString* actualFontName in fontNames) {
					// Special case if only 1 font in the family .. just add as is regardless of attributes.
                    // i.e. "Arial Rounded MT Bold" fontName
					if ( ([fontNames count] == 1) || 
                         (![style isBold:actualFontName] && ![style isItalic:actualFontName]) ) {
                        if (!bNormal) {
                            FontStyle *traitStyle = [[FontStyle alloc]init];
                            [traitStyle setFamilyName:family];
                            [traitStyle UpdateStyleTraits:NO italic:NO];
                            [fontlist addObject:traitStyle];
                            [traitStyle release];
                            bNormal = TRUE;
                        }
					}
					else if ([style isBold:actualFontName] && ![style isItalic:actualFontName] ) {
                        if (!bBold) {
                            FontStyle *traitStyle = [[FontStyle alloc]init];
                            [traitStyle setFamilyName:family];
                            [traitStyle UpdateStyleTraits:YES italic:NO];
                            [fontlist addObject:traitStyle];
                            [traitStyle release];
                            bBold = TRUE;
                        }
					}
					else if ([style isItalic:actualFontName] && ![style isBold:actualFontName]) {
                        if (!bItalics) {
                            FontStyle *traitStyle = [[FontStyle alloc]init];
                            [traitStyle setFamilyName:family];
                            [traitStyle UpdateStyleTraits:NO italic:YES];
                            [fontlist addObject:traitStyle];
                            [traitStyle release];
                            bItalics = TRUE;
                        }
					} 
                    else if ([style isBold:actualFontName] && [style isItalic:actualFontName] ) {
                        if (!bBoldItalics) {
                            FontStyle *traitStyle = [[FontStyle alloc]init];
                            [traitStyle setFamilyName:family];
                            [traitStyle UpdateStyleTraits:YES italic:YES];
                            [fontlist addObject:traitStyle];
                            [traitStyle release];
                            bBoldItalics = TRUE;
                        }
					}
				}
			}
            [style release];
		}
		[fontlist sortUsingSelector:@selector(compare:)];
	}	
}

- (FontStyle*) getStyle: (int) index {
	
	return [[self entryList] objectAtIndex:index];
}

// sets the type from the prefs
- (void) setFontType:(NSString *)type {
	
	selectedItem = 0;
	for (FontStyle *style in entryList) {
		if ([[style displayName] isEqualToString:type]) {
			break;
		}
		selectedItem++;
	}
	
    //fail safe to prevent crash if font not found
    if (selectedItem >= [entryList count])
        selectedItem = 0;
    
    // IOS 4 requires the following, IOS 5 doesnt and the didviewAppear method of popovercontroller gets called.
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5.0) {
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedItem inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"FontType";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	// Configure the cell.
	FontStyle *style = [[self entryList] objectAtIndex:indexPath.row];
	[cell.textLabel setText:[style displayName]];
	[cell.textLabel setFont:[UIFont fontWithName:[style actualFontName] size:16]];
	
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	
	return cell;
}

@end
