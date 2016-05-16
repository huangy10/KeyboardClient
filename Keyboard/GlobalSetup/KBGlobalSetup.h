//
//  KBGlobalSetup.h
//  Keyboard
//
//  Created by 黄延 on 15/8/22.
//  Copyright (c) 2015年 黄延. All rights reserved.
//

#ifndef Keyboard_KBGlobalSetup_h
#define Keyboard_KBGlobalSetup_h

/**
 *  All the important GLOBAL Setup are defined here
 */

// Do NOT add '/' after the host name
#define KBHOST_NAME @"http://123.57.69.170"     // Host name
// #define KBHOST_NAME @"http://localhost:8000"     // Host name

/**
 *  Red color of the pannel
 */
#define KBColorPanelRed [UIColor colorWithRed:1.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]
#define KBColorPanelGray [UIColor grayColor]
#define KBColorPanelClear [UIColor clearColor]

#pragma mark blocks

/**
 *  Common Completion block.
 *
 *  @param error error info.
 *  @param data  data returned.
 */
typedef void (^KBCompleteBlock)(NSError* error, NSArray *data);

/**
 *  Error handler. You may notice that you have already get the error info from the complete block. However, the difference is that the errors you get from the complete block can be fixed, and the errors here is dangerous, and you should try to avoid it.
 *
 *  @param error error info.
 */
typedef void (^KBErrorOccuranceBlock)(NSError* error);

#pragma mark enumerable constants

typedef enum {
    KBHandUsangeRight=0,
    KBHandUsangeLeft
}KBHandUsange;


#pragma mark Notifications

// This notification is posted by KBEmtoiconUpdater when update finished.
#define KB_UPDATE_FINISHED_NOTIF @"kb_update_finished_nofitiction"


#ifdef DEBUG
// debug log
#define DMLog(...) NSLog(@"DEBUG:%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
// warning log, it will block the app.
#define WRLog(...) NSLog(@"WARNING:%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]);assert(NO);
#else
#define DMLog(...) do { } while (0)
#define ERRLog(...) do { } while (0)
#endif

#endif
