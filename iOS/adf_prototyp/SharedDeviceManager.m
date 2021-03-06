//
//  SharedDeviceManager.m
//  test
//
//  Created by fza on 10.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "SharedDeviceManager.h"

static NSString *const kReceiverAppID = @"5A71905F";

@implementation SharedDeviceManager

@synthesize delegate, gck_deviceManager, gck_selectedDevice;

+ (SharedDeviceManager *)sharedDeviceManager {
  static SharedDeviceManager *sharedDeviceManagerInstance = nil;
  static dispatch_once_t predicate;
  
  dispatch_once(&predicate, ^{
    sharedDeviceManagerInstance = [[self alloc] init];
  });
  
  return sharedDeviceManagerInstance;
}

- (id)init {
  if(self = [super init]) {
    
  }
  
  return self;
}

- (void)initDeviceManager:(GCKDevice *)device {
  self.gck_deviceManager = [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:kReceiverAppID];
  [self.gck_deviceManager setDelegate:self];
}

#pragma mark -
#pragma mark GCKDeviceManager Methods

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  self.gck_selectedDevice = deviceManager.device;
  
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate connect:deviceManager];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata sessionID:(NSString *)sessionID launchedApplication:(BOOL)launchedApplication {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager connectToApp:applicationMetadata sessID:sessionID launchedApp:launchedApplication];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectFromApplicationWithError:(NSError *)error {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager disconnectFromApp:error];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(NSError *)error {
  self.gck_selectedDevice = nil;
  
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager disconnect:error];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectToApplicationWithError:(NSError *)error {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager connectFailToApp:error];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(NSError *)error {
  self.gck_selectedDevice = nil;
  
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager connectFail:error];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToStopApplicationWithError:(NSError *)error {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager failToStopApp:error];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager appStatus:applicationMetadata];
  }
}

/*- (void)deviceManager:(GCKDeviceManager *)deviceManager volumeDidChangeToLevel:(float)volumeLevel isMuted:(BOOL)isMuted {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dm:deviceManager volumeLevel:volumeLevel isMuted:isMuted];
  }
}*/

@end
