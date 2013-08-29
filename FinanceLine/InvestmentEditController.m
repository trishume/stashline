//
//  InvestmentEditController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-28.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "InvestmentEditController.h"

@interface InvestmentEditController ()

@end

@implementation InvestmentEditController

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

  percentFormatter = [[NSNumberFormatter alloc] init];
  percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
  percentFormatter.minimumFractionDigits = 2;
  percentFormatter.maximumFractionDigits = 2;

  yearFormatter = [[NSNumberFormatter alloc] init];
  yearFormatter.numberStyle = NSNumberFormatterDecimalStyle;
  yearFormatter.maximumFractionDigits = 1;
  yearFormatter.minimumFractionDigits = 1;

  self.yearlyGrowth.stepVal = 0.0025;
  self.monthlyGrowth.stepVal = 0.0005;
  self.doublingPeriod.stepVal = 0.5;
  
  // TODO negative growth rates

  self.yearlyGrowth.formatter = percentFormatter;
  self.monthlyGrowth.formatter = percentFormatter;
  self.doublingPeriod.formatter = yearFormatter;
}

- (double)doublingPeriod:(double)yearlyGrowth {
  if(yearlyGrowth == 0.0) return 0.0;
  return 70.0 / (yearlyGrowth * 100.0);
}

- (void)updateValueDisplay:(double)yearlyGrowth {
  [self.monthlyGrowth setValue:yearlyGrowth / 12.0];
  [self.yearlyGrowth setValue:yearlyGrowth];
  [self.doublingPeriod setValue:[self doublingPeriod:yearlyGrowth]];
}

- (void)clearSelection {
  [super clearSelection];

  [self.yearlyGrowth setText:@""];
  [self.monthlyGrowth setText:@""];
  [self.doublingPeriod setText:@""];
}

- (double)parseValue: (NSString*)str {
  double res = [[percentFormatter numberFromString:str] doubleValue];
  if (res == 0.0) {
    res = [str doubleValue];
  }
  return res;
}

- (IBAction)selectionAmountChanged: (UITextField*)sender {
  if ([sender.text isEqualToString:@""]) return;
  double value = [self parseValue:[sender text]];

  // convert to a monthly cost
  if (sender == self.monthlyGrowth) {
    value = value * 12.0;
  } else if(sender == self.doublingPeriod) {
    value = [self doublingPeriod:value];
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
