//  Utilities.m
//  MicroFiction
//
//  Created by Chen Jianfei on 2/11/11.
//  Copyright 2011 Fakastudio. All rights reserved.
//

#import "Utilities.h"
#import <AudioToolbox/AudioToolbox.h>
#import <sys/socket.h> // Per msqr
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import "NSString+MD5Addition.h"
#import "SVProgressHUD.h"
#import "RegexKitLite.h"
#import "sys/utsname.h"
#import "sys/stat.h"
#import "TKAlertCenter.h"
#import "ASIReachability.h"
#import "KeychainItemWrapper.h"
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#define radians( degrees ) ( degrees * M_PI / 180 )

#define kUDF_deviceUDIDKey      @"device_UDID_key"

@implementation Utilities

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
  -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
  -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

//generate md5 hash from string
+ (NSString *)returnMD5Hash:(NSString *)concat {

  const char *concat_str = [concat UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(concat_str, strlen(concat_str), result);
  NSMutableString *hash = [NSMutableString string];
  for (int i = 0; i < 16; i++)
    [hash appendFormat:@"%02X", result[i]];
  return [hash lowercaseString];
}

+ (NSString *)returnMD5Hash:(NSString *)oneStr withString:(NSString *)twoStr {

  return [Utilities returnMD5Hash:[oneStr stringByAppendingString:twoStr]];
}

+ (NSString *)returnMD5Base64:(NSString *)str {

  const char *concat_str = [str UTF8String];
  unsigned char source[CC_MD5_DIGEST_LENGTH];
  CC_MD5(concat_str, strlen(concat_str), source);

  int strlength = CC_MD5_DIGEST_LENGTH;

  char *characters = malloc(((strlength + 2) / 3) * 4);
  if (characters == NULL)
    return nil;

  NSUInteger length = 0;
  NSUInteger i = 0;

  while (i < strlength) {
    char buffer[3] = {0, 0, 0};
    short bufferLength = 0;
    while (bufferLength < 3 && i < strlength)
      buffer[bufferLength++] = source[i++];
    characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
    characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
    if (bufferLength > 1)
      characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    else characters[length++] = '=';
    if (bufferLength > 2)
      characters[length++] = encodingTable[buffer[2] & 0x3F];
    else characters[length++] = '=';
  }

  return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];

}

+ (void)playSystemSound:(NSString *)fileName withType:(NSString *)type {

  UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
  AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                           sizeof (sessionCategory),
                           &sessionCategory);
  
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
  SystemSoundID soundID;

  AudioServicesCreateSystemSoundID((CFURLRef) [NSURL fileURLWithPath:path], &soundID);
  AudioServicesPlaySystemSound(soundID);
}


+ (void)playSystemSoundMessageSent {

  [Utilities playSystemSound:@"SentMessage" withType:@"caf"];
  
}

+ (void)playSystemSoundEmpty {

  [Utilities playSystemSound:@"emptyTrash" withType:@"aif"];
}


+ (void)playSystemSoundNewMessageComing {

  [Utilities playSystemSound:@"msgcome" withType:@"wav"];
}

+ (CGFloat)deviceVersion {

  NSString *osversion = [UIDevice currentDevice].systemVersion;
  return [osversion floatValue];
}

+ (NSString *)deviceVersionString {

  return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)deviceIMEIStr {

  //return [[UIDevice currentDevice] uniqueIdentifier];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"ss000"];
  NSString *last5 = [formatter stringFromDate:[NSDate date]];
  [formatter release];
  srand([[NSDate date] timeIntervalSince1970]);
  int randomNum = rand() % 65536;
  NSString *str = [NSString stringWithFormat:@"IPHONE%4X%@", randomNum, last5];
  return str;
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
+ (NSString *)macaddress {

  int mib[6];
  size_t len;
  char *buf;
  unsigned char *ptr;
  struct if_msghdr *ifm;
  struct sockaddr_dl *sdl;

  mib[0] = CTL_NET;
  mib[1] = AF_ROUTE;
  mib[2] = 0;
  mib[3] = AF_LINK;
  mib[4] = NET_RT_IFLIST;

  if ((mib[5] = if_nametoindex("en0")) == 0) {
    printf("Error: if_nametoindex error\n");
    return NULL;
  }

  if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
    printf("Error: sysctl, take 1\n");
    return NULL;
  }

  if ((buf = malloc(len)) == NULL) {
    printf("Could not allocate memory. error!\n");
    return NULL;
  }

  if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
    free(buf);
    printf("Error: sysctl, take 2");
    return NULL;
  }

  ifm = (struct if_msghdr *) buf;
  sdl = (struct sockaddr_dl *) (ifm + 1);
  ptr = (unsigned char *) LLADDR(sdl);
  NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                                   *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
  free(buf);

  return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *)uniqueDeviceIdentifier {

  NSString *macaddress = [Utilities macaddress];
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

  NSString *stringToHash = [NSString stringWithFormat:@"%@%@", macaddress, bundleIdentifier];
  NSString *uniqueIdentifier = [stringToHash stringFromMD5];

  return uniqueIdentifier;
}

+ (NSString *)deviceUDID {

  if ([self deviceVersion] >= 7.0) {
    
    /* solution 2, 记录在keychain 中 */
    KeychainItemWrapper *wrapper = [[[KeychainItemWrapper alloc] initWithIdentifier:[self appBundle] accessGroup:nil] autorelease];
    NSString *savedUDID = [wrapper objectForKey:(id)kSecValueData];
    if (!savedUDID || [savedUDID length]==0){
      
      NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
      NSString *udid = [NSString stringWithFormat:@"ios7_%@", adId];
      [wrapper setObject:udid forKey:(id)kSecValueData];
      
      return udid;
      
    }else {
      
      return savedUDID;
    }
     
    
  }else {

    KeychainItemWrapper *wrapper = [[[KeychainItemWrapper alloc] initWithIdentifier:[self appBundle] accessGroup:nil] autorelease];
    NSString *savedUDID = [wrapper objectForKey:(id)kSecValueData];

  
    NSString *macaddress = [Utilities macaddress];
    NSString *uniqueIdentifier = [macaddress stringFromMD5];
    
    
    if ([uniqueIdentifier isEqualToString:savedUDID]) {
      return uniqueIdentifier;
      
    }else {
      
      if (!savedUDID || [savedUDID length] == 0) {
        
        [wrapper setObject:uniqueIdentifier forKey:(id)kSecValueData];
        
      }else {
        // 不知道什么原因，udid变化了
        return savedUDID;
      }
            
      return uniqueIdentifier;
    }
  }
}

+ (NSString *)simIMSIStr {

  return [Utilities deviceIMEIStr];
}

+ (void)alertWithOK:(NSString *)message {

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"好，知道了" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

+ (void)alertInstant:(NSString *)message isError:(BOOL)isError {
  
  if (isError) {
    [SVProgressHUD showErrorWithStatus:message];
  } else {
    [SVProgressHUD showSuccessWithStatus:message];
  }
}

+ (void)alertInstant:(NSString *)message image:(UIImage *)image {

  [[TKAlertCenter defaultCenter] postAlertWithMessage:message image:image];
}

+ (void)errorAlert:(NSString *)message {

  UIImage *iconImg = UIIMAGE_FROMPNG(@"btn_jinggao");
  [Utilities alertInstant:message image:iconImg];
}

+ (NSString *)fileName2docFilePath:(NSString *)fileName {

  if (!fileName || [fileName isEqualToString:@""]) {
    return nil;
  }

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
  return filePath;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)targetSize {

  int kMaxResolutionWidth = targetSize.width;
  int kMaxResolutionHeight = targetSize.height;

  CGImageRef imgRef = image.CGImage;

  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);

  CGAffineTransform transform = CGAffineTransformIdentity;
  CGRect bounds = CGRectMake(0, 0, width, height);

  UIImageOrientation orient = image.imageOrientation;
  if (orient == UIImageOrientationUp || orient == UIImageOrientationDown || orient == UIImageOrientationDownMirrored || orient == UIImageOrientationUpMirrored) {

  } else {

    kMaxResolutionWidth = targetSize.height;
    kMaxResolutionHeight = targetSize.width;
  }

  if (width > kMaxResolutionWidth || height > kMaxResolutionHeight) {
    CGFloat ratio = width / height;
    if (ratio > 1) {
      bounds.size.width = kMaxResolutionWidth;
      bounds.size.height = bounds.size.width / ratio;
    }
    else {
      bounds.size.height = kMaxResolutionHeight;
      bounds.size.width = bounds.size.height * ratio;
    }
  }

  CGFloat scaleRatio = bounds.size.width / width;
  CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
  CGFloat boundHeight;

  switch (orient) {

    case UIImageOrientationUp: //EXIF = 1
      transform = CGAffineTransformIdentity;
      break;

    case UIImageOrientationUpMirrored: //EXIF = 2
      transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      break;

    case UIImageOrientationDown: //EXIF = 3
      transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;

    case UIImageOrientationDownMirrored: //EXIF = 4
      transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
      transform = CGAffineTransformScale(transform, 1.0, -1.0);
      break;

    case UIImageOrientationLeftMirrored: //EXIF = 5
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;

    case UIImageOrientationLeft: //EXIF = 6
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;

    case UIImageOrientationRightMirrored: //EXIF = 7
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeScale(-1.0, 1.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;

    case UIImageOrientationRight: //EXIF = 8
      boundHeight = bounds.size.height;
      bounds.size.height = bounds.size.width;
      bounds.size.width = boundHeight;
      transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;

    default:
      [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

  }

  UIGraphicsBeginImageContext(bounds.size);

  CGContextRef context = UIGraphicsGetCurrentContext();

  if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
    CGContextScaleCTM(context, -scaleRatio, scaleRatio);
    CGContextTranslateCTM(context, -height, 0);
  }
  else {
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
  }

  CGContextConcatCTM(context, transform);

  CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
  UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return imageCopy;
}

+ (BOOL)isMobileNumber:(NSString *)mobileNumStr {

  if ([mobileNumStr length] != 11 || ![[mobileNumStr substringToIndex:1] isEqualToString:@"1"]) {

    return NO;
  }

  return YES;
}

+ (UIDeviceOrientation)deviceOrientationByInterfaceOrientation:(UIInterfaceOrientation)orientation {

  switch (orientation) {
    case UIInterfaceOrientationLandscapeLeft:
      return UIDeviceOrientationLandscapeLeft;

    case UIInterfaceOrientationPortrait:
      return UIDeviceOrientationPortrait;

    case UIInterfaceOrientationLandscapeRight:
      return UIDeviceOrientationLandscapeRight;

    case UIInterfaceOrientationPortraitUpsideDown:
      return UIDeviceOrientationPortraitUpsideDown;
  }
}

+ (NSUInteger)keyboardHeight:(NSNotification *)n inWindow:(UIWindow *)window {

  NSDictionary *userInfo = [n userInfo];

  NSString *osversion = [UIDevice currentDevice].systemVersion;
  float versionNum = [osversion floatValue];
  CGSize keyboardSize;

  if (versionNum < 3.2) {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

    // get the size of the keyboard
    // iOS < 3.2
    NSValue *boundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    keyboardSize = [boundsValue CGRectValue].size;

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

  } else {

    // get the size of the keyboard
    // iOS > 3.2
    NSValue *boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect boundsRect = [boundsValue CGRectValue];
    CGRect converted = [window convertRect:boundsRect toWindow:[[[UIApplication sharedApplication] delegate] window]];
    keyboardSize = converted.size;
  }

  return MIN(keyboardSize.height, keyboardSize.width);
}

+ (BOOL)validateEmail:(NSString *)candidate {

  BOOL isEmailType = [candidate isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];

  return isEmailType;
}

+ (BOOL)validateMobileNumber:(NSString *)candidate {

  BOOL isMobileType = [candidate isMatchedByRegex:@"\\b((13[0-9])|14[7-8]|(15[^4,\\D])|(18[0-9]))\\d{8}\\b"];
  return isMobileType;
}

+ (NSArray *)getRGBAsFromImage:(UIImage *)image atX:(int)xx andY:(int)yy count:(int)count {

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];

  // First get the image into your data buffer
  CGImageRef imageRef = [image CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char *) calloc(height * width * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
      bitsPerComponent, bytesPerRow, colorSpace,
      kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);

  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);

  // Now your rawData contains the image data in the RGBA8888 pixel format.
  int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
  for (int ii = 0; ii < count; ++ii) {
    CGFloat red = (rawData[byteIndex] * 1.0) / 255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
    CGFloat blue = (rawData[byteIndex + 2] * 1.0) / 255.0;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
    byteIndex += 4;

    UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    [result addObject:acolor];
  }

  free(rawData);

  return result;
}

+ (UIColor *)fontColorFromImage:(UIImage *)image inRect:(CGRect)rect {

  // 先截图
  UIGraphicsBeginImageContext(rect.size);
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  UIImage *smallimage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  NSUInteger scale = [[UIScreen mainScreen] scale];
  NSUInteger count = rect.size.width * rect.size.height * scale * scale;

  // First get the image into your data buffer
  CGImageRef imageRef = [smallimage CGImage];
  NSUInteger width = CGImageGetWidth(imageRef);
  NSUInteger height = CGImageGetHeight(imageRef);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char *) calloc(count * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, width, height,
      bitsPerComponent, bytesPerRow, colorSpace,
      kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);

  CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
  CGContextRelease(context);

  // Now your rawData contains the image data in the RGBA8888 pixel format.
  int byteIndex = 0;
  NSUInteger black = 0;
  NSUInteger white = 0;

  for (int ii = 0; ii < count; ++ii) {
    CGFloat red = rawData[byteIndex];
    CGFloat green = rawData[byteIndex + 1];
    CGFloat blue = rawData[byteIndex + 2];
    byteIndex += 4;

    CGFloat brightness = sqrtf(0.241 * red * red + 0.691 * green * green + 0.068 * blue * blue);
    if (brightness < 130) {
      white++;
    } else {
      black++;
    }
  }

  free(rawData);
  CLog(@"image font color white weight is %d, black weight is %d", white, black);
  return white > black ? [UIColor whiteColor] : [UIColor blackColor];
}

+ (UITableViewCell *)cellByClassName:(NSString *)className inNib:(NSString *)nibName forTableView:(UITableView *)tableView {

  Class cellClass = NSClassFromString(className);
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
  if (cell == nil) {

    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

    for (id oneObject in nib)
      if ([oneObject isMemberOfClass:cellClass])
        return oneObject;
  }
  return cell;
}


+ (UIView *)viewByClassName:(NSString *)className inNib:(NSString *)nibName {

  NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
  Class cellClass = NSClassFromString(className);
  for (id oneObject in nib) {
    if ([oneObject isMemberOfClass:cellClass]) {
      return oneObject;
    }
  }
  return nil;
}

/*  
 *功能：获取设备类型  
 *  
 *  AppleTV2,1    AppleTV(2G)  
 *  i386          simulator  
 *  
 *  iPod1,1       iPodTouch(1G)  
 *  iPod2,1       iPodTouch(2G)  
 *  iPod3,1       iPodTouch(3G)  
 *  iPod4,1       iPodTouch(4G)  
 *  
 *  iPhone1,1     iPhone  
 *  iPhone1,2     iPhone 3G  
 *  iPhone2,1     iPhone 3GS  
 *  
 *  iPhone3,1     iPhone 4  
 *  iPhone3,3     iPhone4 CDMA版(iPhone4(vz))  
 
 *  iPhone4,1     iPhone 4S  
 *  
 *  iPad1,1       iPad  
 *  iPad2,1       iPad2 Wifi版  
 *  iPad2,2       iPad2 GSM3G版  
 *  iPad2,3       iPad2 CDMA3G版  
 *  @return null  
 */

+ (NSString *)getDeviceVersion {

  struct utsname systemInfo;
  uname(&systemInfo);
  //get the device model and the system version   
  NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  return machine;
}

/** 判断当前设备是否ipad */
+ (BOOL)isIpad {

  return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIphone4S {

  return [[Utilities getDeviceVersion] isEqualToString:@"iPhone4,1"];
}

+ (BOOL)isRetina {
  
  return [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0);
}

+ (BOOL)isRetina4 {

  NSString *deviceVersion = [Utilities getDeviceVersion];
  
  if ([deviceVersion pd_findSubstring:@"iPod"] || [deviceVersion pd_findSubstring:@"iPhone"] || [deviceVersion pd_findSubstring:@"x86"]){
    return SCREEN_HEIGHT > 480;
  }

  return NO;
}

+ (BOOL)isIphone5OrLater {

  NSString *deviceVersion = [Utilities getDeviceVersion];
  if ([deviceVersion isEqualToString:@"x86_64"]) {
    // device is simulator
    return SCREEN_HEIGHT > 480;
  }
  
  if ([deviceVersion pd_findSubstring:@"iPod"] || [deviceVersion pd_findSubstring:@"iPad"]) {
    return NO;
  }
  
  return [deviceVersion compare:@"iPhone5,1"] !=NSOrderedAscending;
}


+ (long long)fileSizeAtPath:(NSString *)filePath {

  struct stat st;
  if (lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
    return st.st_size;
  }
  return 0;
}

+ (CGSize)deviceSize {

  CGRect rect_screen = [[UIScreen mainScreen] bounds];
  CGSize size_screen = rect_screen.size;
  return size_screen;
}


typedef unsigned short WORD;
typedef unsigned long UINT64;

/*
 一个double型浮点数包括8个字节(64bit)，我们把最低位记作bit0,最高位记作bit63,
 则一个浮点数各个部分定义为:
 第一部分尾数：bit0至bit51，共计52bit，
 第二部分阶码:bit52-bit62,共计11bit，
 第三部分符号位:bit63，0:表示正数，1表示负数。
 如一个数为0.xxxx   *   2^   exp,则exp表示指数部分，范围为－1023到1024，
 实际存储时采用移码的表示法，即将exp的值加上0x3ff，使其变为一个0到2047范围内的一个值。
 
 判断一个数是否整数，可采用如下规则：
 1.   如果一个数的绝对值小于1，则这个数的阶码小于零，则这个数为小数，
 2.   如果一个数的绝对值> =2^52,应视为这个数为整数
 3.   如果一个数x   1 <=x <2^52   且阶码为e,   则：
 这个数的尾数部分，只有前e   bit   可以出现 '1 ',剩下的52-e比特全部为0，
 如此，则只要判断剩下的   52-e   bit是否为0   即可
 下面给出程序
 */


+ (BOOL)isInt:(double)a {
  
  int int_a = round(a);
  if (int_a * 1.0 == a) {
    return YES;
  }

  return NO;
}

+ (NSString *)double2string:(double)doubleValue {

  if ([Utilities isInt:doubleValue]) {
    return [NSString stringWithFormat:@"%.0f", doubleValue];
  } else {
    return [NSString stringWithFormat:@"%.2f", doubleValue];
  }
}

+ (NSString *)appBundle {
  
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {

  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBundleDisplyName {

  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)appBuildString {

  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (void)runOnMainQueueWithoutDeadlocking:(VoidBlockType)block {

  if ([NSThread isMainThread]) {
    block();
  }
  else {
    dispatch_async(dispatch_get_main_queue(), block);
  }
}

+ (BOOL)hasWifiAvailable {

  ASIReachability *wifi = [ASIReachability reachabilityForLocalWiFi];
  if (wifi.currentReachabilityStatus == NotReachable)
    return NO;
  else
    return YES;
}


+ (NSString *)stringByStringArray:(NSArray *)array withSeperator:(NSString *)seperator {
  
  NSMutableString *temp = [[NSMutableString alloc] init];
  for (int i=0; i<[array count]; i++) {
    NSString *string = [array objectAtIndex:i];
    if (i!=[array count]-1) {
      [temp appendString:string];
      [temp appendString:seperator];
    }else {
      [temp appendString:string];
    }
  }

  return [temp autorelease];
}

static inline void drawArc(CGContextRef ctx, CGPoint point, float angle_start, float angle_end, UIColor* color , NSUInteger radius, NSUInteger clockwise) {
  
  CGContextMoveToPoint(ctx, point.x, point.y);
  CGContextSetFillColor(ctx, CGColorGetComponents( [color CGColor]));
  CGContextAddArc(ctx, point.x, point.y, radius,  angle_start, angle_end, clockwise);
  CGContextFillPath(ctx);
}

+ (void)drawArcInView:(UIView *)view startAngle:(float) angle_start endAngle:(float)angle_end color:(UIColor*) color clockwise:(BOOL)isClockwise{
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextClearRect(ctx, view.frame);
  drawArc(ctx, CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2), angle_start, angle_end, color, view.bounds.size.height+view.bounds.size.width,isClockwise?0:1);
}

+ (void)drawArcInView:(UIView *)view startAngle:(float) angle_start endAngle:(float)angle_end radiu:(NSUInteger)radius color:(UIColor*) color clockwise:(BOOL)isClockwise {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  //CGContextClearRect(ctx, view.frame);
  drawArc(ctx, CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2), angle_start, angle_end, color, radius,isClockwise?0:1);
}

+ (NSString *)stringWithZero:(int)count{
  if(count<10){
    return [NSString stringWithFormat:@"0%d",count];
  }
  return INT2STR(count);
}

+ (NSString *)desEncryption:(NSString *)sTextIn key:(NSString *)sKey isEncryption:(BOOL)isEncryption {

  NSStringEncoding EnC = NSUTF8StringEncoding;
  
  NSMutableData * dTextIn;
  if (!isEncryption) {
    dTextIn = [[self decodeBase64WithString:sTextIn] mutableCopy];
  }
  else{
    dTextIn = [[sTextIn dataUsingEncoding: EnC] mutableCopy];
  }
  
  NSMutableData * dKey = [[sKey dataUsingEncoding:EnC] mutableCopy];
  [dKey setLength:kCCBlockSizeDES];
  
  uint8_t *bufferPtr1 = NULL;
  size_t bufferPtrSize1 = 0;
  size_t movedBytes1 = 0;
  Byte iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
  bufferPtrSize1 = ([sTextIn length] + kCCKeySizeDES) & ~(kCCKeySizeDES -1);
  bufferPtr1 = malloc(bufferPtrSize1 * sizeof(uint8_t));
  memset((void *)bufferPtr1, 0x00, bufferPtrSize1);
  CCCrypt(isEncryption?kCCEncrypt:kCCDecrypt, // CCOperation op
          kCCAlgorithmDES, // CCAlgorithm alg
          kCCOptionPKCS7Padding, // CCOptions options
          [dKey bytes], // const void *key
          [dKey length], // size_t keyLength
          iv, // const void *iv
          [dTextIn bytes], // const void *dataIn
          [dTextIn length],  // size_t dataInLength
          (void*)bufferPtr1, // void *dataOut
          bufferPtrSize1,     // size_t dataOutAvailable
          &movedBytes1);      // size_t *dataOutMoved
  
  
  NSString * sResult;
  if (!isEncryption){
    sResult = [[[ NSString alloc] initWithData:[NSData dataWithBytes:bufferPtr1
                                                              length:movedBytes1] encoding:EnC] autorelease];
  }
  else {
    NSData *dResult = [NSData dataWithBytes:bufferPtr1 length:movedBytes1];
    sResult = [self encodeBase64WithData:dResult];
  }
  [dTextIn release];
  return sResult;
}

+ (NSString *)encodeBase64WithString:(NSString *)strData {
  
  return[self encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}


+ (NSString *)encodeBase64WithData:(NSData *)objData {
  const unsigned char * objRawData = [objData bytes];
  char * objPointer;
  char * strResult;
  
  // Get the Raw Data length and ensure we actually have data
  int intLength = [objData length];
  if (intLength == 0) return nil;
  
  // Setup the String-based Result placeholder and pointer within that placeholder
  strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
  objPointer = strResult;
  
  // Iterate through everything
  while(intLength > 2) { // keep going until we have less than 24 bits
    *objPointer++ = encodingTable[objRawData[0] >> 2];
    *objPointer++ = encodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
    *objPointer++ = encodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
    *objPointer++ = encodingTable[objRawData[2] & 0x3f];
    
    // we just handled 3 octets (24 bits) of data
    objRawData += 3;
    intLength -= 3;
  }
  
  // now deal with the tail end of things
  if (intLength != 0) {
    *objPointer++ = encodingTable[objRawData[0] >> 2];
    if (intLength > 1) {
      *objPointer++ = encodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
      *objPointer++ = encodingTable[(objRawData[1] & 0x0f) << 2];
      *objPointer++ = '=';
    } else {
      *objPointer++ = encodingTable[(objRawData[0] & 0x03) << 4];
      *objPointer++ = '=';
      *objPointer++ = '=';
    }
  }
  
  // Terminate the string-based result
  *objPointer = '\0';
  
  // Return the results as an NSString object
  return[NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}


+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
  
  const char* objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
  int intLength = strlen(objPointer);
  int intCurrent;
  int i = 0, j = 0, k;
  
  unsigned char * objResult;
  objResult = calloc(intLength, sizeof(char));
  
  // Run through the whole string, converting as we go
  while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
    if (intCurrent == '=') {
      if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
        // the padding character is invalid at this point -- so this entire string is invalid
        free(objResult);
        return nil;
      }
      continue;
    }
    
    intCurrent = _base64DecodingTable[intCurrent];
    if (intCurrent == -1) {
      // we're at a whitespace -- simply skip over
      continue;
    } else if (intCurrent == -2) {
      // we're at an invalid character
      free(objResult);
      return nil;
    }
    
    switch (i % 4) {
      case 0:
        objResult[j] = intCurrent << 2;
        break;
        
      case 1:
        objResult[j++] |= intCurrent >> 4;
        objResult[j] = (intCurrent & 0x0f) << 4;
        break;
        
      case 2:
        objResult[j++] |= intCurrent >>2;
        objResult[j] = (intCurrent & 0x03) << 6;
        break;
        
      case 3:
        objResult[j++] |= intCurrent;
        break;
    }
    i++;
  }
  
  // mop things up if we ended on a boundary
  k = j;
  if (intCurrent == '=') {
    switch (i % 4) {
      case 1:
        // Invalid state
        free(objResult);
        return nil;
        
      case 2:
        k++;
        // flow through
      case 3:
        objResult[k] = 0;
    }
  }
  
  // Cleanup and setup the return NSData
  NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
  free(objResult);
  return objData;
}

+ (NSString *)deviceName {
  
  NSString *deviceVersion = [self getDeviceVersion];
  
  if (![deviceVersion pd_isNotEmptyString]) {
    return @"Unknown device";
  }
  
  /// iphone
  if ([deviceVersion isEqualToString:@"iPhone1,1"]) {
    return @"iPhone 1G";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone1,2"]) {
    return @"iPhone 3G";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone2,1"]) {
    return @"iPhone 3GS";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone3,1"]) {
    return @"iPhone 4";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone3,2"]) {
    return @"iPhone 4 Verizon";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone3,3"]) {
    return @"iPhone 4 CDMA";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone4,1"]) {
    return @"iPhone 4S";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone5,1"]) {
    return @"iPhone 5 GSM";
  }

  if ([deviceVersion isEqualToString:@"iPhone5,2"]) {
    return @"iPhone 5 Global";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone5,3"]) {
    return @"iPhone 5C GSM";
  }

  if ([deviceVersion isEqualToString:@"iPhone5,4"]) {
    return @"iPhone 5C Global";
  }
  
  if ([deviceVersion isEqualToString:@"iPhone6,1"]) {
    return @"iPhone 5S GSM";
  }

  if ([deviceVersion isEqualToString:@"iPhone6,2"]) {
    return @"iPhone 5S Global";
  }
  
  /// iPod
  if ([deviceVersion isEqualToString:@"iPod1,1"]) {
    return @"iPod Touch 1G";
  }
  
  if ([deviceVersion isEqualToString:@"iPod2,1"]) {
    return @"iPod Touch 2G";
  }
  
  if ([deviceVersion isEqualToString:@"iPod3,1"]) {
    return @"iPod Touch 3G";
  }
  
  if ([deviceVersion isEqualToString:@"iPod4,1"]) {
    return @"iPod Touch 4G";
  }
  
  if ([deviceVersion isEqualToString:@"iPod5,1"]) {
    return @"iPod Touch 5G";
  }
  
  /// iPad
  if ([deviceVersion isEqualToString:@"iPad1,1"]) {
    return @"iPad";
  }
  
  if ([deviceVersion isEqualToString:@"iPad2,1"]) {
    return @"iPad 2 WIFI";
  }
  
  if ([deviceVersion isEqualToString:@"iPad2,2"]) {
    return @"iPad 2 GSM";
  }
  
  if ([deviceVersion isEqualToString:@"iPad2,3"]) {
    return @"iPad 2 CDMA";
  }
  
  if ([deviceVersion isEqualToString:@"iPad2,4"]) {
    return @"iPad 2 WIFI Rev1";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,1"]) {
    return @"iPad 3 WIFI";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,2"]) {
    return @"iPad 3 CDMA";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,3"]) {
    return @"iPad 3 Global";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,4"]) {
    return @"iPad 4 WIFI";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,5"]) {
    return @"iPad 4 GSM";
  }
  
  if ([deviceVersion isEqualToString:@"iPad3,6"]) {
    return @"iPad 4 Global";
  }
  
  return deviceVersion;
}

+ (void)blinkAnimationForView:(UIView *)view withDuration:(float)duration andRepeatCount:(float)repeatCount {
  
  CABasicAnimation *blink = [CABasicAnimation animationWithKeyPath:@"opacity"];
  [blink setDuration:duration];
  [blink setAutoreverses:YES];
  [blink setRepeatCount:repeatCount];
  [blink setFromValue:[NSNumber numberWithFloat:1.0]];
  [blink setToValue:[NSNumber numberWithFloat:0.3]];
  [view.layer addAnimation:blink forKey:@"view blink"];
  

}

+ (void)expandAnimationForViews:(NSArray *)views withDuration:(float)duration andRepearCount:(float)repeatCount dx:(float)dx dy:(float)dy{
  
  CABasicAnimation *expandInX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
  [expandInX setDuration:duration];
  [expandInX setAutoreverses:YES];
  [expandInX setRepeatCount:repeatCount];
  [expandInX setFromValue:[NSNumber numberWithFloat:1.0]];
  [expandInX setToValue:[NSNumber numberWithFloat:dx]];
  
  CABasicAnimation *expandInY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
  [expandInY setDuration:duration];
  [expandInY setAutoreverses:YES];
  [expandInY setRepeatCount:repeatCount];
  [expandInY setFromValue:[NSNumber numberWithFloat:1.0]];
  [expandInY setToValue:[NSNumber numberWithFloat:dy]];
  for (UIView *view in views) {

    [view.layer addAnimation:expandInX forKey:@"view expand x"];
    [view.layer addAnimation:expandInY forKey:@"view expand y"];
  }

}

@end
