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
  
  // Create test data
  DataTrack *testData = [[DataTrack alloc] init];
  CGFloat *dataArr = [testData dataPtr];
  for (NSUInteger i = 0; i <= kMaxMonth; ++i)
    dataArr[i] = arc4random_uniform(1000) * 3.5;
  [testData recalc];
  
  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = testData;
  TrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  AnnuityTrackView *incomeTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  incomeTrack.data = testData;
  
  
  [self.timeLine addTrack:stashTrack withHeight:150.0];
  [self.timeLine addTrack:timeTrack withHeight:110.0];
  [self.timeLine addTrack:incomeTrack withHeight:60.0];
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

@end
