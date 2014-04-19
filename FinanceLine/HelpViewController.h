//
//  HelpViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-10-14.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpViewDelegate <NSObject>

- (void)startIntro;
- (void)userWasInformed;

@end

@interface HelpViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<HelpViewDelegate> parentDelegate;
@property (nonatomic, weak) IBOutlet UIImageView *panelView;
@end
