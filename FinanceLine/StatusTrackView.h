//
//  StatusTrackView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-15.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackView.h"
#import "DataTrack.h"

@interface StatusTrackView : TrackView {
  UIColor *normalColor;
  UIColor *retiredColor;
}

@property (nonatomic, strong) DataTrack *statusTrack;
@end
