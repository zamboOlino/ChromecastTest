//
//  Game.h
//  test
//
//  Created by fza on 05.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import <UIKit/UIKit.h>
//CHANNEL
#import "MovementChannel.h"

@interface Game : UIViewController

//CHANNEL
@property (strong, nonatomic) MovementChannel *castChannel;

@end
