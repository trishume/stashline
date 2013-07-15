//
//  DataTrack.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface DataTrack : NSObject <NSCoding> {
  double data[kMaxMonth + 1];
}

- (id) init;
- (double)valueAt:(NSUInteger)month;
- (void)setValue:(double)value forMonth:(NSUInteger)month;
- (double)valueFor:(NSUInteger)month scaledTo:(double)maxVal;
- (double*)dataPtr;
- (void) recalc;

@property (readonly) double max;
@property (readonly) double min;
@property (nonatomic, strong) NSString *name;

@end
