//
//  FruitDetailViewController.h
//  BuyFruit
//
//  Created by Michael Beyer on 19.09.13.
//  Copyright (c) 2013 Michael Beyer. All rights reserved.
//

@import UIKit;
@import StoreKit;

@interface FruitDetailViewController : UIViewController

@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, strong) UIImageView *fruitImageView;
@property (nonatomic, strong) UILabel *fruitLabel;
@property (nonatomic, strong) UITextView *fruitDescription;
@property (nonatomic, strong) UIButton *button;

@end
