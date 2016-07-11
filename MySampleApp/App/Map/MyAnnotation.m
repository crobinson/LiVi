#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize title,subtitle,proImage,urlStreamIos,urlStream, rtmpStream;
@synthesize coordinate;


- (id)initWithTitle:(NSString*)strTitle andSubtitle:(NSString *)strSubtitle andImage:(UIImage *)proImg andUrlIos:(NSString *)urlIos andUrlOther:(NSString *)urlOther andUrlStream:(NSString *)urlRTMP andCoordinate:(CLLocationCoordinate2D)coord
{
    
    if (self = [super init]) {
        self.title = strTitle;//[strTitle copy];
        self.subtitle=strSubtitle;
        self.proImage=proImg;
        self.urlStreamIos = urlIos;
        self.urlStream = urlOther;
        self.rtmpStream = urlRTMP;
        self.coordinate = coord;
    }
    return self;
}
-(CLLocationCoordinate2D)coord
{
    return coordinate;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
    
}

@end