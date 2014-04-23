//
//  ScrubbableTextView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-08-03.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrubbableTextView : UITextField {
  double startVal;
  double curVal;
  UILabel *padLabel;
}

+ (NSNumberFormatter*)amountFormatter;

- (void)setValue:(double)v;
- (double)parseValue;
- (double)parseAndUpdate;
- (BOOL)validValue;

@property (nonatomic) double minVal;
@property (nonatomic) double maxVal;
@property (nonatomic) double stepVal;
@property (nonatomic, strong) UIColor *scrubColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) NSNumberFormatter *formatter;

@end
