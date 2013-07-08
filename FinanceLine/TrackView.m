//
//  TrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TrackView.h"

#define kMonthThreshold 10.0
#define kQuarterThreshold 3.0

@implementation TrackView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSUInteger)monthForX:(CGFloat)x {
  CGFloat month = self.delegate.startMonth + x/self.delegate.monthSize;
  return floor(month);
}

- (NSUInteger)blockSizeForScale:(CGFloat)scale {
  if (scale > kMonthThreshold) {
    return 1;
  } else if (scale > kQuarterThreshold) {
    return 3;
  } else {
    return 12;
  }
}

- (void)drawBlocks:(CGContextRef)context {
  CGFloat start = [self.delegate startMonth];
  CGFloat monthSize = [self.delegate monthSize];
  NSUInteger maxMonth = [self.delegate maxMonth];

  NSUInteger monthsPerBlock = [self blockSizeForScale:monthSize];
  CGFloat blockSize = monthsPerBlock * monthSize;
  
  NSUInteger curMonth = floor(start / monthsPerBlock) * monthsPerBlock;
  CGFloat offset = -(start - curMonth) * monthSize;
  
  while (offset - blockSize < self.bounds.size.width && curMonth <= maxMonth) {
    [self drawBlock:curMonth ofMonths:monthsPerBlock atX:offset andScale:monthSize withContext:context];
    offset += blockSize;
    curMonth += monthsPerBlock;
  }
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
