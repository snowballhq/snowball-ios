//
//  SBReel.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBClip.h"
#import "SBParticipation.h"
#import "SBReel.h"
#import "SBSessionManager.h"
#import "SBUser.h"

@implementation SBReel

- (BOOL)hasNewClip {
    if ([self.clips count] == 0) return YES;
    if ([[self unwatchedClips] count] > 0) {
        return YES;
    }
    return NO;
}

- (NSArray *)unwatchedClips {
    if (self.lastWatchedClip) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@ && createdAt > %@", self, self.lastWatchedClip.createdAt];
        return [SBClip MR_findAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@", self];
        return [SBClip MR_findAllSortedBy:@"createdAt" ascending:YES withPredicate:predicate];
    }
}

- (NSArray *)unwatchedAndLastClips {
    NSMutableArray *unwatchedAndLastClips = [[self unwatchedClips] mutableCopy];
    [unwatchedAndLastClips addObject:[self lastClip]];
    return [unwatchedAndLastClips copy];
}

- (BOOL)hasPendingUpload {
    SBClip *lastClip = [self lastClip];
    if (lastClip) {
        if ([lastClip.remoteID length] == 0) {
            return YES;
        }
    }
    return NO;
}

- (SBClip *)lastClip {
    return [SBClip MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"reel == %@", self] sortedBy:@"createdAt" ascending:NO];
}

#pragma mark - NSManagedObject

- (void)willSave {
    unless (self.color) [self setColor:[UIColor randomColor]];
}

#pragma mark - Participation

- (void)setParticipants:(NSArray *)users {
    NSMutableArray *participations = [@[] mutableCopy];
    for (SBUser *user in users) {
        SBParticipation *participation = [SBParticipation createParticipationForUser:user andReel:self inContext:self.managedObjectContext];
        [participations addObject:participation];
    }
    [self setParticipations:[NSSet setWithArray:[participations copy]]];
}

- (void)addParticipants:(NSArray *)users {
    for (SBUser *user in users) {
        [SBParticipation createParticipationForUser:user andReel:self inContext:self.managedObjectContext];
    }
}

#pragma mark - Remote

+ (void)getHomeFeedReelsOnPage:(NSUInteger)page
                       success:(void (^)(BOOL canLoadMore))success
                       failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels"];;
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_reels = responseObject[@"reels"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [_reels each:^(id object) {
                                          SBReel *reel = [SBReel MR_findFirstByAttribute:@"remoteID"
                                                                               withValue:object[@"id"]
                                                                               inContext:localContext];
                                          if (reel) {
                                              [reel MR_importValuesForKeysWithObject:object];
                                          } else {
                                              [SBReel MR_importFromObject:object inContext:localContext];
                                          }
                                      }];
                                  }];
                                  if (success) { success([_reels count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

- (void)getParticipantsOnPage:(NSUInteger)page
                      success:(void (^)(BOOL canLoadMore))success
                      failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants", self.remoteID];
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_users = responseObject[@"users"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      NSArray *users = [SBUser MR_importFromArray:_users inContext:localContext];
                                      SBReel *reel = [self MR_inContext:localContext];
                                      if (page > 1) {
                                          [reel addParticipants:users];
                                      } else {
                                          [reel setParticipants:users];
                                      }
                                  }];
                                  if (success) { success([_users count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

#pragma mark - Participants

- (void)addParticipant:(SBUser *)user
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure {
    [SBParticipation createParticipationForUser:user andReel:self];
    [self postParticipant:user
                  success:^{
                      if (success) { success(); }
                  } failure:^(NSError *error) {
                      if (failure) { failure(error); }
                  }];
}

- (void)removeParticipant:(SBUser *)user
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    [SBParticipation deleteParticipationForUser:user andReel:self];
    [self deleteParticipant:user
                    success:^{
                        if (success) { success(); }
                    } failure:^(NSError *error) {
                        if (failure) { failure(error); }
                    }];
}

- (void)postParticipant:(SBUser *)user
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants/%@", self.remoteID, user.remoteID];
    [[SBAPIManager sharedManager] POST:path
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       [SBParticipation deleteParticipationForUser:user andReel:self inContext:localContext];
                                   }];
                                   if (failure) { failure(error); };
                               }];
}

- (void)deleteParticipant:(SBUser *)user
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants/%@", self.remoteID, user.remoteID];
    [[SBAPIManager sharedManager] DELETE:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     if (success) { success(); }
                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                         [SBParticipation createParticipationForUser:user andReel:self inContext:localContext];
                                     }];
                                     if (failure) { failure(error); };
                                 }];
}

@end
