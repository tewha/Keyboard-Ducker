//
//  DuckingViewController.m
//  KeyboardDucker
//
//  Created by Steven Fisher on 2012-09-20.
//

#import "DuckingViewController.h"

@interface DuckingViewController ()
@property (weak) IBOutlet UIView *resizingView;
@property (weak) IBOutlet UITextView *textView;
@end

@implementation DuckingViewController


// The iPhone does not have a dismiss keyboard button, so we added one to the storyboard and mapped its action here.
- (IBAction)tappedHideKeyboardButton: (UIButton *)button {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}


- (IBAction)tappedCloseButton:(UIButton *)sender {
    [self dismissModalViewControllerAnimated: YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *e;
    NSString *text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ModalViewControllerBlurb" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&e];
    _textView.text = text;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    // The view is not fully set up the first time viewWillAppear is called, so instead of assigning the first responder immediately we wait for events already in the main queue to be handled. In particular, this makes view coordinate conversion in keyboardWillShowNotification work as expected.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_textView becomeFirstResponder];
    });
}


- (void)viewDidDisappear:(BOOL)animated {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewDidDisappear: animated];
}


- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    UIView *workingView = self.view;
    CGRect keyboardScreenRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardRect = [workingView convertRect:keyboardScreenRect fromView:nil];
    CGRect resizeRect = [workingView convertRect:_resizingView.superview.bounds fromView:_resizingView.superview];
    CGRect unionRect = CGRectIntersection(keyboardRect, resizeRect);
    CGFloat bottom = resizeRect.origin.y + resizeRect.size.height;
    if (!isinf(unionRect.origin.y)) {
        bottom = unionRect.origin.y;
    }
    
    CGRect newFrame = _resizingView.frame;
    newFrame.size.height = [_resizingView.superview convertPoint:(CGPoint){.x=0.0f, .y=bottom} fromView:workingView].y - newFrame.origin.y;
    
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration: duration delay: 0 options: (curve << 16) animations:^{
        _resizingView.frame = newFrame;
    } completion:^(BOOL finished) {
    }];
    
}


- (void)keyboardWillHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect owningBounds = _resizingView.superview.bounds;
    CGRect newFrame = _resizingView.frame;
    newFrame.size.height = owningBounds.size.height - newFrame.origin.y;
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration: duration delay: 0 options: (curve << 16) animations:^{
        _resizingView.frame = newFrame;
    } completion:^(BOOL finished) {
    }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
