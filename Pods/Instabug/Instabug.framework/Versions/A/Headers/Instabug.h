/*
 File:       Instabug/Instabug.h

 Contains:   API for using Instabug's SDK.

<<<<<<< HEAD
 Copyright:  (c) 2013-2016 by Instabug, Inc., all rights reserved.

 Version:    6.0.3
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IBGEnums.h"

/**
 This is the API for using Instabug's SDK. For more details about the SDK integration,
 please visit https://instabug.com/developers
 */

NS_ASSUME_NONNULL_BEGIN
@interface Instabug : NSObject

/// ------------------------
/// @name SDK Initialization
/// ------------------------

/**
 @brief Starts the SDK.
 
 @discussion This is the main SDK method that does all the magic. This is the only method that SHOULD be called.
 Should be called at the end of `-[UIApplicationDelegate application:didFinishLaunchingWithOptions:]`.
 
 @param token The token that identifies the app, you can find it on your dashboard.
 @param invocationEvent The event that invokes the SDK's UI.
 
 @see IBGInvocationEvent
 */
+ (void)startWithToken:(NSString *)token invocationEvent:(IBGInvocationEvent)invocationEvent;

/// ---------------------------
/// @name SDK Manual Invocation
/// ---------------------------

/**
 @brief Invokes the SDK manually with the default invocation mode.
 
 @discussion Shows a view that asks the user whether they want to start a chat, report a problem or suggest an improvement.
=======
 Copyright:  (c) 2014 by Instabug, Inc., all rights reserved.

 Version:    5.2.2
 */

//===========================================================================================================================================
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IBGEnums.h"
//===========================================================================================================================================

/**
 *  This is the API for using Instabug's SDK, for more details about the SDK integration, please visit http://instabug.com/sdk-integration
 */
@interface Instabug : NSObject

//===========================================================================================================================================
/** @name SDK Initialization */
//===========================================================================================================================================
/**
 *  Starts the SDK
 *
 *  This is the main SDK method that does all the magic. This is the only method that SHOULD be called.
 *  Should be called at the end of the method application:didFinishLaunchingWithOptions:
 *  
 *  @param token           The token that identifies the app, you can find it on your dashboard
 *  @param invocationEvent The event that invocates the feedback form
 */
+ (void)startWithToken:(NSString *)token invocationEvent:(IBGInvocationEvent)invocationEvent;

//===========================================================================================================================================

//===========================================================================================================================================
/** @name SDK Manual Invocation */
//===========================================================================================================================================

/**
 *  Shows the form with the prompt asking whether to report a bug or send feedback
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)invoke;

/**
<<<<<<< HEAD
 @brief Invokes the SDK with a specific mode.
 
 @discussion Invokes the SDK and show a specific view, instead of showing a prompt for users to choose from.
 
 @param invocationMode Specifies which mode the SDK is going to start with.
 
 @see IBGInvocationMode
=======
 *  Invoke the SDK's either bug reporter or feedback sender UIs
 *
 *  @param invocationMode invocationMode
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)invokeWithInvocationMode:(IBGInvocationMode)invocationMode;

/**
<<<<<<< HEAD
 @brief Dismisses any Instabug views that are currently being shown.
 */
+ (void)dismiss;

/// ----------------------
/// @name SDK Pro Features
/// ----------------------

/**
 @brief Attaches a file to each report being sent.
 
 @discussion A new copy of the file at fileLocation will be attached with each bug report being sent.
 Each call to this method overrides the file to be attached.
 The file has to be available locally at the provided path.
 
 @param fileLocation Path to a file that's going to be attached to each report.
=======
 *  Dismiss Instabug
 */
+ (void)dismiss;

//===========================================================================================================================================

//===========================================================================================================================================
/** @name SDK Pro Features */
//===========================================================================================================================================

/**
 *  Attaches a new copy of this file with each bug report sent with a maximum size of 1 MB. Calling this method several times overrides the file to be attached. The file has to be stored locally at the location provided
 *
 *  @param fileLocation fileLocation
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setFileAttachment:(NSString *)fileLocation;

/**
<<<<<<< HEAD
 @brief Attaches user data to each report being sent.
 
 @discussion Each call to this method overrides the user data to be attached.
 Maximum size of the string is 1,000 characters.
 
 @param userData A string to be attached to each report, with a maximum size of 1,000 characters.
=======
 *  Sets the user data that's attached with each bug report sent. Maximum size of the string is 1000 characters
 *
 *  @param userData userData
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setUserData:(NSString *)userData;

/**
<<<<<<< HEAD
 @brief Adds custom logs that will be sent with each report.
 
 @discussion Can be used in a similar fashion to NSLog. For usage in Swift, see `Instabug.ibgLog()`.
 *
 *  @param format Format string.
 *  @param ... Optional varargs arguments.
=======
 *  Adds custom logs that will be sent with each report
 *
 *  @param format format
 *  @param ...    ...
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
OBJC_EXTERN void IBGLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

/**
<<<<<<< HEAD
 @brief Adds custom logs that will be sent with each report.
 
 @param log Message to be logged.
 */
+ (void)IBGLog:(NSString *)log;

/**
 @brief Sets whether the SDK is tracking user steps or not.
 
 @discussion Enabling user steps would give you an insight on the scenario a user has performed before encountering a
 bug or a crash. User steps are attached with each report being sent.
 
 User Steps tracking is enabled by default if it's available in your current plan.
 
 @param isUserStepsEnabled A boolean to set user steps tracking to being enabled or disabled.
=======
 *  Adds custom logs that will be sent with each report. A convenience method for Swift, identical to IBGLog().
 *
 *  Put following function in your swift project:
 *  func IBGLog(str: String, _ arguments: CVarArgType...) -> Void {
 *      return withVaList(arguments) { Instabug.IBGLog(str, withArguments :$0) }
 *  }
 *  And use it like this IBGLog("%@ - %d - %0.1f", "foo", 3, 3.0)
 *
 *  @param format    format
 *  @param arguments arguments
 */
+ (void)IBGLog:(NSString *)format withArguments:(va_list)arguments;

/**
 *  Sets whether to track the user's steps while using the app or not
 *
 *  Default = YES
 *  @param isUserStepsEnabled isUserStepsEnabled
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setUserStepsEnabled:(BOOL)isUserStepsEnabled;

/**
<<<<<<< HEAD
 @brief Sets whether to track and report crashes or not.
 
 @discussion When enabled, Instabug will automatically report crashes, which can be viewed later on from your dashboard.
 
 Crash reporting is enabled by default if it's available in your current plan.
 
 @param isReportingCrashes A boolean to set crash reporting to being enabled or disabled.
=======
 *  Sets whether to track the crashes in the app or not
 *
 *  Default = YES
 *  @param isReportingCrashes isReportingCrashes
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setCrashReportingEnabled:(BOOL)isReportingCrashes;

/**
<<<<<<< HEAD
 @brief Sets whether In-App Conversations button and notifications are displayed or not.
 
 @deprecated Starting from v6.0, use `setPromptOptionsEnabled:` instead.
 
 @discussion When In-App Conversations are disabled, push notifications are disabled as well.

 In-App Conversations is enabled by default if it's available in your current plan.

 @param isInAppConversationsEnabled A boolean to set In-App Conversations to being enabled or disabled.
 */
+ (void)setInAppConversationsEnabled:(BOOL)isInAppConversationsEnabled DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setPromptOptionsEnabled: instead.");

/**
 @brief Sets a block of code to be executed before sending each report.
 
 @deprecated Starting from v6.0, use `setPreSendingHandler:` instead.
 
 @discussion This block is executed in the background before sending each report. Could be useful for attaching logs
 and extra data to reports.
 
 @param preSendingBlock A block of code that gets executed before sending each bug report.
 */
+ (void)setPreSendingBlock:(void (^)())preSendingBlock DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setPreSendingHandler: instead.");

/**
 @brief Sets a block of code to be executed before sending each report.

 @discussion This block is executed in the background before sending each report. Could be used for attaching logs
 and extra data to reports.
 
 @param preSendingHandler A block of code that gets executed before sending each bug report.
 */
+ (void)setPreSendingHandler:(void (^)())preSendingHandler;

/**
 @brief Sets a block of code to be executed just before the SDK's UI is presented.
 
 @deprecated Starting from v6.0, use `setPreInvocationHandler:` instead.
 
 @discussion This block is executed on the UI thread. Could be used for performing any UI changes before the SDK's UI 
 is shown.

 @param preInvocationBlock A block of code that gets executed before presenting the SDK's UI.
 */
+ (void)setPreInvocationBlock:(void (^)())preInvocationBlock DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setPreInvocationHandler: instead.");

/**
 @brief Sets a block of code to be executed just before the SDK's UI is presented.
 
 @discussion This block is executed on the UI thread. Could be used for performing any UI changes before the SDK's UI
 is shown.
 
 @param preInvocationHandler A block of code that gets executed before presenting the SDK's UI.
 */
+ (void)setPreInvocationHandler:(void (^)())preInvocationHandler;

/**
 @brief Sets a block of code to be executed right after the SDK's UI is dismissed.
 
 @deprecated Starting from v6.0, use `setPostInvocatioHandler:` instead.
 
 @discussion This block is executed on the UI thread. Could be used for performing any UI changes after the SDK's UI
 is dismissed.
 
 @param postInvocationBlock A block of code that gets executed after the SDK's UI is dismissed.
 
 The block has the following parameters:
 
 - issueState: The state of the issue after the SDK has been dismissed. Indicates whether the issues has been submitted,
 cancelled, or still in progress.
 - feedbackType: Type of feedback that has been sent. Will be set to IBGFeedbackTypeBug in case the SDK has been 
 dismissed without selecting a report type, so you might need to check issueState before feedbackType.
 
 @see IBGIssueState, IBGFeedbackType
 */
+ (void)setPostInvocationBlock:(void (^)(IBGIssueState issueState, IBGFeedbackType feedbackType))postInvocationBlock DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setPostInvocatioHandler: instead.");

/**
 @brief Sets a block of code to be executed right after the SDK's UI is dismissed.
 
 @discussion This block is executed on the UI thread. Could be used for performing any UI changes after the SDK's UI
 is dismissed.
 
 @param postInvocationHandler A block of code that gets executed after the SDK's UI is dismissed.
 
 The block has the following parameters:
 
 - dismissType: How the SDK was dismissed.
 - reportType: Type of report that has been sent. Will be set to IBGReportTypeBug in case the SDK has been dismissed
 without selecting a report type, so you might need to check issueState before reportType
 
 @see IBGReportType, IBGDismissType
 */
+ (void)setPostInvocatioHandler:(void (^)(IBGDismissType dismissType, IBGReportType reportType))postInvocationHandler;

/**
 @brief Present a view that educates the user on how to invoke the SDK with the currently set invocation event.
=======
 *  Sets whether In-App Conversations button and notifications are displayed or not
 *  If set to NO it disables push notifications as well
 *
 *  Default = YES
 *  @param isInAppConversationsEnabled isInAppConversationsEnabled
 */
+ (void)setInAppConversationsEnabled:(BOOL)isInAppConversationsEnabled;

/**
 *  Sets the block of code that gets executed just before sending the bug report.
 *
 *  @param preSendingBlock preSendingBlock
 */
+ (void)setPreSendingBlock:(void (^)())preSendingBlock;

/**
 * Presents a quick tip UI educating the user on how to invoke SDK with the currently set invocation event
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)showIntroMessage;

/**
<<<<<<< HEAD
 @brief Enables/disables the attachment of an initial screenshot when reporting a bug/improvement.
 
 @deprecated Starting from v6.0, use 
 `setAttachmentTypesEnabledScreenShot:extraScreenShot:galleryImage:voiceNote:screenRecording:` instead.
 
 @param willTakeScreenshot A boolean to set whether attachment of an initial screenshot is enabled or disabled.
 */
+ (void)setWillTakeScreenshot:(BOOL)willTakeScreenshot DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setAttachmentTypesEnabledScreenShot:extraScreenShot:galleryImage:voiceNote:screenRecording: instead.");

/**
 @brief Sets the default value of the user's email and hides the email field from the reporting UI.
 
 @discussion Defaults to an empty string.

 @param userEmail An email address to be set as the user's email.
=======
 * Enabled/disable the attachment of an initial screenshot when reporting a bug/imporovement
 * @param willTakeScreenshot willTakeScreenshot
 */

+ (void)setWillTakeScreenshot:(BOOL)willTakeScreenshot;

/**
 *  Sets the default value of the email field and hides the email field from the reporting UI
 *
 *  Default = @""
 *  @param userEmail userEmail
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setUserEmail:(NSString *)userEmail;

/**
<<<<<<< HEAD
 @brief Sets the default value of the user's name to be included with all reports.
 
 @discussion Defaults to an empty string.

 @param userName Name of the user to be set.
 */
+ (void)setUserName:(NSString *)userName;

/**
 @brief Enables/disables screenshot view when reporting a bug/improvement.
 
 @deprecated Starting from v6.0, use `setWillSkipScreenshotAnnotation:` instead.
 
 @discussion By default, screenshot view is shown when reporting a bug, but not when sending feedback.
 
 @param willShowScreenshotView A boolean to set whether screenshot view is shown or not. Passing YES will show
 screenshot view for both feedback and bug reporting, while passing NO will disable it for both.
 */
+ (void)setWillShowScreenshotView:(BOOL)willShowScreenshotView DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setWillSkipScreenshotAnnotation: instead.");

/**
 @brief Enables/disables screenshot view when reporting a bug/improvement.
 
 @discussion By default, screenshot view is shown when reporting a bug, but not when sending feedback.
 
 @param willSkipScreenShot A boolean to set whether screenshot view is shown or not. Passing YES will show
 screenshot view for both feedback and bug reporting, while passing NO will disable it for both.
 */
+ (void)setWillSkipScreenshotAnnotation:(BOOL)willSkipScreenShot;

/**
 @brief Returns the number of unread messages the user currently has.
 
 @discussion Use this method to get the number of unread messages the user has, then possibly notify them about it with
 your own UI.
 
 @return Notifications count, or -1 incase the SDK has not been initialized.
 */
+ (NSInteger)getUnreadMessagesCount;

/// ------------------
/// @name SDK Settings
/// ------------------

/**
 @brief Sets the event that invoke the feedback form.

 @discussion Default is set by `startWithToken:invocationEvent:`.
 
 @param invocationEvent Event that invokes the feedback form.
 
 @see IBGInvocationEvent
=======
 *  Sets the user name that is used in the dashboard's contacts
 *
 *  Default = @""
 *  @param userName userName
 */
+ (void)setUserName:(NSString *)userName;

//===========================================================================================================================================

//===========================================================================================================================================
/** @name SDK Settings */
//===========================================================================================================================================

/**
 *  Sets the event that invocates the feedback form
 *
 *  Default is set by startWithToken:invocationEvent:
 *  @param invocationEvent invocationEvent
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setInvocationEvent:(IBGInvocationEvent)invocationEvent;

/**
<<<<<<< HEAD
 @brief Sets the default SDK invocation mode.
 
 @deprecated Starting from v6.0, use `setPromptOptionsEnabledWithBug:feedback:chat:` instead.

 @discussion Defaults to IBGInvocationModeNA.
 
 @param invocationMode A mode that's used to invoke the SDK.
 
 @see IBGInvocationMode
 */
+ (void)setDefaultInvocationMode:(IBGInvocationMode)invocationMode DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setPromptOptionsEnabledWithBug:feedback:chat: instead");

/**
 @brief Enables/disables the use of push notifications in the SDK.

 @discussion In order to enable push notifications, implement 
 `-[UIApplicationDelegate application:didRegisterForRemoteNotificationsWithDeviceToken:]` and either
 `-[UIApplicationDelegate application:didReceiveRemoteNotification]` or
 `-[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:]`.
 
 Defaults to YES.
 
 @param isPushNotificationsEnabled A boolean to indicate whether push notifications are enabled or disabled.
=======
 *  Sets the default SDK mode upon invocation
 *
 *  Default = IBGInvocationModeNA
 *  @param invocationMode invocationMode
 */
+ (void)setDefaultInvocationMode:(IBGInvocationMode)invocationMode;

/**
 *  Enable/disable SDK to use push notifications
 *
 *  Default = YES
 *  @param isPushNotificationsEnabled isPushNotificationsEnabled
 *  Note: In order to enable push notifications, UIApplicationDelegate method 
 *  `application:didRegisterForRemoteNotificationsWithDeviceToken:` should be implemented. Also 
 *  `application:didReceiveRemoteNotification` or `application:didReceiveRemoteNotification:fetchCompletionHandler:`
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setPushNotificationsEnabled:(BOOL)isPushNotificationsEnabled;

/**
<<<<<<< HEAD
 @brief Sets whether users are required to enter an email address or not when sending reports.

 @discussion Defaults to YES.

 @param isEmailFieldRequired A boolean to indicate whether email field is required or not.
=======
 *  Sets the value of whether the email field is validated or not
 *
 *  Default = YES
 *  @param isEmailFieldRequired isEmailFieldRequired
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setEmailFieldRequired:(BOOL)isEmailFieldRequired;

/**
<<<<<<< HEAD
 @brief Sets whether users are required to enter a comment or not when sending reports.
 
 @discussion Defaults to NO.
 
 @param isCommentFieldRequired A boolean to indicate whether comment field is required or not.
=======
 *  Sets whether the comment field is validated or not
 *
 *  Default = NO
 *  @param isCommentFieldRequired isCommentFieldRequired
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setCommentFieldRequired:(BOOL)isCommentFieldRequired;

/**
<<<<<<< HEAD
 @brief Sets the threshold value of the shake gesture for iPhone/iPod Touch and iPad.
 
 @discussion Default for iPhone is 2.5.
 Default for iPad is 0.6.
 
 @param iPhoneShakingThreshold Threshold for iPhone.
 @param iPadShakingThreshold Threshold for iPad.
=======
 *  Sets the threshold value of the shake gesture for iPhone/iPod Touch and iPad
 *
 *  Default iPhone = 2.5
 *  Default iPad = 0.6
 *  @param iPhoneShakingThreshold iPhoneShakingThreshold
 *  @param iPadShakingThreshold iPadShakingThreshold
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setShakingThresholdForiPhone:(double)iPhoneShakingThreshold foriPad:(double)iPadShakingThreshold;

/**
<<<<<<< HEAD
 @brief Sets the default edge and offset from the top at which the floating button will be shown. Different orientations
 are already handled.
 
 @discussion Default for `floatingButtonEdge` is `CGRectMaxXEdge`.
 Default for `floatingButtonOffsetFromTop` is 50
 
 @param floatingButtonEdge `CGRectMaxXEdge` to show on the right, or `CGRectMinXEdge` to show on the left.
 @param floatingButtonOffsetFromTop Top offset for floating button.
=======
 *  Sets the default edge and offset from the top at which the floating button will be shown. Different orientations are already handled
 *
 *  Default floatingButtonEdge = CGRectMaxXEdge
 *  Default floatingButtonOffsetFromTop = 50
 *  @param floatingButtonEdge CGRectMaxXEdge(right) or CGRectMinXEdge(left)
 *  @param floatingButtonOffsetFromTop floatingButtonOffsetFromTop
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setFloatingButtonEdge:(CGRectEdge)floatingButtonEdge withTopOffset:(double)floatingButtonOffsetFromTop;

/**
<<<<<<< HEAD
 @brief Sets the SDK's locale.
 
 @discussion Use to change the SDK's UI to different language.
 Defaults to the device's current locale.
 
 @param locale A locale to set the SDK to.
 
 @see IBGLocale
=======
 *  Sets the locale used to display the strings in the correct language
 *
 *  Default is fetched from the device locale
 *  @param locale locale
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setLocale:(IBGLocale)locale;

/**
<<<<<<< HEAD
 @brief Sets whether the intro message that gets shown on launching the app is enabled or not.

 @discussion Defaults to YES.
 
 @param isIntroMessageEnabled A boolean to indicate whether the intro message is enabled or not.
=======
 *  Sets the default value of the intro message that gets shown on launching the app
 *
 *  Default = YES
 *  @param isIntroMessageEnabled isIntroMessageEnabled
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setIntroMessageEnabled:(BOOL)isIntroMessageEnabled;

/**
<<<<<<< HEAD
 @brief Sets the color theme of the SDK's whole UI.

 @param colorTheme An `IBGColorTheme` to set the SDK's UI to.
 
 @see IBGColorTheme
=======
 *  Sets the color theme of the whole SDK UI
 *
 *  @param colorTheme colorTheme
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setColorTheme:(IBGColorTheme)colorTheme;

/**
<<<<<<< HEAD
 @brief Sets the primary color of the SDK's UI.
 
 @discussion Sets the color of UI elements indicating interactivity or call to action.

 @param color A color to set the UI elements of the SDK to.
=======
 *  Sets the primary color of the SDK user interface, mostly indicating interactivity or call to action
 *
 *  @param color color
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
 */
+ (void)setPrimaryColor:(UIColor *)color;

/**
<<<<<<< HEAD
 @brief Sets a block of code that is used to capture a screenshot.
 
 @deprecated Starting from v6.0, use `setScreenshotCapturingHandler:` instead.
 
 @discussion Should only be used if your app uses OpenGL.
 
 @param screenshotCapturingBlock A block of code that's going to be used to capture screenshots.
 */
+ (void)setScreenshotCapturingBlock:(UIImage *(^)())screenshotCapturingBlock DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use setScreenshotCapturingHandler: instead.");

/**
 @brief Sets a block of code that is used to capture a screenshot.
 
 @discussion Should only be used if your app uses OpenGL.
 
 @param screenshotCapturingHandler A block of code that's going to be used to capture screenshots.
 */
+ (void)setScreenshotCapturingHandler:(UIImage *(^)())screenshotCapturingHandler;

/**
 @brief Appends a set of tags to previously added tags of reported feedback, bug or crash.
 
 @deprecated Starting from v6.0, use `appendTags:` instead.
 
 @param tag A set of tags.
 @param ... ...
 */
+ (void)addTags:(NSString *)tag, ... NS_REQUIRES_NIL_TERMINATION DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use appendTags: instead.");

/**
 @brief Appends a set of tags to previously added tags of reported feedback, bug or crash.
 
 @deprecated Starting from v6.0, use `appendTags:` instead.
 
 @discussion This method is identical to `+[Instabug addtags:]`, but is meant to be used from Swift.
 
 To use this method from Swift, you will need to add the following code to the class that's going to call it.
 
 ```
 func addTags(str: String, _ arguments: CVarArgType...) -> Void {
    return withVaList(arguments) { Instabug.addTags(str, withArguments :$0) }
 }
 ```
 And then call addTags("tag 1", "tag 2", "tag 3").
 
 @param tag tag
 @param arguments arguments
 */
+ (void)addTags:(NSString *)tag withArguments:(va_list)arguments DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use appendTags: instead.");

/**
 @brief Appends a set of tags to previously added tags of reported feedback, bug or crash.

 @param tags An array of tags to append to current tags.
*/
+ (void)appendTags:(NSArray<NSString *> *)tags;

/**
 @brief Manually removes all tags of reported feedback, bug or crash.
 */
+ (void)resetTags;

/**
 @brief Gets all tags of reported feedback, bug or crash.
 */
+ (NSArray *)getTags;

/**
 @brief Overrides any of the strings shown in the SDK with custom ones.
 
 @discussion Allows you to customize any of the strings shown to users in the SDK.
 
 @param value String value to override the default one.
 @param key Key of string to override.
 
 @see IBGString
 */
+ (void)setString:(NSString*)value toKey:(IBGString)key;

/**
 @brief Sets whether attachments in bug reporting and in-app messaging are enabled or not.
 
 @param screenShot A boolean to enable or disable screenshot attachments.
 @param extraScreenShot A boolean to enable or disable extra screenshot attachments.
 @param galleryImage A boolean to enable or disable gallery image attachments. In iOS 10+, NSPhotoLibraryUsageDescription should be set in info.plist to enable gallery image attachments.
 @param voiceNote A boolean to enable or disable voice note attachments. In iOS 10+, NSMicrophoneUsageDescription should be set in info.plist to enable voiceNote attachments.
 @param screenRecording A boolean to enable or disable screen recording attachments.
 */
+ (void)setAttachmentTypesEnabledScreenShot:(BOOL)screenShot
                            extraScreenShot:(BOOL)extraScreenShot
                               galleryImage:(BOOL)galleryImage
                                  voiceNote:(BOOL)voiceNote
                            screenRecording:(BOOL)screenRecording;

/**
 @brief Enables/disables showing in-app notifications when the user receives a new message.
 
 @param chatNotificationEnabled A boolean to set whether notifications are enabled or disabled.
 */
+ (void)setChatNotificationEnabled:(BOOL)chatNotificationEnabled;

/**
 @brief Sets a block of code that gets executed when a new message is received.

 @param onNewMessageHandler A block of code that gets executed when a new message is received.
 */
+ (void)setOnNewMessageHandler:(void (^)())onNewMessageHandler;

/**
 @brief Enables/disables prompt options when SDK is invoked.
 
 @discussion When only a single option is enabled, it become the default invocation mode. 
 If all options are disabled, bug reporting becomes the default invocation mode.
 
 By default, all three options are enabled.
 
 @param bugReportEnabled A boolean to indicate whether bug reports are enabled or disabled.
 @param feedbackEnabled A boolean to indicate whether feedback is enabled or disabled.
 @param chatEnabled A boolean to indicate whether chat is enabled or disabled.
 */
+ (void)setPromptOptionsEnabledWithBug:(BOOL)bugReportEnabled feedback:(BOOL)feedbackEnabled chat:(BOOL)chatEnabled;

/// -------------------
/// @name SDK Reporting
/// -------------------

/**
 @brief Report an exception manually.
 
 @param exception Exception to be reported.
 */
+ (void)reportException:(NSException *)exception;

/// --------------------------
/// @name In-App Conversations
/// --------------------------

/**
 @brief Invokes the SDK and shows the conversations view.
 
 @deprecated Starting from v6.0, use `invokeWithInvocationMode:` instead.
 */
+ (void)invokeConversations DEPRECATED_MSG_ATTRIBUTE("Starting from v6.0, use invokeWithInvocationMode: instead.");

/// ------------------------
/// @name Push Notifications
/// ------------------------

/**
 @brief Checks if a notification is from Instabug.
 
 @discussion If you are using push notifications, use this method to check whether an incoming notification is from
 Instabug or not. If this method returns YES, you should call didReceiveRemoteNotification: to let the Instabug handle
 the notification. Otherwise, handle the notification on your own.
 
 @param notification userInfo dictionary received in `-[UIApplicationDelegate application:didReceiveRemoteNotification:]`.
 
 @return YES if notification is from Instabug.
 */
+ (BOOL)isInstabugNotification:(NSDictionary *)notification;

/**
 @brief Use this method to set Apple Push Notification token to enable receiving Instabug push notifications.
 
 @discussion You should call this method after receiving token in 
 `-[UIApplicationDelegate didRegisterForRemoteNotificationsWithDeviceToken:]` and pass received token.
 
 @param deviceToken Device token received in `-[UIApplicationDelegate didRegisterForRemoteNotificationsWithDeviceToken:]`
 */
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 @brief Call this method and pass the notification's userInfo dictionary to allow Instabug to handle its remote notifications.
 
 @discussion Instabug will check if notification is from Instabug's servers and only handle it if it is.
 You should call this method in -[UIApplicationDelegate application:didReceiveRemoteNotification:] and pass received userInfo
 dictionary, or `-[UIApplicationDelegate application:didFinishLaunchingWithOptions:]` and pass
 `[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]`.
 
 @param userInfo userInfo dictionary from `-[UIApplicationDelegate application:didReceiveRemoteNotification:]` or
 `[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]` from
 `-[UIApplicationDelegate application:didFinishLaunchingWithOptions:]`.
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end
NS_ASSUME_NONNULL_END
=======
 *  Manually sets how to capture a screenshot, use it only if you're using OpenGL
 *
 *  @param screenshotCapturingBlock screenshotCapturingBlock
 */
+ (void)setScreenshotCapturingBlock:(CGImageRef (^)())screenshotCapturingBlock;

//===========================================================================================================================================

//===========================================================================================================================================
/** @name SDK Reporting */
//===========================================================================================================================================

/**
 *  Manually reports an exception
 *  @param exception exception(required)
 */
+ (void)reportException:(NSException *)exception;

//===========================================================================================================================================

//===========================================================================================================================================
/** @name In-App Conversations */
//===========================================================================================================================================

/**
 *  Open conversations view
 */
+ (void)invokeConversations;

//===========================================================================================================================================

@end
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
