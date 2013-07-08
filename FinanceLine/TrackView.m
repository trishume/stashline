//
//  TrackView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TrackView.h"

@implementation TrackView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawMonths:(CGContextRef)context {
    CGFloat start = [self.delegate startMonth];
    CGFloat scale = [self.delegate monthSize];
    NSUInteger maxMonth = [self.delegate maxMonth];
    
    CGFloat partMonth = fmodf(start, 1.0);
    CGFloat offset = (1 - partMonth) * scale;
    if (partMonth == 0.0) {
        offset = 0.0;
    }
    NSUInteger curMonth = ceil(start);
    while (offset < self.bounds.size.width && curMonth <= maxMonth) {
        [self drawMonth:curMonth atX:offset andScale:scale withContext:context];
        offset += scale;
        curMonth += 1;
    }
}

- (void)drawMonth:(NSUInteger)month atX:(CGFloat)x andScale:(CGFloat)scale withContext:(CGContextRef)context {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
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
