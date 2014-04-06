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
#import "FinanceModel.h"

@interface TimelineView : UIView <TrackViewDelegate> {
  @private
  // current speed in months/second
  CADisplayLink *displayLink;
  
  UIView *beforeStartView;
}

@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic) CGFloat startMonth;
@property (nonatomic) CGFloat monthSize;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) double labelMult;
@property (nonatomic, readonly) NSUInteger maxMonth;
@property (nonatomic, readonly) CGFloat nextTrackTop;

@property (nonatomic, strong) FinanceModel *model;

- (void)addTrack: (TrackView*)track withHeight:(CGFloat)height;
- (void)redrawTracks;
- (void)clearTracks;
@end
