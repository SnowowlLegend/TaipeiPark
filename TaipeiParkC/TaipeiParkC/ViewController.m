//
//  ViewController.m
//  TaipeiParkC
//
//  Created by Richard on 2018/01/31.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

#import "ViewController.h"
#import "ParkListTableViewCell.h"
#import "ParkDetailViewController.h"

#define QUERY_REMOTE_URL                @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=bf073841-c734-49bf-a97f-3757a6013812"
#define QUERY_TIMER_INTERVAL            3.0f
#define QUERY_TIMEOUT_INTERVAL          15.0f


@interface ViewController () <NSURLSessionDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSTimer *queryTimer;
    NSTimer *timeoutTimer;
    NSTimeInterval  timeout;
    NSMutableData *responseData;

    NSMutableArray *sectionArray;
    NSMutableArray *tableviewArray;
    NSMutableArray *nearbyviewArray;
    
    NSIndexPath *selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *aTableView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation ViewController

@synthesize selectedIndexPath = _selectedIndexPath;

- (void)setATableView:(UITableView *)aTableView
{
    _aTableView = aTableView;
    self.aTableView.dataSource = self;
    self.aTableView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.aTableView.rowHeight = UITableViewAutomaticDimension;
    self.aTableView.estimatedRowHeight = 150;
    
    [self.activityView startAnimating];
    
    [self startQueryTimer];
}



#pragma mark - HTTP Connection

- (void)startConnection {
    NSString *urlString = QUERY_REMOTE_URL;
    
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:QUERY_TIMEOUT_INTERVAL];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];

}

- (void)startQueryTimer {
    if (queryTimer == nil) {
        queryTimer = [NSTimer scheduledTimerWithTimeInterval:QUERY_TIMER_INTERVAL target:self selector:@selector(timerHandler:) userInfo:nil repeats:NO];
    }
}

- (void)timerHandler:(NSTimer*)timer {
    if (timer == queryTimer) {
        [self startConnection];
    } else if (timer == timeoutTimer) {
        
    }
}


#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    int statusCode = (int)[httpResponse statusCode];
    
    if( statusCode != 200 ) {
        NSLog(@"didReceiveResponse error: %d", statusCode);
        NSLog(@"didReceiveResponse response: %@", response);
    } else if (statusCode == 200) {
        NSLog(@"didReceiveResponse successful");
        responseData = [[NSMutableData alloc] init];
        
        completionHandler(NSURLSessionResponseAllow);
    }

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"didCompleteWithError: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"didCompleteWithError data: %@", jsonString);
        
        [self parseNprocess:jsonString];

    }
}


#pragma mark - Parsing JSON Data

- (void)parseNprocess:(NSString*)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    //NSLog(@"JSON Dictionary: %@", json);
    
    sectionArray = [[NSMutableArray alloc] init];
    tableviewArray = [[NSMutableArray alloc] init];
    
    NSDictionary *result = [json objectForKey:@"result"];
    
    NSArray *results = [result objectForKey:@"results"];
    
    __block int nImageCount = 0;
    __block int nThumbCount = 0;
    
    if (results.lastObject) {
        NSDictionary *currentItem = [results objectAtIndex:0];
        [sectionArray addObject:currentItem];
        
        NSMutableArray *nearbyArray = [[NSMutableArray alloc] init];
        
        __block int nLoadedImageCount = 0;
        
        for (NSDictionary *item in results) {
            NSString *imageURL = [[item objectForKey:@"Image"] description];
            NSString *parkName = [[item objectForKey:@"ParkName"] description];
            NSString *name = [[item objectForKey:@"Name"] description];
            NSString *introduction = [[item objectForKey:@"Introduction"] description];
            NSString *openTime = [[item objectForKey:@"OpenTime"] description];
            NSString *yearBuilt = [[item objectForKey:@"YearBuilt"] description];
            
            NSLog(@"\nImage URL: %@,\nPark Name:%@,\nName: %@,\nOpen Time: %@,\nYear Build: %@,\nIntroduction: %@\n",
                  imageURL, parkName, name, openTime, yearBuilt, introduction);
            
            if (![imageURL isEqualToString:@""]) {
                nImageCount++;
            }
            
            __block NSMutableDictionary *cellItem = [NSMutableDictionary dictionaryWithDictionary:item];
            
            dispatch_queue_t queue = dispatch_queue_create("parser", NULL);
            dispatch_async(queue, ^{
                NSURL *url = [NSURL URLWithString:imageURL];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (image) {
                        [cellItem setObject:image forKey:@"thumbImage"];
                        nThumbCount++;
                        
                        if (nThumbCount % 10 == 0) {
                            nLoadedImageCount = nThumbCount;
                        }
                        
                        if (nThumbCount - nLoadedImageCount >= 10) {
                            [self reloadTableView];
                        }
                    }
                });
            });
            
            NSString *currentParkName = [[currentItem objectForKey:@"ParkName"] description];
            
            if ([parkName isEqualToString:currentParkName]) {
                [nearbyArray addObject:cellItem];
            } else {
                currentItem = cellItem;
                [sectionArray addObject:currentItem];
                
                NSArray *itemArray = [NSArray arrayWithArray:nearbyArray];
                [tableviewArray addObject:itemArray];
                [nearbyArray removeAllObjects];
                [nearbyArray addObject:cellItem];
            }
        }
        
        [tableviewArray addObject:nearbyArray];
    }

    [self reloadTableView];
}

- (void)reloadTableView {
    if (tableviewArray.lastObject) {
        [self.aTableView reloadData];
        
        [self.activityView stopAnimating];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (sectionArray.lastObject) {
        return sectionArray.count;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if ([tableviewArray lastObject]) {
        //NSLog(@"tableView numberOfRowsInSection: %ld", (long)[tableviewArray count]);
        if (tableviewArray.count > section) {
            NSArray *sectionItem = [tableviewArray objectAtIndex:section];
            rows = sectionItem.count;
        } else {
            return 0;
        }
    }
    else {
        return 0;
    }
    
    return rows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";

    if (sectionArray.lastObject) {
        if (section < sectionArray.count) {
            NSDictionary *sectionItem = [sectionArray objectAtIndex:section];
            headerTitle = [sectionItem objectForKey:@"ParkName"];
        }
    }

    return headerTitle;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParkListTableViewCell *cell = (ParkListTableViewCell*)[self.aTableView dequeueReusableCellWithIdentifier:@"Park Cell"];

    if (!cell) {
        cell = [[ParkListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Park Cell"];
    }
    
    if (tableviewArray.lastObject) {
        if ([tableviewArray count] > indexPath.row) {
            NSArray *sectionItem = [tableviewArray objectAtIndex:indexPath.section];
            NSDictionary *cellItem = [sectionItem objectAtIndex:indexPath.row];
//            NSString *imageURL = [[cellItem objectForKey:@"Image"] description];
            NSString *parkName = [[cellItem objectForKey:@"ParkName"] description];
            NSString *name = [[cellItem objectForKey:@"Name"] description];
            NSString *introduction = [[cellItem objectForKey:@"Introduction"] description];
//            NSString *openTime = [[cellItem objectForKey:@"OpenTime"] description];
//            NSString *yearBuilt = [[cellItem objectForKey:@"YearBuilt"] description];

            UIImage *image = (UIImage *)[cellItem objectForKey:@"thumbImage"];
            
            if (!image) {
                image = [UIImage imageNamed:@"Round_Landmark_Icon_Park"];
            }
            
            cell.parkImageView.image = image;
            cell.parkNameLabel.text = parkName;
            cell.nameLabel.text = name;
            cell.parkIntroLabel.text = introduction;
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Show Detail" sender:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"Show Detail"]) {
         if ([segue.destinationViewController isKindOfClass:[ParkDetailViewController class]]) {
             ParkDetailViewController *pdvc = (ParkDetailViewController*)segue.destinationViewController;
             NSArray *sectionItem = [tableviewArray objectAtIndex:selectedIndexPath.section];
             NSDictionary *cellItem = [sectionItem objectAtIndex:selectedIndexPath.row];
             pdvc.parkItem = cellItem;
             pdvc.nearbyviewArray = sectionItem;
         }
     }
 }




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
