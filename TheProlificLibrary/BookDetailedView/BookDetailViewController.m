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
#import "MBProgressHUD.h"

@interface BookDetailViewController ()<ServiceProtocol,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel        *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel        *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel        *lblPublisher;
@property (weak, nonatomic) IBOutlet UILabel        *lblCategories;
@property (weak, nonatomic) IBOutlet UILabel        *lblLastCheckedOutBy;
@property (weak, nonatomic) IBOutlet UIButton       *btnCheckOut;

@property (nonatomic, strong) ServiceManager        *manager;
@property (nonatomic, strong) NSString              *name;

@property BOOL checkedOutBool;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self designCheckOutButton];
    [self setupNavigationBar];
    [self getBook];
    self.checkedOutBool = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UI Design and Initial Setup Methods

-(void)designCheckOutButton
{
    self.btnCheckOut.layer.cornerRadius = 10.0f;
    self.btnCheckOut.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnCheckOut.layer.borderWidth = 1.0f;
}

- (void)setupNavigationBar
{
    UIBarButtonItem *rightBarButtonItemShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBook)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItemShare;
    self.navigationItem.title = @"Detail";
}


#pragma mark - Utility methods

- (void)getBook
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:self.bookUrl];
    if(!self.checkedOutBool)
        [self.manager serviceCallWithURL:url andParameters:nil andRequestMethod:@"GET"];
    else
    {
        NSDictionary *requestParameters = [self prepareParameters];
        [self.manager serviceCallWithURL:url andParameters:requestParameters andRequestMethod:@"PUT"];
    }
}

- (void)showBookDetails:(NSArray *)bookArray
{
    Book *book = [bookArray objectAtIndex:0];
    self.lblTitle.text = book.title;
    self.lblAuthor.text = book.author;
    self.lblPublisher.text = book.publisher;
    self.lblLastCheckedOutBy.text = book.lastCheckedOutBy;
    self.lblCategories.text = book.categories;
}

- (void)shareBook
{
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[self.lblTitle.text, self.lblAuthor.text, self.lblPublisher.text, self.lblCategories.text]
     applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSDictionary *)prepareParameters
{
    NSMutableDictionary *preparedParameters = [[NSMutableDictionary alloc]init];
    [preparedParameters setObject:self.name forKey:@"lastCheckedOutBy"];
    return preparedParameters;
}

- (void)disableProgressHUD
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

#pragma mark - Action methods
- (IBAction)checkoutBook:(id)sender
{
    UIAlertView *promptUsernameAlertView = [[UIAlertView alloc] initWithTitle:@"Checkout Name"
                                                                      message:@"Please Enter Your Name"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"OK", nil];
    promptUsernameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [promptUsernameAlertView show];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.name = [[alertView textFieldAtIndex:0] text];
    if(buttonIndex == 1)
    {
        self.checkedOutBool = YES;
        [self getBook];
    }
}

#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response withResponseCode:(NSInteger)responseStatusCode
{
    if(responseStatusCode == 200)
    {
        NSDictionary *data = (NSDictionary *)response;
        NSLog(@"%@",data);
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        [dataArray addObject:data];
        [self showBookDetails:[BooksParser getBookObjects:dataArray]];
        [self disableProgressHUD];
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
