//
//  BookDetailViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "BookDetailViewController.h"
#import "BooksParser.h"
#import "Book.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"

@interface BookDetailViewController ()<ServiceProtocol>

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel *lblPublisher;
@property (weak, nonatomic) IBOutlet UILabel *lblCategories;
@property (weak, nonatomic) IBOutlet UILabel *lblLastCheckedOutBy;



@property (nonatomic, strong) ServiceManager *manager;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getBook];
}

- (void)getBook
{
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:self.bookUrl];
    [self.manager serviceCallWithURL:url andParameters:nil];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *rightBarButtonItemShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(shareBook)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItemShare;
}

- (void)shareBook
{
    
}

- (void)showBookDetails:(NSArray *)bookArray
{
    Book *book = [bookArray objectAtIndex:0];
    self.lblTitle.text = book.title;
    self.lblAuthor.text = book.author;
    self.lblPublisher.text = book.publisher;
    self.lblLastCheckedOutBy.text = book.lastCheckedOutBy;
    self.lblCategories.text = book.categories;
    [self.view setNeedsDisplay];
}

#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *data = (NSDictionary *)response;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    [dataArray addObject:data];
    [self showBookDetails:[BooksParser getBookObjects:dataArray]];
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
