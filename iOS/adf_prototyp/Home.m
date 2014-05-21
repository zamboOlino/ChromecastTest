//
//  Home.m
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "Home.h"

#import "SharedDeviceManager.h"
//CHANNEL
#import "MovementChannel.h"

static NSString *const kReceiverAppID = @"5A71905F";

@interface Home () <UIAlertViewDelegate, SDMDelegate>

@property (strong, nonatomic) SharedDeviceManager *SDM;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (strong, nonatomic) NSDictionary *mainBundleInfo;

@property (assign, nonatomic) BOOL reconnectApp;
@property (assign, nonatomic) BOOL connectingApp;

//GCDeviceScenner
@property (strong, nonatomic) NSString *gck_sessionID;
@property (strong, nonatomic) GCKApplicationMetadata *gck_applicationMetadata;
@property (strong, nonatomic) GCKDeviceManager *gck_deviceManager;
@property (strong, nonatomic) GCKDeviceScanner *gck_deviceScanner;
@property (strong, nonatomic) GCKDevice *gck_selectedDevice;
//CHANNEL
@property (strong, nonatomic) MovementChannel *movementChannel;

@property (weak, nonatomic) IBOutlet UIButton *gameButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

//CHANNEL
//@property MessageChannel *messageChannel;

@end

@implementation Home

@synthesize SDM, gck_deviceManager, gck_selectedDevice, gck_applicationMetadata, gck_deviceScanner, gck_sessionID;
@synthesize userDefaults, reconnectApp, connectingApp;
@synthesize gameButton, joinButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

  self.userDefaults = [NSUserDefaults standardUserDefaults];
  self.mainBundleInfo = [[NSBundle mainBundle] infoDictionary];
  
  self.reconnectApp = NO;
  self.connectingApp = NO;
  
  [self initSDM];
  [self initViewComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if(![self isConnected]) {
    [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
  }
}

#pragma mark - UIButton Actions

- (IBAction)gameButton:(id)sender {
  if(![self isConnected]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No device"
                                                    message:@"Please connect to an chromecast device"
                                                   delegate:self
                                          cancelButtonTitle:@"connect"
                                          otherButtonTitles:nil];

    alert.tag = 1;
    
    [alert show];

  } else {
    self.connectingApp = YES;
    
    [self.SDM.gck_deviceManager launchApplication:kReceiverAppID];
  }
}

- (IBAction)joinButton:(id)sender {
  if(![self isConnected]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No device"
                                                    message:@"Please connect to an chromecast device"
                                                   delegate:self
                                          cancelButtonTitle:@"connect"
                                          otherButtonTitles:nil];
    
    alert.tag = 2;
    
    [alert show];
  } else {
    self.connectingApp = YES;
    
    [self.SDM.gck_deviceManager joinApplication:kReceiverAppID];
  }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(alertView.tag == 1) {
    if(buttonIndex == 0) {
      [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
    }
  } else if(alertView.tag == 2) {
    if(buttonIndex == 0) {
      [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
    }
  }
}

#pragma mark - FUNCTIONS

- (BOOL)isConnected {
  return self.SDM.gck_deviceManager.isConnected;
}

- (void)initSDM {
  self.SDM = [SharedDeviceManager sharedDeviceManager];
  [self.SDM setDelegate:self];
}

- (void)initViewComponents {
  [self.gameButton.layer setCornerRadius:20];
  [self.joinButton.layer setCornerRadius:20];
}

#pragma mark - SDMDelegate / GCKDeviceManagerDelegate

- (void)dm:(GCKDeviceManager *)dm connectToApp:(GCKApplicationMetadata *)metaData sessID:(NSString *)sessID launchedApp:(BOOL)launchedApp {
  NSLog(@"connectToApp");
  self.connectingApp = NO;
  
  self.gck_applicationMetadata = metaData;
  self.gck_sessionID = sessID;
  NSLog(@"%d", launchedApp);
  if(launchedApp) {
    self.movementChannel = [[MovementChannel alloc] initWithNamespace:@"urn:x-cast:de.adf.chromecast.pong"];
    [self.SDM.gck_deviceManager addChannel:self.movementChannel];
    
    [self performSegueWithIdentifier:@"GameSegue" sender:self];
  }
}

- (void)dm:(GCKDeviceManager *)dm disconnectFromApp:(NSError *)error {
  NSLog(@"disconnectFromApp");
  self.connectingApp = NO;

  if(error != NULL) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Application"
                                                    message:@"Can't disconnect from application"
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil];
    
    alert.tag = 3;
    
    [alert show];
  }
}

- (void)dm:(GCKDeviceManager *)dm connectFailToApp:(NSError *)error {
  NSLog(@"connectFailToApp");
  self.connectingApp = NO;

  if(error != NULL) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Application"
                                                    message:@"Can't connect to application"
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil];
    
    alert.tag = 4;
    
    [alert show];
  }
}

- (void)dm:(GCKDeviceManager *)dm failToStopApp:(NSError *)error {
  NSLog(@"failToStopApp");
  self.connectingApp = NO;

  if(error != NULL) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Application"
                                                    message:@"Can't stop the application"
                                                   delegate:self
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil];
    
    alert.tag = 5;
    
    [alert show];
  }
}

- (void)dm:(GCKDeviceManager *)dm appStatus:(GCKApplicationMetadata *)metaData {
  self.gck_applicationMetadata = metaData;
  
  NSLog(@"Received device status: %@", metaData);
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
