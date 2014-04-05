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

+ (NSNumberFormatter*)amountFormatter {
  NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
  amountFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
  amountFormatter.roundingIncrement = @1;
  amountFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
  amountFormatter.maximumFractionDigits = 0;
  return amountFormatter;
}

- (void)initialize
{
  self.minVal = 0.0;
  self.maxVal = 100000000.0;
  self.stepVal = 10.0;
  
  self.formatter = nil;
  
  self.scrubColor = [UIColor blueColor];
  self.normalColor = [UIColor colorWithHue:0.583 saturation:1.000 brightness:1.000 alpha:1.000];
  
  curVal = 0.0;
  
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
  [self addGestureRecognizer:pan];
  
  // Add Bar for closing number pad on iPhone
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.inputAccessoryView = numberToolbar;
  }
}

-(void)cancelNumberPad{
  [self resignFirstResponder];
  [self setValue:curVal];
}

-(void)doneWithNumberPad{
  [self resignFirstResponder];
  [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
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

-(void) awakeFromNib{
  [super awakeFromNib];
  self.font = [UIFont fontWithName:@"PTSans-CaptionBold" size: self.font.pointSize];
}

- (double)doubleValue {
  return curVal;
}

- (void)setValue:(double)v {
  curVal = v;
  if (self.formatter != nil) {
    self.text = [self.formatter stringFromNumber:[NSNumber numberWithDouble:v]];
  } else {
    self.text = [NSString stringWithFormat:@"%.2f", v];
  }
}

- (double)newValueFromOld:(double)oldVal withDelta:(CGFloat)delta {
//  if (delta > 0.0) {
//    double change = delta / kScrubRange * oldVal;
//    return oldVal + change;
//  }
  
  double value = startVal + delta / 5 * self.stepVal;
  value = round(value / self.stepVal) * self.stepVal;
  value = [self rangeValue:value];
  return value;
}

- (void)panHandler:(UIPanGestureRecognizer *)sender {
  CGPoint translation = [sender translationInView:self];
  if (sender.state == UIGestureRecognizerStateBegan) {
    startVal = [self doubleValue];
    self.textColor = self.scrubColor;
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    double newVal = [self newValueFromOld:startVal withDelta:translation.x];
    [self setValue:newVal];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    self.textColor = self.normalColor;
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
  }
}

- (double)rangeValue: (double)val {
  val = MIN(val, self.maxVal);
  val = MAX(val, self.minVal);
  return val;
}

- (BOOL)validValue {
  double val = [self parseValue];
  return ![self.text isEqualToString:@""] && val <= self.maxVal && val >= self.minVal;
}

- (double)parseAndUpdate {
  double res = [self parseValue];
  res = [self rangeValue:res];
  [self setValue:res];
  return res;
}

- (double)parseValue {
  double res = [[self.formatter numberFromString:self.text] doubleValue];
  if (res == 0.0) {
    res = [self.text doubleValue];
  }
  return res;
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
