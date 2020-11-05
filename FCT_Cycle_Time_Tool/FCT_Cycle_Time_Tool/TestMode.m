//
//  TestMode.m
//  TestDemo
//
//  Created by ciwei luo on 2020/4/21.
//  Copyright © 2020 macdev. All rights reserved.
//
#import <CWGeneralManager/NSString+Extension.h>
#import "TestMode.h"

@implementation CommMode
@end
@interface TestMode ()
@property (nonatomic,strong)NSMutableArray<SubTestMode *> *mutCommInofs;
@end


@implementation TestMode

+(instancetype)testMode{
    TestMode *mode = [TestMode new];
    mode.xavierSendCmds = [[NSMutableArray alloc]init];
    mode.xavierReplys=[[NSMutableArray alloc]init];
    mode.diagsReplys = [[NSMutableArray alloc]init];
    mode.diagsSendCmds=[[NSMutableArray alloc]init];
    
    mode.commInofs = [[NSMutableArray alloc]init];
    
    mode.mutCommInofs= [[NSMutableArray alloc]init];
    mode.commModeInofs =[[NSMutableArray alloc]init];

    return mode;
}

-(NSMutableArray *)commModeInofs{
    
    if (_commModeInofs.count) {
        return _commModeInofs;
    }
    NSArray *commInofArr = self.commInofs;
    
    if (commInofArr.count && commInofArr.count%2==0) {
        NSMutableArray *mutArr = [[NSMutableArray alloc]init];
        CommMode *commM = nil;
   
        for (int i=0; i<commInofArr.count; i++) {
            SubTestMode *subTMode = commInofArr[i];
            CommandType type =subTMode.cmdType;
            NSString *cmd = subTMode.str;

            if (i%2==0) {
                commM = [CommMode new];
                
                commM.send = cmd;
                if ([cmd containsString:@"]ACK"]) {
                    NSLog(@"1");
                }
                
                commM.cmdType = type;
                
            }else{
                commM.recived = cmd;
                [mutArr addObject:commM];
            }
        }
        
        _commModeInofs = [NSMutableArray arrayWithArray:mutArr];
    }else{
        
    }
    
    return _commModeInofs;
}

-(BOOL)sortCmdsAndReplys{
    BOOL b = YES;
    NSMutableArray *commInfs = [self joint_send_reply_cmds];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"indexx" ascending:YES];
    _commInofs =[[NSMutableArray alloc] initWithArray:[commInfs sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    for (int i =0; i<_commInofs.count; i++) {
        SubTestMode *subTMode = _commInofs[i];
        NSString *cmd = subTMode.str;//101748

        if (i%2==0) {//cmd-send:
            if (!([cmd containsString:@"[sendcmd]:"] || [cmd containsString:@"cmd-send:"])) {
                b= NO;
                _isAnomaly=YES;
                break;
            }
        }else{
//            if (![cmd containsString:@"]ACK("]) {
//                return NO;
//            }
        }
    }
    
    if (!b) {
        NSMutableArray *mut_commInf = [[NSMutableArray alloc] initWithArray:_commInofs];
        [_commInofs removeAllObjects];
        [_commInofs addObject:mut_commInf.firstObject];
        [_commInofs addObject:mut_commInf.lastObject];
    }
    
    return b;
}



-(NSMutableArray *)joint_send_reply_cmds{
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    if (_diagsSendCmds.count) {
        for (SubTestMode *sub_mode in _diagsSendCmds) {
            [mutArr addObject:sub_mode];
        }
    }
    if (_diagsReplys.count) {
        for (SubTestMode *sub_mode in _diagsReplys) {
            [mutArr addObject:sub_mode];
        }
    }
    if (_xavierSendCmds.count) {
        for (SubTestMode *sub_mode in _xavierSendCmds) {
            [mutArr addObject:sub_mode];
        }
    }
    if (_xavierReplys.count) {
        for (SubTestMode *sub_mode in _xavierReplys) {
            [mutArr addObject:sub_mode];
        }
    }
    return mutArr;
}


-(void)setSubTestName:(NSString *)subTestName{
    if ([subTestName containsString:@"==SubTest: "]) {
        _subTestName = [subTestName stringByReplacingOccurrencesOfString:@"==SubTest: " withString:@""];
    }else{
        _subTestName=subTestName;
    }
}

-(void)setSubSubTestName:(NSString *)subSubTestName{
    if ([subSubTestName containsString:@"==SubSubTest: "]) {
        _subSubTestName = [subSubTestName stringByReplacingOccurrencesOfString:@"==SubSubTest: " withString:@""];
    }else{
        _subSubTestName=subSubTestName;
    }
}

-(void)setItem_strArr:(NSArray *)item_strArr{
    if (item_strArr.count) {
        NSMutableString *text = [[NSMutableString alloc] init];
        for (int i =0; i<item_strArr.count; i++) {
            NSString *str=item_strArr[i];
            NSString *new_str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
            [text appendString:new_str];
        }
        _item_str =[ NSString stringWithFormat:@"%@",text];
    }
    _item_strArr =item_strArr;
}



-(NSMutableString *)textString:(NSMutableString *)text appendString:(NSString *)str{
    if (str==nil) {
        str=@"";
    }
    [text appendFormat:@"%@", [NSString stringWithFormat:@"%@,",str]];
    return text;
}


//-(float)itemTime{
//    _itemTime =[self get_item_time:_item_filterStrArr];
//    return _itemTime;
//}

-(float)get_item_time:(NSArray *)mut_arr last_fillterArr:(NSArray *)last_fillterArr{
    
    if (!mut_arr.count || !last_fillterArr.count) {
        return 0;
    }
    NSString *last_resultStr =last_fillterArr.lastObject;
    double item_time =[self interval_time:mut_arr.lastObject send:last_resultStr];
    _itemTime = item_time;
    return item_time;
}

-(double)interval_time:(NSString *)receive send:(NSString *)send{
    double interval = 0;
    if (send.length && receive.length) {
        
        double time1 =  [self str2time:receive];
        
        double time2 =  [self str2time:send];
        
        double interval = time1-time2;
        
        if (interval<=0) {
            interval=0;
        }
        
        return interval;
       // interval_str=[NSString stringWithFormat:@"%f",time];
        
    }

    return interval;
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
-(void)setItem_filterStrArr:(NSArray *)item_filterStrArr{
    
    if (item_filterStrArr.count) {
        //_itemTime = [self get_item_time:item_filterStrArr];
        NSMutableString *text = [[NSMutableString alloc] init];
        for (int i =0; i<item_filterStrArr.count; i++) {
            NSString *str=item_filterStrArr[i];
            NSString *new_str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
            [text appendString:new_str];
 
        }//Entering recovery mode
        if ([text containsString:@"pmu: flt 0f"]||[text containsString:@"task #0, file:"]||[text containsString:@"Entering recovery mode"]) {
            _isIboot = YES;
        }
        _item_filterStr =[ NSString stringWithFormat:@"%@",text];
    }
    

    _last_resultStr = item_filterStrArr.lastObject;
    _item_filterStrArr = item_filterStrArr;
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


@end
