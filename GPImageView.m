//
//  GPImageView.m
//
//  Created by Gaurav D. Sharma & Piyush Kashyap
//  Date 11/06/12.
//

#import "GPImageView.h"
#define TMP NSTemporaryDirectory()

@implementation GPImageView

@synthesize isCacheImage, showActivityIndicator;

@synthesize defaultImage;

- (NSString*)getUniquePath:(NSString*)  urlStr
{
    NSMutableString *tempImgUrlStr = [NSMutableString stringWithString:[urlStr substringFromIndex:7]];
    
    [tempImgUrlStr replaceOccurrencesOfString:@"/" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempImgUrlStr length])];
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [NSString stringWithFormat:@"%@",tempImgUrlStr] ;   
    
    // [[something unique, perhaps the image name]];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    return uniquePath;
}

- (void)setImageFromURL:(NSString*)url
{
    [self setImageFromURL:url 
    showActivityIndicator:showActivityIndicator 
            setCacheImage:isCacheImage];
}


- (void)setImageFromURL:(NSString*)url 
  showActivityIndicator:(BOOL)isActivityIndicator
          setCacheImage:(BOOL)cacheImage
{
    
    imageURL = [self getUniquePath:url];
    
    showActivityIndicator = isActivityIndicator;
    
    isCacheImage = cacheImage;
    
	if (isCacheImage && [[NSFileManager defaultManager] fileExistsAtPath:imageURL])
    {
        /* --- Set Cached Image --- */
        imageData = [[NSMutableData alloc] initWithContentsOfFile:imageURL];
        
		[self setImage:[[UIImage alloc] initWithData:imageData]];
        
    }
    /* --- Download Image from URL --- */
	else 
	{
        if (showActivityIndicator) {
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            activityIndicator.tag = 786;
            
            [activityIndicator startAnimating];
            
            [activityIndicator setHidesWhenStopped:YES];
            
            CGRect myRect = self.frame;
            
            CGRect newRect = CGRectMake(myRect.size.width/2 -12.5f,myRect.size.height/2 - 12.5f, 25, 25);
            
            [activityIndicator setFrame:newRect];
            
            [self addSubview:activityIndicator];
            
        }
        
        /* --- set Default image Until Image will not load --- */
        if (defaultImage) {
            [self setImage:defaultImage];
        }
        
        /* --- Switch to main thread If not in main thread URLConnection wont work --- */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            imageURL = url;
            
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            
            NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:req
                                                                   delegate:self
                                                           startImmediately:NO];
            
            [con scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
            
            [con start];
            
            if (con) {
                imageData = [NSMutableData new];
            }   
            else {
                NSLog(@"GPImageView Image Connection is NULL");
            }
        });
	}
    
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    [imageData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error 
{
    NSLog(@"Error downloading");
    
    imageData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    /* --- hide activity indicator --- */
    if (showActivityIndicator) 
    {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[self viewWithTag:786];
        
        [activityIndicator stopAnimating];
        
        [activityIndicator removeFromSuperview];
    }
    
    /* --- set Image Data --- */
    [self setImage:[UIImage imageWithData:imageData]];
    
    /* --- Get Cache Image --- */
    if (isCacheImage) {
        [imageData writeToFile:[self getUniquePath:imageURL] 
                    atomically:YES];
    }
    
    imageData = nil;
	
}						   

@end
