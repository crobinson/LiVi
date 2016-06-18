#import "callOutView.h"

@implementation callOutView
@synthesize lblName,lblLastSeen,imgViewProfile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)addrequest:(id)sender
{
    NSLog(@"requested");
}


@end