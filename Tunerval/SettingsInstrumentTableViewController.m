//
//  SettingsInstrumentTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 7/9/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

@import StoreKit;
#import <SBMusicUtilities/SBNote.h>
#import <SSZipArchive/SSZipArchive.h>
#import "SettingsInstrumentTableViewController.h"
#import "InstrumentTableViewCell.h"
#import "KeychainUserPass.h"

@interface SettingsInstrumentTableViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *instrumentNames;
@property (nonatomic, strong) NSArray *instrumentValues;
@property (nonatomic, strong) NSMutableArray *selectedInstruments;
@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation SettingsInstrumentTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Instruments"];
    [self.tableView setDelegate:self];
    [self removeTableCellButtonClickDelay];
    [self addRestorePurchasesBarButtonItem];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.selectedInstruments = [[self.defaults objectForKey:@"instruments"] mutableCopy];
    self.instrumentNames = @[
                             @"Sine Wave",
                             @"Piano"
                             ];
    self.instrumentValues = @[
                              @(InstrumentTypeSineWave),
                              @(InstrumentTypePiano)
                              ];
}

- (void) removeTableCellButtonClickDelay
{
    self.tableView.delaysContentTouches = NO;
    for (UIView *currentView in self.tableView.subviews) {
        if ([currentView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
}

- (void) addRestorePurchasesBarButtonItem
{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restorePurchases)];
    [self.navigationItem setRightBarButtonItem:bbi];
}

#pragma mark - Tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.instrumentNames.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstrumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstrumentTableViewCell"];
    
    if (indexPath.row == 0)
    {
        [cell hideBuyButton];
    }
    
    NSNumber *instrument = self.instrumentValues[indexPath.row];
    [cell setCheckMarkHidden:![self.selectedInstruments containsObject:instrument]];
    [cell.instrumentNameLabel setText:self.instrumentNames[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    InstrumentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.isSelected && self.selectedInstruments.count == 1) {
        return;
    }
    
    InstrumentType instrument = [self.instrumentValues[indexPath.row] integerValue];
    NSString *instrumentName = self.instrumentNames[indexPath.row];
    if (![self purchasedInstrument:instrumentName])
    {
        [self initiatePurchaseForInstrumentAtIndex:indexPath.row];
        return;
    }
    
    [cell toggleCheckMark];
    if (cell.isSelected) {
        [self.selectedInstruments addObject:@(instrument)];
    } else {
        [self.selectedInstruments removeObject:@(instrument)];
    }
    
    [self.defaults setObject:self.selectedInstruments forKey:@"instruments"];
}

#pragma mark - In-app purchase helper

- (BOOL)purchasedInstrument:(NSString*)instrumentName
{
    if ([instrumentName isEqualToString:@"Sine Wave"]) {
        return YES;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@Purchased", instrumentName];
    BOOL purchased = [[KeychainUserPass load:key] boolValue];
    
    return purchased;
}

- (void)initiatePurchaseForInstrumentAtIndex:(NSInteger)instrumentIndex
{
    if (![SKPaymentQueue canMakePayments])
    {
        [self tellUserInAppPurchasesAreDisabled];
    }
    
    SKProductsRequest *request = [[SKProductsRequest alloc]
                                  initWithProductIdentifiers:
                                  [NSSet setWithObject:@"com.sambender.InstrumentTypePiano"]];
    
    request.delegate = self;
    [request start];
}

- (void)tellUserInAppPurchasesAreDisabled
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"In-App Purchases Disabled"
                                message:@"To purchase the instrument, enable In-App Purchases in Settings > General > Restrictions."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Storekit delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.products.count < 1) return;
    
    
    // Subscribe to observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Purchase
    SKProduct *product = response.products[0];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    /* products = response.invalidProductIdentifiers;
    for (SKProduct *product in products) {
        // Handle invalid product IDs if required } */
}


- (void)confirmPurchaseForProduct:(SKProduct*)product
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Purchase"
                                message:@"Would you like to purchase this instrument?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"No"
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction *action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SKPaymentTransactionObserver delegate

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                if (transaction.downloads)
                {
                    [[SKPaymentQueue defaultQueue]
                     startDownloads:transaction.downloads];
                }
                else
                {
                    // Unlock feature or content here before finishing
                    // transaction
                    [[SKPaymentQueue defaultQueue]
                     finishTransaction:transaction];
                }
                break;
                
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedDownloads:(NSArray*)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState) {
            case SKDownloadStateActive:
                NSLog(@"Download progress = %f",
                      download.progress);
                NSLog(@"Download time = %f",
                      download.timeRemaining);
                break;
            case SKDownloadStateFinished:
                // Download is complete. Content file URL is at
                // path referenced by download.contentURL. Move
                // it somewhere safe, unpack it and give the user
                // access to it
                break;
            default:
                break;
        }
    }
}

#pragma mark - Actions

- (void) restorePurchases
{
    
}

@end
