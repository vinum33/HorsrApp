//
//  LocationAutoSearchViewController.m
//  Moza
//
//  Created by Purpose Code on 06/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "LocationAutoSearchViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import "Constants.h"
#import <AddressBookUI/AddressBookUI.h>

@interface LocationAutoSearchViewController () <GMSAutocompleteViewControllerDelegate,CLLocationManagerDelegate>{
    
    CLLocationManager* locationManager;
    IBOutlet UILabel *lblLocation;
    IBOutlet UIButton *btnContinue;
    IBOutlet UIButton *btnSearch;
    IBOutlet UIActivityIndicatorView *indicator;
    CLLocationCoordinate2D coordinate;
    NSString *strAddress;
    NSString *strCity;

}

@end

@implementation LocationAutoSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    btnContinue.layer.borderColor = [[UIColor clearColor] CGColor];
    btnContinue.layer.borderWidth = 0.0f;
    btnContinue.layer.cornerRadius = 5.0f;
    btnContinue.alpha = 0.5;
    
    float width = self.view.frame.size.width - 20;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 50);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [btnContinue.layer addSublayer:gradient];
    [btnContinue.layer insertSublayer:gradient atIndex:0];
    btnContinue.layer.borderWidth = 1.0f;
    btnContinue.layer.cornerRadius = 5.0f;
    btnContinue.clipsToBounds = YES;
    [btnContinue setEnabled:false];
    
    btnSearch.layer.borderColor = [[UIColor getThemeColor] CGColor];
    btnSearch.layer.borderWidth = 1.0f;
    btnSearch.layer.cornerRadius = 5.0f;
    NSMutableAttributedString *text =  [[NSMutableAttributedString alloc]  initWithString:@"If not search your location"];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.80 green:0.01 blue:0.01 alpha:1.0] range:NSMakeRange(0,6)];
    [btnSearch setAttributedTitle:text forState:UIControlStateNormal];
    
    [self checkLocationPermisionStatus];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // user allowed
        [self getUserLocation];
    }
    
}

- (void)getUserLocation

{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [indicator startAnimating];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [geocoder reverseGeocodeLocation:locationManager.location
                       completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error){
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             [indicator stopAnimating];
             NSMutableAttributedString *text =  [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"YOU ARE IN %@",placemark.locality]];
             [text addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(11, text.length - 11)];
             [lblLocation setAttributedText: text];
             NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
             strAddress = [lines componentsJoinedByString:@","];
             strCity = placemark.locality;
             coordinate = placemark.location.coordinate;
             [btnContinue setEnabled:true];
             [btnContinue setAlpha:1];
             
         }];
            
    }else{
        
        [self checkLocationPermisionStatus];
    }
    // The user has not enabled any location services. Request background authorization.
    
}

-(void)checkLocationPermisionStatus{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSString *strMessage = nil;
    if (status==kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
        return;
    }else if ((status==kCLAuthorizationStatusDenied) || status==kCLAuthorizationStatusRestricted){
        strMessage = @"Location is required to find out where you are";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location" message:strMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        [[UIApplication sharedApplication]openURL:settingsURL];
        
    }
}



- (IBAction)showPlaceSearchPage {
    [indicator startAnimating];
     [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor getBlackTextColor]}];
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterCity;
    acController.delegate = self;
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    //  NSLog(@"Place name %@", place.name);
    //  NSLog(@"Place address %@", place.formattedAddress);
    // NSLog(@"Place attributions %@", place.attributions.string);
    
    [indicator stopAnimating];
    NSMutableAttributedString *text =  [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"YOU ARE IN %@",place.name]];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(11, text.length - 11)];
    [lblLocation setAttributedText: text];
    strAddress = place.formattedAddress;
    strCity = place.name;
    coordinate = place.coordinate;
    [btnContinue setEnabled:true];
    [btnContinue setAlpha:1];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    [indicator stopAnimating];
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [indicator stopAnimating];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (IBAction)continueApplied {
    
    if ([self.delegate respondsToSelector:@selector(locationSearchedWithInfo:address:latitude:longitude:)])
        [self.delegate locationSearchedWithInfo:strCity address:strAddress latitude:coordinate.latitude longitude:coordinate.longitude];
    [[self navigationController]popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
