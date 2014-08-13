//
//  SBFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 8/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFriendsViewController.h"
#import "SBNavigationController.h"
#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBFriendsViewController () <SBUserTableViewCellDelegate>

@end

@implementation SBFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"remoteID == %@", [SBUser currentUser].remoteID];
    [self setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:@[self.predicate, currentUserPredicate]]];
    [self setSectionNameKeyPath:@"isCurrentUser"];
}

#pragma mark - SBFollowingViewController

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    [cell setStyle:SBUserTableViewCellStyleNone];
}

#pragma mark - Actions

- (IBAction)switchToReelsStoryboard:(id)sender {
    [(SBNavigationController *)self.navigationController switchToStoryboardWithName:@"Reels"];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        [headerView.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [headerView.textLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameBook] size:headerView.textLabel.font.pointSize]];
        [headerView.textLabel setTextColor:[UIColor colorWithRed:114/255.0 green:214/255.0 blue:235/255.0 alpha:1.0]];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Me";
            break;
    }
    return @"My Friends";
}

@end
