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
    }
    return self;
}

- (void) drawString:(NSString*) s withFont:(UIFont*) font inRect:(CGRect) contextRect {
    CGFloat fontHeight = font.pointSize;
    CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;
    
    CGRect textRect = CGRectMake(contextRect.origin.x, contextRect.origin.y + yOffset,
                                 contextRect.size.width, fontHeight);
    
    [s drawInRect: textRect withFont: font lineBreakMode: NSLineBreakByClipping
        alignment: NSTextAlignmentCenter];
}

- (void)drawTick:(NSUInteger)month atX:(CGFloat)x withContext:(CGContextRef)context {
    BOOL isYearTick = (month % 12) == 0;
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

- (void)drawTicks:(CGContextRef)context {
    CGFloat start = [self.delegate startMonth];
    CGFloat scale = [self.delegate monthSize];
    
    CGFloat offset = fmodf(start, 1.0) * scale;
    NSUInteger curMonth = ceil(start);
    while (offset < self.bounds.size.width) {
        [self drawTick:curMonth atX:offset withContext:context];
        offset += scale;
        curMonth += 1;
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
    
    [self drawTicks:context];
}


@end
