//
//  PanelTabView.m
//  FinanceLine
//
//  Created by Tristan Hume on 10/31/2013.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "PanelTabView.h"

#define kMinTouchY 95
#define kMaxTouchY 155

@implementation PanelTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  return (point.x > 0.0 && point.x < self.frame.size.width) && (point.y > kMinTouchY && point.y < kMaxTouchY);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  //// General Declarations
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  //// Color Declarations
  UIColor* lineBlue = [UIColor colorWithRed: 0.078 green: 0.753 blue: 0.89 alpha: 1];
  UIColor* transparentFill = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
  UIColor* tabFill = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
  
  //// Shadow Declarations
  UIColor* innerGlow = lineBlue;
  CGSize innerGlowOffset = CGSizeMake(-2.1, -0.1);
  CGFloat innerGlowBlurRadius = 8.5;
  
  //// TabBg Drawing
  UIBezierPath* tabBgPath = [UIBezierPath bezierPath];
  [tabBgPath moveToPoint: CGPointMake(5, 150)];
  [tabBgPath addLineToPoint: CGPointMake(5, 95)];
  [tabBgPath addLineToPoint: CGPointMake(11, 95)];
  [tabBgPath addLineToPoint: CGPointMake(35.5, 105.5)];
  [tabBgPath addLineToPoint: CGPointMake(35.5, 140.5)];
  [tabBgPath addLineToPoint: CGPointMake(11, 150)];
  [tabBgPath addLineToPoint: CGPointMake(5, 150)];
  [tabBgPath closePath];
  [tabFill setFill];
  [tabBgPath fill];
  
  
  //// TabShape Drawing
  UIBezierPath* tabShapePath = [UIBezierPath bezierPath];
  [tabShapePath moveToPoint: CGPointMake(10, 97)];
  [tabShapePath addLineToPoint: CGPointMake(35, 107)];
  [tabShapePath addLineToPoint: CGPointMake(35, 142)];
  [tabShapePath addLineToPoint: CGPointMake(10, 152)];
  [tabShapePath addLineToPoint: CGPointMake(10, 340)];
  [tabShapePath addLineToPoint: CGPointMake(-10, 340)];
  [tabShapePath addLineToPoint: CGPointMake(-10, -20)];
  [tabShapePath addLineToPoint: CGPointMake(10, -20)];
  [tabShapePath addLineToPoint: CGPointMake(10, 97)];
  [tabShapePath closePath];
  tabShapePath.lineJoinStyle = kCGLineJoinRound;
  
  [transparentFill setFill];
  [tabShapePath fill];
  
  ////// TabShape Inner Shadow
  CGRect tabShapeBorderRect = CGRectInset([tabShapePath bounds], -innerGlowBlurRadius, -innerGlowBlurRadius);
  tabShapeBorderRect = CGRectOffset(tabShapeBorderRect, -innerGlowOffset.width, -innerGlowOffset.height);
  tabShapeBorderRect = CGRectInset(CGRectUnion(tabShapeBorderRect, [tabShapePath bounds]), -1, -1);
  
  UIBezierPath* tabShapeNegativePath = [UIBezierPath bezierPathWithRect: tabShapeBorderRect];
  [tabShapeNegativePath appendPath: tabShapePath];
  tabShapeNegativePath.usesEvenOddFillRule = YES;
  
  CGContextSaveGState(context);
  {
    CGFloat xOffset = innerGlowOffset.width + round(tabShapeBorderRect.size.width);
    CGFloat yOffset = innerGlowOffset.height;
    CGContextSetShadowWithColor(context,
                                CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                innerGlowBlurRadius,
                                innerGlow.CGColor);
    
    [tabShapePath addClip];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(tabShapeBorderRect.size.width), 0);
    [tabShapeNegativePath applyTransform: transform];
    [[UIColor grayColor] setFill];
    [tabShapeNegativePath fill];
  }
  CGContextRestoreGState(context);
  
  [lineBlue setStroke];
  tabShapePath.lineWidth = 4;
  [tabShapePath stroke];
  
  if (!self.panelOpen) {
    //// Arrow Open Drawing
    UIBezierPath* arrowOpenPath = [UIBezierPath bezierPath];
    [arrowOpenPath moveToPoint: CGPointMake(16.5, 114.5)];
    [arrowOpenPath addLineToPoint: CGPointMake(26.5, 124.5)];
    [arrowOpenPath addLineToPoint: CGPointMake(16.5, 134.5)];
    [lineBlue setStroke];
    arrowOpenPath.lineWidth = 2;
    [arrowOpenPath stroke];
  } else {
    //// Arrow Close Drawing
    UIBezierPath* arrowClosePath = [UIBezierPath bezierPath];
    [arrowClosePath moveToPoint: CGPointMake(22.5, 114.5)];
    [arrowClosePath addLineToPoint: CGPointMake(12.5, 124.5)];
    [arrowClosePath addLineToPoint: CGPointMake(22.5, 134.5)];
    [lineBlue setStroke];
    arrowClosePath.lineWidth = 2;
    [arrowClosePath stroke];
  }
}


@end
