//
//  SnakeView.m
//  Snake
//
//  Created by Jo Albright on 1/24/19.
//  Copyright © 2019 Roadie, Inc. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "SnakeView.h"

CGFloat speed = 3;
CGFloat count = 20;

// up 0, down 1, left 2, right 3
typedef enum : NSUInteger {
    Up,
    Down,
    Left,
    Right
} SnakeDirection;

@interface Snake : NSObject

@property (nonatomic) NSMutableArray *segments;
@property (nonatomic) SnakeDirection direction;

@end

@implementation Snake

- (instancetype)initWithStart:(CGPoint)start andLength:(CGFloat)length
{
    self = [super init];
    if (self) {

        _segments = [@[] mutableCopy];

        for (CGFloat i = 0; i < length; i++) {

            [_segments addObject:[NSValue valueWithPoint:NSPointFromCGPoint(CGPointMake(start.x - i * speed, start.y))]];

        }

        _direction = 3;
    }
    return self;
}

- (void)change {

    switch (_direction) {
        case Up:
            _direction = arc4random_uniform(10) % 2 == 0 ? Left : Right;
            break;
        case Down:
            _direction = arc4random_uniform(10) % 2 == 0 ? Left : Right;
            break;
        case Left:
            _direction = arc4random_uniform(10) % 2 == 0 ? Up : Down;
            break;
        case Right:
            _direction = arc4random_uniform(10) % 2 == 0 ? Up : Down;
            break;
    }

}

- (void)move {

    NSValue *last = nil;
    NSInteger count = 0;

    for (NSValue *value in [self.segments copy]) {

        if (last == nil) {

            last = value;
            NSPoint point = last.pointValue;

            switch (_direction) {
                case Up:
                    point.y += speed;
                    break;
                case Down:
                    point.y -= speed;
                    break;
                case Left:
                    point.x -= speed;
                    break;
                case Right:
                    point.x += speed;
                    break;
            }

            if (point.x < 0) { point.x = [NSScreen mainScreen].frame.size.width; }
            if (point.x > [NSScreen mainScreen].frame.size.width) { point.x = 0; }
            if (point.y < 0) { point.y = [NSScreen mainScreen].frame.size.height; }
            if (point.y > [NSScreen mainScreen].frame.size.height) { point.y = 0; }

            self.segments[count] = [NSValue valueWithPoint:point];

        } else {

            self.segments[count] = last;
            last = value;

        }

        count += 1;

    }

}

@end

@interface SnakeView ()

@property (nonatomic) NSMutableArray *snakes;

@end

@implementation SnakeView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];

        _snakes = [@[] mutableCopy];

        CGFloat midY = [NSScreen mainScreen].frame.size.height / 2;
        CGFloat median = floor(count / 2);

        for (CGFloat i = 0; i < count; i++) {

            [_snakes addObject:[[Snake alloc] initWithStart:CGPointMake(0, midY + (i - median) * 40) andLength:arc4random_uniform(50) + 50]];

        }

    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    CGContextRef context = [NSGraphicsContext currentContext].CGContext;

    [[NSColor whiteColor] set];

    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, speed * 5);

    for (Snake *snake in self.snakes) {

        for (NSValue *value in snake.segments) {

            NSPoint point = value.pointValue;

            CGContextMoveToPoint(context, point.x, point.y);
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextStrokePath(context);

        }

    }

}

- (void)animateOneFrame
{
    for (Snake *snake in self.snakes) {

        BOOL change = arc4random_uniform(60) == 30;
        if (change) { [snake change]; }
        [snake move];

    }

    [self setNeedsDisplay:YES];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
