//
//  AlertViewController.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/11/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "AlertViewController.h"
#import "DynamicLayout.h"

@interface AlertViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewCenterX;


@property CGFloat top,center;


@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTextFields];
    self.btnOK.enabled = NO;
    self.top = self.alertViewTopConstraint.constant;
    self.center = self.alertViewCenterX.constant;
}

- (void)setupTextFields
{
    self.txtUserName.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/* This method is responsible for designing the alert view */
-(void)designAlertView
{
    self.alertView.center = CGPointMake(self.view.center.x, self.view.frame.origin.y -self.alertView.frame.size.height/2);
    self.alertView.layer.cornerRadius = 10.0f;
}

/* This method is reponsible for performing UISnapbehavior for the alert box when the user presses the
   check out button in book detailed view. */
- (void)performAnimation
{
    [self designAlertView];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    DynamicLayout *dynamic = [DynamicLayout with:self.alertView];
    
    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:dynamic snapToPoint:CGPointMake(self.center, self.top)];
    NSLog(@"%f,%f",self.view.center.x,self.view.center.y);
    snapBehaviour.damping = 0.65f;
    snapBehaviour.action=^{
        self.alertViewCenterX.constant = [dynamic center].x;
        self.alertViewTopConstraint.constant = [dynamic center].y;
        
        NSLog(@"constants %f,%f",self.alertViewTopConstraint.constant,self.alertViewCenterX.constant);
        NSLog(@"alert view %f,%f",self.center,self.top);

    };
    
    [self.animator addBehavior:snapBehaviour];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger stringLength = [textField.text length] + [string length] - range.length;
    if(stringLength>0)
        self.btnOK.enabled = YES;
    else
        self.btnOK.enabled = NO;
    
    return YES;
}

#pragma mark - Action methods
- (IBAction)btnOk:(id)sender
{
    [self.alertDelegate dismissAlertView:0 withText:self.txtUserName.text];
    
}

- (IBAction)btnCancel:(id)sender
{
    [self.alertDelegate dismissAlertView:1 withText:self.txtUserName.text];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
