//
//  IPhoneTimelineViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-17.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "IPhoneTimelineViewController.h"

@interface IPhoneTimelineViewController ()

@end

@implementation IPhoneTimelineViewController

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
}

- (FinanceModel*)newModel {
  FinanceModel *m = [[FinanceModel alloc] init];
  
  DataTrack *track = [[DataTrack alloc] init];
  track.name = @"Income";
  [m.incomeTracks addObject:track];
  
  DataTrack *track2 = [[DataTrack alloc] init];
  track2.name = @"Expenses";
  [m.expenseTracks addObject:track2];
  
  DataTrack *investmentTrack = [[DataTrack alloc] init];
  investmentTrack.name = @"Investment";
  m.investmentTrack = investmentTrack;
  
  return m;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
