//
//  AppDelegate.m
//  TestTimeCount
//
//  Created by RyanGao on 2018/11/14.
//  Copyright © 2018 RyanGao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSString *csvPath;
}

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

-(void)awakeFromNib
{
    csv_uart_files=[[NSMutableArray alloc]init];
    csv_uart2_files=[[NSMutableArray alloc]init];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


- (double)str2time:(NSString *)str
{
    NSArray *subStr = [str componentsSeparatedByString:@" "];
    if ([subStr count]<2)
    {
        return 0.0;
    }
    NSArray * arrayStr = [subStr[1] componentsSeparatedByString:@":"];
    if ([arrayStr count]>2)
    {
        double hour = [arrayStr[0] doubleValue] * 60*60;
        double minute = [arrayStr[1] doubleValue] * 60;
        double second = [arrayStr[2] doubleValue] * 1;
        return hour+minute+second;
    }
    return 0.0;
}



-(void)writeLogs:(NSString *)str path:(NSString *)filePath
{
    
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!fh)
    {
        NSFileManager *fm=[NSFileManager defaultManager];
        [fm createFileAtPath:filePath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    [fh seekToEndOfFile];
    [fh writeData:[[NSString stringWithFormat:@"%@\r\n",str]  dataUsingEncoding:NSUTF8StringEncoding]];
    [fh closeFile];
}


- (IBAction)openFile:(id)sender
{
        NSOpenPanel *openPanel=[NSOpenPanel openPanel];
        NSString *openPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:openPath]];
        
        NSArray *fileType=[NSArray arrayWithObjects:@"log",@"txt",nil];
        [openPanel setAllowedFileTypes:fileType];
        openPanel.canChooseDirectories=YES;
        [openPanel setCanChooseFiles:NO];
        [openPanel setAllowsMultipleSelection:NO];
        [openPanel setPrompt:@"Choose"];
        
        [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
            if (result==NSFileHandlingPanelOKButton)
            {
                
                NSArray *urls=[openPanel URLs];
                for (int i=0; i<[urls count]; i++)
                {
                    self->csvPath = [[urls objectAtIndex:i] path];
              
                }
                [self->csv_uart_files removeAllObjects];
                [self->csv_uart2_files removeAllObjects];
                NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self->csvPath error:nil];
                for (NSString *str in tmplist)
                {
                    if ([str containsString:@"uart.txt"]) {
                        [self->csv_uart_files addObject:[self->csvPath stringByAppendingPathComponent:str]];
                    }else if ([str containsString:@"uart2.txt"]){
                        [self->csv_uart2_files addObject:[self->csvPath stringByAppendingPathComponent:str]];
                       
                    }
                }
                if ([self->csv_uart_files count]>0 && [self->csv_uart2_files count]>0)
                {

                    [self->_txtCreateFilePath setStringValue:@"Please click START to calculate the time!!!"];
                }
                else
                {
                    [self->_txtCreateFilePath setStringValue:@"choose Folder error!!!"];
                }
            }
        }];
}

- (IBAction)Calculate:(NSButton *)sender
{
    if ([self->csv_uart_files count]<1 || [self->csv_uart2_files count]<1)
    {
        [_txtCreateFilePath setStringValue:@"choose file error!!!"];
        return;
    }

    [_txtCreateFilePath setStringValue:@""];
    NSError *error=nil;
    //NSLog(@"file path : %@",[_txtFilePathUart stringValue]);
    NSString * filePathUart1 = self->csv_uart_files[0];
    NSString * filePathUart2 = self->csv_uart2_files[0];
    

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY_MM_dd__HH_mm_ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSString *pathNoExtension = [filePathUart1 stringByDeletingPathExtension];
    NSString *filePath_calculate=[NSString stringWithFormat:@"%@_%@.csv",pathNoExtension,currentTimeString];
    [self writeLogs:@"Diags_Execution_Time(s),Diags_Execution_Time / Total_Time (%),Diags_Idle_Time(s),Diags_Idle_Time / Total_Time(%),Diags_Command" path:filePath_calculate];
    
    
   
    NSString *str1 = [NSString stringWithContentsOfFile:filePathUart1 encoding:NSUTF8StringEncoding error:&error];
    NSString *str2 = [NSString stringWithContentsOfFile:filePathUart2 encoding:NSUTF8StringEncoding error:&error];
    NSString *str = [NSString stringWithFormat:@"%@\r\n%@",str2,str1];
    if(!str) return;
    
    double sendDiagsTime = 0;
    double diagsReponseTime = 0;
    double recordDiagsRespondTime = 0;
    double diagsIdleTime = 0;
    //double iBootTime = 0;
    
    double diagsTotalTime = 0;
    
    NSString *longest_Diags_Command = @"";
    NSString *longest_Idel_Command = @"";
    double diags_Execution_Time_Total = 0;
    double diags_Idle_Time_Total = 0;
    double last_diags_Execution_Time = 0;
    double last_diags_Idle_Time = 0;
    
    // for total time
    NSString *patternTotal = @".*Starting application[\\s\\S]*\\]\\s*:-\\)";
    NSRegularExpression *regularTotal = [[NSRegularExpression alloc] initWithPattern:patternTotal options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultsAll = [regularTotal matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSLog(@"resultsAll:  %ld",resultsAll.count);
    for (NSTextCheckingResult *resultall in resultsAll)
    {
        NSString *subStr =  [str substringWithRange:resultall.range];
        NSArray *arrayStr = [subStr componentsSeparatedByString:@"\n"];
        sendDiagsTime = [self str2time:arrayStr[0]];
        diagsReponseTime = [self str2time:arrayStr[arrayStr.count-1]];
        diagsTotalTime = diagsReponseTime - sendDiagsTime;
        
    }
    
    // for first iboot time
    NSString *patterniBoot = @".*Starting application[\\s\\S]*?Entering recovery mode";
    NSRegularExpression *regulariBoot = [[NSRegularExpression alloc] initWithPattern:patterniBoot options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultsiBoot = [regulariBoot matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSLog(@"resultsiBoot:  %ld",resultsiBoot.count);
    for (NSTextCheckingResult *resultiBoot in resultsiBoot)
    {
        NSString *subStr =  [str substringWithRange:resultiBoot.range];
        NSArray *arrayStr = [subStr componentsSeparatedByString:@"\n"];
        sendDiagsTime = [self str2time:arrayStr[0]];
        diagsReponseTime = [self str2time:arrayStr[arrayStr.count-1]];
        
        diagsIdleTime = 0;
        recordDiagsRespondTime = diagsReponseTime;
        
        double executeTime = diagsReponseTime-sendDiagsTime;
        double percentageExecute = executeTime/diagsTotalTime *100;
        double percentageIdle = diagsIdleTime/diagsTotalTime*100;
        
        NSString *value = [NSString stringWithFormat:@"%f,%f,%f,%f,iboot",executeTime,percentageExecute,diagsIdleTime,percentageIdle];
        [self writeLogs:value path:filePath_calculate];
        
        diags_Execution_Time_Total +=executeTime;
        diags_Idle_Time_Total +=diagsIdleTime;
        
        
    }
    
    // send diags time
    NSString *pattern = @".*cmd-send:[\\s\\S]*?\\]\\s*:-\\)";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSLog(@"diags cmd:%ld",results.count);
    
    NSString *patternCmd = @"cmd-send:\\s*(.*)";
    NSRegularExpression *regularCmd = [[NSRegularExpression alloc] initWithPattern:patternCmd options:NSRegularExpressionCaseInsensitive error:nil];
    
    double iboot_start = 0;
    double iboot_end = 0;
    NSString *patterniBootSecond = @".*\\]\\s*:-\\).*pmu: flt 0f:[\\s\\S]*?cmd-send";
    NSRegularExpression *regulariBootSecond = [[NSRegularExpression alloc] initWithPattern:patterniBootSecond options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultsiBootSecond = [regulariBootSecond matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSLog(@"second iboot:%ld",resultsiBootSecond.count);
    for (NSTextCheckingResult *resultiBootSecond in resultsiBootSecond)
    {
        NSString *subStr =  [str substringWithRange:resultiBootSecond.range];
        NSArray *arrayStr = [subStr componentsSeparatedByString:@"\n"];
        iboot_start = [self str2time:arrayStr[0]];
        iboot_end = [self str2time:arrayStr[arrayStr.count-1]];
        NSLog(@"-----second iboot time:%f",iboot_end-iboot_start);
        
    }
    
    int m_Flag = 0;
  
    for (NSTextCheckingResult *result in results)
    {
      
        NSString *subStr =  [str substringWithRange:result.range];
        NSArray *arrayStr = [subStr componentsSeparatedByString:@"\n"];
        
        NSString *tempStr = arrayStr[0];
        NSArray *resultsCmd = [regularCmd matchesInString:tempStr options:0 range:NSMakeRange(0, tempStr.length)];
        NSString *diagsCmd = @"";
        for (NSTextCheckingResult *resultCmd in resultsCmd)
        {
            diagsCmd = [tempStr substringWithRange:resultCmd.range];
            break;
        }
        diagsCmd  = [diagsCmd stringByReplacingOccurrencesOfString:@"cmd-send: " withString:@""];
        diagsCmd = [diagsCmd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([diagsCmd isEqualToString:@"diags"])
        {
            //inset sencond time iboot execute time
            if (m_Flag == 1)
            {
                double executeTime = iboot_end-iboot_start;
                double percentageExecute = executeTime/diagsTotalTime *100;
                double percentageIdle = diagsIdleTime/diagsTotalTime*100;
                
                diagsIdleTime = recordDiagsRespondTime-iboot_start;
                recordDiagsRespondTime = iboot_end;
                
                NSString *value = [NSString stringWithFormat:@"%f,%f,%f,%f,iBoot Second Enter diags",executeTime,percentageExecute,diagsIdleTime,percentageIdle];
                [self writeLogs:value path:filePath_calculate];
                
                diags_Execution_Time_Total +=executeTime;
                diags_Idle_Time_Total +=diagsIdleTime;
            }
            m_Flag++;
        }
        sendDiagsTime = [self str2time:arrayStr[0]];
        diagsReponseTime = [self str2time:arrayStr[arrayStr.count-1]];
        
        diagsIdleTime = sendDiagsTime - recordDiagsRespondTime;
        recordDiagsRespondTime = diagsReponseTime;
        
        double executeTime = diagsReponseTime-sendDiagsTime;
        double percentageExecute = executeTime/diagsTotalTime *100;
        double percentageIdle = diagsIdleTime/diagsTotalTime*100;
        
        NSString *value = [NSString stringWithFormat:@"%f,%f,%f,%f,%@",executeTime,percentageExecute,diagsIdleTime,percentageIdle,diagsCmd];
        [self writeLogs:value path:filePath_calculate];
        
        diags_Execution_Time_Total +=executeTime;
        diags_Idle_Time_Total +=diagsIdleTime;
        if (last_diags_Execution_Time<executeTime)
        {
            longest_Diags_Command = [NSString stringWithFormat:@"%@,%f",diagsCmd,executeTime];
            last_diags_Execution_Time = executeTime;
        }
        if (last_diags_Idle_Time<diagsIdleTime)
        {
            longest_Idel_Command = [NSString stringWithFormat:@"%@,%f",diagsCmd,diagsIdleTime];
            last_diags_Idle_Time = diagsIdleTime;
        }
        
    }
    
    NSString *value1 = [NSString stringWithFormat:@",,\r\n\r\nLongest_Diags_Execute_Command: %@",longest_Diags_Command];
    [self writeLogs:value1 path:filePath_calculate];
    NSString *value2 = [NSString stringWithFormat:@"Longest_Idel_Command: %@",longest_Idel_Command];
    [self writeLogs:value2 path:filePath_calculate];
    
    NSString *value3 = [NSString stringWithFormat:@"Diags_Execution_Time_Total: %f",diags_Execution_Time_Total];
    [self writeLogs:value3 path:filePath_calculate];
    
    NSString *value4 = [NSString stringWithFormat:@"Diags_Idle_Time_Total: %f",diags_Idle_Time_Total];
    [self writeLogs:value4 path:filePath_calculate];
    
    
    
    /*
  
    
    
    //需要被筛选的字符串
    NSString *str = @"#今日要闻#[偷笑] http://asd.fdfs.2ee/aas/1e @sdf[test] #你确定#@rain李23: @张三[挖鼻屎]m123m";
        //表情正则表达式
        //  \\u4e00-\\u9fa5 代表unicode字符
        NSString *emopattern = @"\\[[a-zA-Z\\u4e00-\\u9fa5]+\\]";
        //@正则表达式
        NSString *atpattern = @"@[0-9a-zA-Z\\u4e00-\\u9fa5]+";
        //#...#正则表达式
        NSString *toppattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
        //url正则表达式
        NSString *urlpattern = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
        //设定总的正则表达式
        NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@|%@",emopattern,atpattern,toppattern,urlpattern];
        //根据正则表达式设定OC规则
        NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        //获取匹配结果
        NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        //NSLog(@"%@",results);
        //遍历结果
        for (NSTextCheckingResult *result in results)
        {
            NSLog(@"%@ %@",NSStringFromRange(result.range),[str substringWithRange:result.range]);
        }
    */
    /*
    int item_flag = 0;
    NSString * group = @"";
    NSString * subItem = @"";
    NSString * subSubItem = @"";
    NSString * time = @"0";
    NSString * timeBuffer = @"0";
    
    for (int i = 0; i<[arrayStr count];i++)
    {
        if ( i%5 == 0)
        {
            item_flag++;
            NSArray *testGroup = [arrayStr[i] componentsSeparatedByString:@":"];
            if ([testGroup count]>1) {
                group = [testGroup[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else
            {
                group = @"N/A";
            }
            
        }
        
        if ( i%5 == 1)
        {
            item_flag++;
            NSArray *subItemArray = [arrayStr[i] componentsSeparatedByString:@":"];
            if ([subItemArray count]>1) {
                subItem = [subItemArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else
            {
                subItem = @"N/A";
            }
        }
        
        if ( i%5 == 2)
        {
            item_flag++;
            NSArray *subItemArray = [arrayStr[i] componentsSeparatedByString:@":"];
            if ([subItemArray count]>1) {
                subSubItem = [subItemArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else
            {
                subSubItem = @"N/A";
            }
        }
        
        if ( i%5 == 4)
        {
            item_flag++;
            NSArray *testTime = [arrayStr[i] componentsSeparatedByString:@" "];
            if ([testTime count]>1)
            {
                time = [testTime[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else
            {
                time = @"0";
            }
            if (i == 4) {
                timeBuffer = time;
            }
            
        }
        
        if (item_flag >= 4)
        {
            NSString *value = [NSString stringWithFormat:@"%@,%@,%@,%f",group,subItem,subSubItem,[self str2time:time]-[self str2time:timeBuffer]];
            NSLog(@"%@",value);
            [self writeLogs:value path:filePath_calculate];
            item_flag = 0 ;
            group = @"";
            subItem = @"";
            subSubItem = @"";
            timeBuffer = time;
            time = @"0";
            
        }
    }
    */
    [_txtCreateFilePath setStringValue:filePath_calculate];
    [_txtFilePathUart setStringValue:@""];
    
}

@end
