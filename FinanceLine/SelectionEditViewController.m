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

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
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
  
  [self updateValueDisplay:average];
  [self.delegate redraw];
}

- (void)updateSelectionAmount:(double)value {
  if (currentSelection == nil || selectedTrack == nil) {
    return;
  }
  
  [self updateValueDisplay:value];
  
  // Set selection
  double *data = [selectedTrack dataPtr];
  for (int i = currentSelection.start; i <= currentSelection.end; ++i)
    data[i] = value;
  [selectedTrack recalc];
  
  // Recalc and render
  [self.delegate updateModel: NO];
}

- (void)textFieldUpdated: (UITextField*)sender {
  
}

// Don't save
- (IBAction)selectionAmountUpdate: (UITextField*)sender {
  [self textFieldUpdated:sender];
}

// Save
- (IBAction)selectionAmountChanged: (UITextField*)sender {
  [self textFieldUpdated:sender];
  [self.delegate updateModel: YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
