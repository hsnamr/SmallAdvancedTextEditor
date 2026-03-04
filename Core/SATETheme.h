//
//  SATETheme.h
//  SmallAdvancedTextEditor
//
//  Represents an editor theme: background, foreground, and syntax colors.
//  Supports dictionary representation for saving/loading custom themes.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SATETheme : NSObject
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    NSString *_name;
    NSColor *_backgroundColor;
    NSColor *_foregroundColor;
    NSColor *_keywordColor;
    NSColor *_stringColor;
    NSColor *_commentColor;
    NSColor *_numberColor;
    NSColor *_preprocessorColor;
    BOOL _builtIn;
}
#endif

@property (nonatomic, copy) NSString *name;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic, retain) NSColor *foregroundColor;
@property (nonatomic, retain) NSColor *keywordColor;
@property (nonatomic, retain) NSColor *stringColor;
@property (nonatomic, retain) NSColor *commentColor;
@property (nonatomic, retain) NSColor *numberColor;
@property (nonatomic, retain) NSColor *preprocessorColor;
#else
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSColor *keywordColor;
@property (nonatomic, strong) NSColor *stringColor;
@property (nonatomic, strong) NSColor *commentColor;
@property (nonatomic, strong) NSColor *numberColor;
@property (nonatomic, strong) NSColor *preprocessorColor;
#endif

/// Whether this is a built-in theme (read-only).
@property (nonatomic, assign) BOOL builtIn;

- (instancetype)initWithName:(NSString *)name
             backgroundColor:(NSColor *)bg
             foregroundColor:(NSColor *)fg
               keywordColor:(NSColor *)kw
                stringColor:(NSColor *)str
               commentColor:(NSColor *)cmt
                numberColor:(NSColor *)num
          preprocessorColor:(NSColor *)pre
                    builtIn:(BOOL)builtIn;

/// Dictionary for saving (colors as hex strings "#RRGGBB").
- (NSDictionary *)dictionaryRepresentation;

/// Create theme from saved dictionary.
+ (instancetype)themeFromDictionary:(NSDictionary *)dict;

/// Copy with a new name (for "Duplicate"); builtIn will be NO.
- (instancetype)copyWithName:(NSString *)newName;

@end
