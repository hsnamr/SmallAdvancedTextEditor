//
//  SATEThemeManager.h
//  SmallAdvancedTextEditor
//
//  Singleton: current theme, built-in themes, load/save custom themes.
//  Posts SATEThemeDidChangeNotification when current theme changes.
//

#import <Foundation/Foundation.h>

@class SATETheme;

extern NSString * const SATEThemeDidChangeNotification;

@interface SATEThemeManager : NSObject
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    SATETheme *_currentTheme;
    NSArray *_builtInThemes;
    NSMutableArray *_customThemes;
}
#endif

+ (instancetype)sharedManager;

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) SATETheme *currentTheme;
#else
@property (nonatomic, strong) SATETheme *currentTheme;
#endif

/// Built-in themes: Dark, High Contrast, Sepia, Classic.
- (NSArray *)builtInThemes;

/// User-created themes (loaded from app support directory).
- (NSArray *)customThemes;

/// All themes (built-in then custom).
- (NSArray *)allThemes;

- (void)setCurrentTheme:(SATETheme *)theme;

/// Apply a built-in theme by identifier.
- (void)applyBuiltInThemeWithName:(NSString *)name;

/// Save a custom theme (adds to custom list and persists).
- (void)saveCustomTheme:(SATETheme *)theme;

/// Remove a custom theme by name.
- (void)deleteCustomThemeNamed:(NSString *)name;

/// Replace existing custom theme with same name.
- (void)replaceCustomTheme:(SATETheme *)theme;

@end
