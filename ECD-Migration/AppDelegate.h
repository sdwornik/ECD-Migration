@class CoreDataController;

#import <UIKit/UIKit.h>

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pragma mark - CocoaLumberjack logging library support
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#import "CocoaLumberjack.h"


// Log levels: off, error, warn, info, verbose
//
// If you set the log level to:
// LOG_LEVEL_ERROR, then you will only see DDLogError statements.
// LOG_LEVEL_WARN, then you will only see DDLogError and DDLogWarn statements.
// LOG_LEVEL_INFO, you'll see Error, Warn and Info statements.
// LOG_LEVEL_VERBOSE, you'll see all DDLog statements.
// LOG_LEVEL_OFF, you won't see any DDLog statements.

#ifndef __OPTIMIZE__
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
// static const DDLogLevel ddLogLevel = DDLogFlagWarning | DDLogFlagInfo | DDLogFlagDebug | DDLogFlagVerbose;  // ALL but errors.
// static const int ddLogLevel = DDLogFlagInfo;
// static const int ddLogLevel = DDLogFlagDebug;
// static const int ddLogLevel = DDLogFlagWarning;
// static const int ddLogLevel = DDLogFlagError;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif



#define gkAPPDELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataController *persistenceController;

- (NSString *)applicationDocumentsDirectory;


@end