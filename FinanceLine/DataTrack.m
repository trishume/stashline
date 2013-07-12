//
//  DataTrack.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "DataTrack.h"
#include "Constants.h"

@implementation DataTrack
@synthesize min, max;

- (id)init
{
  self = [super init];
  if (self) {
    // zero data array
    for (NSUInteger i = 0; i <= kMaxMonth; ++i) {
      data[i] = 0.0;
    }
    [self recalc];
  }
  return self;
}

- (void) recalc {
  min = max = data[0];
  for (NSUInteger i = 0; i <= kMaxMonth; ++i) {
    double x = data[i];
    if (x > max) max = x;
    if (x < min) min = x;
  }
}

- (double)valueAt:(NSUInteger)month {
  return data[month];
}

- (void)setValue:(double)value forMonth:(NSUInteger)month {
  data[month] = value;
}

- (double)valueFor:(NSUInteger)month scaledTo:(double)maxVal {
  if (data[month] == 0.0) return 0.0;
  double swing = max - min;
  return (data[month] - min) / swing * maxVal;
}

- (double*)dataPtr {
  return data;
}


@end
