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

#define kDefaultIncomeTracks 2
#define kDefaultExpenseTracks 2
//#define kLoadOnStart

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  currentSelection = nil;
  
  // Load or create model
  model = nil;
  [self loadModel];
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

#pragma mark Persistence

- (NSString *) pathForDataFile
{
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSString *folder = @"~/Documents";
  folder = [folder stringByExpandingTildeInPath];

  if ([fileManager fileExistsAtPath:folder] == NO){
    [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
  }

  NSString *fileName = @"WhatNow.taskStore";
  return [folder stringByAppendingPathComponent: fileName];
}

- (void)saveModel {
  [NSKeyedArchiver archiveRootObject:model toFile: [self pathForDataFile]];
}

- (void)loadModel {
#ifdef kLoadOnStart
  model = [NSKeyedUnarchiver unarchiveObjectWithFile: [self pathForDataFile]];
#endif
  if (model == nil) {
    model = [self newModel];
  }
  
  [self loadTracks];
}

- (FinanceModel*)newModel {
  FinanceModel *m = [[FinanceModel alloc] init];
  
  for (int i = 0; i < kDefaultIncomeTracks; ++i) {
    DataTrack *track = [[DataTrack alloc] init];
    [m.incomeTracks addObject:track];
  }
  
  for (int i = 0; i < kDefaultExpenseTracks; ++i) {
    DataTrack *track = [[DataTrack alloc] init];
    [m.expenseTracks addObject:track];
  }
  
  return m;
}

- (void)loadTracks {
  [self.timeLine clearTracks];
  
  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = model.stashTrack;
  [self.timeLine addTrack:stashTrack withHeight:150.0];
  
  TrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  [self.timeLine addTrack:timeTrack withHeight:110.0];
  
  [self addDivider];
  
  for (DataTrack *track in model.incomeTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:60.0];
    [self addDivider];
  }
  
  for (DataTrack *track in model.expenseTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.hue = 0.083;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:60.0];
    [self addDivider];
  }
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

- (void)setAmount:(double)amount forField:(UITextField*)field {
  NSString *str = [self stringForAmount:amount];
  [field setText:str];
}

- (void)updateAmountFields:(double)monthlyValue {
  [self setAmount:monthlyValue forField:self.monthlyCost];
  [self setAmount:monthlyValue*12.0 forField:self.yearlyCost];
  [self setAmount:monthlyValue/30.0 forField:self.dailyCost];
  [self setAmount:monthlyValue/20.0 forField:self.workDailyCost];
  [self setAmount:monthlyValue/160.0 forField:self.workHourlyCost];
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
  [self saveModel];
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
  } else if(sender == self.workDailyCost) {
    value *= 5.0*4.0;
  } else if(sender == self.workHourlyCost) {
    value *= 40*4.0;
  }
  
  [self updateSelectionAmount: value];
}

- (IBAction)zeroSelection {
  [self updateSelectionAmount:0.0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

@end
