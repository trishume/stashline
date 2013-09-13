//
//  AmountEditController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-26.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "AmountEditController.h"

@interface AmountEditController ()

@end

@implementation AmountEditController

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
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  amountFormatter = [ScrubbableTextView amountFormatter];
  
  self.yearlyCost.stepVal = 1000.0;
  self.monthlyCost.stepVal = 200.0;
  self.dailyCost.stepVal = 10.0;
  self.workDailyCost.stepVal = 10.0;
  self.workHourlyCost.stepVal = 1.0;
  
  self.yearlyCost.formatter = amountFormatter;
  self.monthlyCost.formatter = amountFormatter;
  self.dailyCost.formatter = amountFormatter;
  self.workDailyCost.formatter = amountFormatter;
  self.workHourlyCost.formatter = amountFormatter;
}

- (void)updateValueDisplay:(double)monthlyValue {
  [self.monthlyCost setValue:monthlyValue];
  [self.yearlyCost setValue:monthlyValue*12.0];
  [self.dailyCost setValue:monthlyValue/30.4];
  [self.workDailyCost setValue:monthlyValue/20.0];
  [self.workHourlyCost setValue:monthlyValue/160.0];
}

- (void)clearSelection {
  [super clearSelection];
  
  [self.monthlyCost setText:@""];
  [self.yearlyCost setText:@""];
  [self.dailyCost setText:@""];
  [self.workDailyCost setText:@""];
  [self.workHourlyCost setText:@""];
}

- (double)parseValue: (NSString*)str {
  double res = [[amountFormatter numberFromString:str] doubleValue];
  if (res == 0.0) {
    res = [str doubleValue];
  }
  return res;
}

- (void)textFieldUpdated: (UITextField*)sender {
  if ([sender.text isEqualToString:@""]) return;
  double value = [self parseValue:[sender text]];
  
  // convert to a monthly cost
  if (sender == self.yearlyCost) {
    value /= 12.0;
  } else if(sender == self.dailyCost) {
    value *= 30.4;
  } else if(sender == self.workDailyCost) {
    value *= 5.0*4.0;
  } else if(sender == self.workHourlyCost) {
    value *= 40*4.0;
  }
  
  [self updateSelectionAmount: value];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
