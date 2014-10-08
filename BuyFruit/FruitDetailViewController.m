//
//  FruitDetailViewController.m
//  BuyFruit
//
//  Created by Michael Beyer on 19.09.13.
//  Copyright (c) 2013 Michael Beyer. All rights reserved.
//

#import "FruitDetailViewController.h"
#import "FruitIAPHelper.h"

@interface FruitDetailViewController ()

@end

@implementation FruitDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.product.localizedTitle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    if (self.product != nil) {
        // Check if chosen product has been bought yet
        if ([[NSUserDefaults standardUserDefaults] boolForKey:self.product.productIdentifier]){
            NSLog(@"Product purchased");
            
            NSString *imageName = [[FruitIAPHelper sharedInstance] imageNameForProduct:self.product];
            self.fruitImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
            self.fruitImageView.frame = CGRectMake((self.view.frame.size.width / 2) - (self.fruitImageView.frame.size.width / 2), (self.view.frame.size.height / 2) - (self.fruitImageView.frame.size.height / 2), self.fruitImageView.frame.size.width, self.fruitImageView.frame.size.height);
            [self.view addSubview:self.fruitImageView];
            
            self.fruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, (self.view.frame.size.height - 70), 240, 50)];
            self.fruitLabel.text = @"Yummy!";
            self.fruitLabel.numberOfLines = 0;
            self.fruitLabel.textColor = [UIColor darkGrayColor];
            self.fruitLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:self.fruitLabel];
        }
        else
        {
            NSLog(@"Product not purchased");
            
            self.fruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 150, 240, 80)];
            self.fruitLabel.text = @"Come on! Live healthy and buy some fruits :-)";
            self.fruitLabel.numberOfLines = 0;
            self.fruitLabel.textColor = [UIColor darkGrayColor];
            self.fruitLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:self.fruitLabel];
            
            self.fruitDescription = [[UITextView alloc] initWithFrame:CGRectMake(20, 280, (self.view.frame.size.width - 40), self.view.frame.size.height)];
            NSString *fruitDescription = [[FruitIAPHelper sharedInstance] descriptionForProduct:self.product];
            self.fruitDescription.text = fruitDescription;
            self.fruitDescription.editable = NO;
            self.fruitDescription.textColor = [UIColor darkGrayColor];
            self.fruitDescription.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:self.fruitDescription];
            
            self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.button.frame = CGRectMake(40, (self.view.frame.size.height - 70), 240, 50);
            self.button.layer.cornerRadius = 5.0;
            [self.button addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.button setBackgroundColor:[UIColor lightGrayColor]];
            [self.button setTintColor:[UIColor whiteColor]];
            [self.button setTitle:@"Buy this fruit!" forState:UIControlStateNormal];
            [self.view addSubview:self.button];
        }
    }
}

- (void) refreshView
{
    [self.button removeFromSuperview];
    [self.fruitLabel removeFromSuperview];
    [self.fruitDescription removeFromSuperview];
    
    NSString *imageName = [[FruitIAPHelper sharedInstance] imageNameForProduct:self.product];
    self.fruitImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    self.fruitImageView.frame = CGRectMake((self.view.frame.size.width / 2) - (self.fruitImageView.frame.size.width / 2), (self.view.frame.size.height / 2) - (self.fruitImageView.frame.size.height / 2), self.fruitImageView.frame.size.width, self.fruitImageView.frame.size.height);
    [self.view addSubview:self.fruitImageView];
    
    self.fruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, (self.view.frame.size.height - 70), 240, 50)];
    self.fruitLabel.text = @"Yummy!";
    self.fruitLabel.numberOfLines = 0;
    self.fruitLabel.textColor = [UIColor darkGrayColor];
    self.fruitLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.fruitLabel];
}

#pragma mark - UIButton Action
- (void)buyButtonPressed:(id)sender
{
    [[FruitIAPHelper sharedInstance] buyProduct:self.product];
    
}

#pragma mark - StoreKit
- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;
    if ([self.product.productIdentifier isEqualToString:productIdentifier]) {
        NSLog(@"This product has been purchased!");
        [self refreshView];
    }
}


@end
