//
//  FilterViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "FilterViewController.h"
#import "BookFilter.h"

@interface FilterViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *bookPropertySegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orderSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *checkoutBookSwitch;
@property (weak, nonatomic) IBOutlet UIButton *submitFilter;
@property (weak, nonatomic) IBOutlet UIButton *resetFilter;

@property (nonatomic, strong) NSMutableArray *booksListArray;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
}

#pragma mark - UI setup methods
- (void)setupNavBar
{
    UIBarButtonItem *leftBarButtonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissCancelPage)];
    self.navigationItem.leftBarButtonItem = leftBarButtonCancel;
}


#pragma mark - Action methods
/* This method is responsible for setting the filter for the booklist when the user presses the submit filter button. */
- (IBAction)submitFilter:(id)sender
{
    NSString *field = [self bookPropertySelected];
    BOOL selectedOrder = [self getOrderOfSelected];
    BOOL checkoutFlag = [self getCheckOutStatus];
    self.booksListArray = [BookFilter filterArray:self.bookTempArray basedOn:field orderOfField:selectedOrder andCheckOutStatus:checkoutFlag];
    [self.filterDelegate filteredResults:self.booksListArray];
    [self dismissViewController];
}

/* This method is responsible for resetting the filters and the content in the tableview. */
- (IBAction)resetAll:(id)sender
{
    [self resetAllFields];
    [self.filterDelegate resetAllFilterPressed];
    [self dismissViewController];
}

/* This method deletes all the books from the library. */
- (IBAction)deletAllBooks:(id)sender
{
    [self.filterDelegate deleteBooks];
    [self dismissViewController];
}


#pragma mark - Utility methods
/* This method is responsible for dissmissing the filter page. */
- (void)dismissCancelPage
{
    [self resetAllFields];
    [self dismissViewController];
}

/* This method returns either title or author when the user selects the segmented control.  */
- (NSString *)bookPropertySelected
{
    if(self.bookPropertySegmentedControl.selectedSegmentIndex == 0)
        return @"title";
    else
        return @"author";
}

/* This method returns ascending or descending depending on the user selection. */
- (BOOL)getOrderOfSelected
{
    if(self.orderSegmentedControl.selectedSegmentIndex == 0)
        return YES;
    else
        return NO;
}
/* This method removes books when checkout is not available. */
- (BOOL)getCheckOutStatus
{
    if([self.checkoutBookSwitch isOn])
        return YES;
    else
        return NO;
}

/* This method resets all the fields of filter page. */
- (void)resetAllFields
{
    [self.bookPropertySegmentedControl setSelectedSegmentIndex:0];
    [self.orderSegmentedControl setSelectedSegmentIndex:0];
    [self.checkoutBookSwitch setOn:NO];
}

/* This method dissmisses the view controller. */
- (void)dismissViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
