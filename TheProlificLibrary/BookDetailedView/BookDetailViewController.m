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
#import "AlertViewController.h"

@interface BookDetailViewController ()<ServiceProtocol,UIAlertViewDelegate,AlertViewDismissProtocol>

@property (weak, nonatomic) IBOutlet UILabel        *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel        *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel        *lblPublisher;
@property (weak, nonatomic) IBOutlet UILabel        *lblCategories;
@property (weak, nonatomic) IBOutlet UILabel        *lblLastCheckedOutBy;
@property (weak, nonatomic) IBOutlet UIButton       *btnCheckOut;
@property (nonatomic, strong) AlertViewController   *alertview;
@property (nonatomic, strong) ServiceManager        *manager;
@property (nonatomic, strong) NSString              *name;

@property BOOL checkedOutBool;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getBook];
    [self designCheckOutButton];
    [self setupNavigationBar];
    self.checkedOutBool = NO;
}

#pragma mark - UI Design and Initial Setup Methods
/* This method is responsible for setting up the check out button. */
-(void)designCheckOutButton
{
    self.btnCheckOut.layer.cornerRadius = 10.0f;
    self.btnCheckOut.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnCheckOut.layer.borderWidth = 1.0f;
}

/* This method is responsible for setting up the navigation bar. */
- (void)setupNavigationBar
{
    UIBarButtonItem *rightBarButtonItemShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBook)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItemShare;
    self.navigationItem.title = @"Detail";
}


#pragma mark - Utility methods
/* This method is responsible for getting the book from the server. */
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

/* This method setups the book details. */
- (void)showBookDetails:(NSArray *)bookArray
{
    Book *book = [bookArray objectAtIndex:0];
    self.lblTitle.text = book.title;
    self.lblAuthor.text = book.author;
    self.lblPublisher.text = book.publisher;
    self.lblLastCheckedOutBy.text = book.lastCheckedOutBy;
    self.lblCategories.text = book.categories;
}

/* This method is responsible for sharing the book via social media. */
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

/* This method returns the parameters for submitting it to the server. */
- (NSDictionary *)prepareParameters
{
    NSMutableDictionary *preparedParameters = [[NSMutableDictionary alloc]init];
    [preparedParameters setObject:self.name forKey:@"lastCheckedOutBy"];
    return preparedParameters;
}

/* This method is responsible for disabling the Progress HUD when the book is loaded. */
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
    self.alertview = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([AlertViewController class])];
    self.alertview.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:self.alertview.view];
    self.alertview.alertDelegate = self;
    [self.alertview performAnimation];
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

#pragma mark - AlertViewDismissProtocol method
- (void)dismissAlertView:(NSInteger)buttonPressedValue withText:(NSString *)textString
{
    if(buttonPressedValue == 0)
    {
        self.checkedOutBool = YES;
        self.name = textString;
        [self getBook];
    }
    [self.alertview.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
