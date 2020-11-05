//
//  AppDelegate.h
//  TestTimeCount
//
//  Created by RyanGao on 2018/11/14.
//  Copyright © 2018 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableArray *csv_uart_files;
    NSMutableArray *csv_uart2_files;
}

@property (weak) IBOutlet NSTextField *txtFilePathUart;
@property (weak) IBOutlet NSTextField *txtFilePathUart2;

@property (weak) IBOutlet NSTextField *txtCreateFilePath;
@end

