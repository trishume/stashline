//
//  TimelineTrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineTrackView.h"

#define kYearTextShift 0.0
#define kYearLabelThresh 3.0
#define kYearMajorTickThres 4.0

#define kPanVelocityThresh 70.0

@implementation TimelineTrackView
@synthesize yearTickLength, monthTickLength, lineGap;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
    lineColor = [UIColor blackColor];
    self.yearFont = [UIFont boldSystemFontOfSize:20.0];
    
    yearTickLength = 20.0;
    monthTickLength = 10.0;
    lineGap = 17;
    
    normalTextColor = [UIColor blackColor];
    retiredTextColor = [UIColor grayColor];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:pan];
  }
  return self;
}

- (BOOL)retiredDuringYear:(NSUInteger)startMonth {
  BOOL allGood = YES;
  for(NSUInteger i = startMonth; i < startMonth + 12 && i < kMaxMonth; ++i) {
    double status = [self.status valueAt:i];
    allGood = (status == kStatusSafeWithdraw || status == kStatusSavedEnough) && allGood;
  }

  return allGood;
}

#pragma mark Gestures

- (void)panHandler:(UIPanGestureRecognizer *)sender {
  CGPoint translation = [sender translationInView:self];
  if (sender.state == UIGestureRecognizerStateChanged) {
    CGFloat monthsMoved = translation.x / [self.delegate monthSize];
    CGFloat curMonth = [self.delegate startMonth];
    [self.delegate setStartMonth:curMonth-monthsMoved];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint velocity = [sender velocityInView:self];
    CGFloat monthVelocity = -(velocity.x);
    //NSLog(@"Panned with velocity %f",monthVelocity);
    if(abs(monthVelocity) > kPanVelocityThresh) {
      [self.delegate setVelocity:monthVelocity];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.TimelineTrackPanEnded" object:self];
  }
  [sender setTranslation:CGPointZero inView:self];
}

#pragma mark Rendering

- (void) drawString:(NSString*) s withFont:(UIFont*) font inRect:(CGRect) contextRect {
  CGFloat fontHeight = font.pointSize;
  CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;

  CGRect textRect = CGRectMake(contextRect.origin.x, contextRect.origin.y + yOffset,
                               contextRect.size.width, fontHeight);

  [s drawInRect: textRect withFont: font lineBreakMode: NSLineBreakByClipping
      alignment: NSTextAlignmentCenter];
}

- (void)drawBlock:(NSUInteger)month ofMonths:(NSUInteger)monthsPerBlock
              atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context {
  BOOL isYearTick = (month % 12) == 0;
  BOOL isMajorYearTick = (month % (12*5)) == 0;
  BOOL isLabelTick = (isYearTick && scale > kYearLabelThresh) || isMajorYearTick;
  BOOL isMajorTick = (isYearTick && scale > kYearMajorTickThres) || isMajorYearTick;

  CGContextSetLineWidth(context, isMajorTick ? 2.0 : 1.0);
  [lineColor setStroke];

  CGFloat middleY = self.bounds.size.height / 2.0;
  CGFloat tickLength = isMajorTick ? yearTickLength : monthTickLength;

  CGContextMoveToPoint(context,x, middleY + lineGap);
  CGContextAddLineToPoint(context,x, middleY + lineGap + tickLength);
  CGContextStrokePath(context);

  CGContextMoveToPoint(context,x, middleY - lineGap);
  CGContextAddLineToPoint(context,x, middleY - lineGap - tickLength);
  CGContextStrokePath(context);

  if (isLabelTick) {
    bool retired = [self retiredDuringYear: month];
    UIColor *color = retired ? retiredTextColor : normalTextColor;
    [color setFill];

    CGRect textRect = CGRectMake(x - 25.0, middleY - lineGap - kYearTextShift, 50.0, lineGap*2);
    NSString *yearStr = [NSString stringWithFormat:@"%u",month/12];
    [self drawString:yearStr withFont:self.yearFont inRect:textRect];
  }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetLineWidth(context, 4.0);
  [lineColor setStroke];

  CGFloat middleY = self.bounds.size.height / 2.0;
  CGContextMoveToPoint(context,0.0, middleY + lineGap);
  CGContextAddLineToPoint(context,self.bounds.size.width, middleY + lineGap);
  CGContextStrokePath(context);

  CGContextMoveToPoint(context,0.0, middleY - lineGap);
  CGContextAddLineToPoint(context,self.bounds.size.width, middleY - lineGap);
  CGContextStrokePath(context);

  [self drawBlocks:context extraBlock: YES autoScale: YES];
}


@end
