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
  
  // Create test data
  DataTrack *testData = [[DataTrack alloc] init];
  double *dataArr = [testData dataPtr];
  for (NSUInteger i = 0; i <= kMaxMonth; ++i)
    dataArr[i] = arc4random_uniform(1000) * 3.5;
  [testData recalc];
  
  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = testData;
  TrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  
  AnnuityTrackView *incomeTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  incomeTrack.data = testData;
  incomeTrack.selectionDelegate = self;
  
  AnnuityTrackView *expensesTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  expensesTrack.hue = 0.083;
  expensesTrack.data = [[DataTrack alloc] init];
  expensesTrack.selectionDelegate = self;
  
  
  [self.timeLine addTrack:stashTrack withHeight:150.0];
  [self.timeLine addTrack:timeTrack withHeight:110.0];
  [self.timeLine addTrack:incomeTrack withHeight:60.0];
  [self.timeLine addTrack:expensesTrack withHeight:60.0];
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
  
  // Render
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
