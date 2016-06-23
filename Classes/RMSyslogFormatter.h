//
//  RMSyslogFormatter.h
//  Pods
//
//  Created by Malayil Philip George on 5/7/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <DDLog.h>

#warning JZ Locally modified
static NSString * const RMAppUUIDKey = @"RMAppUUIDKey";

/**
 Formats messages in the form of a syslog message.
    The syslog format is defined as follows -
    \<xx\>timestamp machineName programName: message.
    xx is a log level that depicts the criticality of the error.
    timestamp - Time at which log was generated. Ex. Oct 11 22:14:15.
    machineName - typically hostname. We use 'vendorId' on iOS.
    programName - program or component generating log. CFBundleDisplayName (stripped of whitespace) is used
    message - is the message to be logged.
 */
@interface RMSyslogFormatter : NSObject <DDLogFormatter>

#warning JZ Locally modified
-(NSString *) machineName;
-(NSString *) programName;

@end
