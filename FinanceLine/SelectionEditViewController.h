//
//  SelectionEditViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-09.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrubbableTextView.h"
#import "Selection.h"
#import "DataTrack.h"
#import "TimelineView.h"

@protocol SelectionEditorDelegate <NSObject>
- (void) redraw;
- (void) updateModel:(BOOL)save;
@end

@interface SelectionEditViewController : UIViewController <UITextFieldDelegate>

- (void)clearSelection;
- (void)expandSelectionToEnd;
- (void)setSelection:(Selection *)sel onTrack:(DataTrack *)track;
- (void)updateValueDisplay:(double)monthlyValue;
- (void)updateSelectionAmount:(double)monthlyValue;
- (void)textFieldUpdated: (UITextField*)sender;
- (double)convertValue: (double)val forField: (ScrubbableTextView*)sender;

- (IBAction)selectionAmountUpdate: (UITextField*)sender;
- (IBAction)selectionAmountChanged: (UITextField*)sender;

@property (strong,nonatomic) id<SelectionEditorDelegate> delegate;
@property (strong,nonatomic) Selection *currentSelection;
@property (strong,nonatomic) DataTrack *selectedTrack;

@end
