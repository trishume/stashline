//
//  StatusTrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-15.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "StatusTrackView.h"
#import "Constants.h"

#define kStatusHeight 8.0

@implementation StatusTrackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization codeh
      normalColor = [UIColor whiteColor];
      retiredColor = [UIColor greenColor];
      self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context  {
  double status = [self.statusTrack valueAt:month];
  if (status == kStatusSafeWithdraw) {
    [retiredColor setFill];
  } else {
    [normalColor setFill];
  }
  
  CGFloat width = monthsPerBlock * scale;
  
  CGRect rect;
  rect.origin.x = x; rect.origin.y = self.bounds.size.height - kStatusHeight;
  rect.size.width = width; rect.size.height = kStatusHeight * 2.0;
  
  CGContextFillRect(context, rect);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  [self drawBlocks:context];
}


@end
