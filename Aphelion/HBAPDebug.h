//
//  HBAPDebug.h
//  Aphelion
//
//  Created by Adam D on 6/10/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#include <libgen.h>

#if DEBUG
void HBAPDebugStart();

#define XCODE_COLORS

#ifdef XCODE_COLORS
#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"fg;"
#define XCODE_COLORS_RESET_BG XCODE_COLORS_ESCAPE @"bg;"
#define XCODE_COLORS_RESET XCODE_COLORS_ESCAPE @";"

#define NSLog(format, ...) NSLog(XCODE_COLORS_ESCAPE @"fg101,176,66;%s" XCODE_COLORS_ESCAPE @"fg137,150,168;:%d: " XCODE_COLORS_RESET format, basename(__FILE__), __LINE__, ##__VA_ARGS__)

#define HBLogInfo(format, ...) NSLog(XCODE_COLORS_ESCAPE @"fg51,135,204;" format XCODE_COLORS_RESET, ##__VA_ARGS__)
#define HBLogWarn(format, ...) NSLog(XCODE_COLORS_ESCAPE @"fg226,137,100;" format XCODE_COLORS_RESET, ##__VA_ARGS__)
#define HBLogError(format, ...) NSLog(XCODE_COLORS_ESCAPE @"fg255,0,0;" format XCODE_COLORS_RESET, ##__VA_ARGS__)
#endif

#endif

#if !defined(XCODE_COLORS) || !DEBUG
#if DEBUG
#warning install xcodecolors to add awesome. https://github.com/robbiehanson/XcodeColors
#define _HBLogFunction NSLog
#else
void TFLog(NSString *format, ...) __attribute__((format(__NSString__, 1, 2)));
#define _HBLogFunction TFLog
#endif

#define NSLog(format, ...) _HBLogFunction(@"%s:%d: " format, basename(__FILE__), __LINE__, ##__VA_ARGS__)

#define HBLogInfo(format, ...) NSLog(@"INFO: " format, ##__VA_ARGS__)
#define HBLogWarn(format, ...) NSLog(@"WARN: " format, ##__VA_ARGS__)
#define HBLogError(format, ...) NSLog(@"ERROR: " format, ##__VA_ARGS__)
#endif

#if DEBUG
#define _HBLogNoimp HBLogWarn
#else
#define _HBLogNoimp HBLogError
#endif

#define NOIMP { _HBLogNoimp(@"%@ not implemented", NSStringFromSelector(_cmd)); }
