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
#import "StatusTrackView.h"
#import "Constants.h"
#import "AmountEditController.h"

#include <stdlib.h>

#define kDefaultIncomeTracks 2
#define kDefaultExpenseTracks 3
#define kAnnuityTrackHeight 50.0
#define kLoadOnStart

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self.fileNameField setText:@"Main"];
  
  // Create selection editors
  selectEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"amountEditor"];
  selectEditor.delegate = self;
  selectEditor.view.frame = self.editorContainerView.bounds;
  [self.editorContainerView addSubview:selectEditor.view];

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

  NSString *fileName = [self.fileNameField text];
  if([fileName isEqualToString:@""]) return nil;
  fileName = [fileName stringByAppendingString:@".stashLine"];

  return [folder stringByAppendingPathComponent: fileName];
}

- (void)saveModel {
  NSString *path = [self pathForDataFile];
  if(path != nil)
    [NSKeyedArchiver archiveRootObject:model toFile: path];
}

- (void)loadModel {
#ifdef kLoadOnStart
  NSString *path = [self pathForDataFile];
  if(path != nil) {
    model = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
  }
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

  TimelineTrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  timeTrack.status = model.statusTrack;
  [self.timeLine addTrack:timeTrack withHeight:100.0];

  [self addDivider];

  for (DataTrack *track in model.incomeTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:kAnnuityTrackHeight];
    [self addDivider];
  }

  for (DataTrack *track in model.expenseTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.hue = 0.083;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:kAnnuityTrackHeight];
    [self addDivider];
  }

  [self updateParameterFields];
}

#pragma mark File Management

- (IBAction)loadFile {
  [self loadModel];
}

#pragma mark Operations

- (IBAction)cutJobAtRetirement {
  [model cutJobAtRetirement];
  [self.timeLine redrawTracks];
  [self saveModel];
}

- (IBAction)aboutMe {
  NSURL *url = [NSURL URLWithString:@"http://thume.ca/"];
  [[UIApplication sharedApplication] openURL:url];
}

#pragma mark Investment parameters

- (NSString*)stringForAmount:(double)v {
  return [NSString stringWithFormat:@"%.2f",v];
}

- (void)updateParameterField:(UITextField*)field toPercent:(double)value {
  NSString *str = [self stringForAmount:value * 100.0];
  [field setText:str];
}

- (void)updateParameterFields {
  [self updateParameterField:self.growthRateField toPercent:model.growthRate];
  [self updateParameterField:self.dividendRateField toPercent:model.dividendRate];
  [self updateParameterField:self.safeWithdrawalField toPercent:model.safeWithdrawalRate];
}

- (double)parseValue: (NSString*)str {
  return [str doubleValue];
}

- (IBAction)parameterFieldChanged:(UITextField*)sender {
  double value = [self parseValue:[sender text]] / 100.0;

  if (sender == self.safeWithdrawalField) {
    model.safeWithdrawalRate = value;
  } else if(sender == self.dividendRateField) {
    model.dividendRate = value;
  } else if(sender == self.growthRateField) {
    model.growthRate = value;
  }

  [self updateParameterFields];
  [model recalc];
  [self.timeLine redrawTracks];
  [self saveModel];
}

#pragma mark Selections

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  // TODO decide on the correct selection editor
  [selectEditor setSelection:sel onTrack:track];
}

- (IBAction)clearSelection {
  [selectEditor clearSelection];
}

- (IBAction)expandSelectionToEnd {
  [selectEditor expandSelectionToEnd];
}

- (IBAction)zeroSelection {
  [selectEditor updateSelectionAmount:0.0];
}

- (void)updateModel {
  [model recalc];
  [self.timeLine redrawTracks];
  [self saveModel];
}

- (void)redraw {
  [self.timeLine redrawTracks];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (void)viewDidUnload {
  [self setGrowthRateField:nil];
  [self setDividendRateField:nil];
  [self setSafeWithdrawalField:nil];
  [super viewDidUnload];
}
@end
