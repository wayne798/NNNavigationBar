//
//  UINavigationBar+NNTransition.h
//  NNNavigationBar
//
//  Created by GuHaijun on 2018/4/20.
//  Copyright © 2018年 GuHaijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationBar+NNTransitionClass.h"

@protocol NNTransition <NSObject>

@required
- (instancetype)initWithNavigationBar:(UINavigationBar *)bar;
/**
 nn_startTransitionWithParams:

 @param params
 key: transition
 {
     0: no anmiation
     1: push
     2: pop
     3: pop multi-vcs include popToRootViewController
 }
 */
- (void)nn_startTransitionWithParams:(NSDictionary *)params;
- (void)nn_endTransitionWithParams:(NSDictionary *)params;
- (void)nn_updateInteractiveTransitionWithParams:(NSDictionary *)params;
- (void)nn_endInteractiveTransitionWithParams:(NSDictionary *)params;

@optional
- (void)nn_updateBarStyleTransitionWithParams:(NSDictionary *)params;

@end

@interface UINavigationBar (NNTransition)

- (NSArray<id<NNTransition>> *)nn_transitions;

@end
