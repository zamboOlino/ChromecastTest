//
//  MessageChannel.m
//  adf_prototyp
//
//  Created by fza on 02.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "MessageChannel.h"

@implementation MessageChannel

- (void)didReceiveTextMessage:(NSString*)message {
  NSLog(@"received message: %@", message);
}

@end
