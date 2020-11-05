/*
 *  get_hash.h
 *  DFUSecuredCB
 *
 *  Created by Wei Wang on 3/2/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

//modified by Saqib yaqub on 22/12/2016 for J120 DVT

#pragma once
/* control bit meaning
 *		0: PASS
 *		1: INCOMPLETE
 *		2: FAIL
 *		3: UNTEST
 *		
 *		DFU station id: 0x00
 *		FCT station id: 0x01
 *		
 *		getnonce
 *		fg 0x02 0
 *		rb 0x02
 */

#define STATUS_OK 0
#define ERROR_CREATE_SHA1DIGEST -10001
#define ERROR_UNKNOWN_STATION_ID -10002

#ifdef __cplusplus
extern "C"
{
#endif
//In the next two functions, it's the caller's repsonsibility to create and manage the 
//memory for both unsigned char* buffer. The size must be 20 for both of them.
//int get_fct_hash(unsigned char* nounce, unsigned char* hash);
//int get_dfu_hash(unsigned char* nounce, unsigned char* hash);
//int get_soc_hash(unsigned char* nounce, unsigned char* hash);
//int get_ict_hash(unsigned char* nounce, unsigned char* hash);
//int get_G_1_CAL_hash(unsigned char* nounce, unsigned char* hash);
//int get_KONA_TEST_hash(unsigned char* nounce, unsigned char* hash);
//int get_IP_1_hash(unsigned char* nounce, unsigned char* hash);
//int get_station_hash(unsigned short station_id, unsigned char* nounce, unsigned char* hash);
//int get_socgpu_hash(unsigned char* nonce, unsigned char* hash);
    
    int get_fct_hash(unsigned char* nounce, unsigned char* hash);
    int get_dfu_hash(unsigned char* nounce, unsigned char* hash);
    int get_soc_hash(unsigned char* nounce, unsigned char* hash);
    int get_ict_hash(unsigned char* nounce, unsigned char* hash);
    int get_smtdev32_hash(unsigned char* nounce, unsigned char* hash);
    int get_G_1_hash(unsigned char* nounce, unsigned char* hash);
    int get_IP_1_hash(unsigned char* nounce, unsigned char* hash);
    int get_station_hash(unsigned short station_id, unsigned char* nounce, unsigned char* hash);

#ifdef __cplusplus
}
#endif
