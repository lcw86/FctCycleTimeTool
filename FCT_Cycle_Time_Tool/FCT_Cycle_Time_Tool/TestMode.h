//
//  TestMode.h
//  TestDemo
//
//  Created by ciwei luo on 2020/4/21.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubTestMode.h"
NS_ASSUME_NONNULL_BEGIN
//typedef NSUInteger TestModeCmdType;
//NS_ENUM(TestModeCmdType) {
//     TestModeCmdTypeXavier= 1,
//     TestModeCmdTypeDut= 2,
//     TestModeCmdTypePower= 3,
//
//    };

@interface CommMode : NSObject

@property (nonatomic)CommandType cmdType;
@property (nonatomic,copy)NSString *send;
@property (nonatomic,copy)NSString *recived;
@end

@interface TestMode : NSObject

//@property (nonatomic)TestModeCmdType cmdType;
@property (nonatomic,strong)NSMutableArray<SubTestMode *> *diagsSendCmds;
@property (nonatomic,strong)NSMutableArray<SubTestMode *> *diagsReplys;
@property (nonatomic,strong)NSMutableArray<SubTestMode *> *xavierSendCmds;
@property (nonatomic,strong)NSMutableArray<SubTestMode *> *xavierReplys;

@property (nonatomic,strong)NSMutableArray<SubTestMode *> *commInofs;

@property (nonatomic,strong)NSMutableArray<CommMode *> *commModeInofs;
@property (nonatomic)BOOL isAnomaly;

@property NSInteger item_index;
-(BOOL)sortCmdsAndReplys;
@property (nonatomic) BOOL isIboot;
+(instancetype)testMode;
@property (nonatomic) double itemTime;
@property (nonatomic,copy) NSString * last_resultStr;
//@property (nonatomic,copy) NSString *itemTime;
@property (nonatomic,copy) NSString *testName;
@property (nonatomic,copy) NSString *subTestName;
@property (nonatomic,copy) NSString *subSubTestName;

@property (nonatomic,strong) NSArray *item_filterStrArr;
@property (nonatomic,strong) NSArray *item_strArr;

@property (nonatomic,copy) NSString *item_filterStr;
@property (nonatomic,copy) NSString *item_str;

@property float totalIntervalTime;
@property float totalIdleTime;
-(float)get_item_time:(NSArray *)mut_arr last_fillterArr:(NSArray *)last_fillterArr;
@end

NS_ASSUME_NONNULL_END
