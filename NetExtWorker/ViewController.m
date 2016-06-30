//
//  ViewController.m
//  NetExtWorker
//
//  Created by Xuan Liu on 6/29/16.
//  Copyright © 2016 App Annie. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkService.h"

@interface ViewController ()
// UI components
@property (weak, nonatomic) IBOutlet UIButton *testHTTPButton;
@property (weak, nonatomic) IBOutlet UIButton *testTCPButton;
@property (weak, nonatomic) IBOutlet UIButton *testUDPButton;

// button handlers
- (IBAction)testHTTPHandler:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)testHTTPHandler:(id)sender {
    [NETWorkServiceClient GET:@"http://localhost:8080" success:^(id  _Nullable result) {
        NSLog(@"%@", result);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end
