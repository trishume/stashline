//
//  TimelineTrackView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackView.h"
#import "DataTrack.h"

@interface TimelineTrackView : TrackView {
    UIColor *lineColor;
    UIColor *normalTextColor;
    UIColor *retiredTextColor;
}

@property (nonatomic, strong) DataTrack *status;
@property (nonatomic) CGFloat yearTickLength;
@property (nonatomic) CGFloat monthTickLength;
@property (nonatomic) CGFloat lineGap;
@property (nonatomic) UIFont *yearFont;

@end
