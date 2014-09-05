//
//  SBFindFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAddressBookManager.h"
#import "SBAuthenticationNavigationController.h"
#import "SBFindFriendsViewController.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBFindFriendsViewController () <SBUserTableViewCellDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *users;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@end

@implementation SBFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBUserTableViewCell registerNibToTableView:self.tableView];

    [self.doneButton setHidden:YES];

    if ([SBAddressBookManager authorized]) {
        [self showSpinner];
        [self getContactsFromAddressBook];
    } else {
        [self.tableView setHidden:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBUser *user = self.users[indexPath.row];
    [cell configureForObject:user delegate:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"People in my contacts on Snowball";
            break;
    }
    return nil;
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = self.users[indexPath.row];
    [cell setChecked:!user.followingValue];
    if (user.followingValue) {
        [user unfollowWithSuccess:nil failure:nil];
    } else {
        [user followWithSuccess:nil failure:nil];
    }
}

#pragma mark - Actions

- (IBAction)findFriendsViaContacts:(id)sender {
    [self showSpinner];
    [self getContactsFromAddressBook];
}

- (IBAction)done:(id)sender {
    if ([self.navigationController isKindOfClass:[SBAuthenticationNavigationController class]]) {
        [(SBAuthenticationNavigationController *)self.navigationController dismiss];
    }
}

#pragma mark - Private

- (void)getContactsFromAddressBook {
    [SBAddressBookManager getAllPhoneNumbersWithCompletion:^(NSArray *phoneNumbers) {
        if ([phoneNumbers count] > 0) {
            [SBUser findUsersByPhoneNumbers:phoneNumbers
                                       page:0  // TODO: make this paginated
                                    success:^(NSArray *users) {
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"following == FALSE"];
                                        [self setUsers:[users filteredArrayUsingPredicate:predicate]];
                                        [self hideSpinner];
                                        [self showContacts];
                                    } failure:^(NSError *error) {
                                        [self hideSpinner];
                                        [error displayInView:self.view];
                                    }];
        } else {
            [self hideSpinner];
        }
    }];
}

- (void)showContacts {
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
    
    if ([self.navigationController isKindOfClass:[SBAuthenticationNavigationController class]]) {
        [self.doneButton setHidden:NO];
    }
}

@end
