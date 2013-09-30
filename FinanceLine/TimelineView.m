//
//  TimelineView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineView.h"
#include "Constants.h"

#define kScrollFriction 1.0
#define kMaxVelocity 6000.0
#define kMaxMonthSize 30.0

@implementation TimelineView
@synthesize tracks, startMonth, monthSize, velocity, maxMonth, nextTrackTop;

- (void)initialize
{
    self.tracks = [NSMutableArray array];
    nextTrackTop = 0.0;
    startMonth = 192.0;
    monthSize = 10.0;
    velocity = 0.0;
    maxMonth = kMaxMonth;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [self addGestureRecognizer:pinch];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)beginAnimationLoop {
  displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerFired:)];
  displayLink.frameInterval = 1;
  NSRunLoop *loop = [NSRunLoop mainRunLoop];
  [displayLink addToRunLoop:loop forMode:NSDefaultRunLoopMode];
}

- (void)endAnimationLoop {
  [displayLink invalidate];
  displayLink = nil;
}

- (NSUInteger)maxStartMonth {
    return maxMonth - self.bounds.size.width / monthSize * 0.8;
}

- (CGFloat)minMonthSize {
    return self.bounds.size.width / kMaxMonth;
}

- (void)timerFired:(CADisplayLink *)sender {
  CGFloat dt = sender.duration * sender.frameInterval;
  velocity *= (1.0 - kScrollFriction*dt);
  if (abs(velocity) < 0.01) {
      [self endAnimationLoop];
  }
  
  CGFloat newStart = startMonth + velocity / monthSize * dt;
  if (newStart < 0.0 || newStart > [self maxStartMonth]) {
      velocity = 0.0;
  }
  self.startMonth = newStart; // setter handles redraw
}

- (void)redrawTracks {
    for (TrackView *track in self.tracks) {
        [track setNeedsDisplay];
    }
}

- (void)setStartMonth:(CGFloat)start {
    start = MIN([self maxStartMonth], start);
    start = MAX(0, start);
    startMonth = start;
    [self redrawTracks];
}

- (void)setMonthSize:(CGFloat)scale {
    monthSize = MIN(scale, kMaxMonthSize);
    monthSize = MAX(monthSize, [self minMonthSize]);
    [self redrawTracks];
}

- (void)setVelocity:(CGFloat)vel {
    velocity = MIN(vel, kMaxVelocity);
    velocity = MAX(velocity, -kMaxVelocity);
    if (velocity != 0.0) {
        [self beginAnimationLoop];
    }
}

- (void)addTrack:(TrackView *)track withHeight:(CGFloat)height {
    // Resize track to fit and add it to the subview.
    CGRect newFrame;
    newFrame.origin.y = nextTrackTop;
    newFrame.size.height = height;
    nextTrackTop += height;
    // fill in x direction
    newFrame.origin.x = 0.0;
    newFrame.size.width = self.bounds.size.width;
    
    track.frame = newFrame;
    track.delegate = self;
    [self addSubview:track];
    
    [self.tracks addObject:track];
}

- (void)clearTracks {
  for (TrackView *trackView in self.tracks) {
    [trackView removeFromSuperview];
  }
  
  [self.tracks removeAllObjects];
  nextTrackTop = 0.0;
}

- (void)layoutSubviews {
    for (TrackView *track in self.tracks) {
        CGRect newFrame = track.frame;
        newFrame.size.width = self.bounds.size.width;
        track.frame = newFrame;
    }
}

#pragma mark Gestures

- (void)pinchHandler:(UIPinchGestureRecognizer *)sender {
    CGPoint origin = [sender locationInView:self];
    CGFloat scale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat curSize = monthSize;
        CGFloat newSize = curSize * scale;
        [self setMonthSize:newSize];
        
        // move startmonth so that it zooms where the pinch started
        // only if we actually scaled and didn't clamp
        if (newSize < kMaxMonthSize && newSize > [self minMonthSize]) {
            CGFloat zoomOffset = origin.x / monthSize;
            self.startMonth += zoomOffset * -(1.0 - scale);
        }
        
        [sender setScale:1.0];
    }
}

// Stop the momentum when the user touches the Timeline
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setVelocity:0.0];
    [super touchesBegan:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
