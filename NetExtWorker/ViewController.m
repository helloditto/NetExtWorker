//
//  ViewController.m
//  NetExtWorker
//
//  Created by Xuan Liu on 6/29/16.
//  Copyright © 2016 App Annie. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkService.h"
#import "CocoaAsyncSocket.h"

@interface ViewController () <GCDAsyncUdpSocketDelegate>
// UI components
@property (weak, nonatomic) IBOutlet UIButton *testHTTPButton;
@property (weak, nonatomic) IBOutlet UIButton *testTCPButton;
@property (weak, nonatomic) IBOutlet UIButton *testUDPButton;
@property (weak, nonatomic) IBOutlet UIButton *testAllButton;

// button handlers
- (IBAction)testHTTPHandler:(id)sender;
- (IBAction)testUDPHandler:(id)sender;
- (IBAction)testTCPHandler:(id)sender;
- (IBAction)testALLHandler:(id)sender;

// properties
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createClients];
}

-(void)createClients {
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)testHTTPHandler:(id)sender {
    [NETWorkServiceClient GET:@"http://localhost:8080" success:^(id  _Nullable result) {
        NSLog(@"%@", result);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)testTCPHandler:(id)sender {

}

- (IBAction)testUDPHandler:(id)sender {
    NSData *data = [[NSString stringWithFormat:@"Hello Wold"] dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [weakSelf.udpSocket sendData:data toHost:@"localhost" port:31600 withTimeout:-1 tag:0];
            NSError *error = nil;
            [weakSelf.udpSocket receiveOnce:&error];
            sleep(2);
        }
    });
}

- (IBAction)testALLHandler:(id)sender {

}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#ifdef DEBUG
    NSLog(@"%@", dataString);
#endif

}

@end
