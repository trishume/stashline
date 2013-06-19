//
//  TimelineView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineView.h"

@implementation TimelineView
@synthesize tracks, startMonth, monthSize;

- (void)initialize
{
    self.tracks = [NSMutableArray array];
    nextTrackTop = 0.0;
    startMonth = 0.0;
    monthSize = 15.0;
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

- (void)layoutSubviews {
    for (TrackView *track in self.tracks) {
        CGRect newFrame = track.frame;
        newFrame.size.width = self.bounds.size.width;
        track.frame = newFrame;
    }
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
