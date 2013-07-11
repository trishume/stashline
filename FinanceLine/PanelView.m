//
//  PanelView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-09.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "PanelView.h"

#define kSeparatorSize 6.0

@implementation PanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, kSeparatorSize);
  [[UIColor colorWithHue:0.536 saturation:0.870 brightness:0.863 alpha:1.000] setStroke];
  
  CGFloat sepY = self.bounds.size.height - kSeparatorSize/2.0;
  CGContextMoveToPoint(context, 0.0, sepY);
  CGContextAddLineToPoint(context, self.bounds.size.width, sepY);
  CGContextStrokePath(context);
}


@end
