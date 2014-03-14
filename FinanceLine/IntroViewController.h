//
//  IntroViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2014-03-10.
//  Copyright (c) 2014 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSUInteger IntroState;

@interface IntroViewController : UIViewController {
  CALayer *touch1;
  CALayer *touch2;
  IntroState curState;
}

- (void) startIntro;

@property (weak, nonatomic) IBOutlet UILabel* explanation;

@property (weak, nonatomic) IBOutlet UIView *selectRect;
@property (weak, nonatomic) IBOutlet UIView *adjustRect;
@property (weak, nonatomic) IBOutlet UIView *inspectRect;
@property (weak, nonatomic) IBOutlet UIView *panRect;
@property (weak, nonatomic) IBOutlet UIView *zoomRect;
@end
