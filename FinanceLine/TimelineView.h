//
//  TimelineView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TrackView.h"

@interface TimelineView : UIView <TrackViewDelegate> {
    @private
    CGFloat nextTrackTop;
    // current speed in months/second
    CADisplayLink *displayLink;
}

@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic) CGFloat startMonth;
@property (nonatomic) CGFloat monthSize;
@property (nonatomic) CGFloat velocity;
@property (nonatomic, readonly) NSUInteger maxMonth;

- (void)addTrack: (TrackView*)track withHeight:(CGFloat)height;
@end
