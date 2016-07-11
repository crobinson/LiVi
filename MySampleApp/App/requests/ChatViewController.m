//
//  ChatViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/16/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController () {
    IBOutlet UILabel *referencia;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *messageEditField;

@property (strong, nonatomic) IBOutlet UITableView *historicalMessagesTableView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messageArray = [[NSMutableArray alloc] init];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"];
    _myUserFoto = [UIImage imageWithData:imageData];
    self.historicalMessagesTableView.rowHeight = UITableViewAutomaticDimension;
    [self retrieveMessagesFromParseWithChatMateID:self.chatMateId];
    UITapGestureRecognizer *tapTableGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.historicalMessagesTableView addGestureRecognizer:tapTableGR];
    [self registerForKeyboardNotifications];
}

- (void)didTapOnTableView {
    [self.activeTextField resignFirstResponder];
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(kbSize.height, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
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
    [self sendMessageVoid];
    return YES;
}



- (void)messageDelivered:(NSNotification *)notification
{
    //MNCChatMessage *chatMessage = [[notification userInfo] objectForKey:@"message"];
    //[self.messageArray addObject:chatMessage];
    //[self.historicalMessagesTableView reloadData];
    //[self scrollTableToBottom];
}

-(void)sendMessageVoid {
    /*
     [self.messageArray addObject:chatMessage];
     [self.historicalMessagesTableView reloadData];
     [self scrollTableToBottom];
     
     Manejamos el envío de mensajes desde el controller
     1. Agregamos nuestro objeto mensaje al array y recargamos la tabla
     2. Creamos el mensaje en Parse
     3. Enviamos la notificación al usuario
     
     Nota: Este proceso se debe repetir al recibir un mensaje
     */
    if(![self.messageEditField.text isEqualToString:@""]){
        _chatMessage = [PFObject objectWithClassName:@"TaskMessage"];
        _chatMessage[@"senderId"] = _myUserId;
        _chatMessage[@"recipientId"] = _chatMateId;
        _chatMessage[@"taskId"] = _taskId;
        _chatMessage[@"text"] = self.messageEditField.text;
        
        if(!_notification){
            PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
            [query whereKey:@"from" equalTo:_myUserId];
            [query whereKey:@"taskId" equalTo:_taskId];
            [query whereKey:@"to" equalTo:_chatMateId];
            [query whereKey:@"alert" equalTo:@"Message Received"];
            [query orderByAscending:@"timestamp"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *notificationArray, NSError *error) {
                if (!error) {
                    NSLog(@"%@", notificationArray);
                    if(notificationArray.count<1){
                        _notification = [PFObject objectWithClassName:@"Notifications"];
                        _notification[@"from"]  = _myUserId;
                        _notification[@"to"]    = _chatMateId;
                        _notification[@"type"]    = @"message";
                        _notification[@"title"] = [NSString stringWithFormat:@"%@ %@", [PFUser currentUser][@"firstname"], [PFUser currentUser][@"lastname"]];
                        _notification[@"alert"] = @"Message Received";
                        _notification[@"taskId"] = _taskId;
                        [_notification save];
                    }
                    
                } else {
                    NSLog(@"Error: %@", error.description);
                }
            }];
        }
        
        [_chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 PFQuery *userQuery = [PFUser query];
                 [userQuery whereKey:@"objectId" equalTo:_chatMateId];
                 
                 PFQuery *pushQuery = [PFInstallation query];
                 [pushQuery whereKey:@"user" matchesQuery: userQuery];
                 
                 // Send push notification to query
                 NSDictionary *data = @{
                                        @"alert" : @"You have received a Message",
                                        @"name" : @"TaskMessage",
                                        @"senderId" : _myUserId,
                                        @"recipientId" : _chatMateId,
                                        @"text" : _chatMessage[@"text"],
                                        @"taskId" : _chatMessage.objectId
                                        };
                 PFPush *push = [[PFPush alloc] init];
                 [push setQuery:pushQuery]; // Set our Installation query
                 //[push setMessage:@"Live Stream Finished"];
                 [push setData:data];
                 [push sendPushInBackground];
                 
             }
             
         }];
        
        self.messageEditField.text = @"";
        [self.messageArray addObject:_chatMessage];
        [self.historicalMessagesTableView reloadData];
        [self scrollTableToBottom];
    }
    
    
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    _chatMessage[@"recipientId"] = userInfo[@"recipientId"];
    _chatMessage[@"taskId"] = userInfo[@"taskId"];
    _chatMessage[@"text"] = userInfo[@"text"];
    
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
    textolabel=[[UILabel alloc]initWithFrame:CGRectMake(85, 30, self.view.frame.size.width - 90, 75)];
    textolabel.font=referencia.font;
    textolabel.numberOfLines=0;
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 78, FLT_MAX);
    CGSize expectedLabelSize = [texto sizeWithFont:textolabel.font constrainedToSize:maximumLabelSize lineBreakMode:textolabel.lineBreakMode];
    
    if(expectedLabelSize.height+10<70)
        return 110;
    
    return expectedLabelSize.height+60;
    
    
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
    
    UILabel *textolabel;
    textolabel.text = chatMessage[@"text"];
    NSString *texto = chatMessage[@"text"];
    textolabel=[[UILabel alloc]initWithFrame:CGRectMake(85, 30, self.view.frame.size.width - 90, 75)];
    textolabel.font=messageCell.chatMateMessageLabel.font;
    textolabel.numberOfLines=0;
    messageCell.chatMateMessageLabel.numberOfLines = 0;
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 78, FLT_MAX);
    CGSize expectedLabelSize = [texto sizeWithFont:textolabel.font constrainedToSize:maximumLabelSize lineBreakMode:textolabel.lineBreakMode];
    
    
    
    CGRect newFrame = textolabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    messageCell.chatMateMessageLabel.frame = newFrame;
    messageCell.chatMateMessageLabel.text = chatMessage[@"text"];
    
    
    UIView *viewLabel = [[UIView alloc] initWithFrame:CGRectMake(78, 20, self.view.frame.size.width - 78, newFrame.size.height + 10)];
    viewLabel.layer.masksToBounds = YES;
    [viewLabel.layer setCornerRadius:15.0f];
    
    if ([chatMessage[@"senderId"] isEqualToString:self.myUserId]) {
        // If the message was sent by myself
        messageCell.foto.image = _myUserFoto;
        viewLabel.backgroundColor = [UIColor colorWithRed:54.0/255 green:121.0/255 blue:189.0/255 alpha:1];
    } else {
        // If the message was sent by the chat mate
        messageCell.foto.image = _chatMateFoto;
        viewLabel.backgroundColor = [UIColor colorWithRed:84.0/255 green:196.0/255 blue:238.0/255 alpha:1];
    }
    
    UILabel *NombreLabel;
    
    if(expectedLabelSize.height+10<70)
        viewLabel.frame = CGRectMake(78, 25, self.view.frame.size.width - 78, 75);
    else
        viewLabel.frame = CGRectMake(78, 25, self.view.frame.size.width - 78, expectedLabelSize.height+20);
    
    NombreLabel=[[UILabel alloc]initWithFrame:CGRectMake(viewLabel.frame.origin.x+10, (viewLabel.frame.size.height - textolabel.frame.size.height)/2, textolabel.frame.size.width, textolabel.frame.size.height)];
    NombreLabel.font=messageCell.chatMateMessageLabel.font;
    NombreLabel.textColor = [UIColor whiteColor];
    NombreLabel.text = messageCell.chatMateMessageLabel.text;
    NombreLabel.numberOfLines=0;
    NombreLabel.frame=CGRectMake(textolabel.frame.origin.x, textolabel.frame.origin.y, textolabel.frame.size.width, textolabel.frame.size.height);
    [messageCell.contentView addSubview:viewLabel];
    [messageCell.contentView addSubview:NombreLabel];
    return messageCell;
}


#pragma mark Method to configure the appearance of a message list prototype cell

- (void)configureCell:(MNCChatMessageCell *)messageCell forIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (void)retrieveMessagesFromParseWithChatMateID:(NSString *)chatMateId {
    NSArray *userNames = @[self.myUserId, chatMateId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"TaskMessage"];
    [query whereKey:@"senderId" containedIn:userNames];
    [query whereKey:@"recipientId" containedIn:userNames];
    [query orderByAscending:@"timestamp"];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *chatMessageArray, NSError *error) {
        if (!error) {
            // Store all retrieve messages into historicalMessagesArray
            for (PFObject *object in chatMessageArray){
                [weakSelf.messageArray addObject:object];
            }
            [weakSelf.historicalMessagesTableView reloadData];  // Refresh the table view
            [weakSelf scrollTableToBottom];  // Scroll to the bottom of the table view
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
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
