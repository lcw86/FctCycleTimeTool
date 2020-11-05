//
//  TimeUnit.m
//  TestDemo
//
//  Created by ciwei luo on 2020/4/22.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "TimeUnit.h"
#import <CWGeneralManager/NSString+Extension.h>

@implementation TimeUnit

-(void)setSend:(NSString *)send{

    if ([send containsString:@"\r"]) {
        NSArray *arr = [send componentsSeparatedByString:@"\r"];
        if (arr.count) {
            send = arr[0];
        }
    }

    
    send=[send stringByReplacingOccurrencesOfString:@"," withString:@"'"];
    send=[send stringByReplacingOccurrencesOfString:@"\r" withString:@"'"];
    send=[send stringByReplacingOccurrencesOfString:@"\n" withString:@"'"];
    send=[send stringByReplacingOccurrencesOfString:@"\r\n" withString:@"'"];
    send=[self removeSpaceAndNewline:send];

    NSArray *sendArr=nil;
    if ([send containsString:@"&&"]) {
        sendArr = [send cw_componentsSeparatedByString:@"&&"];
      
    }else{
        sendArr = [[NSArray alloc]initWithObjects:send, nil];
    }
    NSMutableString *mut_sendStr =[[NSMutableString alloc]init];
    for (int i=0; i<sendArr.count; i++) {
        NSString *send_str=sendArr[i];
        
        if ([send_str containsString:@"[sendcmd]:"]) {
            NSString *mut_string = [send_str cw_getSubstringFromStringToEnd:@"[sendcmd]:"];
            if (mut_string.length >14 && [mut_string containsString:@"]"] &&[mut_string containsString:@"["]) {
                mut_string = [mut_string cw_getSubstringFromStringToEnd:@"]"];
            }
            [mut_sendStr appendString:[NSString stringWithFormat:@"%@",mut_string]];
        }else if ([send_str containsString:@"cmd-send:"]){
            NSString *mut_string = [send_str cw_getSubstringFromStringToEnd:@"cmd-send:"];
            [mut_sendStr appendString:[NSString stringWithFormat:@"%@",mut_string]];
        }
        
        else{
         
            [mut_sendStr appendString:send_str];
        }
        if (i!=sendArr.count-1) {
            [mut_sendStr appendString:@"&&"];
        }
    
    }
    if (send.length>=27) {
        self.full_send = [send cw_getSubstringFromIndex:0 toLength:27];
    }else{
        self.full_send =@"none";
    }
    _send = [NSString stringWithFormat:@"%@",mut_sendStr];


}
//receive    __NSCFString *    @"2020-04-21 10:20:16.493883          2020/04/21 10:20:16.493 :  [a5e57d6ec5bd]ACK(DONE;46458,764,46458,772,8)"    0x0000600002c02700
-(void)setFull_send:(NSString *)full_send{
    _full_send=full_send;
    _full_send = [_full_send stringByReplacingOccurrencesOfString:@"," withString:@"'"];
    _full_send = [_full_send stringByReplacingOccurrencesOfString:@"\r" withString:@"'"];
    _full_send = [_full_send stringByReplacingOccurrencesOfString:@"\n" withString:@"'"];
}


-(void)setReceive:(NSString *)receive{//str
    
    if ([receive containsString:@"\r"]) {
        NSArray *arr = [receive componentsSeparatedByString:@"\r"];
        if (arr.count) {
            receive = arr[0];
        }
    }

    
    
    NSString *new_receive = [receive stringByReplacingOccurrencesOfString:@"," withString:@"'"];
    
    new_receive = [new_receive stringByReplacingOccurrencesOfString:@"\n" withString:@"'"];
    new_receive = [self removeSpaceAndNewline:new_receive];
//    if ([new_receive containsString:@"]ACK("]) {
//        NSString *mut_receive = [new_receive cw_getSubstringFromStringToEnd:@"]ACK("];
//        _receive = [NSString stringWithFormat:@"ACK(%@",mut_receive];
//    }else{
//        _receive=new_receive;
//    }
    if (receive.length>=27) {
        self.time_receive = [receive cw_getSubstringFromIndex:0 toLength:27];
    }else{
        self.time_receive =@"none";
    }
    _receive=new_receive;
   // _receive = [receive stringByReplacingOccurrencesOfString:@"," withString:@"'"];
}

- (NSString *)removeSpaceAndNewline:(NSString *)str{
    
    NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
    return text;
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

-(double)idleTime:(NSString *)last_receive send:(NSString *)send{
   // NSString *interval_str = @"0";
    if (send.length && last_receive.length) {
        
        double time1 =  [self str2time:last_receive];
     
        double time2 =  [self str2time:send];
        
        double time = time2-time1;

        if (time<=0) {
            time=0;
        }
       // interval_str=[NSString stringWithFormat:@"%f",time];
        self.idleTime=time;
        return time;

    }else{
        return 0;
    }
    
}


-(double)interval_time:(NSString *)receive send:(NSString *)send{
   // NSString *interval_str = @"0";
    if (send.length && receive.length) {
        
        double time1 =  [self str2time:receive];
        
        double time2 =  [self str2time:send];
        
        double time = time1-time2;
        
        if (time<=0) {
            time=0;
        }
        self.intervalTime=time;
        return time;
    }else{
       return 0;
    }

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



@end
