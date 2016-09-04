#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>
{
    NSString *title;
    NSString *subtitle;
    NSString *proImage;
    
    CLLocationCoordinate2D coordinate;
}
@property ( nonatomic, copy) NSString *title;
@property ( nonatomic, copy) NSString *subtitle;
@property ( nonatomic, copy) NSString *proImage;
@property ( nonatomic, copy) NSString *urlStreamIos;
@property ( nonatomic, copy) NSString *urlStream;
@property ( nonatomic, copy) NSString *rtmpStream;
@property ( nonatomic, copy) NSString *pv;
//@property ( nonatomic, copy) NSString *stars;

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString*)strTitle andSubtitle:(NSString *)strSubtitle andImage:(NSString *)proImg andUrlIos:(NSString *)urlIos andUrlOther:(NSString *)urlOther andUrlStream:(NSString *)urlStream andCoordinate:(CLLocationCoordinate2D)coord andPV:(NSString *)pv;

@end