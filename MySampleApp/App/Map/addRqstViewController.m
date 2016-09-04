//
//  addRqstViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/9/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "addRqstViewController.h"
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>
#import "UIImage+Resize.h"

@interface addRqstViewController () {
    BOOL isPhotoSelected;
    NSData *pictureData;
    MBProgressHUD *hud;
    UITextField *mytextField;
    UIDatePicker *datePicker;
    NSDate *date;
    UIToolbar *keyboardToolbar;
}

@end

@implementation addRqstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];
    
    _requestView.layer.masksToBounds = YES;
    [_requestView.layer setCornerRadius:20.0f];
    
    _submit.layer.masksToBounds = YES;
    [_submit.layer setCornerRadius:6.0f];
    
    if (keyboardToolbar == nil) {
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        [keyboardToolbar setBarTintColor:[UIColor whiteColor]];
        
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyboard:)];
        
        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects: extraSpace, accept, nil]];
    }
    _dateTxt.inputAccessoryView = keyboardToolbar;
    _descriptionTxt.inputAccessoryView = keyboardToolbar;
    datePicker = [[UIDatePicker alloc] init];
    //datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    _dateTxt.inputView = datePicker;
    
    _addPic.layer.masksToBounds = YES;
    [_addPic.layer setCornerRadius:75.0f];
}

- (void)closeKeyboard:(id)sender{
    [_dateTxt resignFirstResponder];
    if(_usrTextView!=nil)
        [_usrTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBtnTakePhoto:(id)sender {
    [self dismissKeyboard];
    UIActionSheet *actionSheetView = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take picture" otherButtonTitles:@"Camera Roll", nil];
    
    [actionSheetView showInView:[self view]];
}

-(void)dismissKeyboard {
    if(_usrTextView!=nil)
        [_usrTextView resignFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self takePhoto];
            break;
        }
        case 1: {
            [self selectPhoto];
            break;
        }
        default:
            break;
    }
}

-(void)selectPhoto {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setAllowsEditing:NO];
    [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:pickerController animated:YES completion:^{}];
    //}
    
}

-(void)takePhoto {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setAllowsEditing:NO];
    [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [self presentViewController:pickerController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    isPhotoSelected = YES;
    [picker dismissModalViewControllerAnimated:YES];
    //Place the image in the imageview
    
    UIImage *scaledImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.addPic.bounds.size interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square (yikes, fancy!)
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.addPic.frame.size.width)/2, (scaledImage.size.height -self.addPic.frame.size.height)/2, self.addPic.frame.size.width, self.addPic.frame.size.height)];
    
    UIImage *colorimage = croppedImage;
    [_addPic setBackgroundImage:colorimage forState:UIControlStateNormal];
    
    pictureData = UIImagePNGRepresentation(img);
    //NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/saved_example_image.png"];
    //[pictureData writeToFile:imagePath atomically:YES];
}

#pragma mark UITextView

- (void)textViewDidBeginEditing:(UITextView *)textView{
    _tooltip.text = @"";
    [self.myscroll setContentSize:CGSizeMake(self.myscroll.bounds.size.width, self.view.bounds.size.height+253)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textView.frame.origin.y - 150) animated:YES];
    
    [UIView commitAnimations];
    
    _usrTextView = textView;
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        _tooltip.text = @"Add description";
    }
    _usrTextView = nil;
    [self.myscroll setContentSize:CGSizeMake(self.myscroll.bounds.size.width, self.myscroll.bounds.size.height+153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textView.frame.origin.y - 150) animated:YES];
    
    [UIView commitAnimations];
}

#pragma mark UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    mytextField = textField;
    [self.myscroll setContentSize:CGSizeMake(self.myscroll.bounds.size.width, self.myscroll.bounds.size.height+153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textField.frame.origin.y - 150) animated:YES];
    
    //if(textField==_emailLogin || textField==_passwordLogin){
       // self.view.frame = CGRectMake(0, 0 - textField.frame.origin.y + 100 , self.view.frame.size.width, self.view.frame.size.height);
    //}
    [UIView commitAnimations];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /* if (textField == _Username_TextField) {
     [_Username_TextField resignFirstResponder];
     [_password_TextField becomeFirstResponder];
     } else if (textField == _password_TextField) {*/
    // here you can define what happens
    // when user presses return on the email field
    [textField resignFirstResponder];
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, 0) animated:YES];
    //if(textField==_emailLogin || textField==_passwordLogin){
       // self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //}
    
    [UIView commitAnimations];
    
    
    // }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

-(IBAction)onNext:(id)sender {
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }  
    PFObject *requestObject = [PFObject objectWithClassName:@"Requests"];
    requestObject[@"creator"] = [PFUser currentUser];
    [requestObject setObject:[PFUser currentUser].objectId forKey:@"userId"];
    [requestObject setObject:_time.text forKey:@"time"];
    [requestObject setObject:_tasktitle.text forKey:@"title"];
    [requestObject setObject:_descriptionTxt.text forKey:@"description"];
    [requestObject setObject:date forKey:@"date"];
    [requestObject setObject:_money.text forKey:@"price"];
    requestObject[@"location"] = [PFGeoPoint geoPointWithLatitude:_latitude longitude:_longitude];
    [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self hideProgressHUD];
        if (succeeded){
            NSData *picData = UIImageJPEGRepresentation(_addPic.currentBackgroundImage, 0.5);
            if(picData){
                PFFile *file = [PFFile fileWithName:@"img" data:picData];
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        PFObject *imageObject = [PFObject objectWithClassName:@"TaskImages"];
                        [imageObject setObject:file forKey:@"image"];
                        [imageObject setObject:requestObject.objectId forKey:@"taskId"];
                        
                        //3
                        [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            //4
                            if (succeeded){
                                //Send notification
                                
                                EKEventStore *store = [EKEventStore new];
                                [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                                    if (!granted) { return; }
                                    EKEvent *event = [EKEvent eventWithEventStore:store];
                                    event.title = _tasktitle.text;
                                    event.startDate = date; //today
                                    event.endDate = [date dateByAddingTimeInterval:[_time.text intValue]];  //set 1 hour meeting
                                    event.calendar = [store defaultCalendarForNewEvents];
                                    NSError *err = nil;
                                    [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                                    //self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
                                }];
                                
                                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:_latitude longitude:_longitude];
                                PFQuery *userquery = [PFUser query];
                                [userquery whereKey:@"location" nearGeoPoint:point withinKilometers: 100.0];
                                
                                PFQuery *pushQuery = [PFInstallation query];
                                [pushQuery whereKey:@"user" matchesQuery: userquery];
                                
                                NSDictionary *data = @{
                                                       @"alert" : [NSString stringWithFormat:@"New task created around you by %@", [PFUser currentUser][@"nickname"]],
                                                       @"badge" : @"Increment",
                                                       @"sounds": @"cheering.caf",
                                                       @"name" : @"NewTask",
                                                       @"title" : [PFUser currentUser].objectId
                                                       };
                                PFPush *push = [[PFPush alloc] init];
                                [push setQuery:pushQuery]; // Set our Installation query
                                //[push setMessage:@"Live Stream Requested"];
                                [push setData:data];
                                //[push setChannel:[PFUser currentUser].objectId];
                                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if(succeeded){
                                        NSLog(@"%@", push);
                                    }else if (error.code == kPFErrorPushMisconfigured) {
                                        NSLog(@"Could not send push. Push is misconfigured: %@", error.description);
                                    } else {
                                        NSLog(@"Error sending push: %@", error.description);
                                    }
                                }];
                                
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Task created succesfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                
                                [alertView show];
                                
                            }
                            else{
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Task created succesfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                
                                [alertView show];
                            }
                        }];
                    }
                }];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Task created succesfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
            
        }else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)datePickerValueChanged:(id)sender{
    
    NSLog(@"%@", datePicker.date);
    
    date = datePicker.date;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_date setTitle:[df stringFromDate:datePicker.date] forState:UIControlStateNormal];
    
   // [_dateTxt setText:[df stringFromDate:date]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
