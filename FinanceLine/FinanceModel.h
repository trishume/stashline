//
//  FinanceModel.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-12.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataTrack.h"

@interface FinanceModel : NSObject <NSCoding>

- (id) init;
- (void) recalc;
- (void)cutJobAtRetirement;

// Inputs
@property (nonatomic) double growthRate;
@property (nonatomic) double dividendRate;
@property (nonatomic) NSUInteger dividendPeriod;

@property (nonatomic) double startAmount;
@property (nonatomic) NSUInteger birthYear;

@property (nonatomic) double safeWithdrawalRate;

@property (nonatomic, strong) NSMutableArray *incomeTracks;
@property (nonatomic, strong) NSMutableArray *expenseTracks;

// Outputs
@property (nonatomic, strong) DataTrack *stashTrack;
@property (nonatomic, strong) DataTrack *statusTrack;
@property (nonatomic) NSUInteger retirementMonth;

@end
