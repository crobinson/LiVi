//
//  LiviViewController.h
//  Livi
//
//  Created by Carlos Robinson on 4/21/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiviViewController : UIViewController<UIWebViewDelegate>
@property ( nonatomic, copy) NSString *urlString;
@property ( nonatomic, copy) NSString *objectId;

@end
