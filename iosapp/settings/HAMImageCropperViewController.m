//
//  HAMImageCropperViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-28.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMImageCropperViewController.h"

@interface HAMImageCropperViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation HAMImageCropperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	// draw blank areas on the image to make its ratio 4:3
	if (self.image.size.height < self.image.size.width) {
		CGSize newSize;
		newSize.width = self.image.size.width;
		newSize.height = self.image.size.width * 4 / 3;
		
		UIGraphicsBeginImageContext(newSize);
		CGContextRef context = UIGraphicsGetCurrentContext();
		UIGraphicsPushContext(context);
				
		CGPoint newOrigin;
		newOrigin.x = 0;
		newOrigin.y = (newSize.height - self.image.size.height) / 2;
		
		[self.image drawInRect:(CGRect){newOrigin, self.image.size}];
		
		UIGraphicsPopContext();
		
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		self.image = newImage;
	}
	
	self.imageView.image = self.image;
	self.scrollView.contentSize = self.imageView.frame.size;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonPressed:(id)sender {
	CGFloat scale = self.image.size.width / self.scrollView.frame.size.width / self.scrollView.zoomScale;
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	CGRect rect;
	rect.origin.x = self.scrollView.contentOffset.x * scale;
	rect.origin.y = (self.scrollView.contentOffset.y + self.topCoverView.frame.size.height)* scale;
	rect.size.width = self.scrollView.frame.size.width * scale;
	rect.size.height = screenSize.width * 3/4 * scale;
	
	CGRect transformedRect;
	if (self.image.imageOrientation == UIImageOrientationUp) {
		transformedRect = rect;
	}
	else if (self.image.imageOrientation == UIImageOrientationRight) {
		transformedRect.origin.x = rect.origin.y;
		transformedRect.origin.y = self.image.size.width - (rect.origin.x + rect.size.width);
		transformedRect.size.width = rect.size.height;
		transformedRect.size.height = rect.size.width;
	}
	else if (self.image.imageOrientation == UIImageOrientationDown) {
		transformedRect.origin.x = self.image.size.width - (rect.origin.x + rect.size.width);
		transformedRect.origin.y = self.image.size.height - (rect.origin.y + rect.size.height);
		transformedRect.size = rect.size;
	}
	else if (self.image.imageOrientation == UIImageOrientationLeft) {
		transformedRect.origin.x = self.image.size.width - (rect.origin.y + rect.size.height);
		transformedRect.origin.y = rect.origin.x;
		transformedRect.size.width = rect.size.height;
		transformedRect.size.height = rect.size.width;
	}
	
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, transformedRect);
	UIImage *croppedImage = [[UIImage alloc] initWithCGImage:imageRef scale:1.0 orientation:self.image.imageOrientation];
	[self.delegate imageCropper:self didFinishCroppingWithImage:croppedImage];
	
	// FIXME: this method is evil
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
