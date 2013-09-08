//
//  InfoOverlayView.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "InfoOverlayView.h"

@implementation InfoOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hidden = YES;
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
