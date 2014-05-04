//
//  Settings.h
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, GCKDeviceScannerListener, GCKDeviceManagerDelegate>

@property NSUserDefaults *userDefaults;

@property NSDictionary *mainBundleInfo;
@property NSMutableArray *gck_devices;

//GCDeviceScenner
@property GCKApplicationMetadata *gck_applicationMetadata;
@property GCKDeviceManager *gck_deviceManager;
@property GCKDeviceScanner *gck_deviceScanner;
@property GCKDevice *gck_selectedDevice;

@end
