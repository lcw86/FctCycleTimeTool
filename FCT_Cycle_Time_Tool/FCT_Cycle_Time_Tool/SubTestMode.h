//
//  SubTestMode.h
//  TestDemo
//
//  Created by ciwei luo on 2020/4/21.
//  Copyright © 2020 macdev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NSUInteger CommandType;
NS_ENUM(CommandType) {
    CommandTypeFixture= 1,
    CommandTypeDut= 2,
    CommandTypeUnkown= 3,
    
    };
@interface SubTestMode : NSObject
@property (nonatomic)CommandType cmdType;
@property(nonatomic) NSInteger indexx;
@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *str;

@end

NS_ASSUME_NONNULL_END
