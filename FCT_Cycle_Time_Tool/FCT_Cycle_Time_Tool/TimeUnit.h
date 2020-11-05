//
//  TimeUnit.h
//  TestDemo
//
//  Created by ciwei luo on 2020/4/22.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubTestMode.h"
NS_ASSUME_NONNULL_BEGIN

@interface TimeUnit : NSObject
@property (nonatomic)CommandType cmdType;
@property (nonatomic,copy) NSString *testName;
@property (nonatomic,copy) NSString *subTestName;
@property (nonatomic,copy) NSString *subSubTestName;
@property (nonatomic)BOOL isAnomaly;
-(double)interval_time:(NSString *)receive send:(NSString *)send;
@property double intervalTime;
//@property (nonatomic,copy) NSString *intervalTime;
//@property (nonatomic,copy) NSString *idleTime;
@property double idleTime;
@property (nonatomic,copy) NSString *send;
@property (nonatomic,copy) NSString *full_send;
@property (nonatomic,copy) NSString *time_receive;
@property (nonatomic,copy) NSString *receive;
@property (nonatomic,copy) NSString *last_receive;
@property (nonatomic) double perIntervalTime;
@property (nonatomic) double perIdleTime;
-(double)idleTime:(NSString *)last_receive send:(NSString *)send;

@property double totalIdleTime;
@property double totalIntervalTime;

@property double totalIntervalTime_diags;
@property double totalIdleTime_diags;

@property double totalIntervalTime_fixture;
@property double totalIdleTime_fixture;
@property double itemTime;
@property (nonatomic) double itemsTime;

@property (nonatomic) double softwareTime;
@property (nonatomic) double total_softwareTime;
@end

NS_ASSUME_NONNULL_END
