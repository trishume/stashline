//
//  IPadTimelineViewController.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "TimelineViewController.h"

@interface IPadTimelineViewController : TimelineViewController {
  UIPopoverController *filesPop;
}


@property (weak, nonatomic) IBOutlet UIView *selectActions;
@property (weak, nonatomic) IBOutlet UIView *trackSelectors;
@end
