//
//  LoadingVC.m
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "LoadingVC.h"
#import "PresentCustomAnimator.h"
@interface LoadingVC ()
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet NSTextField *showingLabel;

@end

@implementation LoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isShowing =YES;

}
-(void)viewWillDisappear{
    [super viewWillDisappear];
    // Do view setup here.
    [self.loadingView stopAnimation:self];
    _isShowing = NO;
}
-(void)viewWillAppear{
    [super viewWillAppear];
    // Do view setup here.
   
    [self.loadingView startAnimation:self];
    _isShowing= YES;

}

-(void)showViewAsSheetOnViewController:(NSViewController *)vc{
    [vc presentViewControllerAsSheet:self];
}
-(void)showViewAsAnimatorOnViewController:(NSViewController *)vc{

   
    self.view.wantsLayer = YES;
    self.view.alphaValue = 1;
    self.view.frame = vc.view.bounds;
    self.view.wantsLayer = YES;
    //self.view.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    [vc.view addSubview:self.view];
 
}

-(void)dismisssViewOnViewController:(NSViewController *)vc{
    [vc dismissViewController:self];
    
   // [self.view removeFromSuperview];
}

-(void)setShowingText:(NSString *)showingText{
    _showingText = showingText;
    if ([showingText.lowercaseString containsString:@"report"]) {
        _showingText = @"Generating Report...";
    }else if([showingText.lowercaseString containsString:@"plot"]){
        _showingText = @"Generating Plot...";
    }else if([showingText.lowercaseString containsString:@"csv"]){
        _showingText = @"Loading Csv...";
    }else{
       _showingText = @"Loading...";
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.showingLabel.stringValue = _showingText;
    });
    
    
}




@end
