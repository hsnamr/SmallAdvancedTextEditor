//
//  TEThemePanel.h
//  SmallAdvancedTextEditor
//
//  Panel to choose, duplicate, delete, and create custom themes.
//

#import <AppKit/AppKit.h>

@interface TEThemePanel : NSPanel
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    NSTableView *_tableView;
    NSButton *_applyButton;
    NSButton *_duplicateButton;
    NSButton *_deleteButton;
    NSButton *_newFromCurrentButton;
    NSArray *_themeList;
}
#endif
+ (void)showPanel;
@end
