//
//  RTMPPlayerViewController.m
//  Livi
//
//  Created by Carlos Robinson on 5/15/16.
//  Copyright © 2016 livi. All rights reserved.
//  https://github.com/slavavdovichenko/MediaLibDemos3x

#import "RTMPPlayerViewController.h"
#import "DEBUG.h"
#import "MemoryTicker.h"
#import "MediaStreamPlayer.h"
#import "VideoPlayer.h"
#import "MPMediaDecoder.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "ChatViewController.h"
#import "ComprarViewController.h"

@interface RTMPPlayerViewController ()<MPIMediaStreamEvent> {
    
    MemoryTicker            *memoryTicker;
    MPMediaDecoder          *decoder;
    BOOL                    isLive;
    BOOL                    wasPlayed;
    CGSize                  kbSize;
    CGFloat                 expectedHeight;
    IBOutlet                UILabel *referencia;
    IBOutlet                UILabel *owner;
    IBOutlet                UILabel *calificacion;
    IBOutlet                UILabel *descripcion;
    IBOutlet                UIView *finalView;
    IBOutlet                UIImageView *foto;
    IBOutlet                UIImageView *munequito;
    NSTimer                 *timer;
    NSString                *amount;
    int                     seconds;
    
    UIActivityIndicatorView *netActivity;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *messageEditField;

@property (strong, nonatomic) IBOutlet UITableView *historicalMessagesTableView;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

-(void)sizeMemory:(NSNumber *)memory;
-(void)setDisconnect;


@end

@implementation RTMPPlayerViewController

#pragma mark -
#pragma mark  View lifecycle

-(void)viewDidLoad {
    
    //[DebLog setIsActive:YES];
    
    [super viewDidLoad];
    
    _myfotoUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImageUrl"];
    _messageEditField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_messageEditField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // BUSCO EL CHAT CON EL _streamStrig YA QUE CADA USUARIO SOLO PUEDE TENER UN CHAT
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    PFQuery *queryTransmisor = [PFUser query];
    [queryTransmisor getObjectInBackgroundWithId:_streamStrig block:^(PFObject *transmisor, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", transmisor);
        owner.text = transmisor[@"businessname"];
        descripcion.text = transmisor[@"description"];
        calificacion.text = @"";
        
        
        PFQuery *queryChat = [PFQuery queryWithClassName:@"Chat"];
        [queryChat whereKey:@"user" equalTo:transmisor];
        [queryChat orderByDescending:@"createdAt"];
        [queryChat getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                self.taskId = object[@"taskId"];
                
                PFQuery *query = [PFQuery queryWithClassName:@"TaskImages"];
                [query whereKey:@"taskId" equalTo:object[@"taskId"]];
                [query orderByDescending:@"createdAt"];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        if(objects.count==0){
                            PFQuery *queryUserImage = [PFQuery queryWithClassName:@"UserImage"];
                            [queryUserImage whereKey:@"user" equalTo:transmisor[@"email"]];
                            [queryUserImage orderByDescending:@"createdAt"];
                            queryUserImage.limit = 1; // limit to at most 10 results
                            [queryUserImage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if (!error) {
                                    for (PFObject *imgObject in objects){
                                        PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                                        NSLog(@"%@", image.url);
                                        [foto sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
                                        foto.layer.masksToBounds = YES;
                                        
                                    }

                                }
                            }];
                            
                        }else{
                            for (PFObject *imgObject in objects){
                                PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                                [foto sd_setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
                                foto.layer.masksToBounds = YES;
                            }
                        }
                        
                        
                        
                    }else{
                        NSLog(@"%@", error);
                    }
                }];
                
                PFObject *gameScore = [PFObject objectWithClassName:@"Views"];
                gameScore[@"userId"] = [PFUser currentUser].objectId;
                gameScore[@"ownerId"] = transmisor.objectId;
                gameScore[@"taskId"] = self.taskId;
                [gameScore saveInBackground];
                
                PFObject *chatObject = [PFObject objectWithClassName:@"Chat"];
                chatObject[@"taskId"] = self.taskId;
                chatObject[@"user"] = [PFUser currentUser];
                [chatObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        // SAVED
                        [self hideProgressHUD];
                    }else{
                        
                    }
                }];
            }else{
                NSLog(@"entro por aqui");
            }
        }];
        
    }];
    
    
    self.messageArray = [[NSMutableArray alloc] init];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"];
    _myUserFoto = [UIImage imageWithData:imageData];
    self.historicalMessagesTableView.rowHeight = UITableViewAutomaticDimension;
    // [self retrieveMessagesFromParseWithChatMateID:self.chatMateId];
    UITapGestureRecognizer *tapTableGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.historicalMessagesTableView addGestureRecognizer:tapTableGR];
    [self registerForKeyboardNotifications];
    __weak typeof(self) weakSelf = self;
    [weakSelf scrollTableToBottom];
    
    [self initNetActivity];
    
    memoryTicker = [[MemoryTicker alloc] initWithResponder:self andMethod:@selector(sizeMemory:)];
    memoryTicker.asNumber = YES;
    
    decoder = nil;
    
#if 1
    //hostTextField.text = @"rtmp://localhost:1935/live";
    //hostTextField.text = @"rtmp://[fe80::6233:4bff:fe1a:8488]:1935/live"; // ipv6
    hostTextField.text = _hostString;
    NSLog(@"%@", _hostString);
    hostTextField.delegate = self;
    
    streamTextField.text = _streamStrig;
    NSLog(@"%@", _streamStrig);
    streamTextField.delegate = self;
    
    isLive = YES;
#else
    
    //hostTextField.text = @"rtmp://localhost:1935/vod";
    hostTextField.text = @"rtmp://10.0.1.62:1935/vod";
    hostTextField.delegate = self;
    
    streamTextField.text = @"sample";
    streamTextField.delegate = self;
    
    isLive = NO;
#endif
    
    [self connectControl];
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

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#if 0
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif
#pragma mark -
#pragma mark Private Methods

// MEMORY

-(void)sizeMemory:(NSNumber *)memory {
    memoryLabel.text = [NSString stringWithFormat:@"%d", [memory intValue]];
}

// ALERT

-(void)showAlert:(NSString *)message {
    loadingView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[[UIAlertView alloc] initWithTitle:@"Receive" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    });
}

-(void)initNetActivity {
    
    // isPad fixes kind of device: iPad (YES) or iPhone (NO)
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    // Create and add the activity indicator
    netActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:isPad?UIActivityIndicatorViewStyleGray:UIActivityIndicatorViewStyleWhiteLarge];
    netActivity.center = isPad? CGPointMake(400.0f, 480.0f) : CGPointMake(160.0f, 240.0f);
    [self.view addSubview:netActivity];
}

-(void)doConnect {
    
    decoder = [[MPMediaDecoder alloc] initWithView:previewView];
    decoder.delegate = self;
    decoder.isRealTime = isLive;
    decoder.orientation = UIImageOrientationUp;
    
    [decoder setupStream:[NSString stringWithFormat:@"%@/%@", hostTextField.text, _streamStrig]];
    
    btnConnect.title = @"Disconnect";
    
    [netActivity startAnimating];
}

-(void)setDisconnect {
    
    [decoder cleanupStream];
    decoder = nil;
    
    btnConnect.title = @"Connect";
    btnPlay.title = @"Start";
    btnPlay.enabled = NO;
    
    hostTextField.hidden = NO;
    streamTextField.hidden = NO;
    
    if(!wasPlayed){
        previewView.hidden = YES;
    }else{
        finalView.hidden = NO;
        //Cobro de paypal
        
        [self cobropaypal];
        
    }
    
    [netActivity stopAnimating];
}

-(void)cobropaypal {
    PFQuery *queryReq = [PFQuery queryWithClassName:@"Requests"];
    [queryReq getObjectInBackgroundWithId:self.taskId block:^(PFObject *request, NSError *error) {
        if(request[@"price"])
            amount = request[@"price"];
        
        if(amount)
            if(seconds>=[request[@"time"] intValue]){
                //Muestro paypal
                if (_progressHUD == nil)
                {
                    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                NSURL *clientTokenURL = [NSURL URLWithString:@"http://liviapp.co/checkout.php?client_token=Zkdjs"];
                NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
                
                [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                    NSLog(@"response %@",responsestring);
                    
                    NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
                    
                    NSString *clientToken = arrayresponse[@"client_token"];
                    NSLog(@"client token %@", clientToken);
                    
                    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
                    [self tappedMyPayButton];
                    
                    
                }] resume];
            }
        
        
    }];
}

#pragma mark -
#pragma mark Public Methods

// ACTIONS

-(IBAction)connectControl:(id)sender {
    
    NSLog(@"******************************************** connectControl: host = %@", hostTextField.text);
    
    (!decoder) ? [self doConnect] : [self setDisconnect];
}

-(void)connectControl {
    (!decoder) ? [self doConnect] : [self setDisconnect];
}

-(IBAction)playControl:(id)sender; {
    
    NSLog(@"********************************************* playControl: stream = %@", streamTextField.text);
    
    (decoder.state != STREAM_PLAYING) ? [decoder resume] : [decoder pause];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self sendMessageVoid];
    return YES;
}

#pragma mark -
#pragma mark MPIMediaStreamEvent Methods

-(void)stateChanged:(id)sender state:(MPMediaStreamState)state description:(NSString *)description {
    
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> stateChangedEvent: %d = %@ [%@]", (int)state, description, [NSThread isMainThread]?@"M":@"T");
    /*
     CONN_DISCONNECTED,
     CONN_CONNECTED,
     STREAM_CREATED,
     STREAM_PLAYING,
     STREAM_PAUSED,
     */
    NSLog(@"%d", CONN_DISCONNECTED);
    NSLog(@"%d", CONN_CONNECTED);
    NSLog(@"%d", STREAM_CREATED);
    NSLog(@"%d", STREAM_PLAYING);
    NSLog(@"%d", STREAM_PAUSED);
    switch (state) {
            
        case CONN_DISCONNECTED: {
            NSLog(@"entro");
            break;
        }
        case STREAM_CREATED: {
            
            hostTextField.hidden = YES;
            streamTextField.hidden = YES;
            
            btnPlay.enabled = YES;
            
            break;
            
        }
            
        case STREAM_PAUSED: {
            
            if ([description isEqualToString:MP_NETSTREAM_PLAY_STREAM_NOT_FOUND]) {
                
                [self connectControl:nil];
                [self showAlert:description];
                
                break;
            }
            
            btnPlay.title = @"Start";
            
            break;
        }
            
        case STREAM_PLAYING: {
            loadingView.hidden = YES;
            if ([description isEqualToString:MP_RESOURCE_TEMPORARILY_UNAVAILABLE]) {
                //[self showAlert:description];
                break;
            }
            
            if ([description isEqualToString:MP_NETSTREAM_PLAY_STREAM_NOT_FOUND]) {
                loadingView.hidden = NO;
                subloadingView.hidden = NO;
                [self connectControl:nil];
                //[self showAlert:description];
                
                //reviso tiempos para saber si debo cobrar
                
                finalView.hidden = NO;
                //Cobro de paypal
                [self cobropaypal];
                
                break;
            }
            
            //Seteo bandera de q hubo streaming
            wasPlayed = YES;
            //Inicio el timer
            timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                    selector:@selector(eachSecond) userInfo:nil repeats:YES];
            
            //[MPMediaData routeAudioToSpeaker];
            
            [netActivity stopAnimating];
            previewView.hidden = (decoder.videoCodecId == MP_VIDEO_CODEC_NONE);
            
            btnPlay.title = @"Pause";
            
            break;
        }
            
        default:
            break;
    }
}

-(void)eachSecond{
    seconds++;
}

-(void)connectFailed:(id)sender code:(int)code description:(NSString *)description {
    
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> connectFailedEvent: %d = %@ [%@]", code, description, [NSThread isMainThread]?@"M":@"T");
    
    if (!decoder)
        return;
    
    [self setDisconnect];
    
    [self showAlert:(code == -1) ?
     @"Unable to connect to the server. Make sure the hostname/IP address and port number are valid" :
     [NSString stringWithFormat:@"connectFailedEvent: %@", description]];
}

-(void)metadataReceived:(id)sender event:(NSString *)event metadata:(NSDictionary *)metadata {
    NSLog(@" $$$$$$ <MPIMediaStreamEvent> dataReceived: EVENT: %@, METADATA = %@ [%@]", event, metadata, [NSThread isMainThread]?@"M":@"T");
}

-(IBAction)back:(id)sender {
    [self setDisconnect];
    [self.navigationController popViewControllerAnimated:YES];
}

// Setting up keyboard notifications.
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

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
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


- (void)scrollTableToBottom {
    int rowNumber = [self.historicalMessagesTableView numberOfRowsInSection:0];
    if (rowNumber > 0) [self.historicalMessagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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


-(void)sendMessage:(id)sender
{
    if(self.activeTextField){
        [self.activeTextField resignFirstResponder];
    }
    [self sendMessageVoid];
}

-(void)sendMessageVoid {
     
     /*Manejamos el envío de mensajes desde el controller
     1. Agregamos nuestro objeto mensaje al array y recargamos la tabla
     2. Enviamos la notificación a los usuarios del chat
     
     Nota: Este proceso se debe repetir al recibir un mensaje
     */
    if(![self.messageEditField.text isEqualToString:@""]){
        
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
    }
    
    
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

-(IBAction)chat:(id)sender{
    
    PFQuery *queryTransmisor = [PFUser query];
    [queryTransmisor getObjectInBackgroundWithId:_streamStrig block:^(PFObject *transmisor, NSError *error) {
        PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
        [queryimg whereKey:@"user" equalTo:transmisor[@"username"]];
        [queryimg orderByDescending:@"createdAt"];
        NSArray *objects = [queryimg findObjects];
        UIImage *croppedImg = nil;
        for (PFObject *imgObject in objects){
            PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
            UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
            croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
        }
        
        if(!croppedImg)
            croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InstantRequest" bundle:nil];
        ChatViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"chat"];
        viewController.myUserId = [PFUser currentUser].objectId;
        viewController.chatMateId = _streamStrig;
        viewController.chatMateFoto = croppedImg;
        viewController.taskId = self.taskId;
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }];
    
}

- (IBAction)tappedMyPayButton {
    
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc]
                                                    initWithAPIClient:self.braintreeClient];
    dropInViewController.delegate = self;
    
    /*UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancelPayment)];
    dropInViewController.navigationItem.leftBarButtonItem = item;*/
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Implement BTDropInViewControllerDelegate ...

- (void)dropInViewController:(BTDropInViewController *)viewController
  didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
    // Send payment method nonce to your server for processing
    [self postNonceToServer:paymentMethodNonce.nonce];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://liviapp.co/checkout.php?mobile=true&amount=%@", amount]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSLog(@"response %@",responsestring);
        
        NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
        
        [self hideProgressHUD];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"pendingPayment"] = self.taskId;
        if([arrayresponse[@"status"] isEqualToString:@"failed"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Livi"
                                                            message: @"Your payment was declined"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [self tappedMyPayButton];
        }else{
            currentUser[@"pendingPayment"] = @"";
            
            PFObject *transaction = [PFObject objectWithClassName:@"MyMoney"];
            transaction[@"userId"] = currentUser.objectId;
            transaction[@"paypalresponse"] = arrayresponse[@"realstatus"];
            transaction[@"taskId"] = self.taskId;
            transaction[@"value"] = amount;
            transaction[@"redeem"] = @"YES";
            
            [transaction saveInBackground];
            
            
            PFObject *transaction2 = [PFObject objectWithClassName:@"MyMoney"];
            transaction2[@"userId"] = _streamStrig;
            transaction2[@"paypalresponse"] = arrayresponse[@"realstatus"];
            transaction2[@"taskId"] = self.taskId;
            transaction2[@"value"] = amount;
            transaction2[@"earning"] = @"YES";
            
            [transaction2 saveInBackground];
            
        }
        [currentUser saveInBackground];
        
    }] resume];
}

@end
