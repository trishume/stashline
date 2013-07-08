//
//  DataTrack.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface DataTrack : NSObject {
  CGFloat data[kMaxMonth + 1];
}

- (id) init;
- (CGFloat)valueAt:(NSUInteger)month;
- (CGFloat)valueFor:(NSUInteger)month scaledTo:(CGFloat)maxVal;
- (CGFloat*)dataPtr;
- (void) recalc;

@property (readonly) CGFloat max;
@property (readonly) CGFloat min;

@end
