//
//  FontStyle.h
//  JMML
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface FontStyle : NSObject {
	
	NSString *familyName;
	NSString *actualFontName;
	NSString *displayName;
	int size;
	UIColor *color;
	long RGBColor;
	
}

@property (retain) NSString *familyName;
@property (retain) NSString *displayName;
@property (retain) NSString *actualFontName;
@property (assign) int size;
@property (retain,readonly) UIColor *color;
@property (assign) long RGBColor;

- (long) hexToLong: (NSString*) hexstring;
- (NSString *) hexcolor;

- (BOOL) hasSymbolicTrait:(NSString *)fontName trait:(unsigned) trait;
- (BOOL) isBold:(NSString *)fontName;
- (BOOL) isItalic:(NSString *)fontName;
- (BOOL) isBold;
- (BOOL) isItalic;
- (BOOL) isEnglish:(NSString *)fontName;

- (void) UpdateStyleTraits:(BOOL) bold italic:(BOOL)italic;


@end
