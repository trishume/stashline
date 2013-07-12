//
//  FinanceModel.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-12.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "FinanceModel.h"
#include "Constants.h"

@implementation FinanceModel

- (id)init
{
    self = [super init];
    if (self) {
      // default values
      self.growthRate = 0.05;
      self.dividendRate = 0.02;
      self.dividendPeriod = 1;
      
      self.startAmount = 0.0;
      self.startMonth = 0;
      
      self.safeWithdrawalRate = 0.04;
      
      // init arrays
      self.incomeTracks = [NSMutableArray arrayWithCapacity:5];
      self.expenseTracks = [NSMutableArray arrayWithCapacity:5];
      self.stashTrack = [[DataTrack alloc] init];
    }
    return self;
}

- (void)recalc {
  self.retirementMonth = kMaxMonth;
  
  double stash = self.startAmount;
  for (int i = self.startMonth; i <= kMaxMonth; ++i) {
    stash = [self iterateStash:stash forMonth: i];
    [self.stashTrack setValue:stash forMonth:i];
  }
  
  [self.stashTrack recalc];
}

- (double)iterateStash:(double)stash forMonth:(NSUInteger)month {
  double income = [self sumTracks:self.incomeTracks forMonth:month];
  double expenses = [self sumTracks:self.expenseTracks forMonth:month];
  double savings = income - expenses;
  
  // Grow stash and pay dividends.
  stash *= 1.0 + self.growthRate / 12.0;
  if (month % self.dividendPeriod == 0) {
    double thisMonthDividends = self.dividendRate / 12 * self.dividendPeriod;
    stash += stash * thisMonthDividends;
  }
  
  // Savings can be negative, in which case we are withdrawing
  stash += savings;
  
  return stash;
}

- (double)sumTracks:(NSArray*)tracks forMonth:(NSUInteger)month {
  double sum = 0.0;
  for (DataTrack *track in tracks) {
    sum += [track valueAt:month];
  }
  return sum;
}
@end
