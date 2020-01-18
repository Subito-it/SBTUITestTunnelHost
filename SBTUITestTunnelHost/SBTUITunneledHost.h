// SBTUITunneledHost.h
//
// Copyright (C) 2017 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@import Foundation;
@import XCTest;

#import "SBTUITunneledHostMouseClick.h"
#import "SBTUITunneledHostMouseDrag.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SBTUITunneledHostLogLevel) {
    SBTUITunneledHostLogLevelNone,
    SBTUITunneledHostLogLevelDebug
};

@interface SBTUITunneledHost : NSObject

/**
 *  Asynchronously connects for remote host
 *
 */
- (void)connect;

/**
 *  Command to execute on the host. Waits for the command to finish.
 *
 *  @return command result. @c nil if command failed or connnection did timeout
 */
- (nullable NSString *)executeCommand:(NSString *)command;

/**
 *  Command to launch a command on the host. Returns immediately.
 *  
 *  @return The command ID. Use this ID for the @c -getStatusOfCommandWithID:
 *          and @c -terminateCommandWithID: methods.
 */
- (NSUUID *)launchCommand:(NSString *)command;

/**
 *  Command to get the status of a command on the host.
 *  
 *  @return An @c NSDictionary containing the status of the command, or @c nil
 *          if no command is found with the given UUID.
 */
- (NSDictionary *)getStatusOfCommandWithID:(NSUUID *)commandID;

/**
*  Command to interrupt a command on the host. Sends a @c SIGINT signal.
*  
*  @return An @c NSDictionary containing the status of the command, or @c nil
*          if no command is found with the given UUID.
*/
- (NSDictionary *)interruptCommandWithID:(NSUUID *)commandID;

/**
*  Command to interrupt a command on the host. Sends a @c SIGTERM signal.
*  
*  @return An @c NSDictionary containing the status of the command, or @c nil
*          if no command is found with the given UUID.
*/
- (NSDictionary *)terminateCommandWithID:(NSUUID *)commandID;

/**
 *  Command to execute a sequence of SBTUITunneledHostMouseClick
 *
 *  @return command result. @c nil if command failed or connnection did timeout
 */
- (nullable NSString *)executeMouseClicks:(NSArray<SBTUITunneledHostMouseClick *> *)clicks
                                      app:(XCUIApplication *)app;

/**
 *  Command to execute a sequence of SBTUITunneledHostMouseDrag
 *
 *  @return command result. @c nil if command failed or connnection did timeout
 */
- (nullable NSString *)executeMouseDrags:(NSArray<SBTUITunneledHostMouseDrag *> *)drags
                                     app:(XCUIApplication *)app;

@property (nonatomic, assign) SBTUITunneledHostLogLevel logLevel;

@end

NS_ASSUME_NONNULL_END
