//
//  RootViewController.m
//  KeyboardDucker
//
//  Created by Steven Fisher on 2012-09-20.
//

#import "RootViewController.h"

@interface RootViewController ()
@property (nonatomic, weak) IBOutlet UITextView *blurbView;
@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *e;
    NSString *blurb = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ViewControllerBlurb" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&e];
    _blurbView.text = blurb;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end
