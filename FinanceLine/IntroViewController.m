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

@interface IntroViewController ()

@end

@implementation IntroViewController

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
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Intro" ofType:@"plist"];
  data = [[NSArray alloc] initWithContentsOfFile:path];
  
  [self doState:0];

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
  [self doState:1];
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
  curState = 0;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ca.thume.IntroViewDone" object:self];
}

- (void)resetAnims {
  touch1.opacity = 0.0;
  touch2.opacity = 0.0;
  [touch1 removeAllAnimations];
  [touch2 removeAllAnimations];
}

- (void)doState:(IntroState)state {
  curState = state;
  if(curState > [data count] || curState < 1) return;
  [self resetAnims];
  
  NSDictionary *stateInfo = [data objectAtIndex:curState - 1];
  
  BOOL phone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
  NSNumber *startx = stateInfo[phone ? @"phonex" : @"startx"];
  NSNumber *starty = stateInfo[phone ? @"phoney" : @"starty"];
  NSNumber *width  = stateInfo[phone ? @"phoneWidth" : @"width"];
  
  if ([stateInfo[@"anim"] isEqualToString:@"Swipe"]) {
    CGPoint start = CGPointMake([startx floatValue], [starty floatValue]);
    [self swipeAnimationStart: start length: [width floatValue] time: [stateInfo[@"time"] floatValue]];
  } else if ([stateInfo[@"anim"] isEqualToString:@"Pinch"]) {
    CGPoint start = CGPointMake([startx floatValue], [starty floatValue]);
    [self pinchOutAnimationStart: start size: [width floatValue] time: [stateInfo[@"time"] floatValue]];
  } else if([stateInfo[@"anim"] isEqualToString:@"Delay"]) {
    [self performSelector:@selector(allDone) withObject:nil afterDelay: [stateInfo[@"time"] floatValue]];
  }
  
  NSString *nextNotif = stateInfo[@"nextNotif"];
  if (nextNotif && ![nextNotif isEqualToString:@""]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionNotification:) name:nextNotif object:nil];
  }
  [self setDescription: stateInfo[@"description"]];
}

@end
