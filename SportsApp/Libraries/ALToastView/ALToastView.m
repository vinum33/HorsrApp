//
//  ALToastView.h
//
//  Created by Alex Leutgöb on 17.07.11.
//  Copyright 2011 alexleutgoeb.com. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "ALToastView.h"


// Set visibility duration
static const CGFloat kDuration = 2;


// Static toastview queue variable
static NSMutableArray *toasts;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ALToastView ()

@property (nonatomic, readonly) UILabel *textLabel;

- (void)fadeToastOut;
+ (void)nextToastInView:(UIView *)parentView;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ALToastView

@synthesize textLabel = _textLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithText:(NSString *)text {
	if ((self = [self initWithFrame:CGRectZero])) {
		// Add corner radius
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
		self.layer.cornerRadius = 5;
		self.translatesAutoresizingMaskIntoConstraints = NO;
        
        
		// Init and add label
		_textLabel = [[UILabel alloc] init];
		_textLabel.text = text;
        _textLabel.numberOfLines = 0;
		_textLabel.font = [UIFont systemFontOfSize:14];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_textLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_textLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_textLabel]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];
	}
	
	return self;
}


- (void)dealloc {
  
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text {
	// Add new instance to queue
	ALToastView *view = [[ALToastView alloc] initWithText:text];
	view.alpha = 0.0f;
	
	if (toasts == nil) {
		toasts = [[NSMutableArray alloc] initWithCapacity:1];
		[toasts addObject:view];
		[ALToastView nextToastInView:parentView];
	}
	else {
		[toasts addObject:view];
	}
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
	// Fade in parent view
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
   
                   animations:^{
                     self.alpha = 0.f;
                   } 
                   completion:^(BOOL finished){
                     UIView *parentView = self.superview;
                     [self removeFromSuperview];
                     
                     // Remove current view from array
                     [toasts removeObject:self];
                     if ([toasts count] == 0) {
                       toasts = nil;
                     }
                     else
                       [ALToastView nextToastInView:parentView];
                   }];
}


+ (void)nextToastInView:(UIView *)parentView {
	if ([toasts count] > 0) {
    ALToastView *view = [toasts objectAtIndex:0];
    
		// Fade into parent view
		[parentView addSubview:view];
        [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[view]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-10]];
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:view.textLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:-10]];

    [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
      view.alpha = 1.0;
                     } completion:^(BOOL finished){}];
    
    // Start timer for fade out
    [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
  }
}

@end
