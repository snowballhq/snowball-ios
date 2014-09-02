//
//  SBFollowingViewController.h
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedTableViewController.h"

@class SBTableViewCell;

@interface SBFollowingViewController : SBManagedTableViewController

// For subclasses, such as SBEditParticipantsViewController

- (void)configureCell:(SBTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
