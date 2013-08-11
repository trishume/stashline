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

@interface TimelineViewController : UIViewController <TrackSelectionDelegate, UITextFieldDelegate> {
  Selection *currentSelection;
  DataTrack *selectedTrack;
  FinanceModel *model;
  NSNumberFormatter *amountFormatter;
}

- (IBAction)selectionAmountChanged: (UITextField*)sender;
- (IBAction)clearSelection;
- (IBAction)zeroSelection;
- (IBAction)expandSelectionToEnd;
- (IBAction)cutJobAtRetirement;
- (IBAction)parameterFieldChanged:(UITextField*)sender;

- (IBAction)loadFile;

- (IBAction)aboutMe;

@property (nonatomic, strong) IBOutlet ScrubbableTextView *yearlyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *monthlyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *dailyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *workDailyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *workHourlyCost;

@property (weak, nonatomic) IBOutlet ScrubbableTextView *growthRateField;
@property (weak, nonatomic) IBOutlet ScrubbableTextView *dividendRateField;
@property (weak, nonatomic) IBOutlet ScrubbableTextView *safeWithdrawalField;

@property (weak, nonatomic) IBOutlet UITextField *fileNameField;

@property (nonatomic, strong) IBOutlet TimelineView *timeLine;
@property (nonatomic, strong) IBOutlet SelectionEditViewController *selectEditor;

@end
