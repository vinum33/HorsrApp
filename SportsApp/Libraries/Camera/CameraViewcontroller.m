//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//


#import "CameraViewcontroller.h"
#import "ViewUtils.h"
#import "ImageViewController.h"
#import "VideoViewController.h"
#import "Constants.h"

@interface CameraViewcontroller (){
    
    UIView *bottomPanel;
    UILabel *lblTimer;
    NSTimer *timer;
    NSInteger counter;
    UILabel *lblCaption;
    
}
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *switchButton;
@end

@implementation CameraViewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];

    counter = _timeLength;
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPreset640x480
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];

    
    bottomPanel = [UIView new];
    bottomPanel.frame = CGRectMake(0, screenRect.size.height - 100, screenRect.size.width, 100);
    bottomPanel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomPanel];
    
    UIView *blackView = [UIView new];
    blackView.frame = CGRectMake(0, 50, screenRect.size.width, 50);
    blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [bottomPanel addSubview:blackView];
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(bottomPanel.frame.size.width / 2 - 35, 15, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.snapButton setImage:[UIImage imageNamed:@"Video_Record"] forState:UIControlStateNormal];
    [bottomPanel addSubview:self.snapButton];
    
    // button to toggle flash
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(0, 5, 40, 40);
    self.cancelBtn.tintColor = [UIColor whiteColor];
    [self.cancelBtn setImage:[UIImage imageNamed:@"Close_Camera"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelCameraView) forControlEvents:UIControlEventTouchUpInside];
    [blackView addSubview:self.cancelBtn];
    
    
    lblCaption = [UILabel new];
    lblCaption.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:lblCaption];
    lblCaption.text = @"Capture Video...";
    lblCaption.textAlignment = NSTextAlignmentCenter;
    lblCaption.font = [UIFont fontWithName:CommonFont size:16];
    lblCaption.textColor = [UIColor whiteColor];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lblCaption
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lblCaption
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
   
    
    lblTimer = [UILabel new];
    lblTimer.translatesAutoresizingMaskIntoConstraints = NO;
    [blackView addSubview:lblTimer];
    lblTimer.text = [NSString stringWithFormat:@"%ld",(long)_timeLength - 1];
    lblTimer.textAlignment = NSTextAlignmentCenter;
    lblTimer.font = [UIFont fontWithName:CommonFont size:18];
    lblTimer.textColor = [UIColor whiteColor];
    [blackView addConstraint:[NSLayoutConstraint constraintWithItem:lblTimer
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:blackView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
    [blackView addConstraint:[NSLayoutConstraint constraintWithItem:lblTimer
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:blackView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-60]];
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [blackView addSubview:self.switchButton];
        
        [blackView addConstraint:[NSLayoutConstraint constraintWithItem:self.switchButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:blackView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0]];
        [blackView addConstraint:[NSLayoutConstraint constraintWithItem:self.switchButton
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:blackView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0]];
        [self.switchButton addConstraint:[NSLayoutConstraint constraintWithItem:self.switchButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:40]];
        
        [self.switchButton addConstraint:[NSLayoutConstraint constraintWithItem:self.switchButton
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0
                                                                       constant:40]];
      
        
    }
  
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}



- (NSURL *)applicationDocumentsDirectory
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/SportsApp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder

    return [NSURL fileURLWithPath:dataPath];
}

-(IBAction)cancelCameraView{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}


- (void)snapButtonPressed:(UIButton *)button
{
    [lblCaption removeFromSuperview];
    if(!self.camera.isRecording) {
        
    self.switchButton.hidden = YES;
       timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(countStart)
                                       userInfo:nil
                                        repeats:YES];
        [self.snapButton setImage:[UIImage imageNamed:@"Video_Stop"] forState:UIControlStateNormal];
        // start recording
        NSURL *outputURL = [[[self applicationDocumentsDirectory]
                             URLByAppendingPathComponent:@"video"] URLByAppendingPathExtension:@"mov"];
        [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
            
            [self recordCompletedWithURL:outputFileUrl];
            
        }];
        
    } else {
        
       // self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
       // self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self.camera stopRecording];
        [self stpRecordingApplied];
         self.switchButton.hidden = NO;
    }
}
-(void)countStart{
    
    counter --;
    lblTimer.text = [NSString stringWithFormat:@"%ld",(long)counter];;
    if (counter == 00) {
        [self.camera stopRecording];
        lblTimer.text = @"";
        [timer invalidate];
    }
}
-(void)stpRecordingApplied{
    [timer invalidate];
}


-(void)recordCompletedWithURL:(NSURL*)url{
    
    [[self delegate]recordCompletedWithOutOutURL:url];
    [self cancelCameraView];
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
    self.camera.view.frame = self.view.contentBounds;
   
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
