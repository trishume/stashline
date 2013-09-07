//
//  SelectDividerView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-07.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "SelectDividerView.h"

@implementation SelectDividerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
  hasSelection = NO;
  
  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
  singleTap.numberOfTapsRequired = 1;
  [self addGestureRecognizer:singleTap];
}

- (void)setHasSelection:(BOOL)_hasSelection {
  hasSelection = _hasSelection;
  [self setNeedsDisplay];
}

- (void)singleTap:(UITapGestureRecognizer*)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self.delegate deselect];
  }
}

#pragma mark Drawing

- (void)drawSelected {
  //// Color Declarations
  UIColor* activeColor = [UIColor colorWithRed: 0.145 green: 0.694 blue: 0.541 alpha: 1];
  
  //// Frames
  CGRect frame = self.bounds;
  
  
  //// Divider Drawing
  UIBezierPath* dividerPath = [UIBezierPath bezierPath];
  [dividerPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + 2)];
  [dividerPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame) - 5, CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame))];
  [dividerPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMaxY(frame) - 2)];
  [activeColor setStroke];
  dividerPath.lineWidth = 2;
  [dividerPath stroke];
  
  
  //// Cross2 Drawing
  UIBezierPath* cross2Path = [UIBezierPath bezierPath];
  [cross2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.45000 * CGRectGetHeight(frame))];
  [cross2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 0.55000 * CGRectGetHeight(frame))];
  [activeColor setStroke];
  cross2Path.lineWidth = 1.5;
  [cross2Path stroke];
  
  
  //// Cross1 Drawing
  UIBezierPath* cross1Path = [UIBezierPath bezierPath];
  [cross1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 0.45000 * CGRectGetHeight(frame))];
  [cross1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 0.55000 * CGRectGetHeight(frame))];
  [activeColor setStroke];
  cross1Path.lineWidth = 1.5;
  [cross1Path stroke];
}

- (void)drawNoSelection {
  CGRect frame2 = self.bounds;
  UIColor* barColor = [UIColor colorWithRed: 0.686 green: 0.714 blue: 0.733 alpha: 1];
  //// Bar Drawing
  UIBezierPath* barPath = [UIBezierPath bezierPath];
  [barPath moveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.40000 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 2)];
  [barPath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.40000 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 118)];
  [barColor setStroke];
  barPath.lineWidth = 2;
  [barPath stroke];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  if (hasSelection) {
    [self drawSelected];
  } else {
    [self drawNoSelection];
  }
}


@end
