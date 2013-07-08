//
//  AnnuityTrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "AnnuityTrackView.h"

#define kDefaultHue 0.391
#define kBaseSaturation 0.3

@implementation AnnuityTrackView
@synthesize data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor whiteColor];
      hue = kDefaultHue;
    }
    return self;
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context  {
  // Saturation is average value in block
  CGFloat saturation = 0.0;
  for (int i = 0; i < monthsPerBlock; ++i) {
    saturation += [data valueFor:month+i scaledTo:1.0-kBaseSaturation];
  }
  saturation /= monthsPerBlock;
  if (saturation > 0.01) {
    saturation += kBaseSaturation;
  }
  
  
  UIColor *boxColour = [UIColor colorWithHue:hue saturation:saturation brightness:1.0 alpha:1.0];
  [boxColour setFill];
  
  CGRect rect = self.bounds;
  rect.origin.x = x; rect.origin.y = 0.0;
  rect.size.width = monthsPerBlock * scale;
  
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
