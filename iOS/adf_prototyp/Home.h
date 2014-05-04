//
//  Home.h
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import <UIKit/UIKit.h>
//CHANNEL
#import "MessageChannel.h"

@interface Home : UIViewController

@property NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UIButton *playbutton;

//CHANNEL
@property MessageChannel *messageChannel;

@end
