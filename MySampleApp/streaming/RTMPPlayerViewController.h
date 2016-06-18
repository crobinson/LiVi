//
//  RTMPPlayerViewController.h
//  Livi
//
//  Created by Carlos Robinson on 5/15/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTMPPlayerViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIImageView     *previewView;
    IBOutlet UIView          *loadingView;
    IBOutlet UIBarButtonItem *btnConnect;
    IBOutlet UIBarButtonItem *btnPlay;
    IBOutlet UILabel         *memoryLabel;
    IBOutlet UITextField     *hostTextField;
    IBOutlet UITextField     *streamTextField;
}
@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *hostString;
@property (nonatomic, copy) NSString *streamStrig;

-(IBAction)connectControl:(id)sender;
-(IBAction)playControl:(id)sender;


@end
