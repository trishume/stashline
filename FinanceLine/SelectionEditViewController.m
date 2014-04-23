//
//  SelectionEditViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-09.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "SelectionEditViewController.h"

@interface SelectionEditViewController ()

@end

@implementation SelectionEditViewController

@synthesize currentSelection, selectedTrack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	// Do any additional setup after loading the view.
  currentSelection = nil;
  [self clearSelection];
}

- (void)clearSelection {
  if(currentSelection) [currentSelection clear];
  currentSelection = nil;
  selectedTrack = nil;
  [self.delegate redraw];
}

- (void)expandSelectionToEnd {
  if (currentSelection != nil && currentSelection.start > 0) {
    currentSelection.end = kMaxMonth;
  }
  [self.delegate redraw];
}

- (void)updateValueDisplay:(double)monthlyValue {
  
}

- (double)calcSelectionValue {
  double total = 0.0;
  double *data = [selectedTrack dataPtr];
  for (NSUInteger i = currentSelection.start; i <= currentSelection.end; ++i)
    total += data[i];
  double average = total / (currentSelection.end - currentSelection.start + 1);
  return average;
}

- (void)updateSelectionDisplay {
  if (currentSelection == nil) {
    return;
  }
  // calculate selection average
  double average = [self calcSelectionValue];
  
  [self updateValueDisplay:average];
  [self.delegate redraw];
}

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  currentSelection = sel;
  selectedTrack = track;
  
  if ([currentSelection isEmpty]) {
    [self clearSelection];
    return;
  }
  
  [self updateSelectionDisplay];
}

- (void)updateSelectionAmount:(double)value {
  if (currentSelection == nil || selectedTrack == nil) {
    return;
  }
  
  [self updateValueDisplay:value];
  
  // Set selection
  double *data = [selectedTrack dataPtr];
  for (NSUInteger i = currentSelection.start; i <= currentSelection.end; ++i)
    data[i] = value;
  [selectedTrack recalc];
  
  // Recalc and render
  [self.delegate updateModel: NO];
}

- (double)convertValue: (double)val forField: (ScrubbableTextView*)sender {
  return val;
}

- (void)textFieldUpdated: (ScrubbableTextView*)sender {
  if (![sender validValue]) {
    [self updateSelectionDisplay];
    return;
  }
  double value = [sender parseAndUpdate];
  
  value = [self convertValue:value forField: sender];
  
  [self updateSelectionAmount: value];
}

- (IBAction)selectionFieldSelected:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.SelectionEditAmountChanging" object:self];
}

// Don't save
- (IBAction)selectionAmountUpdate: (UITextField*)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.SelectionEditAmountChanging" object:self];
  [self textFieldUpdated:sender];
}

// Save
- (IBAction)selectionAmountChanged: (UITextField*)sender {
  [self textFieldUpdated:sender];
  [self.delegate updateModel: YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.SelectionEditAmountChanged" object:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
