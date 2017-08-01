//
//  NotificationDisplayView.m
//  Moza
//
//  Created by Purpose Code on 16/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//


#import "GenderAndDOBPicker.h"
#import "Constants.h"

@interface GenderAndDOBPicker(){
    
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;
    long  dateInTimeStamp;
    NSString * gender;
    
    
}

@end

@implementation GenderAndDOBPicker



-(void)intialiseView{
    
    [btnMale setImage:[UIImage imageNamed:@"Male_Active"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"Female"] forState:UIControlStateNormal];
    gender = @"1";
    datePicker.maximumDate = [NSDate date];
}



-(IBAction)genderApplied:(UIButton*)sender{
    
    gender = @"1";
    [btnMale setImage:[UIImage imageNamed:@"Male_Active"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"Female"] forState:UIControlStateNormal];
    if (sender.tag == 2) {
        gender = @"2";
        [btnMale setImage:[UIImage imageNamed:@"Male"] forState:UIControlStateNormal];
        [btnFemale setImage:[UIImage imageNamed:@"Female_Active"] forState:UIControlStateNormal];
    }
    
    
}

-(IBAction)doneButtonApplied:(id)sender{
    
    dateInTimeStamp = [datePicker.date  timeIntervalSince1970];
    [[self delegate]genderAndDOBSelectedByGender:gender andDOB:dateInTimeStamp];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
