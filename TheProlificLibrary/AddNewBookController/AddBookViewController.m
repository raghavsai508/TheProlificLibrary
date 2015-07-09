//
//  AddBookViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "AddBookViewController.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "SystemLevelConstants.h"

@interface AddBookViewController ()<ServiceProtocol,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *txtBookTitle;
@property (weak, nonatomic) IBOutlet UITextField    *txtAuthor;
@property (weak, nonatomic) IBOutlet UITextField    *txtPublisher;
@property (weak, nonatomic) IBOutlet UITextField    *txtCategories;

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
    UIBarButtonItem *rightBarButtonItemDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItemDone;
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
