//
//  RMSyslogFormatter.m
//  Pods
//
//  Created by Malayil Philip George on 5/7/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All rights reserved.
//
//

#import "RMSyslogFormatter.h"

#warning JZ Locally modified
//static NSString * const RMAppUUIDKey = @"RMAppUUIDKey";

@implementation RMSyslogFormatter

#warning JZ Locally modified
// Note: No longer used -- See MRPaperTrailLogFormatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    return nil;
    
    NSString *msg = logMessage.message;
    
    // See https://tools.ietf.org/html/rfc5424
    NSString *logLevel;
    NSString *logLevelString;
    // See http://help.papertrailapp.com/kb/how-it-works/log-colorization/
    // See https://en.wikipedia.org/wiki/ANSI_escape_code
    //NSString *ansiEscapeCodeBlack = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"0", @"m"];
    NSString *ansiEscapeCodeRed = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"1", @"m"];
    NSString *ansiEscapeCodeGreen = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"2", @"m"];
    NSString *ansiEscapeCodeYellow = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"3", @"m"];
    NSString *ansiEscapeCodeBlue = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"4", @"m"];
    NSString *ansiEscapeCodeMagenta = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"5", @"m"];
    NSString *ansiEscapeCodeCyan = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"6", @"m"];
    //NSString *ansiEscapeCodeWhite = [NSString stringWithFormat:@"%@%@%@", @"\x1b[3", @"7", @"m"];
    NSString *ansiEscapeCodeDefault = @"\x1b[39;49m";
    switch (logMessage.flag)
    {
        case DDLogFlagDev:
            logLevel = @"15";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", @"", @"dev", @""];  // Default
            break;
        case DDLogFlagFatal:
            logLevel = @"10";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeMagenta, @"fatal", ansiEscapeCodeDefault];
            break;
        case DDLogFlagError:
            logLevel = @"11";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeRed, @"error", ansiEscapeCodeDefault];
            break;
        case DDLogFlagWarning:
            logLevel = @"12";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeYellow, @"warn", ansiEscapeCodeDefault];
            break;
        case DDLogFlagInfo:
            logLevel = @"13";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeGreen, @"info", ansiEscapeCodeDefault];
            break;
        case DDLogFlagDebug:
            logLevel = @"14";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeBlue, @"debug", ansiEscapeCodeDefault];
            break;
        case DDLogFlagVerbose:
            logLevel = @"15";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeCyan, @"verbose", ansiEscapeCodeDefault];
            break;
        default:
            logLevel = @"15";
            logLevelString = [NSString stringWithFormat:@"%@%@%@", ansiEscapeCodeRed, @"unknown", ansiEscapeCodeDefault];
            break;
    }
    
    //Also display the file the logging occurred in to ease later debugging
    //NSString *file = [[[NSString stringWithUTF8String:logMessage->file] lastPathComponent] stringByDeletingPathExtension];
    NSString *file = [[logMessage->_file lastPathComponent] stringByDeletingPathExtension];

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
    
    // See http://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-ios-or-os-x-apps/
    //NSString *log = [NSString stringWithFormat:@"<%@>%@ %@ %@: %@ %@@%@@%lu \"%@\"", logLevel, timestamp, machineName, programName, logMessage.threadID, logMessage.fileName, logMessage.function, (unsigned long)logMessage.line, msg];
    // TODO Change programName to reflect device model
    NSString *log = [NSString stringWithFormat:@"<%@> %@ %@ %@: %@ %@ %@ %@ (%lu) %@", logLevel, timestamp, programName, machineName, logLevelString, logMessage.threadID, file, logMessage.function, (unsigned long)logMessage.line, msg];
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
