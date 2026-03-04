//
//  SATEThemeManager.m
//  SmallAdvancedTextEditor
//

#import "SATEThemeManager.h"
#import "SATETheme.h"
#import <AppKit/AppKit.h>

NSString * const SATEThemeDidChangeNotification = @"SATEThemeDidChangeNotification";

static NSString *customThemesKey = @"SATECustomThemes";
static NSString *currentThemeNameKey = @"SATECurrentThemeName";

@implementation SATEThemeManager
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize currentTheme = _currentTheme;
#endif

+ (instancetype)sharedManager {
    static SATEThemeManager *one = nil;
    if (!one) {
        one = [[SATEThemeManager alloc] init];
    }
    return one;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _builtInThemes = [self createBuiltInThemes];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_builtInThemes retain];
#endif
        _customThemes = [[NSMutableArray alloc] init];
        [self loadCustomThemes];
        [self loadCurrentTheme];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_currentTheme release];
    [_builtInThemes release];
    [_customThemes release];
    [super dealloc];
}
#endif

- (NSArray *)createBuiltInThemes {
    NSColor *darkBg = [NSColor colorWithCalibratedRed:0.15 green:0.16 blue:0.18 alpha:1.0];
    NSColor *darkFg = [NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.88 alpha:1.0];
    SATETheme *dark = [[SATETheme alloc] initWithName:@"Dark"
                                       backgroundColor:darkBg
                                       foregroundColor:darkFg
                                         keywordColor:[NSColor colorWithCalibratedRed:0.4 green:0.6 blue:1.0 alpha:1.0]
                                          stringColor:[NSColor colorWithCalibratedRed:0.95 green:0.5 blue:0.5 alpha:1.0]
                                         commentColor:[NSColor colorWithCalibratedRed:0.4 green:0.7 blue:0.4 alpha:1.0]
                                          numberColor:[NSColor colorWithCalibratedRed:0.7 green:0.65 blue:0.9 alpha:1.0]
                                    preprocessorColor:[NSColor colorWithCalibratedRed:0.8 green:0.6 blue:0.4 alpha:1.0]
                                              builtIn:YES];

    NSColor *hcBg = [NSColor blackColor];
    NSColor *hcFg = [NSColor whiteColor];
    SATETheme *highContrast = [[SATETheme alloc] initWithName:@"High Contrast"
                                              backgroundColor:hcBg
                                              foregroundColor:hcFg
                                                keywordColor:[NSColor colorWithCalibratedRed:0.4 green:0.8 blue:1.0 alpha:1.0]
                                                 stringColor:[NSColor colorWithCalibratedRed:1.0 green:0.4 blue:0.4 alpha:1.0]
                                                commentColor:[NSColor colorWithCalibratedRed:0.4 green:1.0 blue:0.4 alpha:1.0]
                                                 numberColor:[NSColor colorWithCalibratedRed:1.0 green:0.85 blue:0.4 alpha:1.0]
                                           preprocessorColor:[NSColor colorWithCalibratedRed:1.0 green:0.6 blue:0.2 alpha:1.0]
                                                     builtIn:YES];

    NSColor *sepiaBg = [NSColor colorWithCalibratedRed:0.94 green:0.89 blue:0.8 alpha:1.0];
    NSColor *sepiaFg = [NSColor colorWithCalibratedRed:0.2 green:0.18 blue:0.14 alpha:1.0];
    SATETheme *sepia = [[SATETheme alloc] initWithName:@"Sepia"
                                      backgroundColor:sepiaBg
                                      foregroundColor:sepiaFg
                                        keywordColor:[NSColor colorWithCalibratedRed:0.35 green:0.25 blue:0.55 alpha:1.0]
                                         stringColor:[NSColor colorWithCalibratedRed:0.6 green:0.2 blue:0.2 alpha:1.0]
                                        commentColor:[NSColor colorWithCalibratedRed:0.35 green:0.45 blue:0.25 alpha:1.0]
                                         numberColor:[NSColor colorWithCalibratedRed:0.4 green:0.35 blue:0.5 alpha:1.0]
                                   preprocessorColor:[NSColor colorWithCalibratedRed:0.5 green:0.35 blue:0.1 alpha:1.0]
                                             builtIn:YES];

    NSColor *classicBg = [NSColor whiteColor];
    NSColor *classicFg = [NSColor blackColor];
    SATETheme *classic = [[SATETheme alloc] initWithName:@"Classic"
                                        backgroundColor:classicBg
                                        foregroundColor:classicFg
                                          keywordColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0.8 alpha:1.0]
                                           stringColor:[NSColor colorWithCalibratedRed:0.8 green:0 blue:0 alpha:1.0]
                                          commentColor:[NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1.0]
                                           numberColor:[NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.6 alpha:1.0]
                                     preprocessorColor:[NSColor colorWithCalibratedRed:0.5 green:0.3 blue:0 alpha:1.0]
                                               builtIn:YES];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    return [[NSArray arrayWithObjects:dark, highContrast, sepia, classic, nil] autorelease];
#else
    return @[ dark, highContrast, sepia, classic ];
#endif
}

- (void)loadCurrentTheme {
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:currentThemeNameKey];
    if ([saved length] > 0) {
        for (SATETheme *t in [self allThemes]) {
            if ([[t name] isEqualToString:saved]) {
                _currentTheme = t;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
                [_currentTheme retain];
#endif
                return;
            }
        }
    }
    _currentTheme = [[self builtInThemes] firstObject];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_currentTheme retain];
#endif
}

- (NSString *)customThemesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *base = [paths firstObject];
    if (!base) base = [NSHomeDirectory() stringByAppendingPathComponent:@".local/share"];
    NSString *appSupport = [base stringByAppendingPathComponent:@"SmallAdvancedTextEditor"];
    return [appSupport stringByAppendingPathComponent:@"themes.plist"];
}

- (void)loadCustomThemes {
    NSString *path = [self customThemesPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) return;
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    if (![arr isKindOfClass:[NSArray class]]) return;
    [_customThemes removeAllObjects];
    for (id obj in arr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            SATETheme *t = [SATETheme themeFromDictionary:obj];
            if (t) {
                [_customThemes addObject:t];
            }
        }
    }
}

- (void)saveCustomThemesToDisk {
    NSMutableArray *arr = [NSMutableArray array];
    for (SATETheme *t in _customThemes) {
        [arr addObject:[t dictionaryRepresentation]];
    }
    NSString *path = [self customThemesPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [path stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:dir]) {
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    [arr writeToFile:path atomically:YES];
}

- (NSArray *)builtInThemes {
    return _builtInThemes;
}

- (NSArray *)customThemes {
    return [NSArray arrayWithArray:_customThemes];
}

- (NSArray *)allThemes {
    NSMutableArray *a = [NSMutableArray arrayWithArray:_builtInThemes];
    [a addObjectsFromArray:_customThemes];
    return a;
}

- (void)setCurrentTheme:(SATETheme *)theme {
    if (theme == _currentTheme) return;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [theme retain];
    [_currentTheme release];
#endif
    _currentTheme = theme;
    [[NSUserDefaults standardUserDefaults] setObject:[theme name] forKey:currentThemeNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:SATEThemeDidChangeNotification object:self];
}

- (void)applyBuiltInThemeWithName:(NSString *)name {
    for (SATETheme *t in _builtInThemes) {
        if ([[t name] isEqualToString:name]) {
            [self setCurrentTheme:t];
            return;
        }
    }
}

- (void)saveCustomTheme:(SATETheme *)theme {
    if (!theme || [theme builtIn]) return;
    NSUInteger i;
    for (i = 0; i < [_customThemes count]; i++) {
        if ([[[_customThemes objectAtIndex:i] name] isEqualToString:[theme name]]) {
            [_customThemes replaceObjectAtIndex:i withObject:theme];
            [self saveCustomThemesToDisk];
            return;
        }
    }
    [_customThemes addObject:theme];
    [self saveCustomThemesToDisk];
}

- (void)deleteCustomThemeNamed:(NSString *)name {
    NSUInteger i;
    for (i = 0; i < [_customThemes count]; i++) {
        if ([[[_customThemes objectAtIndex:i] name] isEqualToString:name]) {
            [_customThemes removeObjectAtIndex:i];
            [self saveCustomThemesToDisk];
            if (_currentTheme && [[_currentTheme name] isEqualToString:name]) {
                [self setCurrentTheme:[_builtInThemes firstObject]];
            }
            return;
        }
    }
}

- (void)replaceCustomTheme:(SATETheme *)theme {
    if (!theme || [theme builtIn]) return;
    NSUInteger i;
    for (i = 0; i < [_customThemes count]; i++) {
        if ([[[_customThemes objectAtIndex:i] name] isEqualToString:[theme name]]) {
            [_customThemes replaceObjectAtIndex:i withObject:theme];
            [self saveCustomThemesToDisk];
            if (_currentTheme && [[_currentTheme name] isEqualToString:[theme name]]) {
                [self setCurrentTheme:theme];
            }
            return;
        }
    }
    [_customThemes addObject:theme];
    [self saveCustomThemesToDisk];
}

@end
