//
//  FinanceModel.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-12.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "FinanceModel.h"
#include "Constants.h"

#define kGrowthKey @"growthRate"
#define kDividendKey @"dividendRate"
#define kDividendPeriodKey @"dividendPeriod"
#define kStartAmountKey @"startAmount"
#define kBirthYearKey @"birthYear"
#define kSafeWithdrawalKey @"safeWithdrawalRate"
#define kIncomeTracksKey @"incomeTracks"
#define kExpenseTracksKey @"expenseTracks"

@implementation FinanceModel

- (id)init
{
    self = [super init];
    if (self) {
      // default values
      self.growthRate = 0.05;
      self.dividendRate = 0.02;
      self.dividendPeriod = 3;

      self.startAmount = 0.0;
      self.birthYear = [self currentYear];

      self.safeWithdrawalRate = 0.04;

      // init arrays
      self.incomeTracks = [NSMutableArray arrayWithCapacity:5];
      self.expenseTracks = [NSMutableArray arrayWithCapacity:5];
      self.stashTrack = [[DataTrack alloc] init];
      self.statusTrack = [[DataTrack alloc] init];
    }
    return self;
}

#pragma mark Operations

- (void)cutJobAtRetirement {
  [self recalc];

  DataTrack *track = [self.incomeTracks objectAtIndex: 0];
  double *data = [track dataPtr];
  for (int i = self.retirementMonth + 1; i <= kMaxMonth; ++i) {
    data[i] = 0.0;
  }
  [track recalc];

  [self recalc];
}

#pragma mark Persistence

- (id)initWithCoder:(NSCoder *)coder {
  FinanceModel *m = [self init];

  m.growthRate = [coder decodeDoubleForKey:kGrowthKey];
  m.dividendRate = [coder decodeDoubleForKey:kDividendKey];
  m.startAmount = [coder decodeDoubleForKey:kStartAmountKey];
  m.safeWithdrawalRate = [coder decodeDoubleForKey:kSafeWithdrawalKey];

  m.incomeTracks = [coder decodeObjectForKey:kIncomeTracksKey];
  m.expenseTracks = [coder decodeObjectForKey:kExpenseTracksKey];

  m.dividendPeriod = [coder decodeIntegerForKey:kDividendPeriodKey];
  m.birthYear = [coder decodeIntegerForKey:kBirthYearKey];

  [m recalc];

  return m;
}

- (void) encodeWithCoder:(NSCoder *)coder {
  [coder encodeDouble:self.growthRate forKey:kGrowthKey];
  [coder encodeDouble:self.dividendRate forKey:kDividendKey];
  [coder encodeInteger:self.dividendPeriod forKey:kDividendPeriodKey];
  [coder encodeDouble:self.startAmount forKey:kStartAmountKey];
  [coder encodeInteger:self.birthYear forKey:kBirthYearKey];
  [coder encodeDouble:self.safeWithdrawalRate forKey:kSafeWithdrawalKey];
  [coder encodeObject:self.incomeTracks forKey:kIncomeTracksKey];
  [coder encodeObject:self.expenseTracks forKey:kExpenseTracksKey];
}

#pragma mark Calculation

- (NSUInteger)currentYear {
  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                 fromDate:[NSDate date]];
  return [components year];
}

- (NSUInteger)startMonth {
  NSUInteger yearOffset = [self currentYear] - self.birthYear;
  return yearOffset * 12;
}

- (void)recalc {
  self.retirementMonth = 0;

  double stash = self.startAmount;
  for (int i = [self startMonth]; i <= kMaxMonth; ++i) {
    stash = [self iterateStash:stash forMonth: i];
    [self.stashTrack setValue:stash forMonth:i];
  }

  // Retirement is one past the last month we didn't make with investment gains
  self.retirementMonth += 1;

  [self.stashTrack recalc];
}

- (double)iterateStash:(double)stash forMonth:(NSUInteger)month {
  double expenses = [self sumTracks:self.expenseTracks forMonth:month];

  double income = [self sumTracks:self.incomeTracks forMonth:month];
  double savings = income - expenses;

  // Grow stash and pay dividends.
  stash *= 1.0 + self.growthRate / 12.0;
  if (month % self.dividendPeriod == 0) {
    double thisMonthDividends = self.dividendRate / 12 * self.dividendPeriod;
    stash += stash * thisMonthDividends;
  }

  // Savings can be negative, in which case we are withdrawing
  stash += savings;

  // Calculate Status
  double status = 0.0; // normal
  if (stash * (self.safeWithdrawalRate/12.0) >= expenses && expenses != 0.0) {
    status = kStatusSafeWithdraw;
  } else if(stash < 0.0) {
    status = kStatusDebt;
  }
  [self.statusTrack setValue:status forMonth:month];

  // Check retirement month
  if (status != kStatusSafeWithdraw) {
    self.retirementMonth = month;
  }

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
