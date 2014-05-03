//
//  ViewController.h
//  adf_prototyp
//
//  Created by condero on 02.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import <UIKit/UIKit.h>
//CHANNEL
#import "MessageChannel.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, GCKDeviceScannerListener, GCKDeviceManagerDelegate>

//GCDeviceScenner
@property GCKApplicationMetadata *gck_applicationMetadata;
@property GCKDeviceManager *gck_deviceManager;
@property GCKDeviceScanner *gck_deviceScanner;
@property GCKDevice *gck_selectedDevice;

@property NSArray *gck_devices;

@property NSDictionary *mainBundleInfo;

//CHANNEL
@property MessageChannel *messageChannel;

//BUTTONS
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_gck_deviceScanner;

@property (weak, nonatomic) IBOutlet UILabel *connectedToLabel;
@property (weak, nonatomic) IBOutlet UITextField *mesage_textfield;
@property (weak, nonatomic) IBOutlet UIButton *message_send;

@end
