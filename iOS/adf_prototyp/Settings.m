//
//  Settings.m
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "Settings.h"
#import "SharedDeviceManager.h"

static NSString *const kReceiverAppID = @"5A71905F";

@interface Settings () <UITextFieldDelegate, UIActionSheetDelegate, GCKDeviceScannerListener, /*GCKDeviceManagerDelegate,*/ SDMDelegate>

@property SharedDeviceManager *SDM;

@property NSUserDefaults *userDefaults;

@property NSDictionary *mainBundleInfo;
@property NSMutableArray *gck_devices;

@property BOOL reconnect;
@property BOOL connecting;

//GCDeviceScenner
@property GCKApplicationMetadata *gck_applicationMetadata;
@property GCKDeviceManager *gck_deviceManager;
@property GCKDeviceScanner *gck_deviceScanner;
@property GCKDevice *gck_selectedDevice;
//Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshbutton;

@end

@implementation Settings

@synthesize userDefaults, mainBundleInfo, gck_devices, connecting, reconnect;

@synthesize gck_applicationMetadata, gck_deviceScanner, gck_deviceManager, gck_selectedDevice;

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
  
  self.connecting = NO;
  self.gck_devices = [[NSMutableArray alloc] init];
  
  self.gck_deviceScanner = [[GCKDeviceScanner alloc] init];
  [self.gck_deviceScanner addListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [self initDeviceScannerService];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.gck_deviceScanner removeListener:self];
  [self.gck_deviceScanner stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButtons Actions

- (IBAction)refreshbutton_action:(id)sender {
  [self reloadCellRow:@[[NSIndexPath indexPathForRow:0 inSection:1]]];
  [self reloadSection:2 len:1];
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
  NSString *header;
  
  if(section == 0) {
    header = @"USERNAME";
  } else if(section == 1) {
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

      if(self.connecting) {
        UIActivityIndicatorView *connectedIndicator = (UIActivityIndicatorView *)[cell viewWithTag:102];
        
        [connectedTo setHidden:YES];
        [connectedIndicator startAnimating];
      } else {
        [connectedTo setHidden:NO];
        [connectedTo setText:@"no device"];
        
        if(self.gck_selectedDevice != nil) {
          [connectedTo setText:self.gck_selectedDevice.friendlyName];
        }
      }
    } else if(indexPath.row == 2) {
      UIButton *disconnect = (UIButton *)[cell viewWithTag:100];
      
      [disconnect addTarget:self action:@selector(disconnectFromDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
  } else if(indexPath.section == 2) {
    UILabel *friendlyNameLabel = (UILabel *)[cell viewWithTag:100];
    UIButton *connectedIcon = (UIButton *)[cell viewWithTag:101];
    
    [connectedIcon setHidden:NO];

    if([self.gck_devices count] > 0) {
      GCKDevice *device = (GCKDevice *)self.gck_devices[indexPath.row];
      
      [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
      
      [friendlyNameLabel setTextColor:[UIColor colorWithRed:255/255.0f green:171/255.0f blue:54/255.0f alpha:1.0f]];
      
      [connectedIcon setImage:[UIImage imageNamed:@"cast_off.png"] forState:UIControlStateNormal];
      [connectedIcon setTintColor:[UIColor colorWithRed:255/255.0f green:171/255.0f blue:54/255.0f alpha:1.0f]];
      
      if(self.gck_selectedDevice != nil) {
        if([device isEqual:self.gck_selectedDevice]) {
          [friendlyNameLabel setTextColor:[UIColor redColor]];
          
          [connectedIcon setImage:[UIImage imageNamed:@"cast_on.png"] forState:UIControlStateNormal];
          [connectedIcon setTintColor:[UIColor redColor]];
        }
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
    GCKDevice *device = (GCKDevice *)self.gck_devices[indexPath.row];

    if(self.gck_selectedDevice == nil && [self.gck_devices count] > 0) {
      self.reconnect = NO;
      self.connecting = YES;
      
      [self reloadCellRow:@[[NSIndexPath indexPathForRow:1 inSection:1]]];
      
      [self connectToDevice:device];
    } else if(![device isEqual:self.gck_selectedDevice]) {
      //DISCONNECT
      [self.SDM.gck_deviceManager disconnect];
      
      self.reconnect = YES;
      //NEW CONNECTION
      self.connecting = YES;
      
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
  [self.SDM.gck_deviceManager disconnect];
}

#pragma mark - FUNCTIONS

- (void)initDeviceScannerService {
  [self.gck_deviceScanner startScan];
}

- (BOOL)isConnected {
  return self.SDM.gck_deviceManager.isConnected;
}

- (BOOL)isConnectedToApp {
  return self.SDM.gck_deviceManager.isConnectedToApp;
}

- (void)deviceDisconnected {
  self.connecting = NO;
  
  self.gck_selectedDevice = nil;
  
  [self reloadSection:1 len:2];
  
  NSLog(@"Device disconnected");
}

- (void)connectToDevice:(GCKDevice *)device {
  self.SDM = [SharedDeviceManager sharedDeviceManager:device];
  [self.SDM setDelegate:self];
  
  self.gck_selectedDevice = device;
  [self reloadSection:1 len:2];
  //[self.SDM.gck_deviceManager connect];
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"defice appear!!!");
  if (![self.gck_devices containsObject:device]) {
    [self.gck_devices addObject:device];
    
    [self reloadSection:1 len:2];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device disappeared!!!");
  [self.gck_devices removeObject:device];
  
  [self reloadSection:1 len:2];
}

#pragma mark - SDMDelegate / GCKDeviceManagerDelegate

- (void)dmConnect:(GCKDeviceManager *)dm {
  self.connecting = NO;
  
  [self reloadSection:1 len:2];
}

- (void)dm:(GCKDeviceManager *)dm connectFail:(NSError *)error {
  NSLog(@"didFailToConnectWithError");
  [self showError:error];
  
  [self deviceDisconnected];
}

- (void)dm:(GCKDeviceManager *)dm disconnect:(NSError *)error {
  NSLog(@"Received notification that device disconnected");
  
  if (error != nil) {
    [self showError:error];
  }
  
  [self deviceDisconnected];
  
  if(self.reconnect) {
    
  }
}

#pragma mark - MISC

- (void)reloadCellRow:(NSArray *)indexArray {
  [self.tableView beginUpdates];
  
  [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
  
  [self.tableView endUpdates];
}

- (void)reloadSection:(NSInteger)from len:(NSInteger)len {
  [self.tableView beginUpdates];

  NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(from, len)];
  [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
  
  [self.tableView endUpdates];
}

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
