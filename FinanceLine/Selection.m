//
//  Selection.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "Selection.h"
#import "Constants.h"

@implementation Selection
@synthesize start, end;

- (id)init
{
    self = [super init];
    if (self) {
      [self clear];
    }
    return self;
}

- (void)clear {
  start = -1;
  end = -2;
}

- (void)selectFrom:(NSUInteger)firstMonth to:(NSUInteger)secondMonth {
  start = MIN(firstMonth, secondMonth);
  end = MAX(firstMonth, secondMonth);
  end = MIN(end, kMaxMonth);
}

- (BOOL)includes:(NSUInteger)month {
  return month >= start && month <= end;
}

- (BOOL)isEmpty {
  return start > end;
}

@end
