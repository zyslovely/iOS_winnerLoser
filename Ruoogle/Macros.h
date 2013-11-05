//
//  Macros.h
//  MyBabyCare
//
//  Created by Tom on 2/1/12.
//  Copyright (c) 2012 儒果网络. All rights reserved.
//

#ifndef MyBabyCare_Macros_h
#define MyBabyCare_Macros_h

#ifdef DEBUG

#import "iConsole.h"

#define INFO(format, ...)   [iConsole info:format, ## __VA_ARGS__]
#define ERROR(format, ...)  [iConsole error:format, ## __VA_ARGS__]
#define BUG(foramt, ...)    [iConsole debug:format, ## __VA_ARGS__]
#define CRASH(format, ...)  [iConsole crash:format, ## __VA_ARGS__]
#define WARN(format, ...)   [iConsole warn:format, ## __VA_ARGS__]
#define CLog(format, ...)   [iConsole log:format, ## __VA_ARGS__]

#else

#define INFO(format, ...)
#define ERROR(format, ...)
#define BUG(format, ...)
#define CRASH(format, ...)
#define WARN(format, ...)
#define CLog(format, ...)

#endif

#define SAFECHECK_RELEASE(x) if(x != nil) {[x release]; x = nil; }

#define UIIMAGE_FROMFILE(filename,type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:type]]

#define UIIMAGE_FROMPNG(filename) UIIMAGE_FROMFILE(filename, @"png")

#define STRING_SET_A_WITH_B_ONLYIF_B_IS_NOT_NIL(A,B)  if((B)!=nil) { A = (B);}

#define NUMBER_SET_A_WITH_B_ONLYIF_B_IS_NOT_NIL(A,B)  if((B)!=nil) { A= ([B intValue]);}

#define SET_DICTIONARY_A_OBJ_B_FOR_KEY_C_ONLYIF_B_IS_NOT_NIL(A,B,C) if((B)!=nil){ [A setObject:(B) forKey:(C)];}

#define INT2NUM(x) [NSNumber numberWithInteger:(x)]
#define DOUBLE2NUM(x) [NSNumber numberWithDouble:(x)]
#define INT2STR(x) [NSString stringWithFormat:@"%d", (x)]
#define LONGLONG2NUM(x) [NSNumber numberWithLongLong:(x)]
#define LONGLONG2STR(x) [NSString stringWithFormat:@"%lld", (x)]

#define SAFESTR(x) ((x)==nil)?@"":(x)

///// 矩形相关
#define CGRectTop(rect) rect.origin.y
#define CGRectLeft(rect) rect.origin.x
#define CGRectBottom(rect) (rect.size.height + rect.origin.y)
#define CGRectRight(rect) (rect.size.width + rect.origin.x)
#define CGRectSet(view, xx, yy, ww, hh) [view setFrame:CGRectMake((xx)==-1?view.frame.origin.x:(xx), (yy)==-1?view.frame.origin.y:(yy),(ww)==-1?view.frame.size.width:(ww), (hh)==-1?view.frame.size.height:(hh))]

///// 屏幕大小
#define SCREEN_ORIGIN_Y ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7?0:0)

#define iOS_STATUS_BAR_HEIGHT ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7?0:20)
#define SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height
#define SCREEN_HEIGHT_WITHOUT_STATUS_BAR  ([[UIScreen mainScreen] bounds].size.height-iOS_STATUS_BAR_HEIGHT)
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width


////颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/// URL
#define URL(urlStr) [NSURL URLWithString:urlStr]

/// 屏幕位置
#define V_POS(x,w,s_w,isLeft)  (isLeft?(x):((s_w)-(w)-(x)))   // 离左边x距离，自身宽度w, superview宽度s_w 并且镜面反射到右边

#endif
