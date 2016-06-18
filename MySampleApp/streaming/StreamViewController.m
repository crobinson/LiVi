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

@interface StreamViewController () <VCSessionDelegate> {
    
}
@property (nonatomic, retain) VCSimpleSession* session;

@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen rect:%@", NSStringFromCGRect(rect));
    [[NSUserDefaults standardUserDefaults] setValue:@"name_preference" forKey:@"test"];
    
    
    _session = [[VCSimpleSession alloc] initWithVideoSize:rect.size frameRate:30 bitrate:1000000 useInterfaceOrientation:YES];
    //    _session.orientationLocked = YES;
    [self.previewView addSubview:_session.previewView];
    _session.previewView.frame = self.previewView.bounds;
    _session.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [user save];
            
            _btnConnect.hidden = YES;
            PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
            [query selectKeys:@[@"userId"]];
        }
            break;
        default:
            [_session endRtmpSession];
            break;
    }
    
    UIButton *btnTemporal = (UIButton *)sender;
    if(btnTemporal.tag==100){
        PFUser *user = [PFUser currentUser];
        user[@"urlStreamIos"] = @""; // attempt to change username
        user[@"urlStream"] = @"";
        [user save];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Views"];
        [query selectKeys:@[@"ownerId"]];
        
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" matchesQuery: query];
        //[query getObjectWithId:];
        NSLog(@"%@", userQuery);
        PFQuery *pushQuery = [PFInstallation query];
        //[pushQuery whereKey:@"user" equalTo:userAgain];
        [pushQuery whereKey:@"user" matchesQuery: userQuery];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:@"Live Stream Finished"];
        [push sendPushInBackground];
        
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

@end
