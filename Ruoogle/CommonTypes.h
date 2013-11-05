//
//  CommonTypes.h
//  GameChat
//
//  Created by Tom on 1/21/13.
//  Copyright (c) 2013 Ruoogle. All rights reserved.
//

#ifndef GameChat_CommonTypes_h
#define GameChat_CommonTypes_h

typedef void (^VoidBlockType)(void);
typedef void (^IntParamBlockType)(int);
typedef void (^NSStringBlockType)(NSString *);

typedef enum GenderType_ {

  GENDER_MALE = 1,
  GENDER_FEMALE = 2

} GenderType;

typedef enum ConstellationType_ {

  CONSTELLATION_ARIES = 1,
  CONSTELLATION_TAURUS = 2,
  CONSTELLATION_GEMINI = 3,
  CONSTELLATION_CANCER = 4,
  CONSTELLATION_LEO = 5,
  CONSTELLATION_VIRGO = 6,
  CONSTELLATION_LIBRA = 7,
  CONSTELLATION_SCORPIO = 8,
  CONSTELLATION_SAGITARIUS = 9,
  CONSTELLATION_CAPRICORN = 10,
  CONSTELLATION_AQUARIUS = 11,
  CONSTELLATION_PISCES = 12

} ConstellationType;

typedef enum BloodType_ {

  BLOOD_UNKNOWN = 0,
  BLOOD_START = BLOOD_UNKNOWN,
  BLOOD_A = 1,
  BLOOD_B = 2,
  BLOOD_O = 3,
  BLOOD_AB = 4,
  BLOOD_S_1 = 5,
  BLOOD_S_2 = 6,
  BLOOD_S_3 = 7,
  BLOOD_S_4 = 8,
  BLOOD_S_5 = 9,
  BLOOD_S_6 = 10,
  BLOOD_S_7 = 11,
  BLOOD_S_8 = 12,
  BLOOD_S_9 = 13,
  BLOOD_S_10 = 14,
  BLOOD_S_11 = 15,
  BLOOD_S_12 = 16,
  BLOOD_S_13 = 17,
  BLOOD_S_14 = 18,
  BLOOD_S_15 = 19,
  BLOOD_S_16 = 20,
  BLOOD_END = BLOOD_S_16 + 1
} BloodType;

#endif
