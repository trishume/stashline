//
//  ViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineTrackView.h"
#import "LineGraphTrack.h"
#import "AnnuityTrackView.h"
#import "DividerTrackView.h"
#import "Constants.h"

#include <stdlib.h>

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  currentSelection = nil;
  
  // Create model
  model = [[FinanceModel alloc] init];
  DataTrack *incomeTrack = [[DataTrack alloc] init];
  DataTrack *expenseTrack = [[DataTrack alloc] init];
  
  [model.incomeTracks addObject:incomeTrack];
  [model.expenseTracks addObject:expenseTrack];

  // Create test data
  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = model.stashTrack;
  TrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  
  AnnuityTrackView *incomeTrackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  incomeTrackView.data = incomeTrack;
  incomeTrackView.selectionDelegate = self;
  
  AnnuityTrackView *expensesTrackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  expensesTrackView.hue = 0.083;
  expensesTrackView.data = expenseTrack;
  expensesTrackView.selectionDelegate = self;
  
  [self.timeLine addTrack:stashTrack withHeight:150.0];
  [self.timeLine addTrack:timeTrack withHeight:110.0];
  [self addDivider];
  [self.timeLine addTrack:incomeTrackView withHeight:60.0];
  [self addDivider];
  [self.timeLine addTrack:expensesTrackView withHeight:60.0];
  [self addDivider];
}

- (void)addDivider {
  TrackView *divider = [[DividerTrackView alloc] initWithFrame:CGRectZero];
  [self.timeLine addTrack:divider withHeight:2.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
        (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark Selections

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  // clear selection on other track
  if (currentSelection != nil && currentSelection != sel) {
    [currentSelection clear];
  }
  
  currentSelection = sel;
  selectedTrack = track;
  
  if ([currentSelection isEmpty]) {
    [self clearSelection];
    return;
  }
  
  // calculate selection average
  double total = 0.0;
  double *data = [selectedTrack dataPtr];
  for (int i = currentSelection.start; i <= currentSelection.end; ++i)
    total += data[i];
  double average = total / (currentSelection.end - currentSelection.start + 1);
  
  [self updateAmountFields:average];
  [self.timeLine redrawTracks];
}

- (IBAction)clearSelection {
  [currentSelection clear];
  currentSelection = nil;
  selectedTrack = nil;
  
  [self.monthlyCost setText:@""];
  [self.yearlyCost setText:@""];
  [self.dailyCost setText:@""];
  
  [self.timeLine redrawTracks];
}

- (IBAction)expandSelectionToEnd {
  if (currentSelection != nil && currentSelection.start > 0) {
    currentSelection.end = kMaxMonth;
  }
  [self.timeLine redrawTracks];
}

- (NSString *)stringForAmount:(double)amount {
  return [NSString stringWithFormat:@"%.2f", amount];
}

- (void)updateAmountFields:(double)monthlyValue {
  NSString *monthlyString = [self stringForAmount:monthlyValue];
  NSString *yearlyString = [self stringForAmount:monthlyValue*12.0];
  NSString *dailyString = [self stringForAmount:monthlyValue/30.0];
  
  [self.monthlyCost setText:monthlyString];
  [self.yearlyCost setText:yearlyString];
  [self.dailyCost setText:dailyString];
}

- (void)updateSelectionAmount:(double)monthlyValue {
  if (currentSelection == nil || selectedTrack == nil) {
    return;
  }
  
  [self updateAmountFields:monthlyValue];
  
  // Set selection
  double *data = [selectedTrack dataPtr];
  for (int i = currentSelection.start; i <= currentSelection.end; ++i)
    data[i] = monthlyValue;
  [selectedTrack recalc];
  
  // Recalc and render
  [model recalc];
  [self.timeLine redrawTracks];
}

- (double)parseValue: (NSString*)str {
  return [str doubleValue];
}

- (IBAction)selectionAmountChanged: (UITextField*)sender {
  double value = [self parseValue:[sender text]];
  
  // convert to a monthly cost
  if (sender == self.yearlyCost) {
    value /= 12.0;
  } else if(sender == self.dailyCost) {
    value *= 30.0;
  }
  
  [self updateSelectionAmount: value];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

@end
