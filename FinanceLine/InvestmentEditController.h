//
//  InvestmentEditController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-28.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrubbableTextView.h"
#import "SelectionEditViewController.h"

@interface InvestmentEditController : SelectionEditViewController <UITextFieldDelegate> {
  NSNumberFormatter *percentFormatter;
  NSNumberFormatter *yearFormatter;
}

@property (nonatomic, strong) IBOutlet ScrubbableTextView *yearlyGrowth;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *monthlyGrowth;
@property (nonatomic, strong) IBOutlet ScrubbableTextView *doublingPeriod;

@end
