//
//  StreamViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/21/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "StreamViewController.h"
#import "VCSimpleSession.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"


@interface StreamViewController () <VCSessionDelegate> {

    CGSize kbSize;
    CGFloat expectedHeight;
    IBOutlet UILabel *referencia;
    IBOutlet UIImageView *munequito;
    PFObject *currentRequest;
}
@property (nonatomic, retain) VCSimpleSession* session;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *messageEditField;

@property (strong, nonatomic) IBOutlet UITextField *titleField;

@property (strong, nonatomic) IBOutlet UITableView *historicalMessagesTableView;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation StreamViewController

- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    _myfotoUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImageUrl"];
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen rect:%@", NSStringFromCGRect(rect));
    [[NSUserDefaults standardUserDefaults] setValue:@"name_preference" forKey:@"test"];
    
    _messageEditField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_messageEditField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    _titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_titleField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    _session = [[VCSimpleSession alloc] initWithVideoSize:rect.size frameRate:30 bitrate:1000000 useInterfaceOrientation:YES];
    //    _session.orientationLocked = YES;
    
    // BUSCO SI TENGO UN REQUEST HOY A ESTA HORA
    NSDate *currentDate = [NSDate date];
    NSDate *arrivedDate = [currentDate dateByAddingTimeInterval:300];
    NSDate *leftDate = [currentDate dateByAddingTimeInterval:-300];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    [query whereKey:@"responsable" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"date" greaterThan:leftDate];
    [query whereKey:@"date" lessThan:arrivedDate];
    [query orderByDescending:@"createdAt"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            self.taskId = object.objectId;
            //Creo el chat y me coloco como primer usuario
            currentRequest = object;
            [self startstreaming];
            
        }else{
            [self hideProgressHUD];
            NSLog(@"%@",[PFUser currentUser]);
            if(![PFUser currentUser][@"vendor"] || [[PFUser currentUser][@"vendor"] isEqualToString:@""]){
                // SI NO SOY PV Y NO TENGO TASK PENDIENTE
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Start Stream" message:@"You dont have Tasks to stream right now" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [alertView show];
            }else{
                // SI SOY PV Y NO TENGO PREGUNTO:
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start Stream"
                                                                message:@"You dont have Resquests to stream right now, Do you want to continue with the LiVi?"
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes, Start Livi", nil];
                [alert show];
            }
        }
    }];
    
    [self.previewView addSubview:_session.previewView];
    [self.previewView bringSubviewToFront:_scrollView];
    _session.previewView.frame = self.previewView.bounds;
    _session.delegate = self;
    
    self.messageArray = [[NSMutableArray alloc] init];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"];
    _myUserFoto = [UIImage imageWithData:imageData];
    self.historicalMessagesTableView.rowHeight = UITableViewAutomaticDimension;
   // [self retrieveMessagesFromParseWithChatMateID:self.chatMateId];
    UITapGestureRecognizer *tapTableGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.historicalMessagesTableView addGestureRecognizer:tapTableGR];
    [self registerForKeyboardNotifications];
    __weak typeof(self) weakSelf = self;
    [weakSelf scrollTableToBottom];  // Scroll to the bottom of the table view
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:{ //"Yes" pressed
            _titleField.hidden = NO;
            [_titleField becomeFirstResponder];
        }
            break;
    }
}

-(void) startstreaming {
    
    PFObject *chatObject = [PFObject objectWithClassName:@"Chat"];
    chatObject[@"taskId"] = self.taskId;
    chatObject[@"user"] = [PFUser currentUser];
    [chatObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            // SAVED
            [self hideProgressHUD];
        }
    }];

    // start record
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Setting up keyboard notifications.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didTapOnTableView {
    [self.activeTextField resignFirstResponder];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(self.activeTextField==self.messageEditField){
        NSDictionary* info = [aNotification userInfo];
        kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        /*UIEdgeInsets contentInsets = UIEdgeInsetsMake(kbSize.height, 0.0, kbSize.height, 0.0);
         self.scrollView.contentInset = contentInsets;
         self.scrollView.scrollIndicatorInsets = contentInsets;
         // If active text field is hidden by keyboard, scroll it so it's visible
         // Your app might not need or want this behavior.
         CGRect aRect = self.view.frame;
         aRect.size.height -= kbSize.height;
         if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
         [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:NO];
         }*/
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.50];
        [UIView setAnimationDelegate:self];
        
        _messageEditField.frame = CGRectMake(_messageEditField.frame.origin.x, _messageEditField.frame.origin.y-kbSize.height, _messageEditField.frame.size.width, _messageEditField.frame.size.height);
        
        munequito.frame = CGRectMake(munequito.frame.origin.x, munequito.frame.origin.y-kbSize.height, munequito.frame.size.width, munequito.frame.size.height);
        
        _historicalMessagesTableView.frame = CGRectMake(_historicalMessagesTableView.frame.origin.x, _historicalMessagesTableView.frame.origin.y, _historicalMessagesTableView.frame.size.width, _historicalMessagesTableView.frame.size.height - kbSize.height);
        
        [self scrollTableToBottom];
        
        [UIView commitAnimations];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(self.activeTextField==self.messageEditField){
        /*UIEdgeInsets contentInsets = UIEdgeInsetsZero;
         self.scrollView.contentInset = contentInsets;
         self.scrollView.scrollIndicatorInsets = contentInsets;*/
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.50];
        [UIView setAnimationDelegate:self];
        
        _messageEditField.frame = CGRectMake(_messageEditField.frame.origin.x, _messageEditField.frame.origin.y+kbSize.height, _messageEditField.frame.size.width, _messageEditField.frame.size.height);
        
        munequito.frame = CGRectMake(munequito.frame.origin.x, munequito.frame.origin.y+kbSize.height, munequito.frame.size.width, munequito.frame.size.height);
        
        _historicalMessagesTableView.frame = CGRectMake(_historicalMessagesTableView.frame.origin.x, _historicalMessagesTableView.frame.origin.y, _historicalMessagesTableView.frame.size.width, _historicalMessagesTableView.frame.size.height + kbSize.height);
        
        [self scrollTableToBottom];
        
        [UIView commitAnimations];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnConnectTouch:(id)sender {
    switch(_session.rtmpSessionState) {
        case VCSessionStateNone:
        case VCSessionStatePreviewStarted:
        case VCSessionStateEnded:
        case VCSessionStateError:{
            [_session startRtmpSessionWithURL:@"rtmp://ec2-54-164-51-55.compute-1.amazonaws.com/live" andStreamKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"objectId"]];
            PFUser *user = [PFUser currentUser];
            user[@"urlStreamIos"] = [NSString stringWithFormat:@"http://54.164.51.55:1935/live/%@/playlist.m3u8", [[NSUserDefaults standardUserDefaults] objectForKey:@"objectId"]]; // attempt to change username
            user[@"urlStream"] = [NSString stringWithFormat:@"rtmp://54.164.51.55:1935/live/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"objectId"]];
            [user saveInBackground];
            
            
            
            _btnConnect.hidden = YES;
            
            NSString *urlString = [NSString stringWithFormat:@"http://wowza:i-0defbdce0dcbf5ecd@54.164.51.55:8086/livestreamrecord?app=live&streamname=djrQm3rayc&action=startRecording&outputFile=%@.mp4&fileTemplate=fileVersionDelegate", self.taskId];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [request setHTTPMethod: @"GET"];
            
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *returnData, NSURLResponse *response, NSError *error) {
                if (error == nil) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    if ([httpResponse statusCode]==200) {
                        currentRequest[@"streamId"] = self.taskId;
                        [currentRequest saveInBackground];
                    }
                    
                }else{
                    NSLog(@"%@", error);
                }
            }];
            [dataTask resume];
            
        }
            break;
        default:
            [_session endRtmpSession];
            break;
    }
    
    UIButton *btnTemporal = (UIButton *)sender;
    if(btnTemporal.tag==100){
        [self handleCloseApp];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//Switch with the availables filters
- (IBAction)btnFilterTouch:(id)sender {
    switch (_session.filter) {
        case VCFilterNormal:
            [_session setFilter:VCFilterGray];
            break;
        case VCFilterGray:
            [_session setFilter:VCFilterInvertColors];
            break;
        case VCFilterInvertColors:
            [_session setFilter:VCFilterSepia];
            break;
        case VCFilterSepia:
            [_session setFilter:VCFilterFisheye];
            break;
        case VCFilterFisheye:
            [_session setFilter:VCFilterGlow];
            break;
        case VCFilterGlow:
            [_session setFilter:VCFilterNormal];
            break;
        default:
            break;
    }
}



- (void) connectionStatusChanged:(VCSessionState) state
{
    switch(state) {
        case VCSessionStateStarting:
            //[self.btnConnect setTitle:@"Connecting" forState:UIControlStateNormal];
            [self.btnConnect setHidden:YES];
            break;
        case VCSessionStateStarted:
            [self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
            break;
        default:
            [self.btnConnect setHidden:NO];
            //[self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            break;
    }
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    if(textField==_titleField){
        if (_progressHUD == nil)
        {
            _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }

        //Guardo el título del LiVi y creo el LiVi
        // CREATE THE REQUEST FROM U TO U
        PFObject *requestObject = [PFObject objectWithClassName:@"Requests"];
        requestObject[@"pv"] = [PFUser currentUser];
        requestObject[@"title"] = self.titleField.text;
        requestObject[@"responsable"] = [PFUser currentUser].objectId;
        requestObject[@"location"] = [PFUser currentUser][@"location"];
        requestObject[@"creator"] = [PFUser currentUser];
        [requestObject setObject:[PFUser currentUser].objectId forKey:@"userId"];
        [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded){
                // SAVED
                //Creo el chat y me coloco como primer usuario
                
                self.taskId = requestObject.objectId;
                currentRequest = requestObject;
                self.titleField.hidden = YES;
                [self hideProgressHUD];
                [self startstreaming];
                
            }
        }];
        
    }else{
        [self sendMessageVoid];
    }
    
    return YES;
}

-(void)sendMessage:(id)sender
{
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate sendTextMessage:self.messageEditField.text toRecipient:self.chatMateId];
    if(self.activeTextField){
        [self.activeTextField resignFirstResponder];
    }
    [self sendMessageVoid];
}

-(void)sendMessageVoid {
    /*
     [self.messageArray addObject:chatMessage];
     [self.historicalMessagesTableView reloadData];
     [self scrollTableToBottom];
     
     Manejamos el envío de mensajes desde el controller
     1. Agregamos nuestro objeto mensaje al array y recargamos la tabla
     2. Enviamos la notificación a los usuarios del chat
     
     Nota: Este proceso se debe repetir al recibir un mensaje
     */
    if(![self.messageEditField.text isEqualToString:@""]){
        /*_chatMessage = [PFObject objectWithClassName:@"TaskMessage"];
        _chatMessage[@"senderId"] = _myUserId;
        _chatMessage[@"recipientId"] = _chatMateId;
        _chatMessage[@"taskId"] = _taskId;
        _chatMessage[@"text"] = self.messageEditField.text;*/
        
        PFQuery *chatquery = [PFQuery queryWithClassName:@"Chat"];
        [chatquery whereKey:@"taskId" equalTo:self.taskId];
        [chatquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects){
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:object[@"user"]];
                    // Send push notification to query
                    NSDictionary *data = @{
                                           @"alert" : @"You have received a Message",
                                           @"name" : @"chatMessage",
                                           @"senderId" : [PFUser currentUser].objectId,
                                           @"text" : self.messageEditField.text,
                                           @"myimage" : _myfotoUrl,
                                           @"taskId" : self.taskId
                                           };
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    [push setData:data];
                    [push sendPushInBackground];
                    self.messageEditField.text = @"";
                }
            }
        }];

        // Esto se va a manejar en la notificación, ya que los que yo envíe también me serán notificados
        // [self.messageArray addObject:_chatMessage];
        // [self.historicalMessagesTableView reloadData];
        // [self scrollTableToBottom];
    }
    
    
}

- (void)scrollTableToBottom {
    int rowNumber = [self.historicalMessagesTableView numberOfRowsInSection:0];
    if (rowNumber > 0) [self.historicalMessagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)handleThePushNotification:(NSDictionary *)userInfo{
    
    //set some badge view here
    NSLog(@"entro");
    NSLog(@"%@", userInfo);
    
    _chatMessage = [PFObject objectWithClassName:@"TaskMessage"];
    _chatMessage[@"senderId"] = userInfo[@"senderId"];
    _chatMessage[@"taskId"] = userInfo[@"taskId"];
    _chatMessage[@"text"] = userInfo[@"text"];
    _chatMessage[@"myimage"] = userInfo[@"myimage"];
    
    [self.messageArray addObject:_chatMessage];
    [self.historicalMessagesTableView reloadData];
    [self scrollTableToBottom];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    UILabel *textolabel;
    PFObject *chatMessage = self.messageArray[indexPath.row];
    textolabel.text = chatMessage[@"text"];
    NSString *texto = chatMessage[@"text"];
    textolabel=[[UILabel alloc]initWithFrame:CGRectMake(85, 30, self.view.frame.size.width - 78, 66)];
    textolabel.font=referencia.font;
    textolabel.numberOfLines=0;
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 78, FLT_MAX);
    CGSize expectedLabelSize = [texto sizeWithFont:textolabel.font constrainedToSize:maximumLabelSize lineBreakMode:textolabel.lineBreakMode];
    
    if(expectedLabelSize.height+10<66)
        return 76;
    expectedHeight = expectedLabelSize.height;
    return expectedLabelSize.height + 10;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MNCChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"MessageListPrototypeCell" forIndexPath:indexPath];
    
    PFObject *chatMessage = self.messageArray[indexPath.row];
    
    messageCell.viewLabel.layer.masksToBounds = YES;
    [messageCell.viewLabel.layer setCornerRadius:15.0f];
    
    messageCell.chatMateMessageLabel.numberOfLines = 0;
    CGRect newFrame = messageCell.chatMateMessageLabel.frame;
    newFrame.size.height = expectedHeight;
    messageCell.chatMateMessageLabel.frame = newFrame;
    
    messageCell.chatMateMessageLabel.text = chatMessage[@"text"];
    [ messageCell.foto sd_setImageWithURL:[NSURL URLWithString:chatMessage[@"myimage"]] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
    
    
    UIView *viewLabel = [[UIView alloc] initWithFrame:CGRectMake(78, 5, self.view.frame.size.width - 78, messageCell.frame.size.height-10)];
    viewLabel.layer.masksToBounds = YES;
    [viewLabel.layer setCornerRadius:15.0f];
    
    if ([chatMessage[@"senderId"] isEqualToString:[PFUser currentUser].objectId]) {
        // If the message was sent by myself
        viewLabel.backgroundColor = [UIColor colorWithRed:84.0/255 green:196.0/255 blue:238.0/255 alpha:0.3];
    } else {
        // If the message was sent by the chat mate
        viewLabel.backgroundColor = [UIColor colorWithRed:234.0/255 green:89.0/255 blue:45.0/255 alpha:0.3];
    }
        
    
    [messageCell.contentView addSubview:viewLabel];
    [messageCell.contentView bringSubviewToFront:messageCell.chatMateMessageLabel];
    return messageCell;
}


#pragma mark Method to configure the appearance of a message list prototype cell

- (void)configureCell:(MNCChatMessageCell *)messageCell forIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)handleCloseApp{
    
    PFUser *user = [PFUser currentUser];
    user[@"urlStreamIos"] = @""; // attempt to change username
    user[@"urlStream"] = @"";
    [user saveInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Views"];
    [query selectKeys:@[@"userId"]];
    
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" matchesQuery: query];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery: userQuery];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setMessage:@"Live Stream Finished"];
    [push sendPush:nil];
    
    //Borramos el chat
    PFQuery *querychat = [PFQuery queryWithClassName:@"Chat"];
    [querychat whereKey:@"taskId" equalTo:self.taskId];
    NSLog(@"%@", self.taskId);
    NSArray *objects = [querychat findObjects];
    for (PFObject *object in objects) {
                [object deleteInBackground];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://wowza:i-0defbdce0dcbf5ecd@54.164.51.55:8086/livestreamrecord?app=live&streamname=djrQm3rayc&action=startRecording&outputFile=%@.mp4&fileTemplate=", self.taskId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setHTTPMethod: @"GET"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *returnData, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSLog(@"%@", response);
            NSString *responsestring = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
            NSLog(@"response %@",responsestring);
        }else{
            NSLog(@"%@", error);
        }
    }];
    [dataTask resume];
}



@end
