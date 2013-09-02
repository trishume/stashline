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
//#define kLoadOnStart

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self.fileNameField setText:@"Main"];
  
  // Create selection editors
  amountEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"amountEditor"];
  amountEditor.delegate = self;
  amountEditor.view.frame = self.editorContainerView.bounds;
  
  investmentEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"investmentEditor"];
  investmentEditor.delegate = self;
  investmentEditor.view.frame = self.editorContainerView.bounds;
  
  selectEditor = nil;
  
  // I am view
  NSNumberFormatter *amountFormatter = [ScrubbableTextView amountFormatter];
  self.savingsField.formatter = amountFormatter;
  self.savingsField.stepVal = 1000.0;
  [self.savingsField setValue:0.0];
  
  NSNumberFormatter *yearFormatter = [[NSNumberFormatter alloc] init];
  yearFormatter.numberStyle = NSNumberFormatterDecimalStyle;
  self.ageField.formatter = yearFormatter;
  self.ageField.stepVal = 1.0;
  self.ageField.maxVal = 98;
  [self.ageField setValue:0.0];

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

- (void)loadTracks {
  [self.timeLine clearTracks];

  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = model.stashTrack;
  stashTrack.model = model;
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
  
  AnnuityTrackView *investTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  investTrack.data = model.investmentTrack;
  investTrack.hue = 0.566;
  investTrack.selectionDelegate = self;
  [self.timeLine addTrack:investTrack withHeight:kAnnuityTrackHeight];
  [self addDivider];
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

#pragma mark I Am

- (IBAction)iAmFieldChanged: (ScrubbableTextView*)sender {
  if ([sender.text isEqualToString:@""]) return;
  double value = [sender parseValue];
  [sender setValue:value];
  
  if (sender == self.ageField) {
    model.startAge = value;
  } else if (sender == self.savingsField) {
    model.startAmount = value;
  }
  
  [self updateModel];
}


#pragma mark Selections

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  // clear selection on other track
  if (selectEditor != nil && selectEditor.currentSelection != nil && selectEditor.currentSelection != sel) {
    [selectEditor.currentSelection clear];
  }
  // Swap view if necessary
  if ([track.name isEqualToString:@"Investment"]) {
    if(investmentEditor != selectEditor) {
      selectEditor = investmentEditor;
      [amountEditor.view removeFromSuperview];
      [self.editorContainerView addSubview:selectEditor.view];
    }
  } else {
    if(selectEditor != amountEditor) {
      selectEditor = amountEditor;
      [investmentEditor.view removeFromSuperview];
      [self.editorContainerView addSubview:selectEditor.view];
    }
  }
  
  [selectEditor setSelection:sel onTrack:track];
}

- (IBAction)clearSelection {
  if(selectEditor) {
    [selectEditor clearSelection];
    [selectEditor.view removeFromSuperview];
    selectEditor = nil;
  }
}

- (IBAction)expandSelectionToEnd {
  if(selectEditor) [selectEditor expandSelectionToEnd];
}

- (IBAction)zeroSelection {
  if(selectEditor) [selectEditor updateSelectionAmount:0.0];
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
  [super viewDidUnload];
}
@end
