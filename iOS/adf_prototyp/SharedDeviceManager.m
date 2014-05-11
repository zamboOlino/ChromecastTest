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

+ (SharedDeviceManager *)sharedDeviceManager:(GCKDevice *)device {
  static SharedDeviceManager *sharedDeviceManagerInstance = nil;
  static dispatch_once_t oncePredicate;
  
  dispatch_once(&oncePredicate, ^{
    //if(sharedDeviceManagerInstance == nil) {
    sharedDeviceManagerInstance = [[self alloc] init:device];
    //}
  });
  
  return sharedDeviceManagerInstance;
}

- (id)init:(GCKDevice *)device {
  self = [super init];
  
  if(self) {
    self.gck_deviceManager = [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:kReceiverAppID];
    [self.gck_deviceManager setDelegate:self];
  }
  return self;
}

#pragma mark -
#pragma mark GCKDeviceManager Methods

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  if([self.delegate conformsToProtocol:@protocol(SDMDelegate)]) {
    [self.delegate dmConnect:deviceManager];
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
