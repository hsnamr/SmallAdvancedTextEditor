//
//  TEThemePanel.m
//  SmallAdvancedTextEditor
//

#import "TEThemePanel.h"
#import "SATEThemeManager.h"
#import "SATETheme.h"

@interface TEThemePanel () <NSTableViewDataSource, NSTableViewDelegate>
@end

@implementation TEThemePanel

+ (void)showPanel {
    static TEThemePanel *panel = nil;
    if (!panel) {
        panel = [[TEThemePanel alloc] init];
    }
    [panel reloadThemes];
    [panel makeKeyAndOrderFront:nil];
}

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 320, 320);
    self = [super initWithContentRect:frame
                           styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                             backing:NSBackingStoreBuffered
                               defer:NO];
    if (self) {
        [self setTitle:@"Themes"];
        [self setReleasedWhenClosed:NO];
        _themeList = [NSArray array];
        [self buildUI];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_tableView release];
    [_applyButton release];
    [_duplicateButton release];
    [_deleteButton release];
    [_newFromCurrentButton release];
    [_themeList release];
    [super dealloc];
}
#endif

- (void)buildUI {
    NSView *content = [self contentView];
    NSRect bounds = [content bounds];
    CGFloat margin = 12;
    CGFloat btnH = 28;
    CGFloat tableTop = bounds.size.height - margin;
    CGFloat tableBottom = margin + btnH + margin + 8;
    CGFloat tableHeight = tableTop - tableBottom - margin;

    _tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(margin, tableBottom, bounds.size.width - 2 * margin, tableHeight)];
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    [col setTitle:@"Theme"];
    [col setWidth:bounds.size.width - 2 * margin - 24];
    [_tableView addTableColumn:col];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [col release];
#endif
    [_tableView setHeaderView:nil];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setTarget:self];
    [_tableView setDoubleAction:@selector(applySelected:)];
    NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:[_tableView frame]];
    [scroll setDocumentView:_tableView];
    [scroll setHasVerticalScroller:YES];
    [scroll setBorderType:NSBezelBorder];
    [scroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_tableView release];
#endif
    [content addSubview:scroll];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [scroll release];
#endif

    CGFloat y = margin;
    _applyButton = [[NSButton alloc] initWithFrame:NSMakeRect(margin, y, 80, btnH)];
    [_applyButton setTitle:@"Apply"];
    [_applyButton setButtonType:NSMomentaryPushInButton];
    [_applyButton setBezelStyle:NSRoundedBezelStyle];
    [_applyButton setTarget:self];
    [_applyButton setAction:@selector(applySelected:)];
    [content addSubview:_applyButton];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_applyButton release];
#endif

    _duplicateButton = [[NSButton alloc] initWithFrame:NSMakeRect(margin + 88, y, 80, btnH)];
    [_duplicateButton setTitle:@"Duplicate"];
    [_duplicateButton setButtonType:NSMomentaryPushInButton];
    [_duplicateButton setBezelStyle:NSRoundedBezelStyle];
    [_duplicateButton setTarget:self];
    [_duplicateButton setAction:@selector(duplicateSelected:)];
    [content addSubview:_duplicateButton];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_duplicateButton release];
#endif

    _deleteButton = [[NSButton alloc] initWithFrame:NSMakeRect(margin + 176, y, 70, btnH)];
    [_deleteButton setTitle:@"Delete"];
    [_deleteButton setButtonType:NSMomentaryPushInButton];
    [_deleteButton setBezelStyle:NSRoundedBezelStyle];
    [_deleteButton setTarget:self];
    [_deleteButton setAction:@selector(deleteSelected:)];
    [content addSubview:_deleteButton];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_deleteButton release];
#endif

    _newFromCurrentButton = [[NSButton alloc] initWithFrame:NSMakeRect(bounds.size.width - margin - 120, y, 120, btnH)];
    [_newFromCurrentButton setTitle:@"New from current"];
    [_newFromCurrentButton setButtonType:NSMomentaryPushInButton];
    [_newFromCurrentButton setBezelStyle:NSRoundedBezelStyle];
    [_newFromCurrentButton setTarget:self];
    [_newFromCurrentButton setAction:@selector(newFromCurrent:)];
    [content addSubview:_newFromCurrentButton];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_newFromCurrentButton release];
#endif
}

- (void)reloadThemes {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_themeList release];
#endif
    _themeList = [[SATEThemeManager sharedManager] allThemes];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_themeList retain];
#endif
    [_tableView reloadData];
}

- (SATETheme *)selectedTheme {
    NSInteger row = [_tableView selectedRow];
    if (row < 0 || row >= (NSInteger)[_themeList count]) return nil;
    return [_themeList objectAtIndex:(NSUInteger)row];
}

- (void)applySelected:(id)sender {
    (void)sender;
    SATETheme *t = [self selectedTheme];
    if (t) {
        [[SATEThemeManager sharedManager] setCurrentTheme:t];
        [self orderOut:nil];
    }
}

- (void)duplicateSelected:(id)sender {
    (void)sender;
    SATETheme *t = [self selectedTheme];
    if (!t) return;
    SATETheme *copy = [t copyWithName:[NSString stringWithFormat:@"Copy of %@", [t name]]];
    [[SATEThemeManager sharedManager] saveCustomTheme:copy];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [copy release];
#endif
    [self reloadThemes];
}

- (void)deleteSelected:(id)sender {
    (void)sender;
    SATETheme *t = [self selectedTheme];
    if (!t || [t builtIn]) return;
    [[SATEThemeManager sharedManager] deleteCustomThemeNamed:[t name]];
    [self reloadThemes];
}

- (void)newFromCurrent:(id)sender {
    (void)sender;
    SATETheme *current = [[SATEThemeManager sharedManager] currentTheme];
    if (!current) return;
    SATETheme *custom = [current copyWithName:@"My Theme"];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [custom autorelease];
#endif
    [[SATEThemeManager sharedManager] saveCustomTheme:custom];
    [self reloadThemes];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    (void)tableView;
    return (NSInteger)[_themeList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    (void)tableView;
    (void)tableColumn;
    if (row < 0 || row >= (NSInteger)[_themeList count]) return nil;
    SATETheme *t = [_themeList objectAtIndex:(NSUInteger)row];
    return [t name];
}

@end
