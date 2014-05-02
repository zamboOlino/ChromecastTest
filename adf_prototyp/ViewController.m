//
//  ViewController.m
//  adf_prototyp
//
//  Created by condero on 02.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize gck_deviceScanner, gck_deviceManager, gck_devices, gck_selectedDevice, mainBundleInfo;
@synthesize btn_gck_deviceScanner;

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
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"device found!!!");
  self.gck_devices = self.gck_deviceScanner.devices;
  
  UIActionSheet *deviceListActonSheet;
  
  if([self.gck_devices count] > 0) {
    deviceListActonSheet = [[UIActionSheet alloc] initWithTitle:@"Available Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for(GCKDevice* device in self.gck_devices) {
      [deviceListActonSheet addButtonWithTitle:device.friendlyName];
    }
  } else {
    deviceListActonSheet = [[UIActionSheet alloc] initWithTitle:@"No Devices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
  }
  
  [deviceListActonSheet addButtonWithTitle:@"Cancel"];
  deviceListActonSheet.cancelButtonIndex = [self.gck_devices count];
  
  [deviceListActonSheet setTag:100];
  
  [deviceListActonSheet showInView:self.view];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device disappeared!!!");
}

- dev

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  NSLog(@"connected!!");
  [self.gck_deviceManager launchApplication:@"APP_ID_HERE"];
}

#pragma mark - UIButtonActions

- (IBAction)btn_gck_deviceScannerAction:(id)sender {
  NSLog(@"device scan");
  [self.gck_deviceScanner startScan];
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(actionSheet.tag  == 100) {
    if(buttonIndex < [self.gck_devices count]) {
      self.gck_selectedDevice = self.gck_devices[buttonIndex];
      
      self.gck_deviceManager = [[GCKDeviceManager alloc]  initWithDevice:self.gck_selectedDevice clientPackageName:[self.mainBundleInfo objectForKey:@"CFBundleIdentifier"]];
      
      [self.gck_deviceManager setDelegate:self];
      [self.gck_deviceManager connect];
    }
    
    //TODO actionSheet öffnet sich nicht mehr
    
    [self.gck_deviceScanner stopScan];
  }
}


@end
