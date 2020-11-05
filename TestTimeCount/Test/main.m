//
//  main.m
//  Test
//
//  Created by RyanGao on 2018/11/14.
//  Copyright © 2018 RyanGao. All rights reserved.
//

#import <Foundation/Foundation.h>

double str2time(NSString *str)
{
    NSArray * arrayStr = [str componentsSeparatedByString:@":"];
    if ([arrayStr count]>2)
    {
        double hour = [arrayStr[0] doubleValue] * 60*60;
        double minute = [arrayStr[1] doubleValue] * 60;
        double second = [arrayStr[2] doubleValue] * 1;
        return hour+minute+second;
    }
    
    return 0.0;
}
void ddd(NSString * filePath,NSString *str)
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



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
//        [@"dndjenjencje" writeToFile:@"/Users/RyanGao/Desktop/test/11.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//
//        NSString * str1 = @"09:11:11.353748";
//        NSString * str2 = @"09:11:12.358930";
//        NSLog(@"%f",str2time(str2)-str2time(str1));
////        int a1 = [str1 intValue];
////        int a2 = [str2 intValue];
////        NSLog(@"-----%d",a2-a1);
//
//
//            NSString * filePath = @"/Users/RyanGao/Desktop/test/DLX845300BYLK461R_J217_FCT_UUT1__11-09-08-58-46_flow_plain_2018_11_14.csv";
//        NSString * str = @"ndjnvjvjf";
//        ddd(filePath,str);
//        ddd(filePath,str);
//        ddd(filePath,str);
        if([@"ddd" writeToFile:@"/Users/RyanGao/Desktop/1111.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil])
        {
            NSLog(@"------写入文件------success");
        }
        else{
            NSLog(@"------写入文件------fail,error==");
        }
        
        
      
        
        
    }
    return 0;
}
