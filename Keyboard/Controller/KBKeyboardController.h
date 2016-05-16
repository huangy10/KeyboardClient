//
//  KBKeyboardController.h
//  
//
//  Created by 黄延 on 15/9/2.
//
//

#import <UIKit/UIKit.h>

@class KBKeyboardController;

@protocol KBKeyboardDelegate <NSObject>

/**
 *  Invoked when an emoticon is successfully picked.
 *
 *  @param keyboard keyboard controller reference.
 *  @param emoticon image of the emoticon.
 */
- (void)keyboard:(KBKeyboardController*)keyboard didPickEmoticon:(UIImage*)emoticon;

/**
 *  Invoked when cancelled
 *
 *  @param keyboard keyboard controller reference.
 */
- (void)keyboardDidCancelled:(KBKeyboardController *)keyboard;

/**
 *  invoked when error occurs
 *
 *  @param keyboard keyboard controller reference.
 *  @param error    error information
 */
- (void)keyboard:(KBKeyboardController*)keyboard errorOccurs:(NSError*)error;

/**
 *  Invoked when starting launching the instance.
 *
 *  @param keyboard keyboard controller reference.
 */
- (void)keyboardWillStartLaunching:(KBKeyboardController *)keyboard;

/**
 *  Invoked when the keyboard is already shown on the screen
 *
 *  @param keyboard keyboard controller reference.
 */
- (void)keyboardDidFinishLaunching:(KBKeyboardController *)keyboard;

/**
 *  Invoked when the keyboard starts dismissing
 *
 *  @param keyboard keyboard controller reference.
 */
- (void)keyboardWillStartDismissing:(KBKeyboardController *)keyboard;

/**
 *  Invoked when the keyboard has already disappeared.
 *
 *  @param keyboard keyboard controller reference.
 */
- (void)keyboardDidEndDismissing:(KBKeyboardController *)keyboard;

@end

/**
 *  This class is the main entrance of the keyboard system.
 *  这个类为键盘的主要入口，一般来说，外部APP与键盘交互只需要接触到这一层
 *
 */
@interface KBKeyboardController : UIViewController

/**
 *  This class method make neccessary configuration before you create your first keyboard instance. You should invoke this method before any keyboard instance being created.
 *  
 *  Data maintaining threads will be created in this function.
 *  
 *  @param option You can manually control the configuration by setting this dictionary. Check our documents for details.
 */
+ (void)environmentConfig:(NSDictionary*)option;

/**
 *  Launch the keyboard to the screen
 *
 *  @param animated animated.
 */
- (void)launchAnimated:(BOOL)animated;

/**
 *  Mannually dismiss the keyboard
 *
 *  @param animated animated.
 */
- (void)dismissKeyboardAnimated:(BOOL)animated;

/**
 *  Delegate to
 */
@property (nonatomic, weak) id<KBKeyboardDelegate> delegate;

/**
 *  Whether to auto dismiss the keyboard after a emoticon was selected
 */
@property (nonatomic) BOOL autoDissmissAfterSelection;

@end
