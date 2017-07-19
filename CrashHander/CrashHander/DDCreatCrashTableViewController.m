//
//  DDCreatCrashTableViewController.m
//  DebugTool
//
//  Created by 张桂杨 on 2017/3/22.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDCreatCrashTableViewController.h"
#import <objc/runtime.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface DDCreatCrashTableViewController () {
    NSArray *_dataArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DDCreatCrashTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[@"unrecognized selector",@"set nil for dictionary",@"add self for self ",@"NSRangeException",@"KVO",@"set nil for array"];

    [self addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SuppressPerformSelectorLeakWarning
        ([self performSelector:NSSelectorFromString([NSString stringWithFormat:@"crash%td",indexPath.row]) withObject:nil];
    );


    
}
- (void)crash0 {
     NSString *str = (NSString *)self;
    
    
    NSLog(@"%td",str.length);
}

- (void)crash1 {
    NSString *password = nil;
    NSDictionary *dict = @{
                           @"userName": @"bruce",
                           @"password": password
                           };
    NSLog(@"dict is : %@", dict);
}
- (void)crash2 {
    [self.view addSubview:self.view];
}

- (void)crash3 {
    
    NSArray *arr = @[@"1"];
    NSLog(@"%@",arr[3]);
}
- (void)crash4 {
    [self removeObserver:self forKeyPath:@"view"];
}
- (void)crash5 {
    NSString *str = nil;
    NSMutableArray *array = [NSMutableArray arrayWithObjects:str, nil];
    NSLog(@"%@",@[str]);
    [array addObject:str];
    
}
@end
