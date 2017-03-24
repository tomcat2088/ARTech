//
// Created by wangyang on 2017/3/16.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property  (strong, nonatomic) NSDictionary * titles;
@property  (strong, nonatomic) NSArray * sections;
@end

@implementation HomeViewController

- (NSString *)title {
    return @"AR实验室";
}

- (NSArray *)sections {
    return [self.titles.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *s1 = (NSString *)obj1;
        NSString *s2 = (NSString *)obj2;
        return [s1 compare:s2];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.titles = @{
                    @"示例展示" : @{
                            @"传统方形Marker展示" : @"gotoSquareMarker",
                            @"NFT Marker展示" :  @"gotoNFTMarker"
                            },
                    @"工具" : @{
                            @"制作NFT Marker" : @"gotoNFDetect"
                            },
                    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell) {
         NSString *sectionKey = self.sections[indexPath.section];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.text =  [self.titles[sectionKey] allKeys][indexPath.row];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = self.sections[section];
    return [self.titles[sectionKey] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *sectionKey = self.sections[indexPath.section];
    NSString *sel = self.titles[sectionKey][cell.textLabel.text];
    UIViewController * vc = [self performSelector:NSSelectorFromString(sel)];
    vc.title = cell.textLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIViewController *)gotoSquareMarker {
    return (UIViewController *)[NSClassFromString(@"SquareARViewController") new];
}

- (UIViewController *)gotoNFTMarker {
    return (UIViewController *)[NSClassFromString(@"NFTARViewController") new];
}

- (UIViewController *)gotoNFDetect {
    return (UIViewController *)[NSClassFromString(@"NFDetectViewController") new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

@end
