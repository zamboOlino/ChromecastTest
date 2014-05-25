//
//  Game.m
//  test
//
//  Created by fza on 05.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "Game.h"

#import <GoogleCast/GoogleCast.h>

#import "SharedDeviceManager.h"

@interface Game () <SDMDelegate>

@property (strong, nonatomic) SharedDeviceManager *SDM;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;

@end

@implementation Game

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
  
  self.userDefaults = [NSUserDefaults standardUserDefaults];
  
  [self initSDM];
  [self initViewComponents];
  [self initChannel];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.SDM setDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self.SDM setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FUNCTIONS

- (BOOL)isConnected {
  return self.SDM.gck_deviceManager.isConnected;
}

- (void)initSDM {
  self.SDM = [SharedDeviceManager sharedDeviceManager];
}

- (void)initViewComponents {
  [self.upButton.layer setCornerRadius:20];
  [self.downButton.layer setCornerRadius:20];
}

- (void)initChannel {
  self.castChannel = [[MovementChannel alloc] initWithNamespace:@"urn:x-cast:de.adf.chromecast.pong"];
  [self.SDM.gck_deviceManager addChannel:self.castChannel];
}

#pragma mark - UIButton Actions

- (IBAction)backButton:(id)sender {
  [self.SDM.gck_deviceManager stopApplication];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)upButtonAction:(id)sender {
  [self.castChannel sendTextMessage:@"1"];
}

- (IBAction)downButtonAction:(id)sender {
  [self.castChannel sendTextMessage:@"2"];
}

@end
