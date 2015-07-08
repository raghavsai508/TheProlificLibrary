//
//  BookListViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "BookListViewController.h"
#import "CustomBookCell.h"
#import "BookDetailedView/BookDetailViewController.h"
#import "AddNewBookController/AddBookViewController.h"
#import "ServiceManager/ServiceManager.h"
#import "Constants/ServiceURLProvider.h"
#import "Constants/SystemLevelConstants.h"
#import "Parser/BooksParser.h"
#import "Book.h"


@interface BookListViewController ()<UITableViewDelegate,UITableViewDataSource,ServiceProtocol>

@property (weak, nonatomic) IBOutlet UITableView        *bookListTableView;

@property (nonatomic, strong) ServiceManager            *manager;
@property (nonatomic, strong) NSArray                   *booksListArray;

@end

@implementation BookListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getBookList];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *leftBarButtonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBook)];
    self.navigationItem.leftBarButtonItem = leftBarButtonAdd;
}

- (void)addBook
{
    AddBookViewController *addBookViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddBookViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addBookViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)getBookList
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooks];
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"GET"];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.booksListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellIdentifier = @"CustomBookCell";
    CustomBookCell *cell  = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier forIndexPath:indexPath];
    Book *book = [self.booksListArray objectAtIndex:indexPath.row];
    [cell configureCell:book.title andAuthor:book.author];
    
    return cell;
}


#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0)
{
    return 50.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDetailViewController *bookDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BookDetailViewController"];
    Book *book = [self.booksListArray objectAtIndex:indexPath.row];
    bookDetailViewController.bookUrl = book.url;
    [self.navigationController pushViewController:bookDetailViewController animated:YES];
}


- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CustomBookCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.bookListTableView dequeueReusableCellWithIdentifier:@"CustomBookCell"];
    });
    
    Book *book = [self.booksListArray objectAtIndex:indexPath.row];
    [sizingCell configureCell:book.title andAuthor:book.author];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bookListTableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; 
}


#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSArray *data = (NSArray *)response;
    self.booksListArray = [BooksParser getBookObjects:data];
    
    NSLog(@"%@",data);
    [self.bookListTableView reloadData];
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
