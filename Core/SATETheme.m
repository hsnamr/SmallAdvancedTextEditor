//
//  SATETheme.m
//  SmallAdvancedTextEditor
//

#import "SATETheme.h"

static NSColor *colorFromHex(NSString *hex) {
    if (!hex || [hex length] < 7 || [hex characterAtIndex:0] != '#') return nil;
    unsigned r = 0, g = 0, b = 0;
    if (sscanf([hex UTF8String], "#%02x%02x%02x", &r, &g, &b) != 3) return nil;
    return [NSColor colorWithCalibratedRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0];
}

static NSString *hexFromColor(NSColor *c) {
    if (!c) return @"#000000";
    NSColor *rgb = [c colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    if (!rgb) rgb = [c colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (!rgb) return @"#000000";
    CGFloat r, g, b, a;
    [rgb getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02x%02x%02x",
            (unsigned)(r * 255), (unsigned)(g * 255), (unsigned)(b * 255)];
}

@implementation SATETheme

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize name = _name;
@synthesize backgroundColor = _backgroundColor;
@synthesize foregroundColor = _foregroundColor;
@synthesize keywordColor = _keywordColor;
@synthesize stringColor = _stringColor;
@synthesize commentColor = _commentColor;
@synthesize numberColor = _numberColor;
@synthesize preprocessorColor = _preprocessorColor;
@synthesize builtIn = _builtIn;
#endif

- (instancetype)initWithName:(NSString *)name
             backgroundColor:(NSColor *)bg
             foregroundColor:(NSColor *)fg
               keywordColor:(NSColor *)kw
                stringColor:(NSColor *)str
               commentColor:(NSColor *)cmt
                numberColor:(NSColor *)num
          preprocessorColor:(NSColor *)pre
                    builtIn:(BOOL)builtIn {
    self = [super init];
    if (self) {
        _name = [name copy];
        _backgroundColor = bg;
        _foregroundColor = fg;
        _keywordColor = kw;
        _stringColor = str;
        _commentColor = cmt;
        _numberColor = num;
        _preprocessorColor = pre;
        _builtIn = builtIn;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            _name ?: @"", @"name",
            hexFromColor(_backgroundColor), @"backgroundColor",
            hexFromColor(_foregroundColor), @"foregroundColor",
            hexFromColor(_keywordColor), @"keywordColor",
            hexFromColor(_stringColor), @"stringColor",
            hexFromColor(_commentColor), @"commentColor",
            hexFromColor(_numberColor), @"numberColor",
            hexFromColor(_preprocessorColor), @"preprocessorColor",
            [NSNumber numberWithBool:_builtIn], @"builtIn",
            nil];
}

+ (instancetype)themeFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    NSString *name = [dict objectForKey:@"name"];
    if (!name) name = @"Unnamed";
    NSColor *bg = colorFromHex([dict objectForKey:@"backgroundColor"]);
    NSColor *fg = colorFromHex([dict objectForKey:@"foregroundColor"]);
    NSColor *kw = colorFromHex([dict objectForKey:@"keywordColor"]);
    NSColor *str = colorFromHex([dict objectForKey:@"stringColor"]);
    NSColor *cmt = colorFromHex([dict objectForKey:@"commentColor"]);
    NSColor *num = colorFromHex([dict objectForKey:@"numberColor"]);
    NSColor *pre = colorFromHex([dict objectForKey:@"preprocessorColor"]);
    if (!bg) bg = [NSColor whiteColor];
    if (!fg) fg = [NSColor blackColor];
    if (!kw) kw = [NSColor blueColor];
    if (!str) str = [NSColor redColor];
    if (!cmt) cmt = [NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1];
    if (!num) num = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.6 alpha:1];
    if (!pre) pre = [NSColor colorWithCalibratedRed:0.5 green:0.3 blue:0 alpha:1];
    BOOL builtIn = [[dict objectForKey:@"builtIn"] boolValue];
    return [[self alloc] initWithName:name backgroundColor:bg foregroundColor:fg keywordColor:kw stringColor:str commentColor:cmt numberColor:num preprocessorColor:pre builtIn:builtIn];
}

- (instancetype)copyWithName:(NSString *)newName {
    return [[SATETheme alloc] initWithName:newName ?: [NSString stringWithFormat:@"Copy of %@", _name]
                          backgroundColor:_backgroundColor
                          foregroundColor:_foregroundColor
                            keywordColor:_keywordColor
                             stringColor:_stringColor
                            commentColor:_commentColor
                             numberColor:_numberColor
                       preprocessorColor:_preprocessorColor
                                 builtIn:NO];
}

@end
