//
//  IPhoneTimelineViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineViewController.h"

@interface IPhoneTimelineViewController : TimelineViewController

@property (weak, nonatomic) IBOutlet UIView *leftPanelView;
@property (strong, nonatomic) IBOutlet UIView *editorPanel;
@property (strong, nonatomic) IBOutlet UIView *mainPanel;
@property (weak,nonatomic) IBOutlet UIView *editorTitleBg;

@end
