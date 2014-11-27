//
//  ViewController.m
//  Demo1126AFNertworking_CL
//
//  Created by Cyrilshanway on 2014/11/26.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate,UITextFieldDelegate>
{
    MBProgressHUD *progressHUD;
    NSMutableArray *dataSource;
    NSTimer *_timer;
    double timerNumber;
}
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *startTimer;
@property (weak, nonatomic) IBOutlet UIButton *pauseTimer;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title =@"KKTix test";
    
//    UIBarButtonItem *preBtn = [[UIBarButtonItem alloc] initWithTitle:@"上一頁" style:(UIBarButtonItemStylePlain) target:self action:@selector(back:)];
//    
//    // Set the properties
//    [preBtn setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor whiteColor],  NSForegroundColorAttributeName, [UIFont systemFontOfSize:12], NSFontAttributeName,
//      nil] forState:UIControlStateNormal];
//    
//    self.navigationItem.leftBarButtonItem = preBtn;
    //新增用圖片的按鈕
    UIImage *leftImage = [[UIImage imageNamed:@"btn_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                   style:(UIBarButtonItemStylePlain)
                                                                  target:self
                                                                  action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    //1127
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 46.0f, 29.0f)];
    [a1 addTarget:self action:@selector(enterEditMode:) forControlEvents:(UIControlEventTouchUpInside)];
    [a1 setTitle:@"編輯" forState:(UIControlStateNormal)];
    [a1.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [a1 setTitleColor:[UIColor purpleColor] forState:(UIControlStateNormal)];
    a1.titleLabel.textColor =[UIColor blackColor];
    UIBarButtonItem *right1Button = [[UIBarButtonItem alloc] initWithCustomView:a1];
    
    UIButton *a2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a2 setFrame:CGRectMake(0.0f, 0.0f, 46.0f, 29.0f)];
    [a2 addTarget:self action:@selector(leaveEditMode:) forControlEvents:(UIControlEventTouchUpInside)];
    [a2 setTitle:@"結束" forState:(UIControlStateNormal)];
    [a2.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [a2 setTitleColor:[UIColor greenColor] forState:(UIControlStateNormal)];
    a2.titleLabel.textColor =[UIColor blackColor];
    UIBarButtonItem *right2Button = [[UIBarButtonItem alloc] initWithCustomView:a2];
    
    self.navigationItem.rightBarButtonItems =@[right1Button,right2Button];
    
    
    [self.startTimer.layer setCornerRadius:10.0f];
    [self.startTimer.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.startTimer.layer setBorderWidth:2.0f];
    
    [self.pauseTimer.layer setCornerRadius:10.0f];
    [self.pauseTimer.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.pauseTimer.layer setBorderWidth:2.0f];

    
    //建立一個空的dataSource//11/26(step.1)
    dataSource = [NSMutableArray arrayWithCapacity:0];
    
    [self getRemoteURL];
    
    [self.textField becomeFirstResponder];
    
}

-(void)enterEditMode:(id)sender{
    NSLog(@"enterEditMode");
}

-(void)leaveEditMode:(id)sender{
    NSLog(@"leaveEditMode");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - progressed init(設定)
- (void)initializeProgressedHUD:(NSString *)msg{
    
    if (progressHUD) {
        [progressHUD removeFromSuperview];
    }
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    
    progressHUD.dimBackground = NO;
    progressHUD.delegate = self;
    progressHUD.labelText = msg;
    
    progressHUD.margin = 20.f;
    progressHUD.yOffset = 10.0f;
    
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSLog(@"textFieldShouldBeginEditing");
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}


#pragma mark - AFNetworking
-(void)getRemoteURL{
#pragma mark - progressed 載入中
    //載入中
    [self initializeProgressedHUD:@"載入中"];
    
    //1. 準備HTTP Client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.187.98.65/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"api/v1/AlphaCampTest.php" parameters:nil];
    //2.準備operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //3.準備callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
#pragma mark - progressed 完成
        //載入完成
        NSLog(@"Completed!");
        //NSLog(@"We are ");
        
        [progressHUD hide:YES];
        
        
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //test log
        //NSLog(@"Response: %@",tmp);
#pragma mark - 轉資料11/26
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        /*
         @class NSError, NSOutputStream, NSInputStream, NSData;
         
         typedef NS_OPTIONS(NSUInteger, NSJSONReadingOptions) {
         NSJSONReadingMutableContainers = (1UL << 0),
         NSJSONReadingMutableLeaves = (1UL << 1),
         NSJSONReadingAllowFragments = (1UL << 2)
         } NS_ENUM_AVAILABLE(10_7, 5_0);
        */
        //回傳NSDictionary
        //回NSMutableArray
        //回傳的是單純字串(單純json字串)
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e];
        
        NSString *RC = [NSString stringWithFormat:@"%@", [dict objectForKey:@"RC"]];
        NSString *RM = [NSString stringWithFormat:@"%@", [dict objectForKey:@"RM"]];
        NSArray *listData = [dict objectForKey:@"result"];
        //NSArray *listData1= dict[@"result"];
        
        NSLog(@"%@", RC);
        NSLog(@"%@", RM);
        NSLog(@"%@", listData);
        //NSLog(@"%@", listData1);
        
        NSInteger arrayLength = [listData count];
        
        NSLog(@"Array Length: %ld", arrayLength);
        
        if (arrayLength > 0) {
            [dataSource removeAllObjects];
            for (int i = 0; i < arrayLength; i++) {
                NSDictionary *innerDict = listData[i];
                //step.2
                [dataSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [innerDict objectForKey:@"announcement_version"],@"announcement_version",
                                       [innerDict objectForKey:@"current_time"],@"current_time",
                                       [innerDict objectForKey:@"waitin_time"],@"waiting_time",
                                       [innerDict objectForKey:@"ios_version"],@"ios_version",
                                       [innerDict objectForKey:@"android_version"],@"android_version",
                                       nil]];
                
                
            }
        }
        //step.4
        NSLog(@"Final dresult: %@", dataSource);
        [self.tableView reloadData];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"確認" delegate:self cancelButtonTitle:@"完成" otherButtonTitles: nil];
        
        [alert show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
    }];
    
    //4. Start傳輸
    [operation start];
}

- (void)back:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"前一頁" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableView Delegate
//分類
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}
//欄位高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath");
    return 60.0;
}
//要顯示幾個欄位
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection");
    NSLog(@"Source count: %ld", dataSource.count);
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //兩個section
    
    static NSString *requestIdentifier = @"HelloCell";
    static NSString *requestIdentifier2 = @"HelloCell2";
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:{
            cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:requestIdentifier];
                cell.textLabel.textColor = [UIColor purpleColor];
                cell.detailTextLabel.textColor =[UIColor brownColor];
                cell.backgroundColor = [UIColor clearColor];
                
                cell.textLabel.font  = [UIFont fontWithName: @"AvenirNextCondensed-Bold" size: 14.0];
                
                cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
                
                cell.selectionStyle =UITableViewCellSelectionStyleGray;
                
                //step.3
                cell.textLabel.text = dataSource[indexPath.row][@"current_time"];
            }
        }
            break;
            
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier2];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:requestIdentifier2];
                cell.textLabel.textColor = [UIColor blueColor];
                cell.detailTextLabel.textColor =
                [UIColor orangeColor];
                cell.backgroundColor = [UIColor clearColor];
                
                cell.textLabel.font  = [UIFont fontWithName: @"AvenirNextCondensed-Bold" size: 14.0];
                
                cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
                
                cell.selectionStyle =UITableViewCellSelectionStyleGray;
            }
        }
            break;
    }
    
   
    
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier];
    
    //cell.textLabel.text = dataSource[indexPath.row];
    //cell.detailTextLabel.text = detailDataSource[indexPath.row];
    
    /*
    //單一section
    static NSString *requestIdentifier = @"HelloCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:requestIdentifier];
        cell.textLabel.textColor = [UIColor redColor];
    }
    cell.textLabel.text = @"Hello";
    */
    
    
    NSString *title;
    switch (indexPath.section) {
        case 0:
            title = @"Download";
            break;
        case 1:
            title = @"Upload";
            break;
            
        default:
            break;
    }
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(230, 10, 80, 40)];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName: @"AvenirNextCondensed-Bold" size: 12.0];
    [button setBackgroundColor:[UIColor yellowColor]];
    button.tag = indexPath.row;
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
    
    [button.layer setCornerRadius:10.0f];
    [button.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [button.layer setBorderWidth:2.0f];
    
    
    UIButton *openTELBtn = [[UIButton alloc]initWithFrame:CGRectMake(140, 10, 80, 40)];
    [button setTitle:@"Open" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName: @"AvenirNextCondensed-Bold" size: 12.0];
    [button setBackgroundColor:[UIColor brownColor]];
    button.tag = indexPath.row;
    
    [button addTarget:self action:@selector(openWeb:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
    
    [button.layer setCornerRadius:10.0f];
    [button.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [button.layer setBorderWidth:2.0f];
   
    
    NSLog(@"cellForRowAtIndexPath");
    return cell;
}

-(void)openWeb:(id)sender{
    NSString *url = [NSString stringWithFormat:@"http://%@", self.textField.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"You pressed: %ld %ld", indexPath.section, indexPath.row);
    /*
     //不分section累加值
     NSInteger rowNumber = 0;
     
     for (NSInteger i = 0; i < indexPath.section; i++) {
     rowNumber += [self tableView:tableView numberOfRowsInSection:i];
     }
     
     rowNumber += indexPath.row;
     return rowNumber;
     NSLog(@"%ld",rowNumber);
     */
    
}
#pragma mark - timer
- (IBAction)startBtnPressed:(id)sender {
    
    //1127
    double interval = 1.0f;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerEvent:)
                                            userInfo:nil
                                             repeats:true];

}
- (IBAction)stopBtnPressed:(id)sender {
    [_timer invalidate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                    message:@"已停止"
                                                   delegate:self
                                          cancelButtonTitle:@"確認"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (void)timerEvent:(NSTimer *)timer{
    
    
    timerNumber += 1.0f;
    self.timerLabel.text = [NSString stringWithFormat:@"%.2f",timerNumber];
    NSLog(@"timer event is invoked");
}
- (void)buttonPressed:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    //按下當個view就會消失(現在是cell)
    //[button removeFromSuperview];
    NSLog(@"You pressed the button %ld", button.tag);
    
}
- (IBAction)completeBtnPressed:(id)sender {
    //空白處理
    NSString *final = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", final);
    
    [self.textField resignFirstResponder];
}
@end
