
#import <QuartzCore/QuartzCore.h>
#include <AR/ar.h>
#include <AR/video.h>
#include <AR/gsub_es2.h>
#import <AR/sys/CameraVideo.h>
#import "EAGLView.h"

@class ARView;
@interface ARViewController : UIViewController <CameraVideoTookPictureDelegate, EAGLViewTookSnapshotDelegate> {
}

- (IBAction)start;
- (IBAction)stop;
- (void) processFrame:(AR2VideoBufferT *)buffer;

- (void)takeSnapshot;

@property (readonly) ARView *glView;
@property (readonly) ARGL_CONTEXT_SETTINGS_REF arglContextSettings;

@property (readonly, nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isPaused) BOOL paused;

@property (nonatomic) NSInteger runLoopInterval;

@property (nonatomic) BOOL markersHaveWhiteBorders;

@end
