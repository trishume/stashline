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
}

@property (nonatomic) double minVal;
@property (nonatomic) double maxVal;
@property (nonatomic) double stepVal;

@end
