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

- (void)updateSelectionAmount:(double)monthlyValue {
  
}

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
  
  [self updateValueDisplay:average];
  [self.delegate redraw];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
