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

@interface LineGraphTrack : TrackView {
  UIColor *lineColor;
  UIColor *ruleColor;
}

@property (nonatomic, strong) DataTrack *data;
@end
