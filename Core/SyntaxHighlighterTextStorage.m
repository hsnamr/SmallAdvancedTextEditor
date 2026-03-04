//
//  SyntaxHighlighterTextStorage.m
//  SmallAdvancedTextEditor
//
//  Applies syntax highlighting per language using regexes for comments,
//  strings, numbers, and keywords. Language set from file extension.
//

#import "SyntaxHighlighterTextStorage.h"

@interface SyntaxHighlighterTextStorage (Private)
- (NSArray *)keywordsForCurrentLanguage;
@end

@implementation SyntaxHighlighterTextStorage

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize language = _language;
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        _backing = [[NSMutableAttributedString alloc] init];
        _language = SATELanguageNone;
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_backing release];
    [super dealloc];
}
#endif

- (NSString *)string {
    return [_backing string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_backing attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [_backing replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)[str length] - (NSInteger)range.length];
    [self applyHighlightingToRange:NSMakeRange(range.location, [str length])];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [_backing setAttributes:attrs range:range];
}

- (void)processEditing {
    [super processEditing];
    if ([self editedMask] & NSTextStorageEditedCharacters) {
        NSRange range = [self editedRange];
        NSInteger delta = [self changeInLength];
        NSUInteger len = [[self string] length];
        if (len == 0) return;
        NSUInteger rangeEnd = range.location + range.length + (NSUInteger)delta;
        if (range.location >= len) return;
        if (rangeEnd > len) rangeEnd = len;
        NSRange extended = NSMakeRange(0, rangeEnd);
        [self applyHighlightingToRange:extended];
    }
}

+ (SATELanguage)languageFromFilename:(NSString *)filename {
    if (!filename || [filename length] == 0) return SATELanguageNone;
    NSString *ext = [[filename pathExtension] lowercaseString];
    NSString *base = [[filename lastPathComponent] lowercaseString];
    if ([base isEqual:@"makefile"] || [base hasPrefix:@"makefile."]) return SATELanguageMakefile;
    if ([ext isEqual:@"c"] || [ext isEqual:@"h"]) return SATELanguageC;
    if ([ext isEqual:@"cpp"] || [ext isEqual:@"cc"] || [ext isEqual:@"cxx"] || [ext isEqual:@"hpp"] || [ext isEqual:@"hxx"]) return SATELanguageCpp;
    if ([ext isEqual:@"m"] || [ext isEqual:@"mm"]) return SATELanguageObjectiveC;
    if ([ext isEqual:@"java"]) return SATELanguageJava;
    if ([ext isEqual:@"cs"]) return SATELanguageCSharp;
    if ([ext isEqual:@"js"]) return SATELanguageJavaScript;
    if ([ext isEqual:@"ts"]) return SATELanguageTypeScript;
    if ([ext isEqual:@"py"]) return SATELanguagePython;
    if ([ext isEqual:@"php"]) return SATELanguagePHP;
    if ([ext isEqual:@"rb"]) return SATELanguageRuby;
    if ([ext isEqual:@"swift"]) return SATELanguageSwift;
    if ([ext isEqual:@"go"]) return SATELanguageGo;
    if ([ext isEqual:@"scala"]) return SATELanguageScala;
    if ([ext isEqual:@"lua"]) return SATELanguageLua;
    if ([ext isEqual:@"raku"] || [ext isEqual:@"rakumod"] || [ext isEqual:@"rakutest"] || [ext isEqual:@"nqp"]) return SATELanguageRaku;
    if ([ext isEqual:@"gd"]) return SATELanguageGodotScript;
    if ([ext isEqual:@"mk"]) return SATELanguageMakefile;
    if ([ext isEqual:@"s"] || [ext isEqual:@"asm"] || [ext isEqual:@"as"]) return SATELanguageAssembly;
    return SATELanguageNone;
}

- (void)applyHighlightingToRange:(NSRange)range {
    if (_language == SATELanguageNone) return;
    NSString *s = [self string];
    NSUInteger len = [s length];
    if (len == 0) return;
    if (range.location >= len) return;
    NSUInteger end = NSMaxRange(range);
    if (end > len) end = len;
    range.length = end - range.location;

    NSFont *baseFont = [NSFont userFixedPitchFontOfSize:12];
    NSDictionary *baseAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
        baseFont, NSFontAttributeName,
        [NSColor blackColor], NSForegroundColorAttributeName,
        nil];
    [self addAttributes:baseAttrs range:range];

    NSColor *commentColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    NSColor *stringColor = [NSColor colorWithCalibratedRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    NSColor *keywordColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.8 alpha:1.0];
    NSColor *numberColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.6 alpha:1.0];
    NSColor *preprocessorColor = [NSColor colorWithCalibratedRed:0.5 green:0.3 blue:0.0 alpha:1.0];

    /* Block comments first so they take precedence over line comments */
    NSRegularExpression *blockComment = [NSRegularExpression regularExpressionWithPattern:@"(/\\*[\\s\\S]*?\\*/)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
    if (blockComment) {
        NSArray *matches = [blockComment matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }

    /* Line comments - language-specific */
    NSString *lineCommentPattern = nil;
    switch (_language) {
        case SATELanguageC:
        case SATELanguageCpp:
        case SATELanguageObjectiveC:
        case SATELanguageJava:
        case SATELanguageCSharp:
        case SATELanguageJavaScript:
        case SATELanguageTypeScript:
        case SATELanguageGo:
        case SATELanguageScala:
        case SATELanguageSwift:
        case SATELanguageGodotScript:
            lineCommentPattern = @"(//[^\n]*)";
            break;
        case SATELanguagePython:
        case SATELanguageRuby:
        case SATELanguagePHP:
        case SATELanguageMakefile:
        case SATELanguageRaku:
            lineCommentPattern = @"(#[^\n]*)";
            break;
        case SATELanguageLua:
            lineCommentPattern = @"(--[^\n]*)";
            break;
        case SATELanguageAssembly:
            lineCommentPattern = @"(;[^\n]*)";
            break;
        default:
            break;
    }
    if (lineCommentPattern) {
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:lineCommentPattern options:NSRegularExpressionAnchorsMatchLines error:NULL];
        if (re) {
            NSArray *matches = [re matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Python/Ruby multi-line string """ or ''' */
    if (_language == SATELanguagePython || _language == SATELanguageRuby) {
        NSRegularExpression *triple = [NSRegularExpression regularExpressionWithPattern:@"(\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?''')" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (triple) {
            NSArray *matches = [triple matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Double-quoted strings (skip escaped quotes) */
    NSRegularExpression *dq = [NSRegularExpression regularExpressionWithPattern:@"(\"(?:[^\"\\\\]|\\\\.)*\")" options:0 error:NULL];
    if (dq) {
        NSArray *matches = [dq matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }
    /* Single-quoted strings */
    NSRegularExpression *sq = [NSRegularExpression regularExpressionWithPattern:@"('(?:[^'\\\\]|\\\\.)*')" options:0 error:NULL];
    if (sq) {
        NSArray *matches = [sq matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }

    /* Numbers */
    NSRegularExpression *num = [NSRegularExpression regularExpressionWithPattern:@"\\b([0-9]+(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)\\b" options:0 error:NULL];
    if (num) {
        NSArray *matches = [num matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:numberColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }

    /* Keywords - language-specific word boundary list */
    NSArray *keywords = [self keywordsForCurrentLanguage];
    if ([keywords count] > 0) {
        NSMutableString *kwPattern = [NSMutableString stringWithString:@"\\b("];
        NSUInteger i = 0;
        for (NSString *w in keywords) {
            if (i++) [kwPattern appendString:@"|"];
            [kwPattern appendString:[NSRegularExpression escapedPatternForString:w]];
        }
        [kwPattern appendString:@")\\b"];
        NSRegularExpression *kwRe = [NSRegularExpression regularExpressionWithPattern:kwPattern options:0 error:NULL];
        if (kwRe) {
            NSArray *matches = [kwRe matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:keywordColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Preprocessor (#include etc) for C/C++/ObjC */
    if (_language == SATELanguageC || _language == SATELanguageCpp || _language == SATELanguageObjectiveC) {
        NSRegularExpression *pre = [NSRegularExpression regularExpressionWithPattern:@"^(\\s*#[^\n]*)" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        if (pre) {
            NSArray *matches = [pre matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:preprocessorColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }
}

- (NSArray *)keywordsForCurrentLanguage {
    switch (_language) {
        case SATELanguageC:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", nil];
        case SATELanguageCpp:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", @"class", @"namespace", @"public", @"private", @"protected", @"virtual", @"override", @"template", @"typename", @"new", @"delete", @"this", @"operator", @"bool", @"throw", @"try", @"catch", @"const_cast", @"dynamic_cast", @"static_cast", @"reinterpret_cast", @"explicit", @"mutable", @"friend", @"inline", @"typeid", @"using", @"wchar_t", nil];
        case SATELanguageObjectiveC:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", @"class", @"interface", @"implementation", @"protocol", @"end", @"self", @"super", @"nil", @"YES", @"NO", @"@interface", @"@implementation", @"@protocol", @"@end", @"@class", @"@selector", @"@property", @"@synthesize", @"@dynamic", @"@optional", @"@required", @"@try", @"@catch", @"@finally", @"@throw", @"@autoreleasepool", @"in", @"out", @"inout", @"bycopy", @"byref", nil];
        case SATELanguageJava:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"throws", @"new", @"class", @"interface", @"extends", @"implements", @"import", @"package", @"public", @"private", @"protected", @"static", @"final", @"abstract", @"void", @"int", @"long", @"short", @"byte", @"char", @"float", @"double", @"boolean", @"true", @"false", @"null", @"super", @"this", @"synchronized", @"volatile", @"transient", @"native", @"strictfp", @"assert", @"enum", @"instanceof", nil];
        case SATELanguageCSharp:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"class", @"interface", @"struct", @"enum", @"namespace", @"using", @"public", @"private", @"protected", @"internal", @"static", @"readonly", @"const", @"void", @"int", @"long", @"short", @"byte", @"char", @"float", @"double", @"decimal", @"bool", @"true", @"false", @"null", @"base", @"this", @"virtual", @"override", @"abstract", @"sealed", @"partial", @"async", @"await", @"var", @"in", @"out", @"ref", @"params", @"get", @"set", @"value", @"event", @"delegate", @"operator", @"implicit", @"explicit", @"checked", @"unchecked", @"fixed", @"lock", @"is", @"as", nil];
        case SATELanguageJavaScript:
        case SATELanguageTypeScript:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"function", @"var", @"let", @"const", @"true", @"false", @"null", @"undefined", @"this", @"typeof", @"instanceof", @"in", @"of", @"class", @"extends", @"super", @"import", @"export", @"from", @"default", @"async", @"await", @"yield", @"delete", @"void", @"get", @"set", @"static", @"async", @"interface", @"type", @"enum", @"implements", @"protected", @"private", @"public", @"abstract", nil];
        case SATELanguagePython:
            return [NSArray arrayWithObjects:@"if", @"else", @"elif", @"while", @"for", @"in", @"break", @"continue", @"return", @"pass", @"try", @"except", @"finally", @"raise", @"with", @"as", @"def", @"class", @"lambda", @"and", @"or", @"not", @"True", @"False", @"None", @"yield", @"async", @"await", @"from", @"import", @"global", @"nonlocal", @"assert", @"del", nil];
        case SATELanguagePHP:
            return [NSArray arrayWithObjects:@"if", @"else", @"elseif", @"while", @"for", @"foreach", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"function", @"class", @"interface", @"extends", @"implements", @"public", @"private", @"protected", @"static", @"final", @"abstract", @"const", @"true", @"false", @"null", @"and", @"or", @"xor", @"not", @"clone", @"instanceof", @"echo", @"print", @"die", @"exit", @"include", @"require", @"include_once", @"require_once", @"namespace", @"use", @"as", @"var", @"global", @"isset", @"empty", @"unset", @"list", @"array", @"eval", nil];
        case SATELanguageRuby:
            return [NSArray arrayWithObjects:@"if", @"else", @"elsif", @"unless", @"while", @"until", @"for", @"do", @"begin", @"end", @"case", @"when", @"break", @"next", @"redo", @"retry", @"return", @"yield", @"def", @"class", @"module", @"def", @"undef", @"defined?", @"self", @"super", @"true", @"false", @"nil", @"and", @"or", @"not", @"in", @"alias", @"begin", @"rescue", @"ensure", @"raise", @"include", @"extend", @"require", @"load", @"attr", @"attr_reader", @"attr_writer", @"attr_accessor", @"private", @"public", @"protected", nil];
        case SATELanguageSwift:
            return [NSArray arrayWithObjects:@"if", @"else", @"switch", @"case", @"default", @"for", @"in", @"while", @"repeat", @"break", @"continue", @"return", @"fallthrough", @"throw", @"defer", @"guard", @"func", @"class", @"struct", @"enum", @"protocol", @"extension", @"import", @"let", @"var", @"true", @"false", @"nil", @"self", @"super", @"Self", @"as", @"is", @"try", @"catch", @"async", @"await", @"throws", @"rethrows", @"where", @"associatedtype", @"init", @"convenience", @"required", @"static", @"final", @"override", @"lazy", @"mutating", @"nonmutating", @"subscript", @"get", @"set", @"willSet", @"didSet", @"open", @"public", @"internal", @"fileprivate", @"private", @"weak", @"unowned", @"optional", nil];
        case SATELanguageGo:
            return [NSArray arrayWithObjects:@"if", @"else", @"switch", @"case", @"default", @"for", @"range", @"break", @"continue", @"return", @"fallthrough", @"func", @"type", @"struct", @"interface", @"var", @"const", @"package", @"import", @"go", @"chan", @"select", @"defer", @"goto", @"map", @"nil", @"true", @"false", @"iota", nil];
        case SATELanguageScala:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"match", @"case", @"yield", @"return", @"try", @"catch", @"finally", @"throw", @"class", @"object", @"trait", @"extends", @"with", @"implicit", @"val", @"var", @"def", @"type", @"lazy", @"override", @"abstract", @"final", @"sealed", @"private", @"protected", @"import", @"package", @"new", @"this", @"super", @"true", @"false", @"null", @"None", @"Some", @"Nil", @"Unit", @"Nothing", @"Any", @"AnyRef", @"Option", @"Either", @"forSome", @"=>", nil];
        case SATELanguageLua:
            return [NSArray arrayWithObjects:@"if", @"then", @"else", @"elseif", @"end", @"while", @"do", @"for", @"in", @"break", @"return", @"function", @"local", @"nil", @"true", @"false", @"and", @"or", @"not", @"repeat", @"until", nil];
        case SATELanguageRaku:
            return [NSArray arrayWithObjects:@"if", @"else", @"elsif", @"unless", @"while", @"until", @"for", @"loop", @"given", @"when", @"default", @"return", @"sub", @"method", @"submethod", @"class", @"role", @"grammar", @"module", @"package", @"my", @"our", @"has", @"state", @"constant", @"true", @"false", @"Nil", @"self", @"Mu", @"Any", @"Cool", @"Str", @"Int", @"Num", @"Rat", @"Bool", @"Array", @"Hash", @"Block", @"Routine", @"do", @"end", @"begin", @"gather", @"take", @"make", @"made", @"temp", @"let", @"require", @"use", @"import", @"export", @"enum", @"subset", @"multi", @"proto", @"only", @"regex", @"token", @"rule", @"macro", @"quasi", @"quote", @"undef", @"so", @"not", @"and", @"or", @"xor", @"orelse", @"andthen", nil];
        case SATELanguageGodotScript:
            return [NSArray arrayWithObjects:@"if", @"else", @"elif", @"for", @"while", @"match", @"break", @"continue", @"return", @"pass", @"class", @"class_name", @"extends", @"func", @"signal", @"const", @"var", @"enum", @"export", @"onready", @"static", @"tool", @"breakpoint", @"preload", @"yield", @"assert", @"true", @"false", @"null", @"and", @"or", @"not", @"in", @"as", @"self", @"void", nil];
        case SATELanguageMakefile:
            return [NSArray arrayWithObjects:@"ifdef", @"ifndef", @"ifeq", @"ifneq", @"else", @"endif", @"include", @"define", @"endef", @"export", @"unexport", @"vpath", @".PHONY", @"@", @"$@", @"$<", @"$^", nil];
        case SATELanguageAssembly:
            return [NSArray arrayWithObjects:@"section", @"text", @"data", @"bss", @"global", @"extern", @"align", @"db", @"dw", @"dd", @"dq", @"resb", @"resw", @"resd", @"resq", @"equ", @"times", @"mov", @"push", @"pop", @"call", @"ret", @"add", @"sub", @"mul", @"div", @"inc", @"dec", @"cmp", @"jmp", @"je", @"jne", @"jg", @"jge", @"jl", @"jle", @"int", @".intel_syntax", @".att_syntax", @".globl", @".type", @".size", @".string", @".asciz", @".byte", @".word", @".long", @".quad", @".text", @".data", @".bss", nil];
        default:
            return [NSArray array];
    }
}

@end
