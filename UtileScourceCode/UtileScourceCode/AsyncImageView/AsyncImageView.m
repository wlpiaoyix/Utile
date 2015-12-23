//  AsyncImageView.m
//  Created by erwin on 11/05/12.

/*
 
	Copyright (c) 2012 eMaza Mobile. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/


#import "AsyncImageView.h"
#import "PYUtile.h"
#import <QuartzCore/QuartzCore.h>
@interface AsyncImageView()

	@property (nonatomic, strong) NSURLConnection			*connection;
	@property (nonatomic, strong) NSMutableData				*data;
	@property (nonatomic, strong) UIActivityIndicatorView	*spinner;
	@property (nonatomic, strong) NSString					*filePath;
	@property (nonatomic, strong) NSString					*imageType;
    @property (nonatomic, assign) long long                    dataSize;//文件总大小
    @property (nonatomic, strong)UILabel    *lablePert;//数据加载率

	@property (nonatomic, assign) BOOL	isInResuableCell;

@end

@implementation AsyncImageView {

}

@synthesize imageId, imageUrl, imageIdKey, imageSize;
@synthesize connection, data, spinner, filePath, imageType, isInResuableCell;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}
-(void) willMoveToSuperview:(UIView *)newSuperview{
    
    if(self.sizeEstimate.width==0&&self.sizeEstimate.height==0){
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.frame = self.frame;
        spinner.center = self.center;
    }else{
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGPoint p =  self.center;
        p.x = self.sizeEstimate.width/2-spinner.frame.size.width/2;
        p.y = self.sizeEstimate.height/2-spinner.frame.size.height/2;
        spinner.center = p;
        CGRect r = spinner.frame;
        r.origin = p;
        spinner.frame = r;
        self.lablePert = [[UILabel alloc]init];
        UIFont *f = [UIFont fontWithName:self.lablePert.font.fontName size:8];
        self.lablePert.font = f;
        self.lablePert.textAlignment = NSTextAlignmentCenter;
        self.lablePert.frame = CGRectMake((r.size.width-20)/2, (r.size.height-10)/2, 20, 10);
        self.lablePert.text = @"0%";
        self.lablePert.textColor = [UIColor whiteColor];
        self.lablePert.backgroundColor = [UIColor clearColor];
        [self.spinner addSubview:self.lablePert];
    }
	spinner.hidesWhenStopped = TRUE;
    [super willMoveToSuperview:newSuperview];
}

- (void)setup {
	self.imageType = @"";
	self.imageSize = AsyncImageSizeLarge;
	self.clipsToBounds = TRUE;
}

- (void)setImageSize:(int)aSize {
	self.filePath = nil;
	imageSize = aSize;
}

- (void)setImageId:(NSString *)anId {
	
	imageId = anId;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if (!self.isIgnoreCacheFile&&[fm fileExistsAtPath:[self filePath]]) {
		// if we know the image extention, and we're not resuing the imageview in a cell, take advantage of iOS image caching
		if ([imageType length] && !isInResuableCell) {
			self.image = [[UIImage alloc] initWithContentsOfFile:[self filePath]];
        } else {
            if (rid) {
                UIImage *image = rid([NSMutableData dataWithContentsOfFile:[self filePath]]);
                if (image) {
                    self.image = image;
                }else{
                    self.image = [UIImage imageWithContentsOfFile:[self filePath]];
                }
            }else{
                self.image = [UIImage imageWithContentsOfFile:[self filePath]];
            }
		}
        //如果图片无效就是下载新的图片
        if(!self.image||self.image==nil||![self.image isKindOfClass:[UIImage class]]){
            [self downloadImage];
        }else{
            
            //setNeedsDisplay方便绘图，而layoutSubViews方便出来数据
            [self setNeedsDisplay];
        }
	} else {
		[self downloadImage];
	}
}

- (void)setImageUrl:(NSString *)url {
    if (self.spinner) {
        [self.spinner removeFromSuperview];
    }
    [connection cancel];
    if(!url && !url.length){
        return;
    }
    self.isInResuableCell = TRUE;
    imageId = nil;
    imageUrl = nil;
    self.filePath = nil;
    self.image = nil;

	imageUrl = url;
	
	NSArray *urlParts = [url componentsSeparatedByString:@"?"];
	
	if ([urlParts count] < 2) {
		[self processFullPathURL];
	} else {
		[self processQueryURL:[urlParts objectAtIndex:1]];
	}
}

- (void)processFullPathURL {
	NSArray *pathParts = [imageUrl componentsSeparatedByString:@"/"];
	NSString *filePart = [pathParts lastObject];//图片文件名
	NSArray *fileParts = [filePart componentsSeparatedByString:@"."];
	
	if ([fileParts count] == 2) {
		self.imageType = [fileParts objectAtIndex:1];
	}

	self.imageId = [fileParts objectAtIndex:0];
}

- (void)processQueryURL:(NSString*)query {
	// if the imageIdKey was not supplied, we can try a generic "imageId" key
	if (!imageIdKey || [imageIdKey length] == 0) {
		self.imageIdKey = defaultImageIdKey;
	}
	
	NSArray *queryParts = [query componentsSeparatedByString:@"&"];
	for (NSString *param in queryParts) {
		if ([param hasPrefix:[NSString stringWithFormat:@"%@=", imageIdKey]]) {
			NSArray *paramParts = [param componentsSeparatedByString:@"="];
			if ([paramParts count] == 2) {
				self.imageId = [paramParts objectAtIndex:1];
			}
		}
	}

	// couldn't generate an imageId, so can't cache, so download every time
	if (!imageId) {
		[self downloadImage];
	}
}

- (void)downloadImage {
    if(!imageUrl||imageUrl==nil)return;
	[self.superview addSubview:spinner];
	[spinner startAnimating];

	self.data = [NSMutableData data];
	NSURL *url = [NSURL URLWithString:imageUrl];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.dataSize  = response.expectedContentLength;//获取文件大小
}

- (void)connection:(NSURLConnection *)theConnection	didReceiveData:(NSData *)incrementalData {
    if (!data) self.data = [NSMutableData data];
    [data appendData:incrementalData];
    if(!self.lablePert)return;
    unsigned int bb = ((unsigned int)(data.length*100)/self.dataSize);
    self.lablePert.text = [NSString stringWithFormat:@"%d%%",bb];
    
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [self.spinner stopAnimating];
    if(!self.ifshowErroAlert){
        return;
    }
//	NSString *url = theConnection.currentRequest.URL.absoluteString;
	NSString *msg = @"网速不佳,没有获取到图片信息!";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Download Error" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	[spinner stopAnimating];
	self.connection = nil;
    if ([theConnection.currentRequest.URL.absoluteString isEqualToString:imageUrl]) {
        //如果可以缓存
        if (!self.isIgnoreCacheFile&&imageId) {
            [data writeToFile:[self filePath] atomically:TRUE];
        }

        if (rid) {
            UIImage *image = rid(data);
            if (image) {
                self.image = image;
            }else{
                self.image = [UIImage imageWithData:data];
            }
        }else{
            self.image = [UIImage imageWithData:data];
        }
        
        CGSize size = self.image.size;
		[self setNeedsLayout];
        if (ris) {
            ris(size);
        }
           
	}

	self.data = nil;
}

-(void) returnImageSize:(CallBackReturnImageSize) _ris{
    ris = _ris;
}
-(void) returnImageData:(CallBackReturnImageData) _rid{
    rid = _rid;
}
- (NSString*)fileName {

	if (!imageId) return @"";
	if (imageSize == AsyncImageSizeThumbnail) return [NSString stringWithFormat:@"thumb_%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];
	if (imageSize == AsyncImageSizeRegular)	return [NSString stringWithFormat:@"small_%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];
	if (imageSize == AsyncImageSizeLarge)		return [NSString stringWithFormat:@"%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];

	return @"";
}

- (NSString*)filePath {
    if (!filePath) {
        static NSString *imageCachesDir = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imageCachesDir = [cachesDir stringByAppendingString:@"/image/"] ;
        });
        self.filePath = [imageCachesDir stringByAppendingString:[self fileName]];
    }
	return filePath;
}

- (void)dealloc {
    [connection cancel];
}

@end
