//
//  SBReelTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTableViewCell.h"

typedef NS_ENUM(NSInteger, SBReelTableViewCellState) {
    SBReelTableViewCellStateNormal,
    SBReelTableViewCellStatePendingUpload
};

@interface SBReelTableViewCell : SBTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *participantOneImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantTwoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantThreeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFourImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFiveImageView;

@property (nonatomic) BOOL showsNewClipIndicator;

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated;

@end
