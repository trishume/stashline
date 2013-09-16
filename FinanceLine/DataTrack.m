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
@synthesize min, max, name;

- (id)init
{
  self = [super init];
  if (self) {
    name = @"";
    // zero data array
    for (NSUInteger i = 0; i <= kMaxMonth; ++i) {
      data[i] = 0.0;
    }
    [self recalc];
  }
  return self;
}

#pragma mark Persistence

- (id)initWithCoder:(NSCoder *)coder {
  DataTrack *t = [self init];
  
  t.name = [coder decodeObjectForKey:@"name"];
  [coder decodeArrayOfObjCType:@encode(double) count:kMaxMonth+1 at:data];
  [t recalc];
  
  return t;
}

- (void) encodeWithCoder:(NSCoder *)coder {
  [coder encodeArrayOfObjCType:@encode(double) count:kMaxMonth+1 at:data];
  [coder encodeObject:self.name forKey:@"name"];
}

#pragma mark Misc

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
  double val = data[month];
  if (val == 0.0) return 0.0;
  if (val < 0.0) {
    return -val / min * maxVal;
  }
  
  return val / max * maxVal;
}

- (double*)dataPtr {
  return data;
}


@end
