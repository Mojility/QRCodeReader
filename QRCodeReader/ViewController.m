//
//  ViewController.m
//  QRCodeReader
//
//  Created by Stacey Vetzal on 15-05-18.
//  Copyright (c) 2015 Mojility Inc. All rights reserved.
//

@import AVFoundation;
#import "ViewController.h"


@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.captureSession = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self startReading];
}

#pragma mark - ui events

- (IBAction)toggleActive:(id)sender {
    if (!self.captureSession) {
        [self startReading];
    } else {
        [self stopReading];
    }
}

- (BOOL)startReading {
    NSError *error;

    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

    if (input) {
        [self setUpCaptureSession:input];
        [self setUpMetadataCapture];
        [self setUpPreviewLayer];
        [self layoutVideoPreview];

        [self.captureSession startRunning];

        self.startButton.title = @"Stop";

        return YES;
    } else {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
}

- (void)stopReading {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.startButton.title = @"Start";

    [self.videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - setup methods

- (void)setUpCaptureSession:(AVCaptureDeviceInput *)input {
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
}

- (void)setUpMetadataCapture {
    AVCaptureMetadataOutput *captureMetadataOutput1 = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput1];
    AVCaptureMetadataOutput *captureMetadataOutput = captureMetadataOutput1;
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("myQueue", NULL)];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
}

- (void)setUpPreviewLayer {
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.videoPreviewLayer];
}

#pragma mark ui events

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutVideoPreview];
    } completion:nil];
}

- (void)layoutVideoPreview {
    self.videoPreviewLayer.frame = self.previewView.layer.bounds;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation orientation = [self AVCaptureVideoOrientationForUIInterfaceOrientation:interfaceOrientation];
    [self.videoPreviewLayer.connection setVideoOrientation:orientation];
}

// Have to do this awkward thing to translate between UI orientation and the camera orientation
- (AVCaptureVideoOrientation)AVCaptureVideoOrientationForUIInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown: return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft: return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight: return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationUnknown: return AVCaptureVideoOrientationPortrait;
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] != 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObject stringValue] waitUntilDone:NO];
        }
    }
}

@end