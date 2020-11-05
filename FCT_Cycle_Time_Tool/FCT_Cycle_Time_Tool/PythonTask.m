//
//  PythonTask.m
//  TestDemo
//
//  Created by ciwei luo on 2020/4/20.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "PythonTask.h"

@implementation PythonTask
{
    BOOL isOpen;
    NSTask *task;
    NSPipe *readPipe;
    NSFileHandle *readHandle;
    NSPipe *writePipe;
    NSFileHandle *writeHandle;
}



-(instancetype)initWithPythonPath:(NSString*)path parArr:(NSArray *)parArr{
    if (self=[super init]) {
        
        task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/python"];
        NSMutableArray *mut_parArr = [[NSMutableArray alloc]initWithArray:[NSArray arrayWithObjects:path, nil]];
        if (parArr.count) {
            [mut_parArr addObjectsFromArray:parArr];
        }
        [task setArguments:mut_parArr];
        readPipe = [NSPipe pipe];
        readHandle = [readPipe fileHandleForReading];
        writePipe = [NSPipe pipe];
        writeHandle = [writePipe fileHandleForWriting];
        [task setStandardInput:writePipe];
        [task setStandardOutput:readPipe];
        [task launch];
        
    }
    return self;
}



-(NSString*)send:(NSString*)command
{
    if(isOpen == false)
    {
        return @"";
    }
    NSData * in_data = [command dataUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    [writeHandle writeData:in_data];
    usleep(200000);
    //[QThread usleep: 100];
    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    NSLog(@"\nsend command: %@ ----> %@\n", command, string);
    return string;
}


-(NSString*)read{

    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];

    return string;
}



-(BOOL)close{
    
    if(isOpen == false)
    {
        return true;
    }
    BOOL result = false;
    NSString * in_str = @"quit\n";
    NSData * in_data = [in_str dataUsingEncoding:(NSStringEncoding)NSUTF8StringEncoding];
    [writeHandle writeData:in_data];
    [writeHandle closeFile];
    usleep(100000);
    NSData *readData = [readHandle availableData];
    NSString *string = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    NSLog(@"\nsend command: %@ ----> %@\n", @"quit", string);
    if([string containsString:@"Quitting"])
    {
        isOpen = false;
        result = true;
    }
    [task waitUntilExit];
    return result;
}


-(BOOL)isOpen
{
    return isOpen;
}


@end
