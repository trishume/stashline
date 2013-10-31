//
//  IPhoneTimelineViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineViewController.h"
#import "PanelTabView.h"

@interface IPhoneTimelineViewController : TimelineViewController {
  UINavigationController *filesModal;
  BOOL panelOut;
}

@property (weak, nonatomic) IBOutlet UIView *leftPanelView;
@property (weak, nonatomic) IBOutlet PanelTabView *panelTab;
@property (strong, nonatomic) IBOutlet UIView *editorPanel;
@property (strong, nonatomic) IBOutlet UIView *mainPanel;
@property (weak,nonatomic) IBOutlet UIView *editorTitleBg;

@end
