//
//  Selection.h
//  FinanceLine
//
//  Created by Tristan Hume on 2013-07-08.
//  Copyright (c) 2013 Tristan Hume. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Selection : NSObject

- (id)init;

- (void)selectFrom:(NSUInteger)firstMonth to:(NSUInteger)secondMonth;
- (BOOL)includes:(NSUInteger)month;


@property (nonatomic) NSUInteger start;
@property (nonatomic) NSUInteger end;

@end
