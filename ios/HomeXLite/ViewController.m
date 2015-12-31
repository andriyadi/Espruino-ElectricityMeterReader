//
//  ViewController.m
//  HomeXLite
//
//  Created by Andri Yadi on 10/6/15.
//  Copyright © 2015 DyCode. All rights reserved.
//

#import "ViewController.h"

#import <MQTTClient/MQTTClient.h>
#import "NSDate+TimeAgo.h"

static NSString* const wattageSubTopicFormat = @"andriyadi/%@/wattage";
static NSString* const controlSubTopicFormat = @"andriyadi/%@/control";
static NSString* const controlPubTopicFormat = @"andriyadi/%@/control";
static NSString* const deviceId = @"xxxxyyyy01";

static NSString* const MQTT_SERVER = @"broker.hivemq.com";
static const int MQTT_PORT = 1883;

@interface ViewController ()<MQTTSessionDelegate>

@property (nonatomic, strong) MQTTSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_gaussian_green"]];
    self.switchButton.layer.cornerRadius = 10.0f;
    self.switchButton.layer.borderColor = [UIColor colorWithRed:(78.0f/255.0f) green:(180.0f/255.0f) blue:(175.0f/255.0f) alpha:1.0f].CGColor;
    self.switchButton.layer.borderWidth = 2.0f;
    
    self.session = [[MQTTSession alloc] initWithClientId:@"HomeX_iOS" userName:@"stub1" password:@"xiVATgZ7GlxhOxKYQnJzaIgP3iuszOq2"];
    [self.session setDelegate:self];
    [self connectToMqtt];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchButtonTapped:(UIButton *)sender {
    if ([sender isSelected]) {
        //Turn off
        [self publishSwitchControl:NO];
    }
    else {
        //Turn on
        [self publishSwitchControl:YES];
    }
    
    [self setSwitchButtonOn:![sender isSelected]];
}

#pragma mark - Private 
- (void)setSwitchButtonOn:(BOOL)on {
    [self.switchButton setSelected:on];
}

- (void)connectToMqtt {
    [self.session connectToHost:MQTT_SERVER port:MQTT_PORT usingSSL:NO];
}

- (void)publishSwitchControl:(BOOL)on {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TODO" message:@"Not yet implemented. The idea is this button for switching ON/OFF electrical device to see the difference in meter reading" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self showViewController:alert sender:nil];
}

- (void)processReceivedMessageData:(NSData*)msgData forTopic:(NSString*)topic{
    
    if ([topic containsString:@"wattage"]) {
        //NSData *data = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:msgData options:NSJSONReadingMutableContainers error:nil];
        
        if ([json objectForKey:@"wattage"]) {
            double d = [[json objectForKey:@"wattage"] doubleValue];
            d = d/1000;
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setGroupingSeparator:@","];
            NSString* wattStr = [numberFormatter stringForObjectValue:@(d)];
            
            double dateNum = [[json objectForKey:@"timestamp"] doubleValue];
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateNum/1000];
            NSString *ago = [date timeAgo];
            
            //NSString *wattStr = [@(d) stringValue];
            NSLog(@"Wattage %@, timestamp: %@", wattStr, ago);
            
            [self.dateTimeLabel setText:ago];
            [self.wattageLabel setText:wattStr];
        }
    }
}

#pragma mark - MQTT Session delegate
- (void)connected:(MQTTSession *)session sessionPresent:(BOOL)sessionPresent {
    NSLog(@"Connected");
    
    NSString *_topic = [NSString stringWithFormat:wattageSubTopicFormat, deviceId];
    
    [self.session subscribeTopic:_topic];
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    
}

- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID {
    NSLog(@"Message with id %d is delivered", msgID);
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    
    NSLog(@"topic %@", topic);
    
    [self processReceivedMessageData:data forTopic:topic];
}

- (void)session:(MQTTSession *)session newMessage:(NSData *)data onTopic:(NSString *)topic {
    NSLog(@"topic %@", topic);
}
@end
