// SBTMouseClick.swift
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

import Cocoa

class SBTMouseClick: NSObject, NSCoding {
    let completionPause: TimeInterval
    let point: CGPoint
    
    init(point: NSPoint, completionPause: TimeInterval) {
        self.point = point
        self.completionPause = completionPause
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.completionPause = aDecoder.decodeDouble(forKey: "completionPause")
        self.point = aDecoder.decodePoint(forKey: "point")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(completionPause, forKey: "completionPause")
        aCoder.encode(point, forKey: "point")
    }
}
