//
//  RMSyslogFormatter.m
//  Pods
//
//  Created by Malayil Philip George on 5/7/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All rights reserved.
//
//

#import "RMSyslogFormatter.h"

static NSString * const RMAppUUIDKey = @"RMAppUUIDKey";

@implementation RMSyslogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *msg = logMessage.message;
    
    NSString *logLevel;
    switch (logMessage.flag)
    {
        case DDLogFlagError     : logLevel = @"11"; break;
        case DDLogFlagWarning   : logLevel = @"12"; break;
        case DDLogFlagInfo      : logLevel = @"14"; break;
        case DDLogFlagDebug     : logLevel = @"15"; break;
        case DDLogFlagVerbose   : logLevel = @"15" ; break;
        default                 : logLevel = @"15"; break;
    }
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    });
    
    NSString *timestamp = [dateFormatter stringFromDate:logMessage.timestamp];
    
    //Get vendor id
    NSString *machineName = [self machineName];
    
    //Get program name
    NSString *programName = [self programName];
    
    NSString *log = [NSString stringWithFormat:@"<%@>%@ %@ %@: %@ %@@%@@%lu \"%@\"", logLevel, timestamp, machineName, programName, logMessage.threadID, logMessage.fileName, logMessage.function, (unsigned long)logMessage.line, msg];
    
    return log;
}

-(NSString *) machineName
{
    //We will generate and use a app-specific UUID to maintain user privacy.
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:RMAppUUIDKey];
    if (uuid == nil) {
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:RMAppUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return uuid;
}

-(NSString *) programName
{
    NSString *programName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (programName == nil) {
        programName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    }
    
    //Remove all whitespace characters from appname
    if (programName != nil) {
        NSArray *components = [programName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        programName = [components componentsJoinedByString:@""];
    }
    
    return programName;
}

@end
