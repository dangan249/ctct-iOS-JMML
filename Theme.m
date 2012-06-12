//
//  Theme.m
//  JMML
//

#import "Theme.h"
#import "MyUIImage.h"


@implementation Theme
@synthesize image_name,image,thumbnail;
@synthesize fs1,fs2,fs3,fs4;

// initiales a theme object with the string from the themes.csv file
- (id)initWithThemeString:(NSString *) ts {
    
    BOOL bold, italic;
    
    themeString = ts;
    
    self = [super init];
     	NSArray *compArray = [[NSArray alloc] initWithArray:[themeString componentsSeparatedByString:@","]];

    
    [self setImage_name: [compArray objectAtIndex:0]];
    [self loadImage];
    
    fs1 = [[FontStyle alloc]init];
    NSString * familyName = [compArray objectAtIndex:1];
    bold = [(NSString *)[compArray objectAtIndex:2] intValue];
    italic = [(NSString *)[compArray objectAtIndex:3] intValue];
    long RGB = [fs1 hexToLong: [compArray objectAtIndex:4]];
    int size  = [(NSString *)[compArray objectAtIndex:5] intValue];
    [fs1 setFamilyName:familyName];
	[fs1 UpdateStyleTraits:bold italic:italic];
    [fs1 setSize:size];
    [fs1 setRGBColor:RGB];

    fs2 = [[FontStyle alloc]init];
    familyName = [compArray objectAtIndex:6];
    bold = [(NSString *)[compArray objectAtIndex:7] intValue];
    italic = [(NSString *)[compArray objectAtIndex:8] intValue];
    RGB = [fs2 hexToLong: [compArray objectAtIndex:9]];
    size  = [(NSString *)[compArray objectAtIndex:10] intValue];
    [fs2 setFamilyName:familyName];
	[fs2 UpdateStyleTraits:bold italic:italic];
    [fs2 setSize:size];
    [fs2 setRGBColor:RGB];

    fs3 = [[FontStyle alloc]init];
    familyName = [compArray objectAtIndex:11];
    bold = [(NSString *)[compArray objectAtIndex:12] intValue];
    italic = [(NSString *)[compArray objectAtIndex:13] intValue];
    RGB = [fs3 hexToLong: [compArray objectAtIndex:14]];
    size  = [(NSString *)[compArray objectAtIndex:15] intValue];
    [fs3 setFamilyName:familyName];
	[fs3 UpdateStyleTraits:bold italic:italic];
    [fs3 setSize:size];
    [fs3 setRGBColor:RGB];
    
    fs4 = [[FontStyle alloc]init];
    familyName = [compArray objectAtIndex:16];
    bold = [(NSString *)[compArray objectAtIndex:17] intValue];
    italic = [(NSString *)[compArray objectAtIndex:18] intValue];
    RGB = [fs4 hexToLong: [compArray objectAtIndex:19]];
    size  = [(NSString *)[compArray objectAtIndex:20] intValue];
    [fs4 setFamilyName:familyName];
	[fs4 UpdateStyleTraits:bold italic:italic];
    [fs4 setSize:size];
    [fs4 setRGBColor:RGB];
	
    [compArray release];
    
    [self setThumbnail: [image scaleWithMaxSize:thumbnail_size]];
    
    
    return self;
}

- (void) dealloc  {
    
    [image_name release];
    [fs1 release];
    [fs2 release];
    [fs3 release];
    [fs4 release];
    [image release];
    [thumbnail release];
    
    [super dealloc];
    
}

- (void) selfSetImage:(UIImage *) i {
    if (image !=i && i != nil) {
        [image release];
        image = [i retain];
        [self setThumbnail: [image scaleWithMaxSize:thumbnail_size]];
    }
}

// saves the theme image to /Documents/images so we can reload when we need to
- (void) saveImage {
    NSAssert(image!=nil,@"Theme: no image to save!!!");
  
    //scale it
	UIImage *scaledImage = [image scaleWithMaxSize:1024];
	double compressionRatio = 0.8;
	//compress
	NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
	NSError *error=nil;
	//save
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/background.jpg"];
	if (![imageData writeToFile:path options:NSAtomicWrite error:&error]) {
		NSLog(@"Error saving: %@ with error code %d", path, error.code);
	}

}


// returns a theme as a string
- (NSString*) toThemeString {
    NSString *ts = [NSString stringWithFormat:@"%@",image_name]; 
 
        ts = [NSString stringWithFormat:@"%@,%@,%d,%d,0x%@,%d",ts,[fs1 familyName],[fs1 isBold],[fs1 isItalic],[fs1 hexcolor],(int)[fs1 size]];    
        ts = [NSString stringWithFormat:@"%@,%@,%d,%d,0x%@,%d",ts,[fs2 familyName],[fs2 isBold],[fs2 isItalic],[fs2 hexcolor],(int)[fs2 size]];    
        ts = [NSString stringWithFormat:@"%@,%@,%d,%d,0x%@,%d",ts,[fs3 familyName],[fs3 isBold],[fs3 isItalic],[fs3 hexcolor],(int)[fs3 size]];    
        ts = [NSString stringWithFormat:@"%@,%@,%d,%d,0x%@,%d",ts,[fs4 familyName],[fs4 isBold],[fs4 isItalic],[fs4 hexcolor],(int)[fs4 size]];    

    return  ts;
}

- (void) loadImage {
    if (image ==nil) {
        NSString* path = [[NSBundle mainBundle] pathForResource:image_name ofType:nil inDirectory:@"theme_images"];
        UIImage *i =[UIImage imageWithContentsOfFile:path];
        //if the image is nil, let's try loading it as custom image
        if (i != nil) {
            [self setImage : i];// important to use setter, so its retained
        }
        else {    
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/background.jpg"];
            UIImage *i = [[UIImage alloc]initWithContentsOfFile:path];
            if (i!=nil) {
                [self setImage :i];
                [i autorelease];
            }else {
                NSAssert1 (i!=nil,@"Could not load image %@",image_name);
            }
        }
        
    }

}




- (long) hexToLong: (NSString*) hexstring {
    NSScanner* pScanner = [NSScanner scannerWithString: hexstring];
    
    unsigned int iValue;
    [pScanner scanHexInt: &iValue];
    return (long)iValue;
    
}

@end
