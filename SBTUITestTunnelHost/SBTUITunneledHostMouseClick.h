// SBTUITunneledHostMouseClick.h
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

@interface SBTUITunneledHostMouseClick : NSObject <NSCoding>

/*!
 @brief Initialize a SBTUITunneledHostMouseClick based on a XCUIElement
 
 @param  element the element that will be clicked
 @param  completionPause time to wait after drag is done. Useful when chaining drag events
 
 @return float The degrees in the Celsius scale.
 */
- (instancetype)initWithElement:(XCUIElement *)element 
                completionPause:(NSTimeInterval)completionPause;

@end

NS_ASSUME_NONNULL_END
