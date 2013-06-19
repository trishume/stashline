//
//  TimelineView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackView.h"

@interface TimelineView : UIView <TrackViewDelegate> {
    @private
    CGFloat nextTrackTop;
}

@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic) CGFloat startMonth;
@property (nonatomic) CGFloat monthSize;

- (void)addTrack: (TrackView*)track withHeight:(CGFloat)height;
@end
