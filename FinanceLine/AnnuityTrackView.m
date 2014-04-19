//
//  AnnuityTrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "AnnuityTrackView.h"

#define kDefaultHue 0.391
#define kDefaultNegativeHue 0.016
#define kBaseSaturation 0.4
#define kSelectionThickness 4.0

#define kEnableDividers
#define kDividerWidth 1.5
#define kDividerAlpha 0.1
#define kDividerWhite 0.0
#define kDividerThresh 25.0
#define kDividerFade 10.0

#define kNumSpacing 30.0

#define kExpandArea 50.0

@implementation AnnuityTrackView
@synthesize data, hue, negativeHue, selection, selectionDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor whiteColor];
      self.percentTrack = NO;
      hue = kDefaultHue;
      negativeHue = kDefaultNegativeHue;
      selecting = NO;
      expanding = NO;
      
      selectionColor = [UIColor blueColor];
      selection = [[Selection alloc] init];
      numFont = [UIFont systemFontOfSize:16.0];
      numColor = [UIColor darkGrayColor];
      //arrowColor = [UIColor colorWithRed: 0.343 green: 0.668 blue: 1 alpha: 1];
      arrowColor = selectionColor;
      
      UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
      [self addGestureRecognizer:pan];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
      doubleTap.numberOfTapsRequired = 2;
      [self addGestureRecognizer:doubleTap];
      
      UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
      singleTap.numberOfTapsRequired = 1;
      [self addGestureRecognizer:singleTap];
    }
    return self;
}

- (NSString*)miniNum:(double)val {
  double divisor = 1.0;
  char quantifier = ' ';
  double absVal = abs(val);
  if (self.percentTrack) {
    divisor = 0.01;
    quantifier = '%';
  } else if(absVal >= 1000000) {
    divisor = 1000000;
    quantifier = 'M';
  } else if(absVal >= 1000) {
    divisor = 1000;
    quantifier = 'k';
  }
  int intVal = (int)(val/divisor);
  return [NSString stringWithFormat:@"%i%c",intVal, quantifier];
}

#pragma mark Selection

- (void)floodSelect:(NSUInteger)month {
  double *dataArr = [data dataPtr];
  double startVal = dataArr[month];
  
  // to the right
  NSUInteger end;
  for (end = month; end <= kMaxMonth; ++end) {
    if(dataArr[end] != startVal) {
      break;
    }
  }
  end--; // rewind to where we were good
  
  // and to the left
  NSInteger start;
  for (start = month; start >= [selectionDelegate minSelectMonth]; --start) {
    if(dataArr[start] != startVal) {
      break;
    }
  }
  start++; // rewind to where we were good
  
  [selection selectFrom:start to:end];
  
  [selectionDelegate setSelection:selection onTrack:data];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.AnnuityTrackSelectionEnded" object:self];
  [self setNeedsDisplay];
}

- (void)selectFrom:(NSUInteger)month to:(NSUInteger)end {
  [selection selectFrom:month to:end];
  [selectionDelegate setSelection:selection onTrack:data];
  [self setNeedsDisplay];
}

- (void)panHandler:(UIPanGestureRecognizer *)sender {
  CGPoint end = [sender locationInView:self];
  CGPoint translation = [sender translationInView:self];
  
  if ([sender state] == UIGestureRecognizerStateEnded) {
    selecting = NO;
    expanding = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.AnnuityTrackSelectionEnded" object:self];
  } else {
    selecting = YES;
  }
  
  // Selection snaps to current block size
  CGFloat blockSize = [self blockSize];
  NSUInteger selEnd = [self blockForX:end.x] * blockSize;
  NSUInteger selStart = [self blockForX:end.x-translation.x] * blockSize;
  
  if (selEnd > selStart && end.x > self.bounds.size.width - kExpandArea) {
    selEnd = kMaxMonth;
    expanding = YES;
  } else {
    expanding = NO;
  }
  
  if (selStart > selEnd) {
    selStart += (blockSize - 1);
  } else {
    selEnd += (blockSize - 1);
  }
  
  [selection selectFrom:selStart to:selEnd];
  
  [selectionDelegate setSelection:selection onTrack:data];
  [self setNeedsDisplay];
}

- (void)tapAction:(NSUInteger)month inverted:(BOOL)invert {
  BOOL isZero = ([data valueAt:month] == 0.0);
  if (isZero ^ invert) {
    [self selectFrom:month to:month];
  } else {
    [self floodSelect:month];
  }
}

- (void)singleTap:(UITapGestureRecognizer*)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint loc = [sender locationInView:self];
    NSUInteger month = [self monthForX:loc.x];
    [self tapAction:month inverted:NO];
  }
}

- (void)doubleTap:(UITapGestureRecognizer*)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint loc = [sender locationInView:self];
    NSUInteger month = [self monthForX:loc.x];
    [self tapAction:month inverted:YES];
  }
}


#pragma mark Rendering

- (void)drawMiniArrowsAtX:(CGFloat)x {
  const CGFloat h = 8;
  const CGFloat w = 20;
  //// Triangle Drawing
  UIBezierPath* trianglePath = [UIBezierPath bezierPath];
  [trianglePath moveToPoint:    CGPointMake(x    , 0.0)];
  [trianglePath addLineToPoint: CGPointMake(x + w, 0.0)];
  [trianglePath addLineToPoint: CGPointMake(x    , h)];
  [trianglePath addLineToPoint: CGPointMake(x    , 0.0)];
  [trianglePath closePath];
  
  [arrowColor setFill];
  [trianglePath fill];
  
  CGFloat b = self.bounds.size.height;
  trianglePath = [UIBezierPath bezierPath];
  [trianglePath moveToPoint:    CGPointMake(x    , b)];
  [trianglePath addLineToPoint: CGPointMake(x + w, b)];
  [trianglePath addLineToPoint: CGPointMake(x    , b - h)];
  [trianglePath addLineToPoint: CGPointMake(x    , b)];
  [trianglePath closePath];
  
  [trianglePath fill];
}

- (void)drawArrowAtX:(CGFloat)x y:(CGFloat)y filled:(BOOL)fill {
  const CGFloat h = 8;
  const CGFloat w = 17;
  //// Triangle Drawing
  UIBezierPath* trianglePath = [UIBezierPath bezierPath];
  [trianglePath moveToPoint:    CGPointMake(x    , y - h)];
  [trianglePath addLineToPoint: CGPointMake(x + w, y)];
  [trianglePath addLineToPoint: CGPointMake(x    , y + h)];
  [trianglePath addLineToPoint: CGPointMake(x    , y - h)];
  [trianglePath closePath];
  
  if (fill) {
    [arrowColor setFill];
    [trianglePath fill];
  }
  
  [arrowColor setStroke];
  trianglePath.lineWidth = 1.5;
  [trianglePath stroke];
}

- (void)drawArrowsFilled:(BOOL)fill {
  CGFloat center = self.bounds.size.height / 2.0;
  CGFloat end = self.bounds.size.width;
  [self drawArrowAtX:end - 25.0 y:center filled:fill];
  [self drawArrowAtX:end - 47.0 y:center filled:fill];
}

- (void)splitBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
               atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context {
  for (int i = 0; i < monthsPerBlock; ++i) {
    [self drawBlock:month+i ofMonths:1 atX:x+(scale*i) andScale:scale withContext:context];
  }
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context  {
  // Saturation is average value in block
  double saturation = [data valueFor:month scaledTo:1.0-kBaseSaturation];
  BOOL selected = [selection includes: month];
  
  // Possibly split block render
  BOOL isZero = (saturation == 0.0);
  BOOL isNegative = (saturation < 0.0);
  for (int i = 1; i < monthsPerBlock; ++i) {
    double monthValue = [data valueFor:month+i scaledTo:1.0-kBaseSaturation];
    saturation += monthValue;
    
    if ((monthValue == 0.0) != isZero || (monthValue < 0.0) != isNegative || [selection includes:month+i] != selected) {
      [self splitBlock:month ofMonths:monthsPerBlock atX:x andScale:scale withContext:context];
      return;
    }
  }
  saturation /= monthsPerBlock;
  saturation = ABS(saturation);
  
  CGFloat width = monthsPerBlock * scale;
  if (saturation > 0.0) {
    saturation += kBaseSaturation;
  
    CGFloat boxHue = isNegative ? negativeHue : hue;
    UIColor *boxColour = [UIColor colorWithHue:boxHue saturation:saturation brightness:1.0 alpha:1.0];
    [boxColour setFill];
    
    CGRect rect = self.bounds;
    rect.origin.x = x; rect.origin.y = 0.0;
    rect.size.width = width - 0.2;

    CGContextFillRect(context, rect);
  }
  
#ifdef kEnableDividers
  if (scale > (kDividerThresh-kDividerFade)) {
    [dividerColor setStroke];
    CGContextSetLineWidth(context, kDividerWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    CGContextMoveToPoint(context, x, 0.0);
    CGContextAddLineToPoint(context, x, self.bounds.size.height);
    CGContextStrokePath(context);
  }
#endif
  
  
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
  // fade in dividers
  CGFloat monthSize = [self.delegate monthSize];
  CGFloat fade = (1.0 - (kDividerThresh - monthSize)/kDividerFade) * kDividerAlpha;
  fade = MIN(MAX(fade,0.0),kDividerAlpha);
  dividerColor = [UIColor colorWithWhite:kDividerWhite alpha:fade];
  
  // Draw rects
  [self drawBlocks:context extraBlock:NO autoScale:YES];
  
  // Draw amount labels
  double labelMult = self.delegate.labelMult;
  if (labelMult != 0.0) {
    if(self.percentTrack) labelMult = 1.0;
    
    __block CGFloat lastNumX = -100.0;
    CGFloat numY = self.bounds.size.height/2.0 - [numFont xHeight];
    [self drawBlocks:context extraBlock:NO autoScale:NO render:^void(NSUInteger month,NSUInteger mpb,CGFloat x,CGFloat scale,CGContextRef cont) {
      double value = [data valueAt:month];
      double prevValue = (month == 0) ? -1.0 : [data valueAt:month - 1];
      if (value != 0.0 && value != prevValue && x > lastNumX + kNumSpacing) {
        NSString *str = [self miniNum:value*labelMult];
        [numColor setFill];
        [str drawAtPoint:CGPointMake(x + 5.0, numY) withFont:numFont];
        lastNumX = x;
      }
    }];
  }
  
  // Draw sidebar
  UIColor *boxColour = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:0.5];
  [boxColour setFill];
  
  CGRect r = CGRectMake(0.0, 0.0, 10.0, self.bounds.size.height);
  CGContextFillRect(context, r);
  
  // Draw selection expand target
  if (selecting) {
    [self drawArrowsFilled:expanding];
  }
  
  // Draw long selection arrows
  NSUInteger endMonth = self.delegate.startMonth + (self.bounds.size.width / self.delegate.monthSize) + 12;
  CGFloat endBuffer = self.bounds.size.width - (([selection start] - self.delegate.startMonth) * self.delegate.monthSize);
  if (![selection isEmpty] && [selection end] > endMonth && endBuffer > 50.0) {
    //[self drawArrowsFilled:NO];
    [self drawMiniArrowsAtX:self.bounds.size.width - 15.0];
    //[self drawMiniArrowsAtX:self.bounds.size.width - 35.0];
  }
}


@end
