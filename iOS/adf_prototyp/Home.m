//
//  Home.m
//  test
//
//  Created by fza on 04.05.14.
//  Copyright (c) 2014 ADF. All rights reserved.
//

#import "Home.h"
//CHANNEL
//#import "MessageChannel.h"

@interface Home ()

@property NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UIButton *playbutton;

//CHANNEL
//@property MessageChannel *messageChannel;

@end

@implementation Home

@synthesize playbutton;

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

  [self initViewComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FUNCTIONS

- (void)initViewComponents {
  [self.playbutton.layer setCornerRadius:self.playbutton.bounds.size.width/2];
  [self.playbutton.layer setBorderColor:[[UIColor  colorWithRed:255/255.0f green:171/255.0f blue:54/255.0f alpha:1.0f] CGColor]];
  [self.playbutton.layer setBorderWidth:5];
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
