// MouseMagic.swift
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


import Foundation
import AppKit

class Mouse {
    
    func drag(from p0: CGPoint, to p1: CGPoint) {
        var mouseDrags = [CGEvent]()
        
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: p0, mouseButton: .left)
        let totalDragPoints = CGFloat(5.0)
        for i in 0..<Int(totalDragPoints) {
            let p = CGPoint(x: p0.x + (p1.x - p0.x) / totalDragPoints * CGFloat(i), y: p0.y + (p1.y - p0.y) / totalDragPoints * CGFloat(i))
            if let mouseDrag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: p, mouseButton: .left) {
                mouseDrags.append(mouseDrag)
            }
        }
        
        let mouseUp   = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: p1, mouseButton: .left)
        
        mouseDown?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 1e-3 * 50.0)
        for mouseDrag in mouseDrags {
            mouseDrag.post(tap: .cghidEventTap)
            Thread.sleep(forTimeInterval: 1e-3 * 25.0)
        }
        
        Thread.sleep(forTimeInterval: 1e-3 * 50.0)
        mouseUp?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 1e-3 * 200.0)
    }
    
    func click(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp   = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        mouseDown?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 1e-3 * 50.0)
        mouseUp?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 1e-3 * 500.0)
    }
}
