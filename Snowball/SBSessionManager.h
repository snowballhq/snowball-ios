//
//  SBSessionManager.h
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSessionManager : NSObject

+ (void)startSession;
+ (void)signOut;
+ (BOOL)validSession;

+ (void)handleDidBecomeActive;
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

+ (NSDate *)sessionDate;

@end
