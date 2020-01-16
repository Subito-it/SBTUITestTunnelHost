// SBTUITunneledHostMouseDrag.h
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

NS_ASSUME_NONNULL_BEGIN

@interface SBTUITunneledHostMouseDrag : NSObject <NSCoding>

/*!
 @brief Initialize a SBTUITunneledHostMouseDrag starting from an XCUIElement
 
 @param  element the element that will be used as a reference for start/stop normalized coordinates
 @param  startNormalizedPoint normalized position where drag begins. (0, 0) corresponds to the top left edge of the XCUIElement, (1, 1) to the bottom right edge of the XCUIElement
 @param  stopNormalizedPoint normalized position where drag ends. (0, 0) corresponds to the top left edge of the XCUIElement, (1, 1) to the bottom right edge of the XCUIElement
 @param  dragDuration time to execute drag
 @param  completionPause time to wait after drag is done. Useful when chaining drag events
 
 @return float The degrees in the Celsius scale.
 */
- (instancetype)initWithElement:(XCUIElement *)element
           startNormalizedPoint:(CGPoint)startNormalizedPoint
            stopNormalizedPoint:(CGPoint)stopNormalizedPoint
                   dragDuration:(NSTimeInterval)dragDuration
                completionPause:(NSTimeInterval)completionPause;

@end

NS_ASSUME_NONNULL_END
