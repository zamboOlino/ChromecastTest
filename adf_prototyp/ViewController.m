//
//  ViewController.m
//  adf_prototyp
//
//  Created by condero on 02.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "ViewController.h"

static NSString *const kReceiverAppID = @"5A71905F";

@interface ViewController ()

@end

@implementation ViewController

@synthesize gck_applicationMetadata, gck_deviceScanner, gck_deviceManager, gck_devices, gck_selectedDevice, mainBundleInfo;
@synthesize btn_gck_deviceScanner, mesage_textfield, message_send;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //self.gck_devices = [[NSArray alloc] init];
  
  self.mainBundleInfo = [[NSBundle mainBundle] infoDictionary];
  
  [self initDeviceScannerService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDeviceScannerService {
  self.gck_deviceScanner = [[GCKDeviceScanner alloc] init];

  [self.gck_deviceScanner addListener:self];
  [self.gck_deviceScanner startScan];
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"defice appear!!!");
  [self updateButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device disappeared!!!");
  [self updateButtonStates];
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  NSLog(@"connected!!");
  [self updateButtonStates];
  
  [self.gck_deviceManager launchApplication:kReceiverAppID];
}


- (void)deviceManager:(GCKDeviceManager *)deviceManager didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata sessionID:(NSString *)sessionID launchedApplication:(BOOL)launchedApplication {
  NSLog(@"did connect");
  NSLog(@"application has launched %hhd", launchedApplication);
  
  //self.textChannel = [[HTGCTextChannel alloc] initWithNamespace:@"urn:x-cast:de.adf.adf_prototyp"];
  //[self.gck_deviceManager addChannel:self.textChannel];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectToApplicationWithError:(NSError *)error {
  NSLog(@"didFailToConnectToApplicationWithError: %@", error);
  [self showError:error];
  
  [self deviceDisconnected];
  [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(GCKError *)error {
  NSLog(@"didFailToConnectWithError: %@", error);
  [self showError:error];
  
  [self deviceDisconnected];
  [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");
  
  if (error != nil) {
    [self showError:error];
  }
  
  [self deviceDisconnected];
  [self updateButtonStates];
  
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
  self.gck_applicationMetadata = applicationMetadata;
  
  NSLog(@"Received device status: %@", applicationMetadata);
}

#pragma mark - misc
- (void)showError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:NSLocalizedString(error.description, nil)
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];
  [alert show];
}

#pragma mark - UIButtonActions

- (IBAction)btn_gck_deviceScannerAction:(id)sender {
  NSLog(@"device scan");
  
  if(!self.gck_selectedDevice) {
    NSLog(@"device found!!!");
    self.gck_devices = self.gck_deviceScanner.devices;
    
    UIActionSheet *deviceListActonSheet;
    
    if([self.gck_devices count] > 0) {
      deviceListActonSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to Device", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
      
      for(GCKDevice* device in self.gck_devices) {
        [deviceListActonSheet addButtonWithTitle:device.friendlyName];
      }
    } else {
      deviceListActonSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"No Devices", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    
    [deviceListActonSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    deviceListActonSheet.cancelButtonIndex = deviceListActonSheet.numberOfButtons - 1;
    
    [deviceListActonSheet setTag:100];
    
    [deviceListActonSheet showInView:self.view];
  } else {
    //Already connected information
    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil), self.gck_selectedDevice.friendlyName];
    NSString *mediaTitle = self.gck_applicationMetadata.applicationName;

    UIActionSheet *deviceListActonSheet = [[UIActionSheet alloc] initWithTitle:str delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if(mediaTitle != nil) {
      [deviceListActonSheet addButtonWithTitle:mediaTitle];
    }
    
    [deviceListActonSheet addButtonWithTitle:@"Disconnect"];
    [deviceListActonSheet addButtonWithTitle:@"Cancel"];
    deviceListActonSheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
    deviceListActonSheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);
    
    [deviceListActonSheet showInView:self.view];
  }
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(actionSheet.tag  == 100) {
    if(self.gck_selectedDevice == nil) {
      if(buttonIndex < [self.gck_devices count]) {
        self.gck_selectedDevice = self.gck_devices[buttonIndex];
        NSLog(@"Selecting device:%@", self.gck_selectedDevice.friendlyName);
        
        [self connectToDevice:self.gck_selectedDevice];
      }
    } else {
      if(buttonIndex == 0) {
        NSLog(@"Disconnecting device:%@", self.gck_selectedDevice.friendlyName);
        [self.gck_deviceManager leaveApplication];
        [self.gck_deviceManager disconnect];
        
        [self deviceDisconnected];
        [self updateButtonStates];
      }
    }
  }
}

#pragma mark - FUNCTIONS

- (BOOL)isConnected {
  return self.gck_deviceManager.isConnected;
}

- (void)connectToDevice:(GCKDevice *)device {
  if(self.gck_selectedDevice == nil) {
    return;
  }
  NSLog(@"%@", [self.mainBundleInfo objectForKey:@"CFBundleIdentifier"]);
  self.gck_deviceManager = [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:[self.mainBundleInfo objectForKey:@"CFBundleIdentifier"]];
  [self.gck_deviceManager setDelegate:self];
  [self.gck_deviceManager connect];
}

- (void)deviceDisconnected {
  self.gck_deviceManager = nil;
  self.gck_selectedDevice = nil;
  
  NSLog(@"Device disconnected");
}

- (void)updateButtonStates {
  if(self.gck_deviceScanner.devices.count == 0) {
    //Hide the cast button
    [self.btn_gck_deviceScanner setImage:[UIImage imageNamed:@"cast_off.png"]];
  } else {
    if (self.gck_deviceManager && self.gck_deviceManager.isConnected) {
      //Enabled state for cast button
      [self.btn_gck_deviceScanner setImage:[UIImage imageNamed:@"cast_on.png"]];
    } else {
      //Disabled state for cast button
      [self.btn_gck_deviceScanner setImage:[UIImage imageNamed:@"cast_off.png"]];
    }
  }
}

- (IBAction)sendText:(id)sender {
  NSLog(@"sending text %@", [self.mesage_textfield text]);
  
  //Show alert if not connected
  if (!self.gck_deviceManager || !self.gck_deviceManager.isConnected) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Connected", nil)
                                                    message:NSLocalizedString(@"Please connect to Cast device", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    
    [alert show];
    return;
  }
  
  //[self.mesage_textfield sendTextMessage:[self.mesage_textfield text]];
}

@end
