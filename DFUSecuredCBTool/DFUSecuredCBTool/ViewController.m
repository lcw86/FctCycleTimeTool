//
//  ViewController.m
//  DFUSecuredCBTool
//
//  Created by ciwei luo on 2020/3/25.
//  Copyright © 2020 ciwei luo. All rights reserved.
//

#import "ViewController.h"
#include "get_hash.h"

@interface ViewController()
@property (weak) IBOutlet NSTextField *nonceView;
@property (weak) IBOutlet NSTextField *hashView;
@property (weak) IBOutlet NSTextField *pwdView;

@property (weak) IBOutlet NSTextField *stationid;

@property (weak) IBOutlet NSTextField *rtc_view;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //            NSDateFormatter *format = [[NSDateFormatter alloc] init] ;
    //            format.dateFormat = @"yyyyMMddHHmmss" ;
    //            NSString *ts = [format stringFromDate:[NSDate date]];
    //            NSString* rtc_cmd = [NSString stringWithFormat:@"rtc --set %@",ts];
    //            WriteStringg(rtc_cmd);

    // Do any additional setup after loading the view.
}
//B61C997385A22E5C682C7D6DD54B83879664C7C2

- (IBAction)rtc_set:(id)sender {
    NSDateFormatter *format = [[NSDateFormatter alloc] init] ;
    format.dateFormat = @"yyyyMMddHHmmss" ;
    NSString *ts = [format stringFromDate:[NSDate date]];
    NSString* rtc_cmd = [NSString stringWithFormat:@"rtc --set %@",ts];
    self.rtc_view.stringValue = rtc_cmd;
}


- (IBAction)changeToHexAndPwd:(id)sender {
    NSString *nonce = self.nonceView.stringValue;
    if (nonce.length !=40) {
        
        return;
    }
    unsigned char aucKey[20] ;
    memset(aucKey, 0, sizeof(aucKey));
    int idx = 0;
    for (int j=0; j<[nonce length]; j+=2)
    {
        NSString *hexStr = [nonce substringWithRange:NSMakeRange(j, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned long long longValue ;
        [scanner scanHexLongLong:&longValue];
        unsigned char c = longValue;
        aucKey[idx] = c;
        idx++;
    }
    //self.hashView.stringValue = [NSString stringWithUTF8String:aucKey];
    unsigned char hashword[20] ;
    memset(hashword, 0, sizeof(hashword));
    int stationhash = -1000;
    int station_id = [self.stationid intValue];
    stationhash = _get_station_hash(station_id, aucKey, hashword);
    
    NSString *password = @"";
    for (int m = 0; m < 20; m++) {
        unsigned long c = hashword[m];
        password = [password stringByAppendingFormat:@"%02lx",c];
    }
    self.pwdView.stringValue = password;
}

static int _get_station_hash(unsigned short station_id, unsigned char* nounce, unsigned char* hash)
{
    int status=0;
   // [g_LockCB lock];
    status = get_station_hash(station_id, nounce, hash);
    //[g_LockCB unlock];
    return status;
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
