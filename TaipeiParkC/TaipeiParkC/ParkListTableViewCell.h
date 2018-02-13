//
//  ParkListTableViewCell.h
//  TaipeiParkC
//
//  Created by Richard on 2018/02/06.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *parkImageView;

@property (weak, nonatomic) IBOutlet UILabel *parkNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *parkIntroLabel;

@end
