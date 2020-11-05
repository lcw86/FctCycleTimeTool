//
//  ViewController.m
//  SC_Eowyn
//
//  Created by ciwei luo on 2020/3/31.
//  Copyright © 2020 ciwei luo. All rights reserved.
//

#import "ViewController.h"
#import "ShowingLogVC.h"
#import <CWGeneralManager/NSString+Extension.h>
#import <CWGeneralManager/CWFileManager.h>
#import "PythonTask.h"
#import "TestMode.h"
#import "SubTestMode.h"
#import "TimeUnit.h"
#import <CWGeneralManager/MyEexception.h>

@interface ViewController ()
@property (weak) IBOutlet NSButton *btnStart;
@property (nonatomic,strong)NSMutableArray<TestMode *> *testModes;
@property(nonatomic,strong)NSMutableArray *csvFilesArr;
@property(nonatomic,strong)NSMutableArray *filterItemArr;
@property(nonatomic,strong)NSMutableArray<TimeUnit *> *timeUnitItemsArr;
@end

@implementation ViewController{
    NSString *csvPath;
    
    NSMutableArray *csv_uart_files;
    NSMutableArray *csv_uart2_files;
    int emptyItemCount;
    int anmoyCount;
}

-(double)getIboot1_time:(NSString *)path{
    double sendDiagsTime = 0;
    double diagsReponseTime = 0;
    double recordDiagsRespondTime = 0;
    double diagsIdleTime = 0;
    double executeTime = 0;
    NSString *str=[CWFileManager cw_readFromFile:path];
    NSString *patterniBoot = @".*[\\n]Starting application[\\s\\S]*?Entering recovery mode";
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
        
        executeTime = diagsReponseTime-sendDiagsTime;
   
        
    }
    return executeTime;
}

-(double)getIboot2_time:(NSString *)path{

    double executeTime = 0;
    double iboot_start = 0;
    double iboot_end = 0;
    NSString *str=[CWFileManager cw_readFromFile:path];

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
        executeTime=iboot_end-iboot_start;
        NSLog(@"-----second iboot time:%f",executeTime);
        //break;
        
    }
    return executeTime;
}



-(NSMutableArray *)getItemsArrWithPath:(NSString *)path{//@"/Users/ciweiluo/Desktop/04-15-00-25-49_uart.txt"
    //@"/Users/ciweiluo/Desktop/J522_FCT_UUT3__04-21-10-19-57_flow.log"
    NSString *read=[CWFileManager cw_readFromFile:path];
    NSArray *arr=[read cw_componentsSeparatedByString:@"==Test: "];
    NSMutableArray *mutArr = [[NSMutableArray alloc]initWithArray:arr];
    
    if (arr.count) {
        for (int i =0; i<arr.count; i++) {
            NSString *str =arr[i];//==SubTest:
            if (!([str containsString:@"==SubSubTest:"] && [str containsString:@"SubTest:"]&& [str containsString:@"upper:"])) {
                [mutArr removeObject:str];
            }
//            else{//cmd-send:
//                if (!([str containsString:@"[sendcmd]:"] || [str containsString:@":-)"]|| [str containsString:@"cmd-send:"])) {
//                    [mutArr removeObject:str];
//                }
//            }
        }
    }
    return mutArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//   double s1=  [self getIboot1_time:@"/Users/ciweiluo/Desktop/DLX01720019PPX715_J522_FCT_UUT1__04-22-13-30-58_flow.log"];
//    double s2=[self getIboot2_time:@"/Users/ciweiluo/Desktop/DLX01720019PPX715_J522_FCT_UUT1__04-22-13-30-58_flow.log"];
    
    emptyItemCount=0;
    csv_uart_files=[[NSMutableArray alloc]init];
    csv_uart2_files=[[NSMutableArray alloc]init];
    
    self.timeUnitItemsArr=[[NSMutableArray alloc]init];
    self.filterItemArr=[[NSMutableArray alloc]init];
    self.csvFilesArr = [[NSMutableArray alloc]init];
    self.testModes = [[NSMutableArray alloc]init];///Users/ciweiluo/Desktop/TEST_flow.log
  //  csvPath =@"/Users/ciweiluo/Desktop/TEST_flow.log";
  //  csvPath =@"/Users/ciweiluo/Desktop/QN_UartLog_0421 2/DLX0172004EPPX71R_04-22-14-09-56_PASS/DLX0172004EPPX71R_J522_FCT_UUT4__04-22-13-50-50_flow.log";
   // [self parseFlowLog:csvPath];

}



-(void)test:(NSArray *)item_strArr{
    NSMutableString *mutStr = [[NSMutableString alloc]init];
    BOOL isEmptyItem = YES;
    for (NSString *str1 in item_strArr) {//@"[sendcmd]:"  @"cmd-send:"
        if ([str1 containsString:@"[sendcmd]:"] ||[str1 containsString:@"cmd-send:"] ) {
            isEmptyItem =NO;
            break;
        }
    }
    
    if (item_strArr.count == 6 ) {
        
        emptyItemCount=emptyItemCount+1;
        
    }
    
    if (isEmptyItem) {
        
        for (int i=0; i<item_strArr.count; i++) {
            [mutStr appendString:item_strArr[i]];
            [mutStr appendString:@"\n"];
            
        }
    }
    [mutStr appendString:[NSString stringWithFormat:@"emptyItemCount:%d\n\n\n",emptyItemCount]];
    [CWFileManager cw_writeToFile:@"/Users/ciweiluo/Desktop/00_flow.txt" content:mutStr];
}


-(NSArray *)filterItemStrArr:(NSArray *)item_strArr{
    
    if (!item_strArr.count) {
        return nil;
    }
    
    
    NSMutableArray *item_filterStrArr =[[NSMutableArray alloc]initWithArray:item_strArr];
    BOOL is_containTime=NO;
    while (1) {
        NSString *frist_str = item_filterStrArr.firstObject;
        
        if (!([frist_str containsString:@"2020-"]||[frist_str containsString:@"2019-"]||[frist_str containsString:@"2021-"])) {
            [item_filterStrArr removeObject:frist_str];
        }else{
            is_containTime=YES;
            break;
        }
    }
    if (!is_containTime) {
        
        [MyEexception messageBox:@"Error" Information:@"nothing time in this item"];
        return nil;
    }
    
//    while (1) {
//
//        NSString *last_str = item_filterStrArr.lastObject;
//        if (!([last_str containsString:@"2020-"]||[last_str containsString:@"2019-"]||[last_str containsString:@"2021-"])) {
//            [item_filterStrArr removeObject:last_str];
//        }else{
//            break;
//        }
//    }
    
    
    for (int j =0; j<item_filterStrArr.count; j++) {
        NSString *str1=item_filterStrArr[j];
        if ([self is_need_delete:str1]) {
            [item_filterStrArr removeObject:str1];
            continue;
        }
        
    }

    NSString *lastTimeStr = @"";
    int i = 0;
    while (i<item_filterStrArr.count) {
        NSString *str = item_filterStrArr[i];
        if (([str containsString:@"2020-"]||[str containsString:@"2019-"]||[str containsString:@"2021-"])) {
            if (str.length >=27) {
                lastTimeStr=[str cw_getSubstringFromIndex:0 toLength:27];
            }
            
        }else{
            NSString *new_str = [NSString stringWithFormat:@"%@;;%@",lastTimeStr,str];
            item_filterStrArr[i] = new_str;
        }
        i++;
    }
    
    return [NSArray arrayWithArray:item_filterStrArr];
}


-(void)parseFlowLog:(NSString *)file_path{
//-(NSMutableArray *)getItemsArrWithPath:(NSString *)path{//@"/Users/ciweiluo/Desktop/04-15-00-25-49_uart.txt"
    [self.testModes removeAllObjects];
    
    NSMutableArray *items_arr= [self getItemsArrWithPath:file_path];
    NSArray *mut_items_arr=[NSArray arrayWithArray:items_arr];
    NSArray *last_filterArr =nil;
    if (mut_items_arr.count) {
       // int error_count =0;
        for (int i =0; i<mut_items_arr.count; i++) {
            NSLog(@"test item---%d",i);
            if (i==2560) {
                NSLog(@"1");
            }
            NSString *item_str =mut_items_arr[i];
            NSArray *item_strArr =[item_str cw_componentsSeparatedByString:@"\n"];
            if (item_strArr.count<=3) {
                break;
            }
            NSArray *item_filterStrArr = [self filterItemStrArr:item_strArr];
            if (!item_filterStrArr.count) {
                break;
            }
           
            TestMode *item_mode = [TestMode testMode];
            item_mode.item_index=i+1;
       
            item_mode.testName = item_strArr[0];
            item_mode.subTestName = item_strArr[1];
            item_mode.subSubTestName = item_strArr[2];
            if ([item_mode.testName containsString:@"USBC"] &&[item_mode.subTestName containsString:@"USB2.0_Data_Transfer@TOP-PD_SOURCE_CC1"]&&[item_mode.subSubTestName containsString:@"Usbfs_Mounted"]) {//cwdebug
                NSLog(@"1");
//                ==Test: USBC
//                ==SubTest: USB2.0_Data_Transfer@TOP-PD_SOURCE_CC1
//                ==SubSubTest: Usbfs_Mounted
            }
            item_mode.item_strArr=item_strArr;
            item_mode.item_filterStrArr=item_filterStrArr;
            [item_mode get_item_time:item_filterStrArr last_fillterArr:last_filterArr];
            last_filterArr = item_filterStrArr;
            //SubTestMode *last_item_subMode=nil;
            if (item_mode.isIboot) {
                [self.testModes addObject:item_mode];
                continue;
            }
            
            for (int j =0; j<item_filterStrArr.count; j++) {
                NSString *str1=item_filterStrArr[j];
                SubTestMode *item_subMode=[[SubTestMode alloc] init];
                //NSLog(@"test sub_item---%d",j);
                item_subMode.str =str1;
                item_subMode.indexx=j;
                
                if ([str1 containsString:@"[sendcmd]:"]) {
                    //if (![last_item_subMode.str containsString:@"[sendcmd]:"]) {
                    item_subMode.cmdType=CommandTypeFixture;
                    [item_mode.xavierSendCmds addObject:item_subMode];
                    // }
                    
                }else if ([str1 containsString:@"]ACK("]){
                    
                    if (item_mode.xavierSendCmds.count) {
                        item_subMode.cmdType=CommandTypeFixture;
                        [item_mode.xavierReplys addObject:item_subMode];
                    }
                    
                }
                else if ([str1 containsString:@"cmd-send:"]){
                    //if (![last_item_subMode.str containsString:@"cmd-send:"]) {
                    item_subMode.cmdType=CommandTypeDut;
                    [item_mode.diagsSendCmds addObject:item_subMode];
                    // }
                    
                }else if ([str1 containsString:@":-)"]){
                   
                    if (item_mode.diagsSendCmds.count) {
                        item_subMode.cmdType=CommandTypeDut;
                        [item_mode.diagsReplys addObject:item_subMode];
                    }
                    
                    
                }else if (j ==item_filterStrArr.count-1){
                    
                    if (i==793) {
                        NSLog(@"ss");
                    }
                    
                    if (item_mode.diagsSendCmds.count-item_mode.diagsReplys.count==1) {
                        if (item_mode.xavierSendCmds.count) {
                            SubTestMode *sub_mode1 = item_mode.diagsSendCmds.lastObject;
                            SubTestMode *sub_mode2 = item_mode.xavierSendCmds.firstObject;
                            NSInteger dex =sub_mode2.indexx-sub_mode1.indexx;
                            
                            if (dex>0) {
                                SubTestMode *mode = [SubTestMode new];
                                NSInteger index =sub_mode2.indexx-1;
                                mode.indexx=index;
                                mode.str=[item_mode.item_filterStrArr objectAtIndex:index];
                                mode.cmdType=CommandTypeDut;
                                [item_mode.diagsReplys addObject:mode];
                                
                            }else{
                                NSLog(@"cw_1relpy:%@",item_subMode.str);
                                item_subMode.cmdType=CommandTypeDut;
                                [item_mode.diagsReplys addObject:item_subMode];
                            }
                        }else{
                            SubTestMode *mode = [SubTestMode new];
                            NSInteger index =item_mode.item_filterStrArr.count-2;
                            mode.indexx=index;
                            mode.str=[item_mode.item_filterStrArr objectAtIndex:index];
                            mode.cmdType=CommandTypeDut;
                            [item_mode.diagsReplys addObject:mode];
//                            item_mode.isAnomaly=YES;
                        }
                        //item_mode.isAnomaly=YES;
                        
                    }
                    if (item_mode.xavierSendCmds.count-item_mode.xavierReplys.count==1) {
                        if (item_mode.diagsSendCmds.count) {
                            //item_mode.isAnomaly=YES;
                            SubTestMode *sub_mode1 = item_mode.xavierSendCmds.lastObject;
                            SubTestMode *sub_mode2 = item_mode.diagsSendCmds.firstObject;
                            NSInteger dex =sub_mode2.indexx-sub_mode1.indexx;
                            if (dex>0) {
                                SubTestMode *mode = [SubTestMode new];;
                                NSInteger index =sub_mode2.indexx-1;
                                mode.indexx=index;
                                mode.str=[item_mode.item_filterStrArr objectAtIndex:index];
                                mode.cmdType=CommandTypeFixture;
                                [item_mode.diagsReplys addObject:mode];
                            }else{
                                item_subMode.cmdType=CommandTypeFixture;
                                [item_mode.xavierReplys addObject:item_subMode];
                            }
                        }else{
//                            item_subMode.cmdType=CommandTypeFixture;
//                            [item_mode.xavierReplys addObject:item_subMode];
//
                            
                            SubTestMode *mode = [SubTestMode new];
                            NSInteger index =item_mode.item_filterStrArr.count-2;
                            mode.indexx=index;
                            mode.str=[item_mode.item_filterStrArr objectAtIndex:index];
                            mode.cmdType=CommandTypeFixture;
                            [item_mode.xavierReplys addObject:mode];
                            
                        }
                    }
                    if (item_mode.diagsSendCmds.count!=item_mode.diagsReplys.count) {
                        NSString *string = [NSString stringWithFormat:@"Seq:%d,==Test: %@,==SubTest: %@,==SubSubTest: %@\nsends not equal replys\ndiagsSendCmds=%lu,diagsReplys=%lu,\n",i,item_mode.testName,item_mode.subTestName,item_mode.subSubTestName,(unsigned long)item_mode.diagsSendCmds.count,(unsigned long)item_mode.diagsReplys.count];
                        NSLog(@"%@",string);
                        //[ShowingLogVC postNotificationWithLog:string type:@""];
                        
                        item_mode.isAnomaly=YES;
                        if (item_mode.diagsReplys.count) {
                            [self joinSendCmds:item_mode.diagsSendCmds];
                            SubTestMode *lastM= item_mode.diagsReplys.lastObject;
                            
                            lastM.indexx = [item_mode.diagsSendCmds.lastObject indexx] +1;
                            if (item_mode.diagsReplys.count) {
                                [item_mode.diagsReplys removeAllObjects];
                                [item_mode.diagsReplys addObject:lastM];
                            }

                        }else{
                            if (item_mode.diagsSendCmds.count) {
                                [item_mode.diagsSendCmds removeAllObjects];
                            }
                            
                        }

                    }
                    if (item_mode.xavierSendCmds.count != item_mode.xavierReplys.count) {
                        NSString *string = [NSString stringWithFormat:@"Seq:%d,==Test: %@,==SubTest: %@,==SubSubTest: %@\nsends not equal replys\nxavierSendCmds=%lu,xavierReplys=%lu,",i,item_mode.testName,item_mode.subTestName,item_mode.subSubTestName,(unsigned long)item_mode.xavierSendCmds.count,(unsigned long)item_mode.xavierReplys.count];
                       // [ShowingLogVC postNotificationWithLog:string type:@""];
                        NSLog(@"%@",string);
                        
                        [self joinSendCmds:item_mode.xavierSendCmds];
                        item_mode.isAnomaly=YES;
 
                        SubTestMode *lastM= item_mode.xavierReplys.lastObject;
                        lastM.indexx = [item_mode.xavierSendCmds.lastObject indexx] +1;
                        [item_mode.xavierReplys removeAllObjects];
                        [item_mode.xavierReplys addObject:lastM];
                        
                    }
//                    ==Test: USBC
//                    ==SubTest: LDCM-ZREF_110Hz
//                    ==SubSubTest: CH0_Tone_1_Peak_Magnitude
                    [item_mode sortCmdsAndReplys];
                    if (item_mode.isAnomaly) {
                        anmoyCount++;
                        NSLog(@"%@", [NSString stringWithFormat:@"cw_anmoyCount%d--==Test: %@\n==SubTest: %@\n==SubSubTest: %@",anmoyCount,item_mode.testName,item_mode.subTestName,item_mode.subSubTestName]);
                    }
                    
                }
                
            }
            
            [self.testModes addObject:item_mode];
            
        }
    }else{
        [ShowingLogVC postNotificationWithLog:@"parse fail--count:0" type:@""];
        return;
    }
    
    [self getTimeUnitItemsArr:self.testModes];
    NSString *save_pathDirectory = [[NSString cw_getDesktopPath]stringByAppendingPathComponent:@"FCT_Cycle_Time"];
    [CWFileManager cw_createFile:save_pathDirectory isDirectory:YES];
    NSArray *arr =[csvPath.lastPathComponent cw_componentsSeparatedByString:@"."];
    if (arr.count==2) {
        NSString *save_filePath= [save_pathDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv",arr[0]]];
        if ([save_filePath containsString:@"_flow"]) {
            save_filePath = [save_filePath stringByReplacingOccurrencesOfString:@"flow" withString:@"_TestTime"];
        }
        
        [self saveTimeUnitLogWithFilePath:save_filePath];
        
        [ShowingLogVC postNotificationWithLog:[NSString stringWithFormat:@"Generate FCT_Cycle_Time File Path:%@",save_filePath] type:@""];
    }

}


-(NSString *)joinSendCmds:(NSMutableArray *)cmdArr{

    NSMutableString *mut_str = [[NSMutableString alloc]init];
    
    for (int i=0; i<cmdArr.count; i++) {
        SubTestMode *subMode =cmdArr[i];
        NSString *cmd = subMode.str;
        [mut_str appendString:cmd];
        if (i!=cmdArr.count-1) {
            [mut_str appendString:@"&&"];
        }
    }
    SubTestMode *fristM = cmdArr.firstObject;
    SubTestMode *newMode = [SubTestMode new];
    newMode.str = mut_str;
    newMode.indexx =fristM.indexx;
    newMode.cmdType=fristM.cmdType;
    [cmdArr removeAllObjects];
    
    [cmdArr addObject:newMode];

    return mut_str;
}

-(void)getTimeUnitItemsArr:(NSMutableArray *)testModes{
    if (!testModes.count) {
        return;
    }
    [self.timeUnitItemsArr removeAllObjects];
    NSString *lastReceive = @"";
    double totalIntervalTime=0;
    double totalIdleTime=0;
    
    double totalIntervalTime_diags=0;
    double totalIdleTime_diags=0;
    double totalIntervalTime_fixture=0;
    double totalIdleTime_fixture=0;
    double items_time=0;
    double total_softwareTime=0;
    for (int i =0; i<testModes.count; i++) {
        TestMode *itemMode = testModes[i];
        NSArray *commModeArr = itemMode.commModeInofs;
        if (!commModeArr.count) {
            TimeUnit *time_unit = [TimeUnit new];
            time_unit.testName = itemMode.testName;
            time_unit.subTestName=itemMode.subTestName;
            time_unit.subSubTestName=itemMode.subSubTestName;
            time_unit.itemTime =itemMode.itemTime;
            time_unit.isAnomaly=itemMode.isAnomaly;
            
            items_time = items_time +itemMode.itemTime;
            
            if (itemMode.isIboot) {
                time_unit.isAnomaly=YES;
                time_unit.cmdType = CommandTypeDut;
                time_unit.send = @"iboot";
                time_unit.full_send = itemMode.item_filterStrArr.firstObject;
                time_unit.receive = itemMode.last_resultStr;
                double idleTime = [time_unit idleTime:lastReceive send:time_unit.full_send];
                totalIdleTime_diags = totalIdleTime_diags + idleTime;
                totalIdleTime= totalIdleTime + idleTime;
                
                time_unit.intervalTime = itemMode.itemTime;
            }else{
                time_unit.cmdType = CommandTypeFixture;
                time_unit.send = @"";
                time_unit.receive = itemMode.last_resultStr;
                time_unit.idleTime =0;
                time_unit.softwareTime=itemMode.itemTime;
                total_softwareTime = total_softwareTime+time_unit.softwareTime;
               // time_unit.total_softwareTime = total_softwareTime;
                // time_unit.idleTime = itemMode.itemTime;
                //totalIdleTime_fixture= totalIdleTime_fixture + time_unit.idleTime;
                //totalIdleTime= totalIdleTime + time_unit.idleTime;
                
                time_unit.intervalTime = 0;
            }
            

            [self.timeUnitItemsArr addObject:time_unit];
            lastReceive = time_unit.receive;
            
            
        }else{
            for (int j=0; j<commModeArr.count; j++) {
                CommMode *commMode = commModeArr[j];
                TimeUnit *time_unit = [TimeUnit new];
                time_unit.isAnomaly=itemMode.isAnomaly;
                time_unit.testName = itemMode.testName;
                time_unit.subTestName=itemMode.subTestName;
                time_unit.subSubTestName=itemMode.subSubTestName;
                if (j==0) {

                    items_time = items_time +itemMode.itemTime;
                    time_unit.itemTime =itemMode.itemTime;
                }else{
                    time_unit.itemTime =0;
                }
                
                time_unit.cmdType = commMode.cmdType;
                NSString *cmd_send =commMode.send;
                NSString *receive =commMode.recived;
                time_unit.send = cmd_send;
                time_unit.receive = receive;
                
                if (i==0&&j==0) {
                    time_unit.idleTime=0;
                }else{
                    double idleTime = [time_unit idleTime:lastReceive send:cmd_send];
                    //                totalIdleTime_diags = totalIdleTime_diags + str_idleTime.floatValue;
                    
                    if (time_unit.cmdType ==CommandTypeDut) {
                        totalIdleTime_diags = totalIdleTime_diags + idleTime;
                    }else{
                        totalIdleTime_fixture= totalIdleTime_fixture + idleTime;
                    }
                    
                    totalIdleTime= totalIdleTime + idleTime;
                }
                
                double intervalTime = [time_unit interval_time:receive send:cmd_send];
                if (time_unit.cmdType ==CommandTypeDut) {
                    totalIntervalTime_diags = totalIntervalTime_diags + intervalTime;
                }else{
                    totalIntervalTime_fixture= totalIntervalTime_fixture + intervalTime;
                }
                
                totalIntervalTime= totalIntervalTime +intervalTime;
                [self.timeUnitItemsArr addObject:time_unit];
                
                lastReceive = receive;
                
            }
        }
 
    }
    
    for (int k=0; k<self.timeUnitItemsArr.count; k++) {
        TimeUnit *time_unit = self.timeUnitItemsArr[k];
        
        double per_interval = time_unit.intervalTime/totalIntervalTime *100;
        time_unit.perIntervalTime =per_interval;
//        if (totalIntervalTime==0) {
//            float per_interval = time_unit.intervalTime.floatValue/totalIntervalTime *100;
//            time_unit.perIntervalTime =[NSString stringWithFormat:@"%f",per_interval];
//        }else{
//            time_unit.perIntervalTime=@"0";
//        }
        double per_idle = time_unit.idleTime/totalIdleTime *100;
        time_unit.perIdleTime =per_idle ;
//        if (totalIdleTime>0) {
//            float per_idle = time_unit.idleTime.floatValue/totalIdleTime *100;
//            time_unit.perIdleTime =[NSString stringWithFormat:@"%f",per_idle] ;
//        }else{
//            time_unit.perIdleTime=@"0";
//        }
//        
        time_unit.totalIntervalTime_diags =totalIntervalTime_diags;
        time_unit.totalIdleTime_diags = totalIdleTime_diags;
        
        time_unit.totalIntervalTime =totalIntervalTime;
        time_unit.totalIdleTime = totalIdleTime;
        
        time_unit.totalIntervalTime_fixture =totalIntervalTime_fixture;
        time_unit.totalIdleTime_fixture = totalIdleTime_fixture;
        time_unit.itemsTime = items_time;
    }
    self.timeUnitItemsArr.lastObject.total_softwareTime = total_softwareTime;
}


-(NSMutableString *)textString:(NSMutableString *)text appendString:(NSString *)str{
    if (str==nil|| !str.length) {
        str=@"";
    }
    [text appendString:[NSString stringWithFormat:@"%@,",str]];
    return text;
}
-(NSMutableString *)textString:(NSMutableString *)text appendVaule:(double)vaule{
    NSString *str = @"";
    if (vaule>0) {
       str = [NSString stringWithFormat:@"%f",vaule] ;
    }
    [text appendString:[NSString stringWithFormat:@"%@,",str]];
    return text;
}

-(void)saveTimeUnitLogWithFilePath:(NSString *)path {

    if (!self.timeUnitItemsArr.count) {
        return;
    }
    NSString *title=@"Item,SubItem,SubSubItem,Item_Execut_Time,Software_Parses_Computation_ Time(s),Diags_Execution_Time(s),Diags_Execution_Time/Total_Time (%),Diags_Idle_Time(s),Diags_Idle_Time/Total_Time(%),Fixture_Execution_Time(s),Fixture_Execution_Time/Total_Time (%),Fixture_Idle_Time(s),Fixture_Idle_Time/Total_Time(%),Fixture_Cmd,Diags_Cmd,Time_Send,Time_Recivice\n";
    NSMutableString *text = [[NSMutableString alloc] initWithFormat:@"%@", title];
    double diagsTime_longest = 0;
    NSString *cmd_longest = @"";
    for (int i=0; i<self.timeUnitItemsArr.count; i++) {
        TimeUnit *time_unit = self.timeUnitItemsArr[i];
       
        [self textString:text appendString:time_unit.testName];
        [self textString:text appendString:time_unit.subTestName];
        [self textString:text appendString:time_unit.subSubTestName];

       // NSString *item_timeStr = i ? @"" : time_unit.itemTime;
    
        [self textString:text appendVaule:time_unit.itemTime];
        [self textString:text appendVaule:time_unit.softwareTime];
        if ([time_unit.testName containsString:@"USBC"] &&[time_unit.subTestName containsString:@"USB2.0_Data_Transfer@TOP-PD_SOURCE_CC1"]&&[time_unit.subSubTestName containsString:@"Usbfs_Mounted"]) {//cwdebug
            NSLog(@"1");
            //                ==Test: USBC
            //                ==SubTest: USB2.0_Data_Transfer@TOP-PD_SOURCE_CC1
            //                ==SubSubTest: Usbfs_Mounted
        }
        if (time_unit.cmdType == CommandTypeDut) {
            if (time_unit.isAnomaly==NO ) {
                if (time_unit.intervalTime >=diagsTime_longest) {
                    
                    diagsTime_longest =time_unit.intervalTime;
                    cmd_longest = time_unit.send;
                }
            }

            [self textString:text appendVaule:time_unit.intervalTime];
            [self textString:text appendVaule:time_unit.perIntervalTime];
            
            [self textString:text appendVaule:time_unit.idleTime];
            [self textString:text appendVaule:time_unit.perIdleTime];
            for (int i =0; i<5; i++) {
                [self textString:text appendString:@""];
            }
            [self textString:text appendString:time_unit.send];
        }else{
            for (int i =0; i<4; i++) {
                [self textString:text appendString:@""];
            }
            [self textString:text appendVaule:time_unit.intervalTime];
            [self textString:text appendVaule:time_unit.perIntervalTime];
            
            [self textString:text appendVaule:time_unit.idleTime];
            [self textString:text appendVaule:time_unit.perIdleTime];
            [self textString:text appendString:time_unit.send];
            [self textString:text appendString:@""];
         
        }
        [self textString:text appendString:time_unit.full_send];
        [self textString:text appendString:time_unit.time_receive];
        
        [text appendString:@"\n"];
       // [self textString:text appendString:item_mode.testName];
    }
    
    TimeUnit *time_unit_last = self.timeUnitItemsArr.lastObject;
    NSString *Execution_Time_Total = [NSString stringWithFormat:@"Diags&Fixture_Execution_Time_Total:%f",time_unit_last.totalIntervalTime];
    NSString *Execution_IdleTime_Total = [NSString stringWithFormat:@"Diags&Fixture_Idle_Time_Total:%f",time_unit_last.totalIdleTime];
    
    NSString *Diags_Execution_Time_Total = [NSString stringWithFormat:@"Diags_Execution_Time_Total:%f",time_unit_last.totalIntervalTime_diags];
    NSString *Diags_Idle_Time_Total = [NSString stringWithFormat:@"Diags_Idle_Time_Total:%f",time_unit_last.totalIdleTime_diags];
    
    NSString *fixture_Execution_Time_Total = [NSString stringWithFormat:@"Fixture_Execution_Time_Total:%f",time_unit_last.totalIntervalTime_fixture];
    NSString *fixture_Idle_Time_Total = [NSString stringWithFormat:@"Fixture_Idle_Time_Total:%f",time_unit_last.totalIdleTime_fixture];
    NSString *ItemsTime_Total = [NSString stringWithFormat:@"Items_Time_Total:%f",time_unit_last.itemsTime];
    
    NSString *swTime_Total = [NSString stringWithFormat:@"Software_Parses_Computation_Time_Total:%f",time_unit_last.total_softwareTime];
    [text appendString:ItemsTime_Total];
    [text appendString:@"\n"];
    
    [text appendString:swTime_Total];
    [text appendString:@"\n"];
    
    [text appendString:Execution_Time_Total];
    [text appendString:@"\n"];
    [text appendString:Execution_IdleTime_Total];
    [text appendString:@"\n"];
    
    [text appendString:Diags_Execution_Time_Total];
    [text appendString:@"\n"];
    [text appendString:Diags_Idle_Time_Total];
    [text appendString:@"\n"];
    
    [text appendString:fixture_Execution_Time_Total];
    [text appendString:@"\n"];
    [text appendString:fixture_Idle_Time_Total];
    [text appendString:@"\n"];
   
    [text appendString:[NSString stringWithFormat:@"Diags_Iboot_Frist_Time:%f",[self getIboot1_time:csvPath]]];
    [text appendString:@"\n"];
    
    [text appendString:[NSString stringWithFormat:@"Diags_Iboot_Seconde_Time:%f",[self getIboot2_time:csvPath]]];
    [text appendString:@"\n"];
    [text appendString:[NSString stringWithFormat:@"Diags_Execution_Longest_Time:%f,Command:%@",diagsTime_longest,cmd_longest]];
   // Diags_Execution_Time_Total: 1094.845188
    //Diags_Idle_Time_Total: 12.807252
    NSError *error;
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(error){
        NSLog(@"save file error %@",error);
    }
}

-(void)saveLogWithFilePath:(NSString *)path{
    
    
    NSString *debug_path=@"/Users/ciweiluo/Desktop/prase_log_debug.csv";
    if (!self.testModes.count) {
        return;
    }
    
    NSMutableString *text = [[NSMutableString alloc] init];
    NSMutableString *text_debug = [[NSMutableString alloc] init];
    for (int i=0; i<self.testModes.count; i++) {
        TestMode *item_mode = self.testModes[i];
        
        [self textString:text_debug appendString:item_mode.testName];
        [self textString:text_debug appendString:item_mode.subTestName];
        [self textString:text_debug appendString:item_mode.subSubTestName];
        [self textString:text_debug appendString:item_mode.item_str];
        [self textString:text_debug appendString:item_mode.item_filterStr];
        [text_debug appendString:@"\n"];
        
        
        NSArray *commInofs=item_mode.commInofs;
        if (commInofs.count) {
            for (int k=0; k<commInofs.count; k++) {
                SubTestMode *item_subMode = commInofs[k];
                if (k%2==0) {
                    [self textString:text appendString:item_mode.testName];
                    [self textString:text appendString:item_mode.subTestName];
                    [self textString:text appendString:item_mode.subSubTestName];
                }
                
                [self textString:text appendString:item_subMode.str];
                if (k%2==1) {
                    [text appendString:@"\n"];
                }

            }

        }
        
    }
    [text_debug writeToFile:debug_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSError *error;
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"save file error %@",error);
    }
}

- (NSString *)removeSpaceAndNewline:(NSString *)str{
    
    NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
    return text;
}


-(BOOL)is_need_delete:(NSString *)str{

    BOOL b = NO;
    if ([str containsString:@":-)"]) {
        NSString *mut_str=[str cw_getSubstringFromStringToEnd:@":-)"];
        NSString *st = [self removeSpaceAndNewline:mut_str];
//        len = st.length;
        if (st.length>2) {
            b=YES;
        }

    }
    
    if (!str.length) {
        b=YES;
    }
    
    if (!([str containsString:@"2020-"]||[str containsString:@"2019-"])) {
        b=YES;
        if ([str containsString:@":-)"] || [str containsString:@"Starting application"]) {
            b=NO;
        }
    }
    if ([str containsString:@"cmd-send:"]) {
        NSString *string =[str cw_getSubstringFromStringToEnd:@"cmd-send:"];
        if (string.length<=2) {
            b=YES;
        }else{
           b=NO;
        }
        
    }
    if ([str containsString:@"[sendcmd]:"]) {
        if ([[str cw_getSubstringFromStringToEnd:@"[sendcmd]:"] length]<2) {
            b=YES;
        }else{
            b=NO;
        }
        
    }
    if ([str containsString:@"value"]&&[str containsString:@"lower"]&&[str containsString:@"upper"]) {
        b=NO;
    }
    
    return b;
    
}


-(void)getDiagsReply:(NSArray *)arr mode:(TestMode *)mode{
    for (int i =0; i<arr.count; i++) {
        
    }
    
    
    return ;
}



- (IBAction)start:(NSButton *)sender {

    
    if (_csvFilesArr.count) {
        csvPath =_csvFilesArr[0];
        
        [self parseFlowLog:csvPath];
        
    }
//    if (_csvFilesArr.count==3) {
//        [self Calculate:_csvFilesArr[1] filePathUart2:_csvFilesArr[2]];
//    }
    //NSString *python_uart_file = [[NSBundle mainBundle] pathForResource:@"parse_uart.py" ofType:nil];
//    NSString *python_flow_file = [[NSBundle mainBundle] pathForResource:@"parse_flow.py" ofType:nil];
//    NSArray *csvPathArr = [NSArray arrayWithObjects:csvPath, nil];
   // NSString *python_file = python_uart_file;
//    if ([csvPath containsString:@"flow.log"]) {
//        python_file=python_flow_file;
//    }
//    PythonTask *pTask = [[PythonTask alloc]initWithPythonPath:python_uart_file parArr:self.csvFilesArr];
//    NSString *read = [pTask read];
//    [ShowingLogVC postNotificationWithLog:read type:@""];
   // csvPath=@"";

}



- (IBAction)open:(NSButton *)sender {
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    //NSString *openPath =[[NSBundle mainBundle] resourcePath];
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
            NSString *file_dir = @"";
            NSArray *urls=[openPanel URLs];
            
            for (int i=0; i<[urls count]; i++)
            {
                file_dir = [[urls objectAtIndex:i] path];
                
            }
//
//            if ([csvPath containsString:@"flow.log"]) {//||[csvPath containsString:@"uart"]||[csvPath containsString:@"hw.log"]
//
//                [ShowingLogVC postNotificationWithLog:@"open file success" type:@""];
//                //                [ShowingLogVC postNotificationWithLog:self.csvFilesArr[0] type:@""];
//                //                [ShowingLogVC postNotificationWithLog:self.csvFilesArr[1] type:@""];
//                self.btnStart.enabled = YES;
//            }else{
//                [ShowingLogVC postNotificationWithLog:@"open file fail" type:@""];
//                self.btnStart.enabled = NO;
//            }
            
            
                   NSMutableArray *csv_flow_files=[[NSMutableArray alloc]init];
                        NSMutableArray *csv_uart_files=[[NSMutableArray alloc]init];
                        NSMutableArray *csv_uart2_files=[[NSMutableArray alloc]init];
                         NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:file_dir error:nil];
                        for (NSString *str in tmplist) {
                            NSLog(@"1");
                            if ([str containsString:@"uart.txt"]) {
                                [csv_uart_files addObject:[ file_dir stringByAppendingPathComponent:str]];
                            }else if ([str containsString:@"uart2.txt"]){
                                [csv_uart2_files addObject:[file_dir stringByAppendingPathComponent:str]];
            
                            }else if ([str containsString:@"flow.log"]){
                                [csv_flow_files addObject:[file_dir stringByAppendingPathComponent:str]];
                                
                            }
                        }
            
                        if (csv_uart_files.count && csv_uart2_files.count&&csv_flow_files.count) {
            
                            [self get_csvFilesArr:csv_uart_files csv_uart2_files:csv_uart2_files csv_flow_files:csv_flow_files];
                            [ShowingLogVC postNotificationWithLog:@"open file success" type:@""];
            //                [ShowingLogVC postNotificationWithLog:self.csvFilesArr[0] type:@""];
            //                [ShowingLogVC postNotificationWithLog:self.csvFilesArr[1] type:@""];
                            self.btnStart.enabled = YES;
                        }else{
                            [ShowingLogVC postNotificationWithLog:@"open file fail" type:@""];
                            self.btnStart.enabled = NO;
                        }
            
        }
    }];
}

-(void)get_csvFilesArr:(NSArray *)csv_uart_files csv_uart2_files:(NSArray *)csv_uart2_files  csv_flow_files:csv_flow_files{
    [self.csvFilesArr removeAllObjects];
    NSString *flow_file =csv_flow_files[0];
    [self.csvFilesArr addObject:flow_file];
    NSString *key = [flow_file cw_getStringBetween:@"_FCT_" and:@"__"];
    if (!key.length) {
        [self.csvFilesArr addObject:csv_uart_files[0]];
        [self.csvFilesArr addObject:csv_uart2_files[0]];
    }else{
        for (NSString *file in csv_uart_files) {
            if ([file containsString:key]) {
                [self.csvFilesArr addObject:file];
                break;
            }
        }
        
        for (NSString *file in csv_uart2_files) {
            if ([file containsString:key]) {
                [self.csvFilesArr addObject:file];
                break;
            }
        }
        
        if (self.csvFilesArr.count!=3) {
            [self.csvFilesArr addObject:csv_uart_files[0]];
            [self.csvFilesArr addObject:csv_uart2_files[0]];
        }
    }
}



- (void)openFilesss
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
//            if ([self->csv_uart_files count]>0 && [self->csv_uart2_files count]>0)
//            {
//
//                [self->_txtCreateFilePath setStringValue:@"Please click START to calculate the time!!!"];
//            }
//            else
//            {
//                [self->_txtCreateFilePath setStringValue:@"choose Folder error!!!"];
//            }


        }
    }];
}

- (void)Calculate:(NSString *)filePathUart1 filePathUart2:(NSString *)filePathUart2
{
//    if ([self->csv_uart_files count]<1 || [self->csv_uart2_files count]<1)
//    {
//        [_txtCreateFilePath setStringValue:@"choose file error!!!"];
//        return;
//    }
//
//    [_txtCreateFilePath setStringValue:@""];
    NSError *error=nil;
    //NSLog(@"file path : %@",[_txtFilePathUart stringValue]);
//    NSString * filePathUart1 = self->csv_uart_files[0];
//    NSString * filePathUart2 = self->csv_uart2_files[0];

//
    NSString *filePath_calculate=@"";
    NSString *save_pathDirectory = [[NSString cw_getDesktopPath]stringByAppendingPathComponent:@"FCT_Cycle_Time"];
    [CWFileManager cw_createFile:save_pathDirectory isDirectory:YES];
    NSArray *arr =[filePathUart1.lastPathComponent cw_componentsSeparatedByString:@"."];
    if (arr.count==2) {
        filePath_calculate= [save_pathDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv",arr[0]]];
        
        [ShowingLogVC postNotificationWithLog:[NSString stringWithFormat:@"Generate FCT_Cycle_Time File Path:%@",filePath_calculate] type:@""];
    }else{
        return;
    }
    
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"YYYY_MM_dd__HH_mm_ss"];
//    NSDate *datenow = [NSDate date];
//    NSString *currentTimeString = [formatter stringFromDate:datenow];
//    NSString *pathNoExtension = [filePathUart1 stringByDeletingPathExtension];
//    NSString *filePath_calculate=[NSString stringWithFormat:@"%@_%@.csv",pathNoExtension,currentTimeString];
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
    //[_txtCreateFilePath setStringValue:filePath_calculate];
   // [_txtFilePathUart setStringValue:@""];

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
        double time =hour+minute+second;
        return time;
    }
    return 0.0;
}
//-(void)test3{
//    
//    NSError *error1;
//    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",@"adc"];//&xx=lkw&dalsjd=12
//    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:regTags
//                                                                            options:NSRegularExpressionCaseInsensitive
//                                                                              error:&error1];
//    
//    // 执行匹配的过程
//    NSString *webaddress=@"http://www.baidu.com/dd/adb.htm?adc=e12&xx=lkw&dalsjd=12";
//    NSArray *matches = [regex1 matchesInString:webaddress
//                                       options:0
//                                         range:NSMakeRange(0, [webaddress length])];
//    for (NSTextCheckingResult *match in matches) {
//        
//        NSString *tagValue = [webaddress substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
//        //    NSLog(@"分组2所对应的串:%@\n",tagValue);
//        NSLog(@"tagvalue = %@",tagValue);
//        
//    }
//    
//}
//
//-(void)test1{
//    NSString *regex = @"\\-\\d*\\.";// \\-\\d*\\.
//    NSString *str = @"-111.-666.-888.";
//    NSError *error;
//    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
//                                                                             options:NSRegularExpressionCaseInsensitive
//                                                                               error:&error];
//    // 对str字符串进行匹配
//    NSArray *matches = [regular matchesInString:str
//                                        options:0
//                                          range:NSMakeRange(0, str.length)];
//    // 遍历匹配后的每一条记录
//    for (NSTextCheckingResult *match in matches) {
//        NSRange range = [match range];
//        NSString *mStr = [str substringWithRange:range];
//        NSLog(@"%@", mStr);
//    }
//}
//-(void)test{
//    NSString *url = @"8888@163.com";
//    NSError *error;
//    // 创建NSRegularExpression对象并指定正则表达式
//    NSRegularExpression *regex = [NSRegularExpression
//                                  regularExpressionWithPattern:@"\\@\\d*\\."
//                                  options:0
//                                  error:&error];
//    if (!error) { // 如果没有错误
//        // 获取特特定字符串的范围
//        NSTextCheckingResult *match = [regex firstMatchInString:url
//                                                        options:0
//                                                          range:NSMakeRange(0, [url length])];
//        if (match) {
//            // 截获特定的字符串
//            NSString *result = [url substringWithRange:match.range];
//            NSLog(@"%@",result);
//        }
//    } else { // 如果有错误，则把错误打印出来
//        NSLog(@"error - %@", error);
//    }
//}
//
//
//-(BOOL)stringMatch:(NSString *)string regex:(NSString *)regex {
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    if ([predicate evaluateWithObject:string]) {
//        return YES;
//    }
//    return NO;
//}
@end
