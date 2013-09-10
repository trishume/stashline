//
//  SelectDividerView.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-09-07.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectDividerDelegate <NSObject>
- (void) deselect;
@end

@interface SelectDividerView : UIView {
  BOOL hasSelection;
}

- (void)setHasSelection:(BOOL)_hasSelection;

@property (nonatomic, weak) id<SelectDividerDelegate> delegate;
@end
