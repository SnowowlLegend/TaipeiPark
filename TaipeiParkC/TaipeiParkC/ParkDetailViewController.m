//
//  ParkDetailViewController.m
//  TaipeiParkC
//
//  Created by Richard on 2018/02/06.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

#import "ParkDetailViewController.h"
#import "ParkCollectionViewCell.h"

@interface ParkDetailViewController ()

@end

@implementation ParkDetailViewController

@synthesize parkItem;
@synthesize nearbyviewArray;

- (void)setAScrollView:(UIScrollView *)aScrollView
{
    _aScrollView = aScrollView;
    self.aScrollView.scrollEnabled = YES;
    self.aScrollView.showsVerticalScrollIndicator = YES;
    self.aScrollView.showsHorizontalScrollIndicator = NO;
    
}

- (void)setACollectionView:(UICollectionView *)aCollectionView
{
    _aCollectionView = aCollectionView;
    self.aCollectionView.backgroundColor = [UIColor whiteColor];
    self.aCollectionView.dataSource = self;
    self.aCollectionView.delegate = self;
    self.aCollectionView.scrollEnabled = YES;
    self.aCollectionView.showsHorizontalScrollIndicator = YES;
    self.aCollectionView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    if (parkItem) {
        //        NSString *imageURL = [[parkItem objectForKey:@"Image"] description];
        NSString *parkName = [[parkItem objectForKey:@"ParkName"] description];
        NSString *name = [[parkItem objectForKey:@"Name"] description];
        NSString *introduction = [[parkItem objectForKey:@"Introduction"] description];
        NSString *openTime = [[parkItem objectForKey:@"OpenTime"] description];
        //        NSString *yearBuilt = [[parkItem objectForKey:@"YearBuilt"] description];
        
        UIImage *image = (UIImage*)[parkItem objectForKey:@"thumbImage"];
        
        self.parkNameLabel.text = parkName;
        self.nameLabel.text = name;
        self.openTimeLabel.text = openTime;
        self.parkIntroLabel.text = introduction;
        self.parkImageView.image = image;
        
        [self.parkIntroLabel sizeToFit];
        
        int nScrollContentSize = self.parkImageView.frame.size.height + self.parkNameLabel.frame.size.height + self.nameLabel.frame.size.height + self.openTimeLabel.frame.size.height + self.parkIntroLabel.frame.size.height + self.aCollectionView.frame.size.height;
        nScrollContentSize += 50;
        
        CGRect contentViewFrame = CGRectMake(0, 0, self.aScrollView.frame.size.width, nScrollContentSize);
        self.scrollContentView.frame = contentViewFrame;
        
        self.aScrollView.contentSize = CGSizeMake(contentViewFrame.size.width, contentViewFrame.size.height);
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (nearbyviewArray.lastObject) {
        return nearbyviewArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ParkCollectionViewCell *cell = (ParkCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    NSDictionary *cellItem = [nearbyviewArray objectAtIndex:indexPath.row];
    
    UIImage *image = (UIImage*)[cellItem objectForKey:@"thumbImage"];
    cell.photoImageView.image = image;
    cell.nameLabel.text = [[cellItem objectForKey:@"Name"] description];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellItem = [nearbyviewArray objectAtIndex:indexPath.row];

    parkItem = cellItem;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
