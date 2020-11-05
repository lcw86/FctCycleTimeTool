//
//  LoadingVC.h
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingVC : NSViewController

@property(strong,nonatomic)NSString *showingText;
@property (readonly)BOOL isShowing;
-(void)showViewAsSheetOnViewController:(NSViewController *)vc;
-(void)dismisssViewOnViewController:(NSViewController *)vc;
-(void)showViewAsAnimatorOnViewController:(NSViewController *)vc;
@end

NS_ASSUME_NONNULL_END
