// SBTUITunneledHostMouseDrag.m
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

#import "SBTUITunneledHostMouseDrag.h"

@interface SBTUITunneledHostMouseDrag()

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint stopPoint;
@property (nonatomic, assign) NSTimeInterval dragDuration;
@property (nonatomic, assign) NSTimeInterval completionPause;

@end

@implementation SBTUITunneledHostMouseDrag

- (instancetype)initWithElement:(XCUIElement *)element
           startNormalizedPoint:(CGPoint)startNormalizedPoint stopNormalizedPoint:(CGPoint)stopNormalizedPoint
                   dragDuration:(NSTimeInterval)dragDuration
                completionPause:(NSTimeInterval)completionPause
{
    CGRect frame = element.frame;
    CGPoint origin = frame.origin;
    CGSize size = frame.size;
    
    CGPoint startPoint = CGPointMake(origin.x + size.width * startNormalizedPoint.x,
                                     origin.y + size.height * startNormalizedPoint.y);
    
    CGPoint stopPoint = CGPointMake(origin.x + size.width * stopNormalizedPoint.x,
                                    origin.y + size.height * stopNormalizedPoint.y);
    
    return [self initWithStartPoint:startPoint 
                          stopPoint:stopPoint 
                       dragDuration:dragDuration 
                    completionPause:completionPause];
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint 
                         stopPoint:(CGPoint)stopPoint 
                      dragDuration:(NSTimeInterval)dragDuration
                   completionPause:(NSTimeInterval)completionPause
{
    if ((self = [super init])) {
        _startPoint = startPoint;
        _stopPoint = stopPoint;
        _dragDuration = dragDuration;
        _completionPause = completionPause;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    CGPoint startPoint = CGPointFromString([decoder decodeObjectForKey:@"startPoint"]);
    CGPoint stopPoint = CGPointFromString([decoder decodeObjectForKey:@"stopPoint"]);
    NSTimeInterval completionPause = [decoder decodeDoubleForKey:@"completionPause"];
    NSTimeInterval dragDuration = [decoder decodeDoubleForKey:@"dragDuration"];
    
    return [self initWithStartPoint:startPoint 
                          stopPoint:stopPoint
                       dragDuration:dragDuration 
                    completionPause:completionPause];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.completionPause forKey:@"completionPause"];
    [encoder encodeDouble:self.dragDuration forKey:@"dragDuration"];
    [encoder encodeObject:NSStringFromCGPoint(self.startPoint) forKey:@"startPoint"];
    [encoder encodeObject:NSStringFromCGPoint(self.stopPoint) forKey:@"stopPoint"];
}

@end
