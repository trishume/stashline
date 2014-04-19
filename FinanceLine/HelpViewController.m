//
//  HelpViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2013-10-14.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectPanel:(NSUInteger)panelIndex {
  NSString *deviceName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone";
  NSString *imageName = [NSString stringWithFormat:@"Info%u-%@", panelIndex+1, deviceName];
  UIImage *image = [UIImage imageNamed:imageName];
  self.panelView.image = image;
  [self.view setNeedsDisplay];
}

- (IBAction)getStartedButtonPressed {
  [self.parentDelegate startIntro];
}

- (IBAction)closeModal {
  [self.parentDelegate userWasInformed];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)panelChanged:(UISegmentedControl*)sender {
  [self selectPanel:[sender selectedSegmentIndex]];
}

@end
