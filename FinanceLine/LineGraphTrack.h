//
//  LineGraphTrack.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackView.h"
#import "DataTrack.h"
#import "FinanceModel.h"

@interface LineGraphTrack : TrackView {
  UIColor *lineColor;
  UIColor *ruleColor;
  UIColor *beforeStartColor;
  
  NSUInteger inspectMonth;
  UIFont *inspectFont;
  NSNumberFormatter *inspectFormatter;
  NSUInteger inspectOffset;
}

@property (nonatomic) BOOL scaleWithZoom;
@property (nonatomic, strong) DataTrack *data;
@property (nonatomic, strong) FinanceModel *model;
@end
