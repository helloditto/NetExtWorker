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
#import "AFNetworking.h"

@interface ViewController () <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>
// UI components
@property (weak, nonatomic) IBOutlet UIButton *testHTTPButton;
@property (weak, nonatomic) IBOutlet UIButton *testTCPButton;
@property (weak, nonatomic) IBOutlet UIButton *testUDPButton;
@property (weak, nonatomic) IBOutlet UIButton *testAllButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

// button handlers
- (IBAction)testHTTPHandler:(id)sender;
- (IBAction)testUDPHandler:(id)sender;
- (IBAction)testTCPHandler:(id)sender;
- (IBAction)testALLHandler:(id)sender;

// properties
@property (strong, nonatomic) GCDAsyncSocket *tcpSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@end

@implementation ViewController

-(void)dealloc {
    [self.tcpSocket disconnect];
    [self.udpSocket close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createClients];
}

-(void)createClients {
    self.tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

-(NSData *)dataFromMessage:(NSString *)message {
    return [message dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)displayMessage:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.messageLabel.text = message;
    });
}

- (IBAction)testHTTPHandler:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:@"http://localhost:8080"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            @autoreleasepool {
                [weakSelf sendHTTPGet:defaultSession url:url];
                sleep(2);
            }
        }
    });
}

-(void) sendHTTPGet:(NSURLSession *)session url:(NSURL *)url
{
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil) {
//            [self displayMessage:[NSString stringWithFormat:@"[%@]: receive HTTP GET", [NSDate date]]];
        } else {
//            [self displayMessage:[NSString stringWithFormat:@"[%@]: HTTP GET Error: %@", [NSDate date], error]];
        }
    }];
    [dataTask resume];
}

- (IBAction)testTCPHandler:(id)sender {
    NSData *data = [self dataFromMessage:@"hello world"];
    __weak typeof(self) weakSelf = self;
    NSError *error = nil;
    if (!self.tcpSocket.isConnected)
        [weakSelf.tcpSocket connectToHost:@"localhost" onPort:31500 error:&error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [weakSelf.tcpSocket writeData:data withTimeout:-1 tag:0];
            [weakSelf.tcpSocket readDataWithTimeout:-1 tag:0];
            sleep(2);
        }
    });
}

- (IBAction)testUDPHandler:(id)sender {
    NSData *data = [self dataFromMessage:@"hello world"];
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

#pragma mark - GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *dataString = [self stringFromData:data];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: receive TCP: %@", [NSDate date], dataString]];
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *dataString = [self stringFromData:data];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: receive UDP: %@", [NSDate date], dataString]];
}

@end
