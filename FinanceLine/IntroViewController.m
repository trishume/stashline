//
//  IntroViewController.m
//  FinanceLine
//
//  Created by Tristan Hume on 2014-03-10.
//  Copyright (c) 2014 Tristan Hume. All rights reserved.
//

#import "IntroViewController.h"

#define kTouchSize 45
#define kPinchBuffer 30.0

enum {
  IntroStateNone,
  IntroStateSelect,
  IntroStateAdjust,
  IntroStateInspect,
  IntroStatePan,
  IntroStateZoom,
  IntroStateYouDone,
  IntroStateAllDone
};

@interface IntroViewController ()

@end

@implementation IntroViewController

@synthesize selectRect,adjustRect,inspectRect,panRect,zoomRect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self doState:IntroStateNone];
	// Do any additional setup after loading the view.
  UIImage* touchImage = [UIImage imageNamed:@"Touch-Icon"];
  
  touch1 = [CALayer layer];
  [touch1 setBounds:CGRectMake(0.0, 0.0, kTouchSize, kTouchSize)];
  touch1.opacity = 0.0;
  touch1.contents = (id)touchImage.CGImage;
  [self.view.layer addSublayer:touch1];
  
  touch2 = [CALayer layer];
  [touch2 setBounds:CGRectMake(0.0, 0.0, kTouchSize, kTouchSize)];
  touch2.opacity = 0.0;
  touch2.contents = (id)touchImage.CGImage;
  [self.view.layer addSublayer:touch2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startIntro {
  [self doState:IntroStateSelect];
}

- (void)swipeAnimationStart: (CGPoint)start length: (CGFloat)len time: (CGFloat)swipeDuration {
  [self swipeAnimationStart:start length:len time:swipeDuration layer:touch1 reverse:NO];
}

- (void)swipeAnimationStart: (CGPoint)start length: (CGFloat)len time: (CGFloat)swipeDuration layer: (CALayer*)layer reverse: (BOOL)autoreverse {
  CAKeyframeAnimation *alphAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  alphAnim.keyTimes = @[@0.0, @0.2, @0.9, @1.0];
  alphAnim.values   = @[@0.0, @1.0, @1.0, @0.0];
  alphAnim.duration = swipeDuration * (autoreverse ? 2.0 : 1.0);
  alphAnim.repeatCount = HUGE_VALF;
  alphAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [layer addAnimation:alphAnim forKey:@"opacity"];
//  layer.opacity = 1.0;
  
  CABasicAnimation *posAnim = [CABasicAnimation animationWithKeyPath:@"position"];
  posAnim.fromValue = [NSValue valueWithCGPoint:start];
  posAnim.toValue   = [NSValue valueWithCGPoint:CGPointMake(start.x + len, start.y)];
  posAnim.duration  = swipeDuration;
  posAnim.repeatCount = HUGE_VALF;
  posAnim.autoreverses = autoreverse;
  posAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [layer addAnimation:posAnim forKey:@"position"];
}

- (void)pinchOutAnimationStart: (CGPoint)centre size: (CGFloat)size time: (CGFloat)duration {
  CGFloat swipeLen = size/2.0 - kPinchBuffer;
  [self swipeAnimationStart: CGPointMake(centre.x - size/2.0, centre.y) length:swipeLen time:duration layer:touch1 reverse:YES];
  [self swipeAnimationStart: CGPointMake(centre.x + size/2.0, centre.y) length:-swipeLen time:duration layer:touch2 reverse:YES];
}

- (void)setDescription: (NSString*)s {
  self.explanation.text = s;
}

#pragma mark States

- (void)transitionNotification:(NSNotification*)not {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self nextState];
}

- (void)nextState {
  [self doState:curState+1];
}

- (void)allDone {
  [self doState:IntroStateAllDone];
}

- (void)doState:(IntroState)state {
  curState = state;
  NSString *nextNotif = nil;
  switch (state) {
    case IntroStateSelect:
      [self swipeAnimationStart: selectRect.frame.origin length: selectRect.frame.size.width time:2.0];
      nextNotif = @"ca.thume.AnnuityTrackSelectionEnded";
      [self setDescription:@"Select a time span on an earnings bar."];
      break;
    case IntroStateAdjust:
      [self swipeAnimationStart: adjustRect.frame.origin length: adjustRect.frame.size.width time:2.0];
      nextNotif = @"ca.thume.SelectionEditAmountChanged";
      [self setDescription:@"Tap or drag on the number to adjust the amount."];
      break;
    case IntroStateInspect:
      [self swipeAnimationStart: inspectRect.frame.origin  length: inspectRect.frame.size.width time:2.0];
      nextNotif = @"ca.thume.LineGraphInspectEnded";
      [self setDescription:@"Inspect your estimated savings."];
      break;
    case IntroStatePan:
      [self swipeAnimationStart: panRect.frame.origin length: -panRect.frame.size.width time:1.5];
      nextNotif = @"ca.thume.TimelineTrackPanEnded";
      [self setDescription:@"Swipe on the timeline to pan."];
      break;
    case IntroStateZoom:
      [self pinchOutAnimationStart: zoomRect.frame.origin size: zoomRect.frame.size.width time:1.5];
      nextNotif = @"ca.thume.TimelineViewZoomEnded";
      [self setDescription:@"Pinch on the timeline to zoom."];
      break;
    case IntroStateYouDone:
      touch1.opacity = 0.0;
      touch2.opacity = 0.0;
      [touch1 removeAllAnimations];
      [touch2 removeAllAnimations];
      [self setDescription:@"Now enter your own estimates to get started."];
      [self performSelector:@selector(allDone) withObject:nil afterDelay:4.0];
      break;
    case IntroStateAllDone:
      [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.IntroViewDone" object:self];
      break;
    default:
      break;
  }
  
  if (nextNotif != nil) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionNotification:) name:nextNotif object:nil];
  }
}

@end
