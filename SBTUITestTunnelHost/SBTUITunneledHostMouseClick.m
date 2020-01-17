// SBTUITunneledHostMouseClick.m
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

#import "SBTUITunneledHostMouseClick.h"

@interface SBTUITunneledHostMouseClick()

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) NSTimeInterval completionPause;

@end

@implementation SBTUITunneledHostMouseClick

- (instancetype)initWithPoint:(CGPoint)point 
              completionPause:(NSTimeInterval)completionPause
{
    if ((self = [super init])) {
        _point = point;
        _completionPause = completionPause;
    }
    
    return self;
}

- (instancetype)initWithElement:(XCUIElement *)element
                completionPause:(NSTimeInterval)completionPause;
{
    CGRect frame = element.frame;
    CGPoint frameCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    return [self initWithPoint:frameCenter completionPause:completionPause];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSTimeInterval completionPause = [decoder decodeDoubleForKey:@"completionPause"];
    CGPoint point = CGPointFromString([decoder decodeObjectForKey:@"point"]);
    
    return [self initWithPoint:point completionPause:completionPause];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.completionPause forKey:@"completionPause"];
    [encoder encodeObject:NSStringFromCGPoint(self.point) forKey:@"point"];
}

@end
