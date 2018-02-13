//
//  ParkDetailViewController.h
//  TaipeiParkC
//
//  Created by Richard on 2018/02/06.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *aScrollView;

@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

@property (weak, nonatomic) IBOutlet UIImageView *parkImageView;

@property (weak, nonatomic) IBOutlet UILabel *parkNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *parkIntroLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *aCollectionView;

@property (strong, nonatomic) NSDictionary *parkItem;
@property (strong, nonatomic) NSArray *nearbyviewArray;


@end
