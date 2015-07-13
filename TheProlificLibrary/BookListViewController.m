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
#import "Filters/FilterViewController.h"
#import "ServiceManager/ServiceManager.h"
#import "Constants/ServiceURLProvider.h"
#import "Constants/SystemLevelConstants.h"
#import "Parser/BooksParser.h"
#import "Book.h"
#import "BookFilter.h"
#import "MBProgressHUD.h"


@interface BookListViewController ()<ServiceProtocol,FilterViewProtocol,AddBookProtocol>

@property (weak, nonatomic) IBOutlet UITableView        *bookListTableView;
@property (weak, nonatomic) IBOutlet UISearchBar        *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController                           *searchController;

@property (nonatomic, strong) FilterViewController      *filterViewController;
@property (nonatomic, strong) AddBookViewController     *addBookViewController;

@property (nonatomic, strong) ServiceManager            *manager;
@property (nonatomic, strong) NSMutableArray            *booksListArray;
@property (nonatomic, strong) NSMutableArray            *bookTempArray;
@property (nonatomic, strong) NSMutableArray            *imagesArray;
@property (nonatomic, strong) NSArray                   *searchBooksArray;
@property (nonatomic, strong) NSIndexPath               *deleteIndexPath;
@property (nonatomic, strong) UIRefreshControl          *refreshControl;
@property BOOL                                          deleteAllBooksFlag;

@end

@implementation BookListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getBookList];
    [self setupNavigationBar];
    [self initialSetup];
}

/* This will do the initial setup for the BookList Table view. */
- (void)initialSetup
{
    self.bookListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bookTempArray = [[NSMutableArray alloc] init];
    self.bookListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.deleteAllBooksFlag = NO;
    [self instantiateFilterMenu];
    [self setupRefreshControl];
}

/* This method is responsible for setup navigation bar. */
- (void)setupNavigationBar
{
    [self setupLeftBarButton];
    [self setupRightBarButton];
    self.navigationItem.title = @"Books";
}

/* This method is reponsible for setting up the navigation item left item.  */
- (void)setupLeftBarButton
{
    UIBarButtonItem *leftBarButtonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBook)];
    self.navigationItem.leftBarButtonItem = leftBarButtonAdd;
}

/* This method is reponsible for setting up the navigation item right item.  */
- (void)setupRightBarButton
{
    UIImage *filterImage = [UIImage imageNamed:@"filter"];
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.bounds = CGRectMake( 0, 0, 30, 30);
    [filterButton setImage:filterImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(showFilterMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonFilter = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonFilter;
}

- (void)instantiateFilterMenu
{
    self.filterViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([FilterViewController class])];
}

- (void)setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getBookList) forControlEvents:UIControlEventValueChanged];
    [self.bookListTableView addSubview:self.refreshControl];
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
    
    if(tableView == self.searchController.searchResultsTableView)
        return self.searchBooksArray.count;
    else
        return self.booksListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
        book = [self.searchBooksArray objectAtIndex:indexPath.section];
    else
        book = [self.booksListArray objectAtIndex:indexPath.section];
    int randomImgNum = [self getRandomImageNumber:indexPath];
    [cell configureCell:book.title andAuthor:book.author andImageNum:randomImgNum];
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDetailViewController *bookDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BookDetailViewController"];;
    Book *book;
    if(tableView == self.searchController.searchResultsTableView)
        book = [self.searchBooksArray objectAtIndex:indexPath.section];
    else
        book = [self.booksListArray objectAtIndex:indexPath.section];
    bookDetailViewController.bookUrl = book.url;
    [self.navigationController pushViewController:bookDetailViewController animated:YES];
}


#pragma mark - Utility methods
/* This method filters the array of books for a given string from search bar.  */
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchBooksArray = [self.booksListArray filteredArrayUsingPredicate:resultPredicate];
}

/* This method presents the modal screen for adding the book. */
- (void)addBook
{
    self.addBookViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddBookViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.addBookViewController];
    self.addBookViewController.addBookDelegate = self;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

/* This method presents the modal screen for showing the filter options. */
- (void)showFilterMenu
{
    self.filterViewController.bookTempArray = self.booksListArray;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.filterViewController];
    self.filterViewController.filterDelegate = self;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

/* This method deletes all the books from the tableview. */
- (void)deleteAllBooks
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.deleteAllBooksFlag = YES;
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooksClean];
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"DELETE"];
}

/* This method fetches list of books from the server. */
- (void)getBookList
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooks];
    [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"GET"];
}

/* This method deletes a book when the user swipes from right to left. */
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

/* This method disables the Progress HUD when the books are fetched from the server. */
- (void)disableProgressHUD
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

/* This method gets a random number for setting up the image for the cell. */
- (int)getRandomImageNumber:(NSIndexPath *)indexPath
{
    int random;
    random = indexPath.section % 5 + 1;
    return random;
}

#pragma mark - FilterViewProtocol methods
- (void)resetAllFilterPressed
{
    [self.booksListArray removeAllObjects];
    [self.booksListArray addObjectsFromArray:self.bookTempArray];
    [self.bookListTableView reloadData];
}

- (void)filteredResults:(NSMutableArray *)filterResults
{
    [self.booksListArray removeAllObjects];
    [self.booksListArray addObjectsFromArray:filterResults];
    [self.bookListTableView reloadData];
}

- (void)deleteBooks
{
    [self deleteAllBooks];
}

#pragma mark - AddBookProtocol
- (void)bookAdded
{
    [self getBookList];
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
            [self.bookTempArray addObjectsFromArray:self.booksListArray];
            NSLog(@"%@",data);
            [self.refreshControl endRefreshing];
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
        [self.booksListArray removeObjectAtIndex:self.deleteIndexPath.section];
        [self.bookListTableView deleteSections:[NSIndexSet indexSetWithIndex:self.deleteIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//        [self.bookListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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
