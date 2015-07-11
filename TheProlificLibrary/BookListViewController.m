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
#import "MBProgressHUD.h"


@interface BookListViewController ()<ServiceProtocol>

@property (weak, nonatomic) IBOutlet UITableView        *bookListTableView;
@property (weak, nonatomic) IBOutlet UISearchBar        *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;



@property (nonatomic, strong) ServiceManager            *manager;
@property (nonatomic, strong) NSMutableArray            *booksListArray;
@property (nonatomic, strong) NSArray                   *searchBooksArray;
@property (nonatomic, strong) NSIndexPath               *deleteIndexPath;
@property BOOL                                          deleteAllBooksFlag;

@end

@implementation BookListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    self.bookListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bookListTableView.allowsMultipleSelectionDuringEditing = NO;
    self.deleteAllBooksFlag = NO;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBookList];
}



- (void)setupNavigationBar
{
    UIBarButtonItem *leftBarButtonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBook)];
    self.navigationItem.leftBarButtonItem = leftBarButtonAdd;
    
    UIBarButtonItem *rightBarButtonDelete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllBooks)];
    self.navigationItem.rightBarButtonItem = rightBarButtonDelete;
    
    self.navigationItem.title = @"Books";
    
}

#pragma mark - UISearchDisplayDelegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.booksListArray.count > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(tableView == self.searchController.searchResultsTableView)
        return self.searchBooksArray.count;
    else
        return self.booksListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellIdentifier = @"CustomBookCell";
    CustomBookCell *cell  = [self.bookListTableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
    if (cell == nil) {
        cell = [[CustomBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellIdentifier];
    }
    
    Book *book;
    if(tableView == self.searchController.searchResultsTableView)
        book = [self.searchBooksArray objectAtIndex:indexPath.row];
    else
        book = [self.booksListArray objectAtIndex:indexPath.row];
    [cell configureCell:book.title andAuthor:book.author];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteBook:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0)
{
    return 50.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath withTableView:tableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDetailViewController *bookDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BookDetailViewController"];;
    Book *book;
    if(tableView == self.searchController.searchResultsTableView)
        book = [self.searchBooksArray objectAtIndex:indexPath.row];
    else
        book = [self.booksListArray objectAtIndex:indexPath.row];
    bookDetailViewController.bookUrl = book.url;
    [self.navigationController pushViewController:bookDetailViewController animated:YES];
}

#pragma mark - Utility methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchBooksArray = [self.booksListArray filteredArrayUsingPredicate:resultPredicate];
}

- (void)addBook
{
    AddBookViewController *addBookViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddBookViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addBookViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)deleteAllBooks
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.deleteAllBooksFlag = YES;
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooksClean];
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"DELETE"];
}

- (void)getBookList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooks];
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"GET"];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView
{
    static CustomBookCell *sizingCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.bookListTableView dequeueReusableCellWithIdentifier:@"CustomBookCell"];
    });
    Book *book;
    if(tableView == self.searchController.searchResultsTableView)
        book = [self.searchBooksArray objectAtIndex:indexPath.row];
    else
        book = [self.booksListArray objectAtIndex:indexPath.row];
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

- (void)deleteBook:(NSIndexPath *)indexPath
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Book *book = [self.booksListArray objectAtIndex:indexPath.row];
    self.deleteIndexPath = indexPath;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:book.url];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"DELETE"];
}

- (void)disableProgressHUD
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response withResponseCode:(NSInteger)responseStatusCode
{
    if(responseStatusCode == 200)
    {
        if(!self.deleteAllBooksFlag)
        {
            NSArray *data = (NSArray *)response;
            self.booksListArray = [BooksParser getBookObjects:data];
            NSLog(@"%@",data);
            [self.bookListTableView reloadData];
            [self disableProgressHUD];
        }
        else
        {
            [self disableProgressHUD];
            self.deleteAllBooksFlag = NO;
            [self.booksListArray removeAllObjects];
            [self.bookListTableView reloadData];
        }
    }
    else if (responseStatusCode == 204)
    {
        [self disableProgressHUD];
        [self.booksListArray removeObjectAtIndex:self.deleteIndexPath.row];
        [self.bookListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
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
