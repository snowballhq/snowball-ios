//
//  SBSessionManager.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"
#import "SBFacebookManager.h"
#import "SBSessionManager.h"
#import "SBUser.h"

@implementation SBSessionManager

+ (void)startSession {
    [self requestUserAuthenticationIfNecessary:NO];
    [SBFacebookManager startSession];
}

+ (void)signOut {
    [SBUser removeCurrentUser];
    [SBFacebookManager signOut];
    [self requestUserAuthenticationIfNecessary:YES];
}

+ (void)requestUserAuthenticationIfNecessary:(BOOL)animated {
    unless ([self validSession]) {
        if (animated) {
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:[self authenticationNavigationController] animated:YES completion:nil];
        }
        else {
            [[UIApplication sharedApplication].delegate.window setRootViewController:[self authenticationNavigationController]];
        }
    }
}

+ (BOOL)validSession {
    if ([SBUser currentUser]) return true;
    return false;
}

#pragma mark - Handlers

+ (void)handleDidBecomeActive {
    [SBFacebookManager handleDidBecomeActive];
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    if ([[url scheme] isEqualToString:@"snowball"]) {
        NSString *remoteID = @"";
        if ([[url path] length] > 1) remoteID = [[url path] substringFromIndex:1]; // Remove / in path (e.g. "/12345" to "12345")
        if ([[url host] isEqualToString:@"reel"] && [remoteID length] > 1) {
            // TODO: go to reel
            return YES;
        }
    }
    return [SBFacebookManager handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - Session Date

+ (NSDate *)sessionDate {
    static NSDate* sessionDate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionDate = [NSDate date];
    });
    return sessionDate;
}

#pragma mark - Private

+ (UINavigationController *)authenticationNavigationController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:[SBAuthenticationNavigationController identifier]];
}

@end
