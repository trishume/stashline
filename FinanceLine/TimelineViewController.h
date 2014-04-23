//
//  ViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-06-18.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimelineView.h"
#import "AnnuityTrackView.h"
#import "SelectionEditViewController.h"
#import "Selection.h"
#import "DataTrack.h"
#import "FinanceModel.h"
#import "ScrubbableTextView.h"
#import "SelectDividerView.h"
#import "FilesViewController.h"
#import "IntroViewController.h"
#import "GAITrackedViewController.h"
#import "HelpViewController.h"

@interface TimelineViewController : GAITrackedViewController <TrackSelectionDelegate, HelpViewDelegate, UITextFieldDelegate, SelectionEditorDelegate, SelectDividerDelegate, FilesControllerDelegate, UIAlertViewDelegate> {
  SelectionEditViewController *amountEditor;
  SelectionEditViewController *investmentEditor;
  SelectionEditViewController *selectEditor;
  UIViewController *infoController;
  UIViewController *currentEditor;
  
  IntroViewController *introController;
  
  NSNumberFormatter *amountFormatter;
  NSNumberFormatter *yearFormatter;
  
  AnnuityTrackView *firstIncomeTrack;
  AnnuityTrackView *firstExpensesTrack;
  AnnuityTrackView *investTrack;
  
  BOOL isPhone;
  CGFloat stashTrackHeight;
  CGFloat timelineTrackHeight;
  
  FinanceModel *model;
  
  NSString *currentFileName;
}

- (IBAction)zeroSelection;
- (IBAction)expandSelectionToEnd;
- (IBAction)cutJobAtRetirement;
- (IBAction)changeLabelMode:(UIButton*)sender;
- (IBAction)aboutMe;
- (IBAction)startIntro;
- (void)setSelectionName:(NSString*)label andColor:(UIColor*)color;

@property (weak, nonatomic) IBOutlet ScrubbableTextView *ageField;
@property (weak, nonatomic) IBOutlet ScrubbableTextView *savingsField;
@property (weak, nonatomic) IBOutlet UILabel *retireAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *retireSavingsLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet SelectDividerView *selectDivider;
@property (weak, nonatomic) IBOutlet UIView *selectActions;
@property (weak, nonatomic) IBOutlet UIView *trackSelectors;

@property (weak, nonatomic) IBOutlet UIView *editorContainerView;


@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *labelModeButton;

@property (weak, nonatomic) IBOutlet UIButton *introNextButton;
@property (weak, nonatomic) IBOutlet UIButton *introPrevButton;

@property (nonatomic, strong) IBOutlet TimelineView *timeLine;

@end
