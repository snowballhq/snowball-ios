//
//  SBClip.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBClip.h"
#import "SBReel.h"

@implementation SBClip

#pragma mark - Remote

+ (void)getRecentClipsForReel:(SBReel *)reel
                         page:(NSUInteger)page
                      success:(void (^)(BOOL canLoadMore))success
                      failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/clips", reel.remoteID];;
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_clips = responseObject[@"clips"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [SBClip MR_importFromArray:_clips inContext:localContext];
                                  }];
                                  if (success) { success([_clips count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

@end
