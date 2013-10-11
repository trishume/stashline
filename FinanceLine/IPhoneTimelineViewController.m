//
//  IPhoneTimelineViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "IPhoneTimelineViewController.h"
#define kTimelineOffset 159

@interface IPhoneTimelineViewController ()

@end

@implementation IPhoneTimelineViewController

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
  stashTrackHeight = 90.0;
  timelineTrackHeight = 70.0;
  isPhone = YES;
  self.selectDivider = nil;
  
  // Set up panels
  // TODO hide on start so no flicker possibility
  self.editorPanel.hidden = YES;
  [self.editorPanel removeFromSuperview];
  [self.leftPanelView addSubview:self.editorPanel];
  // Because starts in portrait orientation can't use other thing.
  self.editorPanel.frame = CGRectMake(0, 0, 154, 320);
  
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  [self setPanelVisible:YES];
}

- (FinanceModel*)newModel {
  FinanceModel *m = [[FinanceModel alloc] init];
  
  DataTrack *track = [[DataTrack alloc] init];
  track.name = @"Income";
  [m.incomeTracks addObject:track];
  
  DataTrack *track2 = [[DataTrack alloc] init];
  track2.name = @"Expenses";
  [m.expenseTracks addObject:track2];
  
  DataTrack *investmentTrack = [[DataTrack alloc] init];
  investmentTrack.name = @"Investment";
  m.investmentTrack = investmentTrack;
  
  return m;
}

- (void)setSelectionName:(NSString *)label andColor:(UIColor*)color {
  self.selectedLabel.text = [label capitalizedString];
  self.editorTitleBg.backgroundColor = color;
  [self.editorTitleBg setNeedsDisplay];
}

#pragma mark File Modal

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"fileModal"])
  {
    UIStoryboardSegue *modal = (UIStoryboardSegue*)segue;
    filesModal = modal.destinationViewController;
    FilesViewController *fileCon = (FilesViewController*)filesModal.topViewController;
    fileCon.fileDelegate = self;
  }
}

#pragma mark Panel Control

- (IBAction)toggleLeftPanel {
  [self setPanelVisible:self.leftPanelView.hidden];
}

- (void)setPanelVisible:(BOOL)visible {
  self.leftPanelView.hidden = !visible;
  
  if (!visible) {
    self.timeLine.frame = self.view.bounds;
  } else {
    self.timeLine.frame = CGRectMake(kTimelineOffset, 0.0, self.view.bounds.size.width - kTimelineOffset, self.view.bounds.size.height);
  }
  [self redraw];
}

- (void)showEditorPanel {
  self.mainPanel.hidden = YES;
  self.editorPanel.hidden = NO;
}

- (void)showMainPanel {
  self.mainPanel.hidden = NO;
  self.editorPanel.hidden = YES;
}

- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track {
  [self showEditorPanel];
  [super setSelection:sel onTrack:track];
}

- (void)deselect {
  [self showMainPanel];
  [super deselect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
