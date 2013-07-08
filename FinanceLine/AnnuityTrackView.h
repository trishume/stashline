//
//  AnnuityTrackView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackView.h"
#import "DataTrack.h"
#import "Selection.h"

@interface AnnuityTrackView : TrackView {
  UIColor *selectionColor;
}

@property (nonatomic) CGFloat hue;
@property (nonatomic, strong) DataTrack *data;
@property (nonatomic, strong) Selection *selection;

@end
