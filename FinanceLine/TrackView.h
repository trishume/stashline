//
//  TrackView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrackViewDelegate <NSObject>
- (CGFloat) startMonth;
- (CGFloat) monthSize;
@end

@interface TrackView : UIView

@property (nonatomic, weak) id<TrackViewDelegate> delegate;

@end
