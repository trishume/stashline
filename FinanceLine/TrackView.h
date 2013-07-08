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
- (NSUInteger) maxMonth;
- (void) setStartMonth: (CGFloat)start;
- (void) setMonthSize: (CGFloat)scale;
- (void) setVelocity: (CGFloat)vel;
@end

@interface TrackView : UIView

@property (nonatomic, weak) id<TrackViewDelegate> delegate;
- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context;
- (void)drawBlocks:(CGContextRef)context;
- (NSUInteger)monthForX:(CGFloat)x;

@end
