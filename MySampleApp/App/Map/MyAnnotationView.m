#import "MyAnnotationView.h"
#import "MyAnnotation.h"
#import "callOutView.h"

@implementation MyAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        
        
        
       /* self.buttonCustomeCallOut = [UIButton buttonWithType:UIButtonTypeCustom];//iconShare//iconShareBlue
        
        [self.buttonCustomeCallOut addTarget:self action:@selector(buttonHandlerCallOut:) forControlEvents:UIControlEventTouchDown];
        [self.buttonCustomeCallOut setBackgroundColor:[UIColor blueColor]];
        
        [self.buttonCustomeCallOut setFrame:CGRectMake(-40,-80, 100, 100)];
        
        
        
        [self addSubview:self.buttonCustomeCallOut];
        
        [self.buttonCustomeCallOut setUserInteractionEnabled:YES];*/
    }
    else
    {
        //Remove your custom view...
        /*[self.buttonCustomeCallOut setUserInteractionEnabled:NO];
        [self.buttonCustomeCallOut removeFromSuperview];
        
        self.buttonCustomeCallOut=nil;*/
    }
}

@end