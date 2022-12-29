// Copyright (C) 2023 Subito.it
//
// Licensed under the Apache License, Version 2.0 (the "License");

// SBTMouseDrag.swift
//
// Copyright (C) 2023 Subito.it
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

class SBTMouseDrag: NSObject, NSCoding {
    let completionPause: TimeInterval
    let dragDuration: TimeInterval
    let startPoint: CGPoint
    let stopPoint: CGPoint

    init(startPoint: NSPoint, stopPoint: NSPoint, dragDuration: TimeInterval, completionPause: TimeInterval) {
        self.startPoint = startPoint
        self.stopPoint = stopPoint
        self.dragDuration = dragDuration
        self.completionPause = completionPause
    }

    required init?(coder aDecoder: NSCoder) {
        self.completionPause = aDecoder.decodeDouble(forKey: "completionPause")
        self.dragDuration = aDecoder.decodeDouble(forKey: "dragDuration")
        self.startPoint = aDecoder.decodePoint(forKey: "startPoint")
        self.stopPoint = aDecoder.decodePoint(forKey: "stopPoint")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(completionPause, forKey: "completionPause")
        aCoder.encode(dragDuration, forKey: "dragDuration")
        aCoder.encode(startPoint, forKey: "startPoint")
        aCoder.encode(stopPoint, forKey: "stopPoint")
    }
}
