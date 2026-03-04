//
//  SyntaxHighlighterTextStorage.h
//  SmallAdvancedTextEditor
//
//  NSTextStorage subclass that applies syntax highlighting by language.
//  Language is set from file extension; supports C, C++, ObjC, Java, C#,
//  JavaScript, TypeScript, Python, PHP, Ruby, Swift, Go, Scala, Lua,
//  Raku, Godot Script, Makefile, Assembly.
//

#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, SATELanguage) {
    SATELanguageNone = 0,
    SATELanguageC,
    SATELanguageCpp,
    SATELanguageObjectiveC,
    SATELanguageJava,
    SATELanguageCSharp,
    SATELanguageJavaScript,
    SATELanguageTypeScript,
    SATELanguagePython,
    SATELanguagePHP,
    SATELanguageRuby,
    SATELanguageSwift,
    SATELanguageGo,
    SATELanguageScala,
    SATELanguageLua,
    SATELanguageRaku,
    SATELanguageGodotScript,
    SATELanguageMakefile,
    SATELanguageAssembly,
};

@interface SyntaxHighlighterTextStorage : NSTextStorage
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    NSMutableAttributedString *_backing;
    SATELanguage _language;
}
#endif

@property (nonatomic, assign) SATELanguage language;

/// Infer language from file extension (e.g. @"file.py" -> SATELanguagePython).
+ (SATELanguage)languageFromFilename:(NSString *)filename;

/// Private: apply highlighting to a range (called from processEditing).
- (void)applyHighlightingToRange:(NSRange)range;

@end
