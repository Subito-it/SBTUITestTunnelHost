//
//  SBTViewController.m
//  SBTUITestTunnelHost
//
//  Created by Tomas Camin on 04/05/2017.
//  Copyright © 2017 tcamin. All rights reserved.
//

#import "SBTViewController.h"

@interface SBTViewController ()
{
    BOOL multipleTapButtonTapped;
    int multipleTapButtonCount;
}

@end

@implementation SBTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    multipleTapButtonTapped = NO;
    multipleTapButtonCount = 0;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    cell.accessibilityIdentifier = cell.textLabel.text;
    
    return cell;
}

- (IBAction)multipleTapButtonTapped:(id)sender {
    multipleTapButtonCount++;
    if (multipleTapButtonTapped) {
        return;
    }
    
    multipleTapButtonTapped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Multi tap test" message:[NSString stringWithFormat:@"%d", multipleTapButtonCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:alertAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        multipleTapButtonCount = 0;
        multipleTapButtonTapped = NO;
    });
}

@end
