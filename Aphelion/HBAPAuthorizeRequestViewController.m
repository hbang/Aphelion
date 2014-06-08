//
//  HBAPAuthorizeRequestViewController.m
//  Aphelion
//
//  Created by Adam D on 7/06/2014.
//  Copyright (c) 2014 HASHBANG Productions. All rights reserved.
//

#import "HBAPAuthorizeRequestViewController.h"

@interface HBAPAuthorizeRequestViewController () {
	void (^_completion)();
}

@end

@implementation HBAPAuthorizeRequestViewController

- (instancetype)initWithCompletion:(void(^)())completion {
	self = [super init];
	
	if (self) {
		_completion = [completion copy];
	}
	
	return self;
}

- (void)loadView {
	[super loadView];

	self.title = L18N(@"Please Authorize Aphelion");
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:self.view.bounds] autorelease];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.delegate = self;
	textView.editable = NO;
	textView.textContainerInset = UIEdgeInsetsMake(13.f, 15.f, 13.f, 15.f);
	textView.textContainer.lineFragmentPadding = 0;
	textView.attributedText = [[[NSAttributedString alloc] initWithFileURL:[[NSBundle mainBundle] URLForResource:@"authorize_request" withExtension:@"rtfd"] options:@{
		NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType
	} documentAttributes:nil error:nil] autorelease];
	[self.view addSubview:textView];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange {
	if ([url.scheme isEqualToString:@"ws.hbang.aphelion"] && [url.host isEqualToString:@"_authorize_request_done"]) {
		[self.navigationController dismissViewControllerAnimated:YES completion:^{
			if (_completion) {
				_completion();
			}
		}];
	}
	
	return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
	return NO;
}

@end
