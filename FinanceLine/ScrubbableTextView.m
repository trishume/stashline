//
//  ScrubbableTextView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-03.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "ScrubbableTextView.h"

#define kScrubRange 100.0

@implementation ScrubbableTextView

- (void)initialize
{
  self.minVal = 0.0;
  self.maxVal = 100000000.0;
  self.stepVal = 10.0;
  
  scrubColor = [UIColor blueColor];
  normalColor = [UIColor blackColor];
  
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
  [self addGestureRecognizer:pan];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initialize];
  }
  return self;
}

- (double)doubleValue {
  return [[self text] doubleValue];
}

- (void)setValue:(double)v {
  self.text = [NSString stringWithFormat:@"%.2f", v];
}

- (double)newValueFromOld:(double)oldVal withDelta:(CGFloat)delta {
//  if (delta > 0.0) {
//    double change = delta / kScrubRange * oldVal;
//    return oldVal + change;
//  }
  
  double value = startVal + delta / 5 * self.stepVal;
  value = round(value / self.stepVal) * self.stepVal;
  value = MIN(value, self.maxVal);
  value = MAX(value, self.minVal);
  return value;
}

- (void)panHandler:(UIPanGestureRecognizer *)sender {
  CGPoint translation = [sender translationInView:self];
  if (sender.state == UIGestureRecognizerStateBegan) {
    startVal = [self doubleValue];
    self.textColor = scrubColor;
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    double newVal = [self newValueFromOld:startVal withDelta:translation.x];
    [self setValue:newVal];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    self.textColor = normalColor;
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
  }
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
