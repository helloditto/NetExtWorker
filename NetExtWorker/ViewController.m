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

static NSString *IPADDRESS = @"192.168.1.195";
static NSInteger HTTPPORT = 8080;
static NSInteger TCPPORT = 31500;
static NSInteger UDPPORT = 31600;

@interface ViewController () <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>
// UI components
@property (weak, nonatomic) IBOutlet UIButton *testHTTPButton;
@property (weak, nonatomic) IBOutlet UIButton *testTCPButton;
@property (weak, nonatomic) IBOutlet UIButton *testUDPButton;
@property (weak, nonatomic) IBOutlet UIButton *testAllButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

// button handlers
- (IBAction)testHTTPHandler:(id)sender;
- (IBAction)testUDPHandler:(id)sender;
- (IBAction)testTCPHandler:(id)sender;
- (IBAction)testALLHandler:(id)sender;
- (IBAction)stopHandler:(id)sender;

// properties
@property (strong, nonatomic) GCDAsyncSocket *tcpSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (copy, nonatomic) NSString *message;
//@property (strong, atomic) BOOL stop;

@end

@implementation ViewController {
    BOOL _stop;
    NSInteger _httpCount;
    NSInteger _tcpCount;
    NSInteger _udpCount;
    NSInteger _maxCount;
    BOOL _isSingleConn;
}

//@synthesize stop = _stop;

- (void)dealloc {
    [self disconnectAll];
}

- (void)disconnectAll {
    [self.tcpSocket disconnect];
    [self.udpSocket close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createClients];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"hh:mm:ss";
    self.message = @"Our goal is to share the sum of all human[1] knowledge about jailbroken iOS development. In other words, this is a collection of documentation written by developers to help each other write extensions (tweaks) for jailbroken iOS, and you're invited to learn from it and contribute to it too. Information about using iOS frameworks (both public and private), SpringBoard, system daemons (for hooking and hacking), and classes in applications included with the system. New articles: Kik, Active Developers, Inter Process Communication (IPC), Using ARC in tweaks, Career advice, IOMobileFramebuffer, IOAudio2Device, IOAudio2Transformer, RocketBootstrap, Breadcrumbs. If youd like to make a new article or improve an existing article, see Help:Editing for advice (and see #Editing this wiki for ideas). Articles that need work: Packaging (tools, control file tips, troubleshooting dpkg-deb errors), Next Steps After Getting Started (a set of ideas for tutorials you could write), edit this page and add your idea here.";

    _stop = false;
    _maxCount = 10;
    _httpCount = 0;
    _tcpCount = 0;
    _udpCount = 0;
    _isSingleConn = NO;
}

- (void)createClients {
    self.tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

- (NSData *)dataFromMessage:(NSString *)message {
    return [message dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)displayMessage:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.messageLabel.text = message;
    });
}

- (IBAction)testHTTPHandler:(id)sender {
    if (_stop) {
        _stop = false;
    }
    while (_httpCount < _maxCount) {
        [self testHTTPTraffic];
        _httpCount += 1;
    }
}

- (void)testHTTPTraffic {
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld", IPADDRESS, HTTPPORT]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_stop) {
            @autoreleasepool {
                [weakSelf sendHTTPGet:defaultSession url:url];
                sleep(2);
            }
        }
    });
}

- (void)sendHTTPGet:(NSURLSession *)session url:(NSURL *)url
{
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
        if(error == nil) {
            [self displayMessage:[NSString stringWithFormat:@"[%@]: receive HTTP GET", dateString]];
        } else {
            [self displayMessage:[NSString stringWithFormat:@"[%@]: HTTP GET Error: %@", dateString, error]];
        }
    }];
    [dataTask resume];
}

- (IBAction)testTCPHandler:(id)sender {
    if (_stop)
        _stop = NO;
    while (_tcpCount < _maxCount) {
        [self testTCPTraffic];
        _tcpCount += 1;
    }
}

- (void)testTCPTraffic {
    NSData *data = [self dataFromMessage:self.message];
    __weak typeof(self) weakSelf = self;
    NSError *error = nil;
    if (_isSingleConn) {
        if (!self.tcpSocket.isConnected)
        [weakSelf.tcpSocket connectToHost:IPADDRESS onPort:TCPPORT error:&error];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_stop) {
            if (!_isSingleConn) {
                NSError *connError = nil;
                if (!self.tcpSocket.isConnected)
                [weakSelf.tcpSocket connectToHost:IPADDRESS onPort:TCPPORT error:&connError]; // connect is sync mode
            }
            [weakSelf.tcpSocket writeData:data withTimeout:-1 tag:0];
            [weakSelf.tcpSocket readDataWithTimeout:-1 tag:0];
            sleep(2);
            if (!_isSingleConn) {
                [weakSelf.tcpSocket disconnect]; // disconnect is sync mode
            }
        }
    });
}

- (IBAction)testUDPHandler:(id)sender {
    if (_stop)
        _stop = NO;
    while (_udpCount < _maxCount) {
        [self testUDPTraffic];
        _udpCount += 1;
    }
}

- (void)testUDPTraffic {
    NSData *data = [self dataFromMessage:self.message];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_stop) {
            [weakSelf.udpSocket sendData:data toHost:IPADDRESS port:UDPPORT withTimeout:-1 tag:0];
            NSError *reError = nil;
            [weakSelf.udpSocket receiveOnce:&reError];
            sleep(2);
        }
    });
}

- (IBAction)testALLHandler:(id)sender {
    [self testHTTPHandler:nil];
    [self testTCPHandler:nil];
    [self testUDPHandler:nil];
}

- (IBAction)stopHandler:(id)sender {
    _stop = true;
    _httpCount = 0;
    _tcpCount = 0;
    _udpCount = 0;
    [self disconnectAll];
}

#pragma mark - GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *dataString = [self stringFromData:data];
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: receive TCP: %@", dateString, dataString]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: %@", dateString, err]];
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *dataString = [self stringFromData:data];
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: receive UDP: %@", dateString, dataString]];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: %@", dateString, error]];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: %@", dateString, error]];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    [self displayMessage:[NSString stringWithFormat:@"[%@]: %@", dateString, error]];
}

@end
