//
//  AddBookViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AddBookViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "SystemLevelConstants.h"
#import "MBProgressHUD.h"

@interface AddBookViewController ()<ServiceProtocol,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *txtBookTitle;
@property (weak, nonatomic) IBOutlet UITextField    *txtAuthor;
@property (weak, nonatomic) IBOutlet UITextField    *txtPublisher;
@property (weak, nonatomic) IBOutlet UITextField    *txtCategories;
@property (weak, nonatomic) IBOutlet UIButton       *btnSubmit;

@property (nonatomic, strong) ServiceManager        *manager;
@property (nonatomic, strong) NSMutableDictionary   *requestParameters;

@property BOOL                                      textBookTitleFlag;
@property BOOL                                      textBookAuthorFlag;

@end

@implementation AddBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    [self setupDelegates];
    [self setupNavigationBar];
}

#pragma mark - UIAndInitialSetup methods
- (void)initialSetup
{
    self.textBookTitleFlag = NO;
    self.textBookAuthorFlag = NO;
    [self setupTextFields];
    [self designSubmitButton];
}

- (void)setupTextFields
{
    [self designTitleField];
    [self designAuthorField];
    [self designCategoriesField];
    [self designPublisherField];
}

- (void)designTitleField
{
    self.txtBookTitle.layer.cornerRadius = 5.0f;
    self.txtBookTitle.layer.borderWidth = 2.0f;
    self.txtBookTitle.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)designAuthorField
{
    self.txtAuthor.layer.cornerRadius = 5.0f;
    self.txtAuthor.layer.borderWidth = 2.0f;
    self.txtAuthor.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)designCategoriesField
{
    self.txtCategories.layer.cornerRadius = 5.0f;
    self.txtCategories.layer.borderWidth = 2.0f;
    self.txtCategories.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)designPublisherField
{
    self.txtPublisher.layer.cornerRadius = 5.0f;
    self.txtPublisher.layer.borderWidth = 2.0f;
    self.txtPublisher.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)designSubmitButton
{
    self.btnSubmit.layer.cornerRadius = 10.0f;
    self.btnSubmit.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnSubmit.layer.borderWidth = 1.0f;
}

- (void)setupDelegates
{
    self.txtBookTitle.delegate = self;
    self.txtAuthor.delegate = self;
    self.txtPublisher.delegate = self;
    self.txtCategories.delegate = self;
}

- (void)setupNavigationBar
{
    UIBarButtonItem* rightBarButtonItemDone = [[UIBarButtonItem alloc] initWithCustomView:[self rightBarButtonItem]];
    self.navigationItem.rightBarButtonItem = rightBarButtonItemDone;
    self.navigationItem.title = @"Add Book";
    
}

- (UIButton *)rightBarButtonItem
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    button.layer.cornerRadius = 5.0f;
    button.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
    button.layer.borderWidth = 1.0f;
    [button setFrame:CGRectMake(0, 0, 60, 30)];
    [button addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.txtBookTitle)
    {
        if(self.txtBookTitle.text.length > 0)
            self.txtBookTitle.backgroundColor = [UIColor whiteColor];
    }
    
    if (textField == self.txtAuthor) {
        if(self.txtAuthor.text.length > 0)
            self.txtAuthor.backgroundColor = [UIColor whiteColor];
    }
    
    return YES;
}

#pragma mark - Action methods
- (IBAction)submitBook:(id)sender
{
    if([self.txtBookTitle.text isEqualToString:@""])
        self.textBookTitleFlag = NO;
    else
        self.textBookTitleFlag = YES;
    
    if([self.txtAuthor.text isEqualToString:@""])
        self.textBookAuthorFlag = NO;
    else
        self.textBookAuthorFlag = YES;
    
    if(self.textBookTitleFlag && self.textBookAuthorFlag)
        [self addBookToLibrary];
    else
        [self checkFields];

}

#pragma mark - Utility methods
- (void)donePressed
{
    if(self.txtBookTitle.text.length > 0 || self.txtAuthor.text.length > 0 || self.txtCategories.text.length > 0 || self.txtPublisher.text.length > 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes Alert"
                                                            message:@"Do you want to leave the screen with unsaved changes."
                                                           delegate:self
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:@"No", nil];
        alertView.tag = 1;
        [alertView show];
    }
    else
        [self dismissViewController];
}

- (void)dismissViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addBookToLibrary
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *requestParameters = [self prepareParameters];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kBooks];
    [self.manager serviceCallWithURL:url andParameters:requestParameters andRequestMethod:@"POST"];
}

- (void)checkFields
{
    NSString *fieldsMissing = @"";
    if(!self.textBookAuthorFlag)
    {
        self.txtAuthor.backgroundColor = [UIColor redColor];
        fieldsMissing = [NSString stringWithFormat:@"%@ %@",fieldsMissing,@"Author"];
    }
    if(!self.textBookTitleFlag)
    {
        self.txtBookTitle.backgroundColor = [UIColor redColor];
        fieldsMissing = [NSString stringWithFormat:@"%@ %@",fieldsMissing,@"Book Title"];
    }
    [self showFieldsAlert:fieldsMissing];
    
}

- (void)showFieldsAlert:(NSString *)fieldsMissing
{
    UIAlertView *fieldsAlertView = [[UIAlertView alloc] initWithTitle:@"Required Fields"
                                                              message:fieldsMissing
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
    [fieldsAlertView show];
}

- (NSDictionary *)prepareParameters
{
    NSMutableDictionary *prepareParameters = [[NSMutableDictionary alloc]init];
    [prepareParameters setObject:self.txtAuthor.text forKey:@"author"];
    [prepareParameters setObject:self.txtCategories.text forKey:@"categories"];
    [prepareParameters setObject:self.txtBookTitle.text forKey:@"title"];
    [prepareParameters setObject:self.txtPublisher.text forKey:@"publisher"];
    return prepareParameters;
}

- (void)disableProgressHUD
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if(buttonIndex == 0)
            [self dismissViewController];
    }
}

#pragma mark - ServiceProtocol methods
- (void)serviceCallCompletedWithResponseObject:(id)response withResponseCode:(NSInteger)responseStatusCode
{
    if(responseStatusCode == 200)
    {
        [self disableProgressHUD];
        NSDictionary *data = (NSDictionary *)response;
        NSLog(@"%@",data);
        [self dismissViewController];
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
