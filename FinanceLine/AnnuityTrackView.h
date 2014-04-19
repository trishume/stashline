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

@protocol TrackSelectionDelegate <NSObject>
- (void) setSelection: (Selection *)sel onTrack: (DataTrack *)track;
- (NSUInteger) minSelectMonth;
@end

@interface AnnuityTrackView : TrackView {
  UIColor *selectionColor;
  UIColor *dividerColor;
  UIColor *numColor;
  UIColor *arrowColor;
  UIFont *numFont;
  
  BOOL selecting;
  BOOL expanding;
}

- (void)selectFrom:(NSUInteger)month to:(NSUInteger)end;

@property (nonatomic, weak) id<TrackSelectionDelegate> selectionDelegate;
@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat negativeHue;
@property (nonatomic, strong) DataTrack *data;
@property (nonatomic, strong) Selection *selection;
@property (nonatomic) BOOL percentTrack;

@end
