//
//  FruitTableViewController.m
//  BuyFruit
//
//  Created by Michael Beyer on 19.09.13.
//  Copyright (c) 2013 Michael Beyer. All rights reserved.
//

#import "FruitTableViewController.h"

// This imports the FruitIAPHelper class we wrote
#import "FruitIAPHelper.h"

@interface FruitTableViewController ()

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;

@end

@implementation FruitTableViewController

#pragma mark - User Interface set up

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Buy Fruits";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(restoreTapped:)];
        
        self.priceFormatter = [[NSNumberFormatter alloc] init];
        [self.priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reload];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [super viewWillAppear:animated];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SKProduct *product = self.products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [product.price stringValue];
    
    [self.priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [self.priceFormatter stringFromNumber:product.price];
    
    if ([[FruitIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Gives the product back
    SKProduct *product = self.products[indexPath.row];
    
    // Creates the DetailViewController
    self.fruitDetailViewController = [[FruitDetailViewController alloc]init];
    self.fruitDetailViewController.product = product;
    
    // Pushes the DetailViewController
    [self.navigationController pushViewController:self.fruitDetailViewController animated:YES];
}

#pragma mark - StoreKit

/*
 When the reload is called (whether it be the first manual call, or when the user pulls to refresh), it calls the FruitIAPHelper’s requestProductsWithCompletionHandler method we wrote earlier to return the In-App Purchase product info from iTunes Connect. When this completes, the block will be called. All it does is store the list of products in the instance variable, reload the table view to display them, and tells the refresh control to stop animating.
 */
- (void)reload
{
    self.products = nil;
    [self.tableView reloadData];
    [[FruitIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)restoreTapped:(id)sender
{
    [[FruitIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;
    [self.products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)buyButtonTapped:(id)sender
{
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = self.products[buyButton.tag];
    NSLog(@"Buying %@ ... (buyButtonTapped in FruitTableViewController.m", product.productIdentifier);
    [[FruitIAPHelper sharedInstance] buyProduct:product];
}



@end
