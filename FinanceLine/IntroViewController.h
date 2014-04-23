//
//  IntroViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2014-03-10.
//  Copyright (c) 2014 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSUInteger IntroState;

@interface IntroViewController : UIViewController <UIAlertViewDelegate> {
  CALayer *touch1;
  CALayer *touch2;
  IntroState curState;
  
  NSArray *data;
}

- (void) startIntro;
- (void) skipStep;
- (void) goBack;

@property (weak, nonatomic) IBOutlet UILabel *explanation;
@property (weak, nonatomic) IBOutlet UIView  *touchLayer;
@property (weak, nonatomic) IBOutlet UIView  *explanationBox;
@end
