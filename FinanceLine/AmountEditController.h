//
//  AmountEditController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-26.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectionEditViewController.h"

@interface AmountEditController : SelectionEditViewController <UITextFieldDelegate> {
  NSNumberFormatter *amountFormatter;
}

@property (nonatomic, strong) IBOutlet ScrubbableTextView *yearlyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *monthlyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *dailyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *workDailyCost;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *workHourlyCost;

@end
