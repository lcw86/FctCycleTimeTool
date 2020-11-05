//
//  PythonTask.h
//  TestDemo
//
//  Created by ciwei luo on 2020/4/20.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PythonTask : NSObject

//-(BOOL)Init:(NSString*)path port:(NSString*) portName;
-(instancetype)initWithPythonPath:(NSString*)path parArr:(NSArray *)parArr;
-(NSString*)send:(NSString*)command;
-(NSString*)timeoutsend:(NSString*)command;
-(BOOL)close;
-(BOOL)isOpen;
-(NSString*)read;
@end

NS_ASSUME_NONNULL_END
