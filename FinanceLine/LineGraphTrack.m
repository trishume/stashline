//
//  LineGraphTrack.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "LineGraphTrack.h"

#define kNumRules 5
#define kInspectOffsetX 70
#define kInspectOffsetY -10

@implementation LineGraphTrack
@synthesize data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor whiteColor];
      lineColor = [UIColor blueColor];
      ruleColor = [UIColor lightGrayColor];
      
      inspectMonth = 0;
      inspectFont = [UIFont boldSystemFontOfSize:16.0];
      inspectFormatter = [[NSNumberFormatter alloc] init];
      inspectFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
      
      self.scaleWithZoom = YES;
    }
    return self;
}


#pragma mark Inspection

- (void)updateInspect:(NSSet *)touches {
  CGPoint loc = [[touches anyObject] locationInView:self];
  inspectMonth = [self monthForX:loc.x];
  [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self updateInspect:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [self updateInspect:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  inspectMonth = 0;
  [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  inspectMonth = 0;
  [self setNeedsDisplay];
}


#pragma mark Rendering

- (double)maxInView {
  NSUInteger startMonth = floor(self.delegate.startMonth);
  NSUInteger endMonth = startMonth + (self.bounds.size.width / self.delegate.monthSize);
  double *dataArr = [data dataPtr];
  
  double max = dataArr[startMonth];
  for (int i = startMonth; i <= endMonth && i <= kMaxMonth; ++i) {
    double val = dataArr[i];
    if (val > max) max = val;
  }
  
  return max;
}

- (CGFloat)scaledYFor:(NSUInteger)month {
  if (self.scaleWithZoom) {
    double max = [self maxInView];
    if(max == 0.0) return 0.0;
    double val = [data valueAt:month] / max;
    return val * self.bounds.size.height;
  } else {
    return [data valueFor:month scaledTo:self.bounds.size.height];
  }
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context  {
  CGFloat y = [self scaledYFor:month];
  CGContextAddLineToPoint(context, x, self.bounds.size.height - y);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Draw Horizontal Rules
  CGContextSetLineWidth(context, 1.0);
  [ruleColor setStroke];
  
  CGFloat ruleSpacing = self.bounds.size.height / kNumRules;
  CGFloat curY = 1.5;
  for (int i = 0; i < kNumRules; ++i) {
    CGContextMoveToPoint(context, 0.0, curY);
    CGContextAddLineToPoint(context, self.bounds.size.width, curY);
    CGContextStrokePath(context);
    curY += ruleSpacing;
  }
  curY = self.bounds.size.height - 1.5;
  CGContextMoveToPoint(context, 0.0, curY);
  CGContextAddLineToPoint(context, self.bounds.size.width, curY);
  CGContextStrokePath(context);
  
  // Draw Graph
  CGContextSetLineWidth(context, 3.0);
  CGContextSetLineJoin(context, kCGLineJoinBevel);
  [lineColor setStroke];
  
  CGFloat startY = [data valueFor:floor(self.delegate.startMonth) scaledTo:self.bounds.size.height];
  
  CGContextMoveToPoint(context,0.0, self.bounds.size.height - startY);
  [self drawBlocks:context];
  CGContextStrokePath(context);
  
  // Draw inspection
  if (inspectMonth != 0 && inspectMonth > self.delegate.startMonth) {
    CGFloat monthX = (inspectMonth - self.delegate.startMonth) * self.delegate.monthSize;
    
    [[UIColor redColor] setStroke];
    CGContextMoveToPoint(context, monthX, 0.0);
    CGContextAddLineToPoint(context, monthX, self.bounds.size.height);
    CGContextStrokePath(context);
    
    CGPoint p;
    p.x = monthX + kInspectOffsetX;
    p.y = self.bounds.size.height / 2.0 + kInspectOffsetY;
    
    double value = [data valueAt:inspectMonth];
    NSString *valueStr = [inspectFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    [valueStr drawAtPoint:p withFont:inspectFont];
  }
}

@end
