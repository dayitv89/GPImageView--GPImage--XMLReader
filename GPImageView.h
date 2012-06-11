//
//  GPImageView.h
//
//  Created by Gaurav D. Sharma & Piyush Kashyap
//  Date 11/06/12.
//

#import <UIKit/UIKit.h>

@interface GPImageView : UIImageView
{
    NSMutableData *imageData;
    
    NSString *imageURL;
    
}
@property (nonatomic) BOOL isCacheImage, showActivityIndicator;

@property (nonatomic, strong) UIImage *defaultImage;

/* --- Img from URL --- */
- (NSString*)getUniquePath:(NSString*)urlStr;

- (void)setImageFromURL:(NSString*)url;

- (void)setImageFromURL:(NSString*)url 
  showActivityIndicator:(BOOL)isActivityIndicator
          setCacheImage:(BOOL)cacheImage;

@end
