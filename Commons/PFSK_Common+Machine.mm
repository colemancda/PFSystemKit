//
//  PFSK_Common+Machine.m
//  PFSystemKit
//
//  Created by Perceval FARAMAZ on 17/05/15.
//  Copyright (c) 2015 faramaz. All rights reserved.
//

#import "PFSK_Common+Machine.h"
#import <string>
#import "NSString+PFSKAdditions.h"

@implementation PFSK_Common(Machine)
+(BOOL) deviceFamily:(PFSystemKitDeviceFamily*__nonnull)ret error:(NSError Ind2_NUAR)error
{
    NSString* str;
    BOOL result = [self deviceModel:&str error:error];
    if (result != true) {
        return false;
    }
    str = [str lowercaseString]; //transform to lowercase, meaning less code afterwards
#if !TARGET_OS_IPHONE
    if ([str containsString:@"mac"]) {
        if ([str isEqualToString:@"imac"])
            *ret = PFSKDeviceFamilyiMac;
        else if ([str containsString:@"air"])
            *ret = PFSKDeviceFamilyMacBookAir;
        else if ([str containsString:@"pro"] && [str containsString:@"book"])
            *ret = PFSKDeviceFamilyMacBookPro;
        else if ([str containsString:@"mini"])
            *ret = PFSKDeviceFamilyMacMini;
        else if ([str containsString:@"pro"])
            *ret = PFSKDeviceFamilyMacPro;
        else if ([str containsString:@"macbook"])
            *ret = PFSKDeviceFamilyMacBook;
    } else if ([str isEqualToString:@"xserve"])
        *ret = PFSKDeviceFamilyXserve;
#endif
#if TARGET_OS_IPHONE
    if ([str hasPrefix:@"i"]) { //don't care about imac, has been checked before
        if ([str isEqualToString:@"iphone"])
            *ret = PFSKDeviceFamilyiPhone;
        else if ([str isEqualToString:@"ipad"])
            *ret = PFSKDeviceFamilyiPad;
        else if ([str isEqualToString:@"ipod"])
            *ret = PFSKDeviceFamilyiPod;
    } else if ([str isEqualToString:@"simulator"]) {
        *ret = PFSKDeviceFamilySimulator;
    }
#endif
    *ret = PFSKDeviceFamilyUnknown;
    return true;
}


+(BOOL) deviceEndianness:(PFSystemKitEndianness*__nonnull)ret error:(NSError Ind2_NUAR)error
{
    double order = 0;
    BOOL result = sysctlDoubleForKeySynthesizing((char*)"hw.byteorder", order, error);
    if (!result) {
        *ret = PFSKEndiannessUnknown;
        return false;
    }
    // values for cputype and cpusubtype defined in mach/machine.h
    if (order == 1234) {
        *ret = PFSKEndiannessLittleEndian;
    } else if (order == 4321) {
        *ret = PFSKEndiannessBigEndian;
    } else {
        *ret = PFSKEndiannessUnknown;
    }
    return true;
}

+(BOOL) deviceModel:(NSString Ind2_NNAR)ret error:(NSError Ind2_NUAR)error
{
    BOOL result = sysctlNSStringForKeySynthesizing((char*)"hw.model", ret, error);
    if (!result) {
        *ret = @"-";
        return false;
    }
    return true;
}

+(BOOL) deviceVersion:(PFSystemKitDeviceVersion*__nonnull)ret error:(NSError Ind2_NUAR)error
{
	NSString* systemInfoString;
	BOOL result = [self deviceModel:&systemInfoString error:error];
	if (result != true) {
		return false;
	}
    *error = synthesizeError(PFSKReturnSuccess);
    NSUInteger positionOfFirstInteger = [systemInfoString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location;
    NSUInteger positionOfComma = [systemInfoString rangeOfString:@","].location;
    
    NSUInteger major = 0;
    NSUInteger minor = 0;
    
    if (positionOfComma != NSNotFound) {
        major = [[systemInfoString substringWithRange:NSMakeRange(positionOfFirstInteger, positionOfComma - positionOfFirstInteger)] integerValue];
        minor = [[systemInfoString substringFromIndex:positionOfComma + 1] integerValue];
    }
    *ret = (PFSystemKitDeviceVersion){major, minor};
	return true;
}
@end
