//
//  SBParticipantsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditParticipantsViewController.h"
#import "SBParticipantsViewController.h"
#import "SBParticipation.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

// TODO: rename this to SBReelDetailsViewController
@interface SBParticipantsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBParticipantsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SBUserTableViewCell registerNibToTableView:self.tableView];
    
    [self setEntityClass:[SBParticipation class]];
    [self setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user.name" ascending:YES]]];
    [self setPredicate:[NSPredicate predicateWithFormat:@"reel == %@", self.reel]];
    
    [self setNavBarColor:self.reel.color];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBEditParticipantsViewController class]]) {
        SBEditParticipantsViewController *vc = segue.destinationViewController;
        [vc setReel:self.reel];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier]
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBParticipation *participation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SBUser *user = participation.user;
    [cell configureForObject:user delegate:self];
    
    [cell setChecked:[user isParticipatingInReel:self.reel]];
    [cell setTintColor:self.reel.color];

    [cell setStyle:SBUserTableViewCellStyleNone];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBParticipation *participation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SBUser *user = participation.user;
    [cell setChecked:!user.followingValue];
    if (user.followingValue) {
        [user unfollowWithSuccess:nil failure:nil];
    } else {
        [user followWithSuccess:nil failure:nil];
    }
}

#pragma mark - SBManagedTableViewController

- (void)getRemoteObjects {
    [self.reel getParticipantsOnPage:self.currentPage
                             success:^(BOOL canLoadMore) {
                                 [self setIsLoading:!canLoadMore];
                                 [self.refreshControl endRefreshing];
                             } failure:^(NSError *error) {
                                 [self.refreshControl endRefreshing];
                             }];
}

@end
