//
//  WindowController.h
//  SC_Eowyn
//
//  Created by ciwei luo on 2020/4/5.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController

-(void)cw_addViewController:(NSViewController *)testVC;
-(void)cw_addViewController:(NSViewController *)testVC logVC:(NSViewController *)logVC;
-(void)cw_addViewControllers:(NSArray <NSViewController *> *)testVCs;
-(void)cw_addViewControllers:(NSArray <NSViewController *> *)testVCs logVC:(NSViewController *)logVC;
@end

NS_ASSUME_NONNULL_END
