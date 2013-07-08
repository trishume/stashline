//
//  TimelineTrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineTrackView.h"

#define kLineSpacing 17
#define kMonthTickLength 10.0
#define kYearTickLength 20.0
#define kYearTextShift 0.0

@implementation TimelineTrackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        lineColor = [UIColor blackColor];
        yearFont = [UIFont boldSystemFontOfSize:20.0];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        [self addGestureRecognizer:pan];
    }
    return self;
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
        CGFloat monthVelocity = -(velocity.x) / [self.delegate monthSize];
        [self.delegate setVelocity:monthVelocity];
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

- (void)drawMonth:(NSUInteger)month atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context {
    BOOL isYearTick = (month % 12) == 0;
    if (!isYearTick && scale < 3.0) {
        return;
    }
    
    
    CGContextSetLineWidth(context, isYearTick ? 2.0 : 1.0);
    [lineColor setStroke];
    
    CGFloat middleY = self.bounds.size.height / 2.0;
    CGFloat tickLength = isYearTick ? kYearTickLength : kMonthTickLength;
    
    CGContextMoveToPoint(context,x, middleY + kLineSpacing);
    CGContextAddLineToPoint(context,x, middleY + kLineSpacing + tickLength);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context,x, middleY - kLineSpacing);
    CGContextAddLineToPoint(context,x, middleY - kLineSpacing - tickLength);
    CGContextStrokePath(context);
    
    if (isYearTick) {
        CGRect textRect = CGRectMake(x - 25.0, middleY - kLineSpacing - kYearTextShift, 50.0, kLineSpacing*2);
        NSString *yearStr = [NSString stringWithFormat:@"%i",month/12];
        [self drawString:yearStr withFont:yearFont inRect:textRect];
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
    CGContextMoveToPoint(context,0.0, middleY + kLineSpacing);
    CGContextAddLineToPoint(context,self.bounds.size.width, middleY + kLineSpacing);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context,0.0, middleY - kLineSpacing);
    CGContextAddLineToPoint(context,self.bounds.size.width, middleY - kLineSpacing);
    CGContextStrokePath(context);
    
    [self drawMonths:context];
}


@end
