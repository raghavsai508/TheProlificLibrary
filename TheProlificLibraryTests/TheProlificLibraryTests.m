//
//  TheProlificLibraryTests.m
//  TheProlificLibraryTests
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BookListViewController_BookTableViewPrivate.h"
#import "CustomBookCell.h"
#import "ServiceURLProvider.h"
#import "SystemLevelConstants.h"
#import "BooksParser.h"
#import "Book.h"
#import "ServiceManager.h"

@interface TheProlificLibraryTests : XCTestCase<ServiceProtocol>

@property (nonatomic, strong) BookListViewController *bookListViewController;
@property BOOL callBackInvoked;

@end

@implementation TheProlificLibraryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self initialSetup];
}

- (void)initialSetup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.bookListViewController = [storyboard instantiateViewControllerWithIdentifier:@"BookListViewController"];
    [self.bookListViewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.bookListViewController = nil;
    [super tearDown];
}

#pragma mark - View Loading Tests
-(void)testThatViewLoads
{
    XCTAssertNotNil(self.bookListViewController.view, @"View not initiated properly");
}

- (void)testBookListViewControllerViewHasTableViewSubview
{
    NSArray *subviews = self.bookListViewController.view.subviews;
    XCTAssertTrue([subviews containsObject:self.bookListViewController.bookListTableView], @"View does not have a table subview");
}

-(void)testTableViewLoads
{
    XCTAssertNotNil(self.bookListViewController.bookListTableView, @"TableView not initiated");
}

#pragma mark - UITableView tests
-(void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.bookListViewController conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.bookListViewController.bookListTableView.dataSource, @"Table datasource cannot be nil");
}

- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.bookListViewController.bookListTableView.delegate, @"Table delegate cannot be nil");
}

- (void)testTableViewCellCreateCellsWithReuseIdentifier
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomBookCell *cell = (CustomBookCell *)[self.bookListViewController tableView:self.bookListViewController.bookListTableView cellForRowAtIndexPath:indexPath];
    NSString *expectedReuseIdentifier = @"CustomBookCell";
    XCTAssertTrue([cell.reuseIdentifier isEqualToString:expectedReuseIdentifier], @"Table does not create reusable cells");
}

#pragma mark - URL check tests
- (void)testServiceURLProvider
{
    NSString *booksURLString = @"http://prolific-interview.herokuapp.com/559c0fe787ed0e000927063e/books";
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooks];
    XCTAssertTrue([booksURLString isEqualToString:url],@"Service url provider is not reposnding with correct url");
}

#pragma mark - Book Parser object check tests
- (void)testBookObject
{
    NSArray *bookArray = [self setUpBookDetails];
    bookArray = [BooksParser getBookObjects:bookArray];
    Book *book = [bookArray objectAtIndex:0];
    
    XCTAssertTrue([book isKindOfClass:[Book class]],@"It is not type Book class");
}


- (NSArray *)setUpBookDetails
{
    NSMutableDictionary *bookDetails = [[NSMutableDictionary alloc]init];
    [bookDetails setObject:@"Ash Maurya" forKey:@"author"];
    [bookDetails setObject:@"process" forKey:@"categories"];
    [bookDetails setObject:[NSNull null] forKey:@"lastCheckedOut"];
    [bookDetails setObject:[NSNull null] forKey:@"lastCheckedOutBy"];
    [bookDetails setObject:@"Running Lean" forKey:@"title"];
    [bookDetails setObject:@"O'REILLY" forKey:@"publisher"];
    [bookDetails setObject:@"/books/1" forKey:@"url"];
    NSArray *booksArray = [[NSArray alloc] initWithObjects:bookDetails,nil];
    return booksArray;
}

#pragma mark - ServiceManager helper methods
- (ServiceManager *)createUniqueInstance
{
    return [[ServiceManager alloc]init];
}

- (ServiceManager *)getSharedInstance
{
    return [ServiceManager defaultManager];
}

#pragma mark - ServiceManager Singleton check
/* This method tests wheter the ServiceManager is a shared Object or not. */
- (void)testServiceManagerSingleton
{
    XCTAssertNotNil([self getSharedInstance]);
}


- (void)testServiceManagerUniqueInstance
{
    XCTAssertNotNil([self createUniqueInstance]);
}

- (void)testServiceManagerReturnsSameSharedInstanceTwice
{
    ServiceManager *serviceManager = [self getSharedInstance];
    XCTAssertEqual(serviceManager, [self getSharedInstance]);
}

- (void)testServiceManagerSharedInstanceSeparateFromUniqueInstance
{
    ServiceManager *serviceManager = [self getSharedInstance];
    XCTAssertNotEqual(serviceManager, [self createUniqueInstance]);
}

- (void)testServiceManagerReturnsSeparateUniqueInstances
{
    ServiceManager *serviceManager = [self createUniqueInstance];
    XCTAssertNotEqual(serviceManager, [self createUniqueInstance]);
}

#pragma mark - Service Call checks
- (void)testServiceCallData
{
    NSDate *fiveSecondsFromNow = [NSDate dateWithTimeIntervalSinceNow:5.0];
    
    NSString *booksURLString = @"http://prolific-interview.herokuapp.com/559c0fe787ed0e000927063e/books";
    ServiceManager *manager = [self getSharedInstance];
    manager.serviceDelegate = self;
    
    [manager serviceCallWithURL:booksURLString andParameters:nil andRequestMethod:@"GET"];
    [[NSRunLoop currentRunLoop] runUntilDate:fiveSecondsFromNow];
    
    XCTAssertTrue(self.callBackInvoked,@"response was not ok. error occured 404");
    
}

#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response withResponseCode:(NSInteger)responseStatusCode
{
    self.callBackInvoked = YES;
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    self.callBackInvoked = NO;
}

@end
