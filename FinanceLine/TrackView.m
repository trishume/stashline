//
//  TrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TrackView.h"
#import "Constants.h"

#define kMonthThreshold 10.0
#define kQuarterThreshold 4.0

@implementation TrackView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      label = nil;
    }
    return self;
}

- (void)setLabel:(NSString *)trackLabel {
  if (label == nil) {
    CGFloat labelHeight = (self.bounds.size.height > 100) ? 35.0 : self.bounds.size.height;
    CGRect labelFrame = CGRectMake(15.0, 0.0, 100.0, labelHeight);
    label = [[NiceLabel alloc] initWithFrame:labelFrame];
    label.small = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHue:0.000 saturation:0.000 brightness:0.400 alpha:0.870];
    [label setFontOfSize:20.0];
    [self addSubview:label];
  }
  label.text = trackLabel;
}

- (NSUInteger)monthForX:(CGFloat)x {
  CGFloat month = self.delegate.startMonth + x/self.delegate.monthSize;
  return MAX(MIN(floor(month), kMaxMonth),0.0);
}

- (NSUInteger)blockForX:(CGFloat)x {
  NSUInteger blockSize = [self blockSize];
  CGFloat month = self.delegate.startMonth + x/self.delegate.monthSize;
  return MAX(MIN(month / blockSize, kMaxMonth / blockSize),0.0);
}

- (NSUInteger)blockSize {
  CGFloat scale = self.delegate.monthSize;
  if (scale > kMonthThreshold) {
    return 1;
  } else if (scale > kQuarterThreshold) {
    return 3;
  } else {
    return 12;
  }
}

- (void)drawBlocks:(CGContextRef)context {
  [self drawBlocks:context extraBlock:NO autoScale:YES];
}

- (void)drawBlocks:(CGContextRef)context extraBlock:(BOOL)extraBlock autoScale:(BOOL)scaleBlocks {
  CGFloat start = [self.delegate startMonth];
  CGFloat monthSize = [self.delegate monthSize];
  NSUInteger maxMonth = [self.delegate maxMonth];

  NSUInteger monthsPerBlock = scaleBlocks ? [self blockSize] : 1;
  CGFloat blockSize = monthsPerBlock * monthSize;
  
  NSUInteger curMonth = floor(start / monthsPerBlock) * monthsPerBlock;
  CGFloat offset = -(start - curMonth) * monthSize;
  
  NSUInteger extraBonus = extraBlock ? 1 : 0;
  while (offset - blockSize < self.bounds.size.width && curMonth <= maxMonth + extraBonus) {
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
