//
//  SharedDeviceManager.h
//  test
//
//  Created by fza on 10.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>

@protocol SDMDelegate

- (void)connect:(GCKDeviceManager *)dm;
- (void)dm:(GCKDeviceManager *)dm disconnect:(NSError *)error;
- (void)dm:(GCKDeviceManager *)dm connectFail:(NSError *)error;

- (void)dm:(GCKDeviceManager *)dm connectToApp:(GCKApplicationMetadata *)metaData sessID:(NSString *)sessID launchedApp:(BOOL)launchedApp;
- (void)dm:(GCKDeviceManager *)dm disconnectFromApp:(NSError *)error;
- (void)dm:(GCKDeviceManager *)dm connectFailToApp:(NSError *)error;
- (void)dm:(GCKDeviceManager *)dm failToStopApp:(NSError *)error;

- (void)dm:(GCKDeviceManager *)dm appStatus:(GCKApplicationMetadata *)metaData;
//- (void)dm:(GCKDeviceManager *)dm volumeLevel:(float)level isMuted:(BOOL)isMuted;

@end

@interface SharedDeviceManager : NSObject <GCKDeviceManagerDelegate> {
  GCKDeviceManager *gck_deviceManager;
  GCKDevice *gck_selectedDevice;
  __weak id delegate;
}

@property (strong, nonatomic) GCKDeviceManager *gck_deviceManager;
@property (strong, nonatomic) GCKDevice *gck_selectedDevice;
@property (weak, nonatomic) id delegate;

- (void)initDeviceManager:(GCKDevice *)device;

+ (SharedDeviceManager *)sharedDeviceManager;

@end
