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
#import "GAI.h"

#include <stdlib.h>
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define kLoadOnStart

#define kDupAlertTitle @"Duplicate As"
#define kNewAlertTitle @"New File"

#define kDefaultIntroPlayed @"ca.thume.IntroPlayed"
#define kDefaultLastFile @"ca.thume.LastFile"

#define kRestoreTimelineZoom @"ca.thume.TimelineMonthSize"
#define kRestoreTimelineScroll @"ca.thume.TimelineStartMonth"

@interface TimelineViewController ()

@end

NSString* SanitizeFilename(NSString* filename)
{
  NSMutableString* stripped = [NSMutableString stringWithCapacity:filename.length];
  for (int t = 0; t < filename.length; ++t)
  {
    unichar c = [filename characterAtIndex:t];
    
    // Only allow a-z, A-Z, 0-9, space, -
    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
        ||  (c >= '0' && c <= '9') || c == ' ' || c == '-')
      [stripped appendFormat:@"%c", c];
    else
      [stripped appendString:@"_"];
  }
  
  // No empty spaces at the beginning or end of the path name (also no dots
  // at the end); that messes up the Windows file system.
  return [stripped stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@implementation TimelineViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.screenName = @"Main";
	// Do any additional setup after loading the view, typically from a nib.
  firstIncomeTrack = nil;
  firstExpensesTrack = nil;
  investTrack = nil;
  
  // Create selection editors
  amountEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"amountEditor"];
  amountEditor.delegate = self;
  amountEditor.view.frame = self.editorContainerView.bounds;
  
  investmentEditor = [self.storyboard instantiateViewControllerWithIdentifier:@"investmentEditor"];
  investmentEditor.delegate = self;
  investmentEditor.view.frame = self.editorContainerView.bounds;
  
  infoController = [self.storyboard instantiateViewControllerWithIdentifier:@"infoController"];
  infoController.view.frame = self.editorContainerView.bounds;
  
  introController = nil;
  
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
  NSString *lastFile = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultLastFile];
  if (lastFile == nil) {
    lastFile = kMainFileName;
  }
  [self openFile:lastFile];
  
  // Play intro on first run
  BOOL introPlayed = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultIntroPlayed];
  if (!introPlayed) {
    [self startIntro];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[GAI sharedInstance] dispatch];
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

//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
//{
//  [coder encodeDouble:self.timeLine.startMonth forKey:kRestoreTimelineScroll];
//  [coder encodeDouble:self.timeLine.monthSize forKey:kRestoreTimelineZoom];
//  [super encodeRestorableStateWithCoder:coder];
//}
//
//- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
//{
//  self.timeLine.startMonth = [coder decodeDoubleForKey:kRestoreTimelineScroll];
//  self.timeLine.monthSize = [coder decodeDoubleForKey:kRestoreTimelineZoom];
//  [self.timeLine redrawTracks];
//  [super decodeRestorableStateWithCoder:coder];
//}

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
  
#ifdef kLoadOnStart
  NSString *path = [self pathForDataFile: name];
  NSLog(@"Loading file %@", path);
  if(path != nil) {
    model = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
  }
#endif
  if (model == nil) {
    model = [self newModel];
    [self saveModelAs:name];
  }

  self.timeLine.model = model;
  [self loadTracks];
  
  self.timeLine.startMonth = (model.startMonth <= 12) ? 192.0 : model.startMonth - 12;
  self.timeLine.monthSize = 5.0;
  
  [self updateDisplays];
  
  [[NSUserDefaults standardUserDefaults] setObject:name forKey:kDefaultLastFile];
}

- (FinanceModel*)newModel {
  @throw @"newModel not implemented";
  return nil;
}

- (void)loadTracks {
  [self.timeLine clearTracks];

  LineGraphTrack *stashTrack = [[LineGraphTrack alloc] initWithFrame:CGRectZero];
  stashTrack.data = model.stashTrack;
  [self.timeLine addTrack:stashTrack withHeight:stashTrackHeight];
  [stashTrack setLabel:@"Savings"];

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
  
  CGFloat timelineHeight = isPhone ? 307.0 : 595.0; // bottom borders subtracted
  if (SYSTEM_VERSION_LESS_THAN(@"7")) {
    timelineHeight -= 20.0;
  }
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
  [firstIncomeTrack setLabel:@"Earn"];

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
  [firstExpensesTrack setLabel:@"Spend"];
  
  investTrack = [[AnnuityTrackView alloc] initWithFrame:CGRectZero];
  investTrack.percentTrack = YES;
  investTrack.data = model.investmentTrack;
  investTrack.hue = 0.566;
  investTrack.selectionDelegate = self;
  [self.timeLine addTrack:investTrack withHeight:annuityTrackHeight];
  [investTrack setLabel:@"Invest"];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [self openFile:kMainFileName];
  }
}

- (NSString *)sanitizeName:(NSString*)name {
  NSString *sanitized = SanitizeFilename(name);
  return [sanitized stringByAppendingString:@".stashLine"];
}

// New file alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  UITextField *fileNameField = [alertView textFieldAtIndex:0];
  NSString *fileName = [self sanitizeName:fileNameField.text];
  
  if ([alertView.title isEqualToString:kDupAlertTitle]) {
    [self saveModelAs:fileName];
  }
  [self openFile:fileName];
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

- (IBAction)changeLabelMode:(UIButton *)sender {
  if (self.timeLine.labelMult == 1.0) {
    self.timeLine.labelMult = 12.0;
    [sender setTitle:@"Yearly Labels" forState:UIControlStateNormal];
  } else if(self.timeLine.labelMult == 0.0) {
    self.timeLine.labelMult = 1.0;
    [sender setTitle:@"Monthly Labels" forState:UIControlStateNormal];
  } else {
    self.timeLine.labelMult = 0.0;
    [sender setTitle:@"No Labels" forState:UIControlStateNormal];
  }
  [self.timeLine redrawTracks];
}

- (IBAction)startIntro {
  if (introController == nil) {
    introController = [self.storyboard instantiateViewControllerWithIdentifier:@"introController"];
    introController.view.frame = self.view.bounds;
    [introController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:introController.view];
  }
  [introController startIntro];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(introDone:) name:@"ca.thume.IntroViewDone" object:introController];
}

- (void)introDone: (NSNotification*)not {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultIntroPlayed];
  NSLog(@"Finished Intro\n");
  [introController.view removeFromSuperview];
  introController = nil;
}

#pragma mark I Am

- (IBAction)iAmFieldEditBegan:(ScrubbableTextView*)sender {
  if (sender == self.ageField) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.ModelAgeChanged" object:self];
  } else if (sender == self.savingsField) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.ModelSavingsChanged" object:self];
  }
}

- (IBAction)iAmFieldUpdated: (ScrubbableTextView*)sender {
  if ([sender.text isEqualToString:@""]) return;
  double value = [sender parseAndUpdate];
  
  if (sender == self.ageField) {
    model.startMonth = value * 12;
    [self.timeLine setStartMonth:value * 12 - 10];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.ModelAgeChanged" object:self];
  } else if (sender == self.savingsField) {
    model.startAmount = value;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.ModelSavingsChanged" object:self];
  }
  
  [self updateModel: NO];
}

- (IBAction)iAmFieldChanged: (ScrubbableTextView*)sender {
  [self iAmFieldUpdated:sender];
  [self updateModel: YES];
}


#pragma mark Selections

- (void)setSelectionName:(NSString*)label andColor:(UIColor*)color {
  self.selectedLabel.text = label;
  self.selectedLabel.textColor = color;
}

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
    [self setSelectionName: @"investing" andColor:[UIColor colorWithHue:0.566 saturation:0.778 brightness:0.725 alpha:1.000]];
  } else {
    [self swapInEditor:amountEditor];
    if ([track.name isEqualToString:@"Income"]) {
      [self setSelectionName:@"earning" andColor:[UIColor colorWithHue:0.468 saturation:0.620 brightness:0.702 alpha:1.000]];
    } else {
      [self setSelectionName:@"spending" andColor:[UIColor colorWithHue:0.077 saturation:0.841 brightness:0.886 alpha:1.000]];
    }
    
  }
  
  if (self.selectDivider) {
    [self.selectDivider setHasSelection:YES];
  }
  if(self.trackSelectors) self.trackSelectors.hidden = YES;
  self.selectActions.hidden = NO;
  [selectEditor setSelection:sel onTrack:track];
}

- (IBAction)deselect {
  if(selectEditor) {
    [selectEditor clearSelection];
  }
  [self swapInEditor:infoController];
  [self setSelectionName:@"planning" andColor:[UIColor colorWithHue:0.785 saturation:0.511 brightness:0.714 alpha:1.000]];
  
  if(self.selectDivider) [self.selectDivider setHasSelection:NO];
  self.selectActions.hidden = YES;
  if(self.trackSelectors) self.trackSelectors.hidden = NO;
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
  if(selectEditor) {
    [selectEditor updateSelectionAmount:0.0];
    [self updateModel:YES];
  }
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
