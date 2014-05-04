//
//  Settings.m
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "Settings.h"

static NSString *const kReceiverAppID = @"5A71905F";

@interface Settings ()

@end

@implementation Settings

@synthesize userDefaults, mainBundleInfo, gck_devices;

@synthesize gck_applicationMetadata, gck_deviceScanner, gck_deviceManager, gck_selectedDevice;
@synthesize messageChannel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
  self.userDefaults = [NSUserDefaults standardUserDefaults];
  self.mainBundleInfo = [[NSBundle mainBundle] infoDictionary];
}

- (void)viewWillAppear:(BOOL)animated {
  [self initDeviceScannerService];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.gck_deviceScanner stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  NSInteger sections = 3;
  
  return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger rows = 1;
  
  if(section == 1) {
    rows = 2;
    
    if(self.gck_selectedDevice != nil) {
      rows = 3;
    }
  } else if(section == 2) {
    if([self.gck_devices count] > 0) {
      rows = [self.gck_devices count];
    }
  }
  
  return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSString *header = @"USERNAME";
  
  if(section == 1) {
    header = @"GENERAL";
  } else if(section == 2) {
    header = @"DEVICES";
  }
  
  return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier;
  
  if(indexPath.section == 0) {
    cellIdentifier = @"UsernameCell";
  } else if(indexPath.section == 1) {
    if(indexPath.row == 0) {
      cellIdentifier = @"AvailableCell";
    } else if(indexPath.row == 1) {
      cellIdentifier = @"ConnectedCell";
    } else if(indexPath.row == 2) {
      cellIdentifier = @"DisconnectCell";
    }
  } else if(indexPath.section == 2) {
    cellIdentifier = @"DeviceCell";
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  
  if(indexPath.section == 0) {
    UITextField *username = (UITextField *)[cell viewWithTag:100];
    [username setDelegate:self];
    
    if([self.userDefaults stringForKey:@"username"] != nil) {
      [username setText:[self.userDefaults stringForKey:@"username"]];
    }
  } else if(indexPath.section == 1) {
    if(indexPath.row == 0) {
      UILabel *availableCount = (UILabel *)[cell viewWithTag:101];
      
      [availableCount setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.gck_devices count]]];
    } else if(indexPath.row == 1) {
      UILabel *connectedTo = (UILabel *)[cell viewWithTag:101];
      
      [connectedTo setText:@"no device"];
      
      if(self.gck_selectedDevice != nil) {
        [connectedTo setText:self.gck_selectedDevice.friendlyName];
      }
    } else if(indexPath.row == 2) {
      UIButton *disconnect = (UIButton *)[cell viewWithTag:100];
      
      [disconnect addTarget:self action:@selector(disconnectFromDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
  } else if(indexPath.section == 2) {
    UILabel *friendlyNameLabel = (UILabel *)[cell viewWithTag:100];
    UIButton *connectedIcon = (UIButton *)[cell viewWithTag:101];

    if([self.gck_devices count] > 0) {
      GCKDevice *device = self.gck_devices[indexPath.row];
      
      [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
      
      [connectedIcon setHidden:NO];
      
      if(self.gck_selectedDevice != nil) {
        if([device isEqual:self.gck_selectedDevice]) {
          [connectedIcon setImage:[UIImage imageNamed:@"cast_on.png"] forState:UIControlStateNormal];
        } else {
          [connectedIcon setHidden:YES];
        }
      } else {
        [connectedIcon setImage:[UIImage imageNamed:@"cast_off.png"] forState:UIControlStateNormal];
      }
      
      [friendlyNameLabel setTextAlignment:NSTextAlignmentLeft];
      [friendlyNameLabel setText:device.friendlyName];
    } else {
      [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      
      [connectedIcon setHidden:YES];
      [friendlyNameLabel setTextAlignment:NSTextAlignmentCenter];
      [friendlyNameLabel setText:@"no devices available"];
    }
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(indexPath.section == 2) {
    if([self.gck_devices count] > 0) {
      GCKDevice *device = self.gck_devices[indexPath.row];
      
      self.gck_selectedDevice = device;
      
      [self connectToDevice:device];
    }
  }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self.userDefaults setObject:textField.text forKey:@"username"];
  [self.userDefaults synchronize];
}

#pragma mark - UIButtons Actions
- (void)disconnectFromDevice:(id)sender {
  [self.gck_deviceManager leaveApplication];
  [self.gck_deviceManager disconnect];
  
  [self deviceDisconnected];
}

#pragma mark - FUNCTIONS

- (void)initDeviceScannerService {
  self.gck_deviceScanner = [[GCKDeviceScanner alloc] init];
  
  [self.gck_deviceScanner addListener:self];
  [self.gck_deviceScanner startScan];
}

- (BOOL)isConnected {
  return self.gck_deviceManager.isConnected;
}

- (void)deviceDisconnected {
  self.messageChannel = nil;
  self.gck_deviceManager = nil;
  self.gck_selectedDevice = nil;
  
  NSLog(@"Device disconnected");
}

- (void)connectToDevice:(GCKDevice *)device {
  if(self.gck_selectedDevice == nil) {
    return;
  }
  
  self.gck_deviceManager = [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:[self.mainBundleInfo objectForKey:@"CFBundleIdentifier"]];
  
  [self.gck_deviceManager setDelegate:self];
  [self.gck_deviceManager connect];
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"defice appear!!!");
  if (![self.gck_devices containsObject:device]) {
    [self.gck_devices addObject:device];
    [self.tableView reloadData];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device disappeared!!!");
  [self.gck_devices removeObject:device];
  [self.tableView reloadData];
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
  NSLog(@"connected!!");
  [self.gck_deviceManager launchApplication:kReceiverAppID];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata sessionID:(NSString *)sessionID launchedApplication:(BOOL)launchedApplication {
  NSLog(@"did connect");
  //HIER MÜSSEN DIE CHANNELS REIN
  
  //self.messageChannel = [[MessageChannel alloc] initWithNamespace:@"urn:x-cast:de.adf.test"];
  //[self.gck_deviceManager addChannel:self.messageChannel];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectToApplicationWithError:(NSError *)error {
  NSLog(@"didFailToConnectToApplicationWithError");
  [self showError:error];
  
  [self deviceDisconnected];
  
  [self.tableView reloadData];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(GCKError *)error {
  NSLog(@"didFailToConnectWithError");
  [self showError:error];
  
  [self deviceDisconnected];
  
  [self.tableView reloadData];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");
  
  if (error != nil) {
    [self showError:error];
  }
  
  [self deviceDisconnected];
  
  [self.tableView reloadData];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
  self.gck_applicationMetadata = applicationMetadata;
  
  NSLog(@"Received device status: %@", applicationMetadata);
}

#pragma mark - MISC

- (void)showError:(NSError *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:NSLocalizedString(error.description, nil)
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];
  [alert show];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
