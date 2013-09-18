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

#define kLoadOnStart

#define kDupAlertTitle @"Duplicate As"
#define kNewAlertTitle @"New File"

@interface TimelineViewController ()

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  firstIncomeTrack = nil;
  firstExpensesTrack = nil;
  investTrack = nil;
  filesPop = nil;
  
  // Create selection editors
  amountEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"amountEditor"];
  amountEditor.delegate = self;
  amountEditor.view.frame = self.editorContainerView.bounds;
  
  investmentEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"investmentEditor"];
  investmentEditor.delegate = self;
  investmentEditor.view.frame = self.editorContainerView.bounds;
  
  introController = [self.storyboard instantiateViewControllerWithIdentifier:@"introController"];
  introController.view.frame = self.editorContainerView.bounds;
  
  selectEditor = nil;
  if (self.selectDivider) self.selectDivider.delegate = self;
  [self deselect];
  
  // I am view
  amountFormatter = [ScrubbableTextView amountFormatter];
  self.savingsField.formatter = amountFormatter;
  self.savingsField.stepVal = 1000.0;
  [self.savingsField setValue:0.0];
  
  yearFormatter = [[NSNumberFormatter alloc] init];
  yearFormatter.numberStyle = NSNumberFormatterDecimalStyle;
  self.ageField.formatter = yearFormatter;
  self.ageField.stepVal = 1.0;
  self.ageField.maxVal = 98;
  [self.ageField setValue:20.0];

  // Load or create model
  model = nil;
  [self openFile:kMainFileName];
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

#pragma mark Persistence

- (NSString *)pathForDataFile:(NSString*)fileName
{
  if(fileName == nil || [fileName isEqualToString:@""]) return nil;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];

  NSString *folder = @"~/Documents";
  folder = [folder stringByExpandingTildeInPath];

  if ([fileManager fileExistsAtPath:folder] == NO){
    [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
  }

  return [folder stringByAppendingPathComponent: fileName];
}

- (void)saveModelAs:(NSString*)fileName {
  NSString *path = [self pathForDataFile: fileName];
  if(path != nil)
    [NSKeyedArchiver archiveRootObject:model toFile: path];
}

- (void)openFile: (NSString*)name {
  if(name == nil || [name isEqualToString:@""]) return;
  [self deselect];
  currentFileName = name;
  self.fileNameLabel.text = [name stringByDeletingPathExtension];
  
  if (filesPop != nil) {
    [filesPop dismissPopoverAnimated:YES];
    filesPop = nil;
  }
  
#ifdef kLoadOnStart
  NSString *path = [self pathForDataFile: name];
  if(path != nil) {
    model = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
  }
#endif
  if (model == nil) {
    model = [self newModel];
  }

  [self loadTracks];
  [self updateDisplays];
}

- (FinanceModel*)newModel {
  @throw @"newModel not implemented";
  return nil;
}

- (void)loadTracks {
  [self.timeLine clearTracks];

  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = model.stashTrack;
  stashTrack.model = model;
  [self.timeLine addTrack:stashTrack withHeight:stashTrackHeight];

  TimelineTrackView *timeTrack = [[TimelineTrackView alloc] initWithFrame:CGRectZero];
  timeTrack.status = model.statusTrack;
  if (isPhone) {
    timeTrack.monthTickLength = 7.0;
    timeTrack.yearTickLength = 14.0;
    timeTrack.lineGap = 15.0;
    timeTrack.yearFont = [UIFont boldSystemFontOfSize:18.0];
  }
  [self.timeLine addTrack:timeTrack withHeight:timelineTrackHeight];

  [self addDivider];
  
  CGFloat timelineHeight = isPhone ? 295.0 : 575.0; // bottom borders subtracted
  CGFloat allAnnuityTracks = timelineHeight - self.timeLine.nextTrackTop;
  CGFloat annuityTrackCount = [model.incomeTracks count] + [model.expenseTracks count] + 1;
  CGFloat annuityTrackHeight = allAnnuityTracks / annuityTrackCount;

  firstIncomeTrack = nil;
  for (DataTrack *track in model.incomeTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:annuityTrackHeight];
    [self addDivider];
    
    if (firstIncomeTrack == nil)
      firstIncomeTrack = trackView;
  }

  firstExpensesTrack = nil;
  for (DataTrack *track in model.expenseTracks) {
    AnnuityTrackView *trackView = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
    trackView.data = track;
    trackView.hue = 0.083;
    trackView.selectionDelegate = self;
    [self.timeLine addTrack:trackView withHeight:annuityTrackHeight];
    [self addDivider];
    
    if (firstExpensesTrack == nil)
      firstExpensesTrack = trackView;
  }
  
  investTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  investTrack.data = model.investmentTrack;
  investTrack.hue = 0.566;
  investTrack.selectionDelegate = self;
  [self.timeLine addTrack:investTrack withHeight:annuityTrackHeight];
  [self addDivider];
}

- (void)updateDisplays {
  NSInteger retirementYear = model.retirementMonth / 12;
  self.retireAgeLabel.text = [yearFormatter stringFromNumber:[NSNumber numberWithInteger:retirementYear]];
  double retirementSavings = [model.stashTrack valueAt:model.retirementMonth];
  self.retireSavingsLabel.text = [amountFormatter stringFromNumber:[NSNumber numberWithDouble:retirementSavings]];
  
  [self.ageField setValue:model.startMonth/12];
  [self.savingsField setValue:model.startAmount];
}

#pragma mark File Operations

- (void)newFile {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kNewAlertTitle message:@"Enter the file name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
  [alertView show];
}

- (void)duplicateFile {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kDupAlertTitle message:@"Enter the file name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
  [alertView show];
}

- (void)deleteFile:(NSString*)name {
  // For error information
  NSError *error;
  
  // Create file manager
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  
  // Point to Document directory
  NSString *documentsDirectory = [NSHomeDirectory()
                                  stringByAppendingPathComponent:@"Documents"];
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
  
  // Attempt to delete the file at filePath
  if ([fileMgr removeItemAtPath:filePath error:&error] != YES)
    NSLog(@"Unable to delete file: %@", [error localizedDescription]);
  
  // If we deleted the file we were editing, load main
  if ([currentFileName isEqualToString:name]) {
    [self openFile:kMainFileName];
  }
}

// New file alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  UITextField *fileNameField = [alertView textFieldAtIndex:0];
  
  if ([alertView.title isEqualToString:kDupAlertTitle]) {
    [self saveModelAs:fileNameField.text];
  }
  [self openFile:fileNameField.text];
}

#pragma mark Operations

- (IBAction)cutJobAtRetirement {
  [model cutJobAtRetirement];
  [self updateModel: YES];
}

- (IBAction)aboutMe {
  NSURL *url = [NSURL URLWithString:@"http://thume.ca/"];
  [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)showInfoOverlay {
  self.infoOverlayView.hidden = NO;
}

- (IBAction)hideInfoOverlay {
  self.infoOverlayView.hidden = YES;
}

#pragma mark I Am

- (IBAction)iAmFieldUpdated: (ScrubbableTextView*)sender {
  if ([sender.text isEqualToString:@""]) return;
  double value = [sender parseValue];
  
  if (sender == self.ageField) {
    model.startMonth = value * 12;
  } else if (sender == self.savingsField) {
    model.startAmount = value;
  }
  
  [self updateModel: NO];
}

- (IBAction)iAmFieldChanged: (ScrubbableTextView*)sender {
  [self iAmFieldUpdated:sender];
  [self updateModel: YES];
}


#pragma mark Selections

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  // if empty, deselect all
  if ([sel isEmpty]) {
    [self deselect];
    return;
  }
  // clear selection on other track
  if (selectEditor != nil && selectEditor.currentSelection != nil && selectEditor.currentSelection != sel) {
    [selectEditor.currentSelection clear];
  }
  // Swap view if necessary
  if ([track.name isEqualToString:@"Investment"]) {
    [self swapInEditor:investmentEditor];
    self.selectedLabel.text = @"investing at";
    self.selectedLabel.textColor = [UIColor colorWithHue:0.566 saturation:0.778 brightness:0.725 alpha:1.000];
  } else {
    [self swapInEditor:amountEditor];
    if ([track.name isEqualToString:@"Income"]) {
      self.selectedLabel.text = @"earning";
      self.selectedLabel.textColor = [UIColor colorWithHue:0.468 saturation:0.620 brightness:0.702 alpha:1.000];
    } else {
      self.selectedLabel.text = @"spending";
      self.selectedLabel.textColor = [UIColor colorWithHue:0.077 saturation:0.841 brightness:0.886 alpha:1.000];
    }
    
  }
  
  if (self.selectDivider) {
    [self.selectDivider setHasSelection:YES];
  }
  self.trackSelectors.hidden = YES;
  self.selectActions.hidden = NO;
  [selectEditor setSelection:sel onTrack:track];
}

- (IBAction)deselect {
  if(selectEditor) {
    [selectEditor clearSelection];
  }
  [self swapInEditor:introController];
  self.selectedLabel.text = @"planning";
  self.selectedLabel.textColor = [UIColor colorWithHue:0.785 saturation:0.511 brightness:0.714 alpha:1.000];
  
  if(self.selectDivider) [self.selectDivider setHasSelection:NO];
  self.selectActions.hidden = YES;
  self.trackSelectors.hidden = NO;
}

- (void)swapInEditor:(UIViewController*)editor {
  // Clean out the old
  if (currentEditor == editor) return;
  [currentEditor.view removeFromSuperview];
  
  // Put in the new
  currentEditor = editor;
  [self.editorContainerView addSubview:currentEditor.view];
  
  if([editor isKindOfClass:[SelectionEditViewController class]]) {
    selectEditor = (SelectionEditViewController*)editor;
  } else {
    selectEditor = nil;
  }
}

- (IBAction)expandSelectionToEnd {
  if(selectEditor) [selectEditor expandSelectionToEnd];
}

- (IBAction)zeroSelection {
  if(selectEditor) [selectEditor updateSelectionAmount:0.0];
}

- (IBAction)selectIncome {
  [firstIncomeTrack selectFrom:model.startMonth to:kMaxMonth];
}

- (IBAction)selectExpenses {
  [firstExpensesTrack selectFrom:model.startMonth to:kMaxMonth];
}

- (IBAction)selectInvestment {
  [investTrack selectFrom:model.startMonth to:kMaxMonth];
}

- (void)updateModel: (BOOL)save {
  [model recalc];
  [self.timeLine redrawTracks];
  [self updateDisplays];
  if (save) {
    [self saveModelAs:currentFileName];
  }
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
