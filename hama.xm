
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <mach-o/getsect.h>
#import <mach-o/loader.h>
#import <dlfcn.h>

static UIView *badgeView = nil;
static AVSpeechSynthesizer *sonicSpeech = nil;

static UIImage *loadHAMAImage(void) {
    Dl_info info;

    if (dladdr((void *)&loadHAMAImage, &info) == 0)
        return nil;

    unsigned long imageSize = 0;

    const struct mach_header_64 *header =
        (const struct mach_header_64 *)info.dli_fbase;

    const uint8_t *imageBytes = getsectiondata(
        header,
        "__DATA",
        "__hama_image",
        &imageSize
    );

    if (!imageBytes || imageSize == 0)
        return nil;

    NSData *imageData =
        [NSData dataWithBytes:imageBytes length:imageSize];

    return [UIImage imageWithData:imageData];
}

static void showOfficialBadge(void);

// HAMA INTRO
static void showSonicIntro(void) {

    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;

    if (!mainWindow) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        if (windows.count > 0) {
            mainWindow = windows[0];
        }
    }

    if (!mainWindow) return;

    UIImage *image = loadHAMAImage();
    if (!image) return;

    UIView *introView = [[UIView alloc] initWithFrame:mainWindow.bounds];
    introView.backgroundColor = [UIColor clearColor];
    introView.alpha = 0;
    introView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;

    UIImageView *imageView =
        [[UIImageView alloc] initWithImage:image];

    imageView.frame = CGRectMake(0, 0, 220, 220);

    imageView.center = CGPointMake(
        introView.bounds.size.width / 2,
        introView.bounds.size.height / 2
    );

    imageView.contentMode = UIViewContentModeScaleAspectFit;

    imageView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;

    [introView addSubview:imageView];

    [mainWindow addSubview:introView];

    // Welcome voice
    sonicSpeech = [[AVSpeechSynthesizer alloc] init];

    AVSpeechUtterance *utterance =
        [AVSpeechUtterance speechUtteranceWithString:@"Welcome to HAMA VIP"];

    utterance.voice =
        [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];

    utterance.rate = 0.48;
    utterance.pitchMultiplier = 1.0;

    [sonicSpeech speakUtterance:utterance];

    // Intro entrance
    [UIView animateWithDuration:0.7 animations:^{
        introView.alpha = 1.0;
    }];

    // Fade out after 3 seconds
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
        dispatch_get_main_queue(), ^{

            [UIView animateWithDuration:1.0 animations:^{
                introView.alpha = 0;
            } completion:^(BOOL finished) {

                [introView removeFromSuperview];

                showOfficialBadge();
            }];
        }
    );
}

// ORIGINAL BADGE - IMAGE ONLY
static void showOfficialBadge(void) {

    if (badgeView) return;

    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;

    if (!mainWindow) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        if (windows.count > 0) {
            mainWindow = windows[0];
        }
    }

    if (!mainWindow) return;

    UIImage *image = loadHAMAImage();
    if (!image) return;

    UIImageView *imageView =
        [[UIImageView alloc] initWithImage:image];

    imageView.frame = CGRectMake(0, 0, 90, 90);
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    CGFloat centerX = mainWindow.bounds.size.width / 2;
    CGFloat topY = 75;

    imageView.center = CGPointMake(centerX, topY);

    imageView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;

    [mainWindow addSubview:imageView];
    badgeView = imageView;

    // Entrance animation
    imageView.alpha = 0;
    imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);

    [UIView animateWithDuration:0.3 animations:^{
        imageView.alpha = 1;
        imageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {

        // Slow up and down movement
        [UIView animateWithDuration:1.8
                              delay:0
                            options:UIViewAnimationOptionAutoreverse |
                                    UIViewAnimationOptionRepeat |
                                    UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            imageView.transform =
                CGAffineTransformMakeTranslation(0, 7);
        } completion:nil];
    }];
}

// Constructor
%ctor {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC),
        dispatch_get_main_queue(), ^{
            showSonicIntro();
        }
    );
}
