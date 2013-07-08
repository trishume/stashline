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
#define kSelectionThickness 4.0

@implementation AnnuityTrackView
@synthesize data, hue, selection;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor whiteColor];
      hue = kDefaultHue;
      selectionColor = [UIColor blueColor];
      selection = [[Selection alloc] init];
      
      UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
      [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark Selection

- (void)panHandler:(UIPanGestureRecognizer *)sender {
  CGPoint start = [sender locationInView:self];
  CGPoint translation = [sender translationInView:self];
  
  NSUInteger startMonth = [self monthForX:start.x];
  NSUInteger endMonth = [self monthForX:start.x-translation.x];
  if (sender.state == UIGestureRecognizerStateChanged) {
    [selection selectFrom:startMonth to:endMonth];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    [selection selectFrom:startMonth to:endMonth];
  }
  [self setNeedsDisplay];
}


#pragma mark Rendering

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context  {
  // Saturation is average value in block
  CGFloat saturation = 0.0;
  BOOL selected = NO;
  for (int i = 0; i < monthsPerBlock; ++i) {
    saturation += [data valueFor:month+i scaledTo:1.0-kBaseSaturation];
    selected = selected || [selection includes:month+i];
  }
  saturation /= monthsPerBlock;
  if (saturation > 0.01) {
    saturation += kBaseSaturation;
  }
  
  
  UIColor *boxColour = [UIColor colorWithHue:hue saturation:saturation brightness:1.0 alpha:1.0];
  [boxColour setFill];
  
  CGFloat width = monthsPerBlock * scale;
  
  CGRect rect = self.bounds;
  rect.origin.x = x; rect.origin.y = 0.0;
  rect.size.width = width;
  
  CGContextFillRect(context, rect);
  
  // Draw line above and below if selected
  if (selected) {
    [selectionColor setStroke];
    CGContextSetLineWidth(context, kSelectionThickness);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    CGFloat curY = kSelectionThickness / 2.0;
    CGContextMoveToPoint(context, x, curY);
    CGContextAddLineToPoint(context, x+width, curY);
    CGContextStrokePath(context);
    
    curY = self.bounds.size.height - curY;
    CGContextMoveToPoint(context, x, curY);
    CGContextAddLineToPoint(context, x+width, curY);
    CGContextStrokePath(context);
  }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  [self drawBlocks:context];
}


@end
