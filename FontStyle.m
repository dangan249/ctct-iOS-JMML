//
//  FontStyle.m
//  JMML
//

#import "FontStyle.h"
#import	"CoreText/CTFont.h"

@implementation FontStyle

@synthesize familyName, actualFontName, size, color, displayName, RGBColor;


- (long) hexToLong: (NSString*) hexstring {
    NSScanner* pScanner = [NSScanner scannerWithString: hexstring];
    
    unsigned int iValue;
    [pScanner scanHexInt: &iValue];
    return (long)iValue;
    
}

- (NSString *) hexcolor {
    NSString * hexString = [NSString stringWithFormat:@"%x", RGBColor];
    return hexString;
}

- (NSInteger) compare: (FontStyle*) style{
	return [displayName compare:[style displayName]];
	
}

- (long) RGBColor {
    return RGBColor;
}


- (void) setRGBColor:(long)rgbValue {
	
	RGBColor = rgbValue;
    if (color)
        [color release];
	color = [UIColorFromRGB (rgbValue) retain];

}

-(void)dealloc
{
    [familyName release];
    familyName = nil;
    
    [actualFontName release];
    actualFontName = nil;
    
    [displayName release];    
    displayName = nil;
    
    [color release];
    color = nil;
    
    [super dealloc];
}

// updates actual font based on current settings, allowing us to specify bold or italic
- (void) UpdateStyleTraits:(BOOL) bold italic:(BOOL)italic  {
	
	NSMutableArray *fontNames = [NSMutableArray arrayWithArray:[UIFont fontNamesForFamilyName:[self familyName]]];
	[self setActualFontName:[fontNames objectAtIndex:0]];
	for (NSString *fontName in fontNames) {
		if (bold == [self isBold:fontName] && italic == [self isItalic:fontName]) {
			[self setActualFontName: fontName];
			break;
		}
	}
	
	if (bold && italic && [self isBold:actualFontName] && [self isItalic:actualFontName]) {
		[self setDisplayName:[NSString stringWithFormat:@"%@ - Italic Bold",familyName]];
	}
	else if (bold && [self isBold:actualFontName]) {
		[self setDisplayName:[NSString stringWithFormat:@"%@ - Bold",familyName]];
	}
	else if (italic && [self isItalic:actualFontName]) {
		[self setDisplayName:[NSString stringWithFormat:@"%@ - Italic",familyName]];
	}
	else {
		[self setDisplayName:[NSString stringWithFormat:@"%@",familyName]];
	}
		 
//	NSLog (@"UpdateStyleTraits Actual:%@ Display:%@ size:%d isBold:%d isItalic:%d",actualFontName, displayName, size, [self isBold:actualFontName], [self isItalic:actualFontName]);
}

- (BOOL) hasSymbolicTrait:(NSString *)fontName trait:(unsigned) trait{
    NSAssert(fontName!=nil,@"hasSymbolicTrait: - fontname is NULL");
	
	CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, 0.0, NULL);
	BOOL hasTrait = (CTFontGetSymbolicTraits (fontRef) & trait) != 0;
	CFRelease(fontRef);
	
	return hasTrait;
}

// is the current style bold?
- (BOOL) isBold:(NSString *)fontName {
    NSAssert(fontName!=nil,@"isBold: - fontname is NULL");
	
	return [self hasSymbolicTrait:fontName trait:kCTFontBoldTrait];
}

- (BOOL) isBold {
    NSAssert([self actualFontName]!=nil,@"isBold - actualFontname is NULL");
    return [self isBold:[self actualFontName]];
}

// is the current style italic?
- (BOOL) isItalic:(NSString *)fontName {
    NSAssert(fontName!=nil,@"isItalic: - fontname is NULL");
	
	return [self hasSymbolicTrait:fontName trait:kCTFontItalicTrait];
}


- (BOOL) isItalic {
    NSAssert([self actualFontName]!=nil,@"isItalic - actualFontname is NULL");
    return [self isItalic:[self actualFontName]];
}

// tests, if the family has a regular font. all english fonts do, if it doesn't have one, its not an english font
- (BOOL) isEnglish:(NSString *)fontName {
    NSAssert(fontName!=nil,@"isEnglish - fontname is NULL");

	// The following are non-english fonts
	if (([fontName rangeOfString:@"Hiragino"].location == NSNotFound) &&
		([fontName rangeOfString:@"AppleGothic"].location == NSNotFound) &&
		([fontName rangeOfString:@"Arial Hebrew"].location == NSNotFound) &&
		([fontName rangeOfString:@"Geeza Pro"].location == NSNotFound) &&
		([fontName rangeOfString:@"Thonburi"].location == NSNotFound) &&
		([fontName rangeOfString:@"Kannada"].location == NSNotFound) &&
		([fontName rangeOfString:@"Gurmukhi"].location == NSNotFound) &&
		([fontName rangeOfString:@"Malayalam"].location == NSNotFound) &&
		([fontName rangeOfString:@"Sinhala"].location == NSNotFound) &&
		([fontName rangeOfString:@"Gujarati"].location == NSNotFound) &&
		([fontName rangeOfString:@"Devanagari"].location == NSNotFound) &&
		([fontName rangeOfString:@"Bangla"].location == NSNotFound) &&
		([fontName rangeOfString:@"Tamil"].location == NSNotFound) &&
		([fontName rangeOfString:@"Telugu"].location == NSNotFound) &&
		([fontName rangeOfString:@"Oriya"].location == NSNotFound) &&
		([fontName rangeOfString:@"Euphemia"].location == NSNotFound) &&
		([fontName rangeOfString:@"Kailasa"].location == NSNotFound) &&
		([fontName rangeOfString:@"Heiti"].location == NSNotFound)) {

		return YES;
	}
	else {
		return NO;
	}

	
	CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, 0.0, NULL);
	CFStringEncoding encoding = CTFontGetStringEncoding (fontRef);
	CFRelease(fontRef);
	
	if (encoding == kCFStringEncodingMacRoman)
		return YES;
	else 
		return NO;
	
}

@end
