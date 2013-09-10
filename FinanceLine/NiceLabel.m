//
//  NiceLabel.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-29.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "NiceLabel.h"

@implementation NiceLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib{
  [super awakeFromNib];
  NSString *name = self.small ? @"PTSans-CaptionBold" : @"PTSans-Caption";
  if(self.body) name = @"PTSans-Regular";
  self.font = [UIFont fontWithName:name size: self.font.pointSize];
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
