//
//  NSString+Extension.m
//  Smart_Charge
//
//  Created by ciwei luo on 2017/8/5.
//  Copyright © 2017 ciwei luo. All rights reserved.
//

#import "NSString+Extension.h"
#import "MyEexception.h"

@implementation NSString (Extension)

-(NSString *)cw_getSubstringFromIndex:(NSInteger)fromIndex toLength:(NSInteger)length
{
    if (self.length<(fromIndex+length)) {
        [MyEexception RemindException:@"Error" Information:@"length beyond bounds"];
        NSLog(@"length beyond bounds");
        return @"";
    }
    NSString *mutStr = [self substringFromIndex:fromIndex];
    NSString *returnString = [mutStr substringToIndex:length];
    return returnString;
}

-(NSString *)cw_getSubstringFromString:(NSString *)from toLength:(NSInteger)length
{
    
    NSString *returnString = nil;
    
    if ([self containsString:from]) {
        NSRange range1 = [self rangeOfString:from];
        NSRange range2 = NSMakeRange(range1.location+range1.length, length);
        if (range1.location+range1.length+length<=self.length) {
            returnString = [self substringWithRange:range2];
        }else{
            NSLog(@"length beyond bounds");
            [MyEexception RemindException:@"Error" Information:@"length beyond bounds"];
        }
        
    }else{
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"%@ not found %@",self,from]];
        NSLog(@"%@ not found %@",self,from);
    }
    
    return returnString;
    
}

-(NSString *)cw_getSubstringFromStringToEnd:(NSString *)from
{
    NSString *returnString = nil;
    
    if ([self containsString:from]) {
        NSRange range = [self rangeOfString:from];
        returnString = [self substringFromIndex:range.location+range.length];
    }else{
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"%@ not found %@",self,from]];
        NSLog(@"%@ not found %@",self,from);
    }
    
    return returnString;
}

-(NSString *)cw_getStringBetween:(NSString *)from and:(NSString *)to
{
    NSString *mutString = @"";
    if([self containsString:from]&&[self containsString:to])
    {
        
        NSRange range1 = [self rangeOfString:from];
        NSRange range2 = [self rangeOfString:to];
        
        NSInteger tempLength =range2.location-range1.location-range1.length;
        NSRange range = {range1.location+range1.length,tempLength};
        mutString = [self substringWithRange:range];
        
    }
    return mutString;
}

-(NSString *)cw_getStringBetween:(NSString *)from toLength:(NSInteger)legth separate:(NSString *)separate index:(NSInteger)index
{
    NSString *tempString = nil;
    tempString = [self cw_getSubstringFromString:from toLength:legth];
    NSString *returnString = [tempString cw_getSubstringSeparate:separate index:index];
    return returnString;
}
//cw_getSubstringFromStringToEnd

-(NSString *)cw_getSubstringFromStringToEnd:(NSString *)from separate:(NSString *)separate index:(NSInteger)index
{
    NSString *tempString = [self cw_getSubstringFromStringToEnd:from];
    NSString *returnString = [tempString cw_getSubstringSeparate:separate index:index];
    return returnString;
}

-(NSString *)cw_getStringBetween:(NSString *)from and:(NSString *)to separate:(NSString *)separate index:(NSInteger)index
{
    NSString *tempString = nil;
    if (to==nil) {
        tempString = [self cw_getSubstringFromStringToEnd:from];
    }else{
        tempString = [self cw_getStringBetween:from and:to];
    }
    
    NSString *returnString = [tempString cw_getSubstringSeparate:separate index:index];
    return returnString;
}

-(NSArray *)cw_componentsSeparatedByString:(NSString *)separate
{
    NSArray *mutArray=nil;
    if([self containsString:separate])
    {
        mutArray = [self componentsSeparatedByString:separate];
    }else{
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"%@ not found %@",self,separate]];
        NSLog(@"%@ not found %@",self,separate);
    }
    return mutArray;
}

-(NSString *)cw_getSubstringSeparate:(NSString *)separate index:(NSInteger)index
{
    NSMutableString *mutString = [NSMutableString stringWithString:self];
    NSArray *mutArray;
    if([mutString containsString:separate])
    {
        mutArray = [mutString componentsSeparatedByString:separate];
    }else{
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"%@ not found %@",mutString,separate]];
        NSLog(@"%@ not found %@",mutString,separate);
    }
    NSString *returnString;
    if (mutArray.count>index) {
        returnString = [mutArray objectAtIndex:index];
    }else{
        [MyEexception RemindException:@"Error" Information:[NSString stringWithFormat:@"index %ld beyond bounds,NSArray:%@",index,self]];
        NSLog(@"index %ld beyond bounds,NSArray:%@",index,self);
    }
    return returnString;
}


-(NSString *)cw_deleteSpecialCharacter:(NSString *)chargcter
{
    return [self stringByReplacingOccurrencesOfString:chargcter withString:@""];
}

+(NSString *)cw_returnJoinStringWithArray:(NSArray *)array
{
    NSMutableString *mutStr = [NSMutableString string];
    int index = 0;
    for (NSString *str in array) {
        if (index == 0) {
            [mutStr appendString:[NSString stringWithFormat:@"%@",str]];
        }else{
            
            [mutStr appendString:[NSString stringWithFormat:@",%@",str]];
        }
        index++;
    }
    [mutStr appendString:@"\n"];
    return (NSString *)mutStr;
}


+(id)cw_getDataWithJosnFile:(NSString *)configfile
{
    //NSString *configfile = [[NSBundle mainBundle] pathForResource:@"EEEECode" ofType:@"json"];
    NSString* items = [NSString stringWithContentsOfFile:configfile encoding:NSUTF8StringEncoding error:nil];
    NSData *data= [items dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return jsonObject;
}

+(id)cw_getDataWithPathForResource:(NSString *)fileName
{
    
    NSArray *array = nil;
    if ([fileName containsString:@"."]) {
        array = [fileName componentsSeparatedByString:@"."];
        if (array.count!=2) {
            [MyEexception RemindException:@"Error" Information:@"wrong file name"];
            NSLog(@"wrong file name");
            return @"";
        }
    }else{
        [MyEexception RemindException:@"Error" Information:@"wrong file name"];
        NSLog(@"wrong file name");
        return @"";
    }
    NSString *name = array[0];
    NSString *type = array[1];
    id data=nil;
    NSString *configfile = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if ([type isEqualToString:@".txt"]|| [type containsString:@".plist"] || [type containsString:@".csv"]) {
        
    }else if ([type containsString:@".json"]){
        data=[self cw_getDataWithJosnFile:configfile];
    }
    
    return data;
}

+(NSString *)cw_getResourcePath{
    return [[NSBundle mainBundle] resourcePath];
}

+(NSString *)cw_getDesktopPath
{
    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    return desktopPath;
    //     NSString *eCodePath=[desktopPath stringByDeletingLastPathComponent];
}
+(NSString *)cw_getUserPath
{
    NSString *desktopPath = [self cw_getDesktopPath];
    
    NSString *userPath=[desktopPath stringByDeletingLastPathComponent];
    return userPath;
}


+(NSMutableArray *)cw_getFileNameListInDirPath:(NSString *)filePath str1:(NSString *)str1 {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:filePath];
    NSString *f;
    NSMutableArray *fileNameList = [NSMutableArray array];
    
    while ((f = [de nextObject]))
    {
        if ([f containsString:str1]||[f containsString:str1.lowercaseString]) {
            // fqn = [filePath stringByAppendingPathComponent:f];
            
            [fileNameList addObject:f];
            
        }
    }
    
    
    return fileNameList;
}


+(NSMutableArray *)cw_getFileNameListInDirPath:(NSString *)filePath str1:(NSString *)str1 str2:(NSString *)str2{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:filePath];
    NSString *f;
    NSMutableArray *fileNameList = [NSMutableArray array];
    
    while ((f = [de nextObject]))
    {
        if (([f containsString:str1]||[f containsString:str1.lowercaseString])&&([f containsString:str2]||[f containsString:str2.lowercaseString])) {
            // fqn = [filePath stringByAppendingPathComponent:f];
            
            [fileNameList addObject:f];
            
        }
    }
    
    
    return fileNameList;
}


+ (NSString *)cw_nowTimeWithMicrosecond:(BOOL)isMicrosecond
{
    
    NSString *dateFormat = isMicrosecond ? @"yyyy-MM-dd hh:mm:ss:SS" : @"yyyy-MM-dd hh:mm:ss";
    
    NSString *newDateString = [self cw_stringFromDate:[NSDate date] dateFormat:dateFormat];
    
    return newDateString;
}

+(NSString *)cw_stringFromCurrentDateTime
{
    return [self cw_stringFromDate:[NSDate date] dateFormat:@"yyyy-MM-dd"];
}

+(NSString *)cw_stringFromCurrentDateTimeWithSecond
{
    return [self cw_nowTimeWithMicrosecond:NO];
}

+(NSString *)cw_stringFromCurrentDateTimeWithMicrosecond
{
    return [self cw_nowTimeWithMicrosecond:YES];
}

+(time_t)cw_Time_tSince1970
{
    time_t tempTime;
    time(&tempTime);
    return tempTime;
}

+(NSString *)cw_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat
{
    if (!dateFormat.length) {
        dateFormat = @"yyyy-MM-dd hh:mm:ss";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)cw_dictionaryToJSONString:(NSDictionary *)dictionary

{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonString;
}


+ (NSString *)cw_arrayToJSONString:(NSArray *)array

{
    NSError *error = nil;
    //    NSMutableArray *muArray = [NSMutableArray array];
    //    for (NSString *userId in array) {
    //        [muArray addObject:[NSString stringWithFormat:@"\"%@\"", userId]];
    //    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    NSLog(@"json array is: %@", jsonResult);
    return jsonString;
}

-(unsigned char)cw_stringToHex{
    NSInteger len = self.length;
    unsigned char aucKey[len/2] ;
    memset(aucKey, 0, sizeof(aucKey));
    
    int idx = 0;
    for (int j=0; j<len; j+=2)
    {
        NSString *hexStr = [self substringWithRange:NSMakeRange(j, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned long long longValue ;
        [scanner scanHexLongLong:&longValue];
        unsigned char c = longValue;
        aucKey[idx] = c;
        idx++;
    }
    
    return aucKey[len/2];
}

+(NSString *)cw_hexToString:(unsigned char *)hashword{
    NSString *password = @"";
    long len = sizeof(hashword);
    for (int m = 0; m < len; m++) {
        unsigned long c = hashword[m];
        password = [password stringByAppendingFormat:@"%02lx",c];
    }
    return password;
}

@end
