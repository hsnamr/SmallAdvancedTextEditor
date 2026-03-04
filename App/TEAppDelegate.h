//
//  TEAppDelegate.h
//  SmallAdvancedTextEditor
//
//  App lifecycle and menu; creates the main editor window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SSAppDelegate.h"

@class TEMainWindow;

@interface TEAppDelegate : NSObject <SSAppDelegate>
{
    TEMainWindow *_mainWindow;
}
@end
