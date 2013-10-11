//
//  IPadTimelineViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "IPadTimelineViewController.h"

#define kDefaultIncomeTracks 2
#define kDefaultExpenseTracks 3

@interface IPadTimelineViewController ()

@end

@implementation IPadTimelineViewController

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
  // Set constants
  stashTrackHeight = 150.0;
  timelineTrackHeight = 100.0;
  isPhone = NO;
  filesPop = nil;
  
  self.trackSelectors.frame = self.selectActions.frame;
  
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (FinanceModel*)newModel {
  FinanceModel *m = [[FinanceModel alloc] init];
  
  for (int i = 0; i < kDefaultIncomeTracks; ++i) {
    DataTrack *track = [[DataTrack alloc] init];
    track.name = @"Income";
    [m.incomeTracks addObject:track];
  }
  
  for (int i = 0; i < kDefaultExpenseTracks; ++i) {
    DataTrack *track = [[DataTrack alloc] init];
    track.name = @"Expenses";
    [m.expenseTracks addObject:track];
  }
  
  DataTrack *investmentTrack = [[DataTrack alloc] init];
  investmentTrack.name = @"Investment";
  m.investmentTrack = investmentTrack;
  
  return m;
}

- (void)openFile:(NSString *)fileName {
  if (filesPop != nil) {
    [filesPop dismissPopoverAnimated:YES];
    filesPop = nil;
  }
  [super openFile:fileName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"filePopover"])
  {
    UIStoryboardPopoverSegue *pop = (UIStoryboardPopoverSegue*)segue;
    filesPop = pop.popoverController;
    UINavigationController *nav = (UINavigationController*)filesPop.contentViewController;
    FilesViewController *fileCon = (FilesViewController*)nav.topViewController;
    fileCon.fileDelegate = self;
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
