//
// Created by wangyang on 2017/3/15.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import "ARNFTMarkerDetector.h"
#include <AR/ar.h>
#include <AR/video.h>
#import "ARMarkerNFT.h"
#import "trackingSub.h"
#include <AR2/tracking.h>

#define PAGES_MAX 10

@interface ARNFTMarkerDetector () {

    THREAD_HANDLE_T     *threadHandle;
    AR2HandleT          *ar2Handle;
    KpmHandle           *kpmHandle;
    AR2SurfaceSetT      *surfaceSet[PAGES_MAX];

    int detectedPage;
    float trackingTrans[3][4];

    NSArray *markers;
}
@end

@implementation ARNFTMarkerDetector
- (instancetype)init {
    self = [super init];
    if (self) {
        detectedPage = -2;
    }
    return self;
}

- (CGSize)size {
    return CGSizeMake(ar2Handle->xsize, ar2Handle->ysize);
}

- (bool)setupWith:(ARParamLT *)paramLT pixelFormat:(AR_PIXEL_FORMAT)pixelFormat {
    kpmHandle = kpmCreateHandle(paramLT);
    if (!kpmHandle) {
        NSLog(@"Error: kpmCreateHandle.\n");
        return NO;
    }

    if (!(ar2Handle = ar2CreateHandle(paramLT, pixelFormat, AR2_TRACKING_DEFAULT_THREAD_NUM))) {
        NSLog(@"Error: ar2CreateHandle.\n");
        return NO;
    }

    if (threadGetCPU() <= 1) {
#ifdef DEBUG
        NSLog(@"Using NFT tracking settings for a single CPU.");
#endif
        ar2SetTrackingThresh(ar2Handle, 5.0);
        ar2SetSimThresh(ar2Handle, 0.50);
        ar2SetSearchFeatureNum(ar2Handle, 16);
        ar2SetSearchSize(ar2Handle, 6);
        ar2SetTemplateSize1(ar2Handle, 6);
        ar2SetTemplateSize2(ar2Handle, 6);
    } else {
#ifdef DEBUG
        NSLog(@"Using NFT tracking settings for more than one CPU.");
#endif
        ar2SetTrackingThresh(ar2Handle, 5.0);
        ar2SetSimThresh(ar2Handle, 0.50);
        ar2SetSearchFeatureNum(ar2Handle, 16);
        ar2SetSearchSize(ar2Handle, 12);
        ar2SetTemplateSize1(ar2Handle, 6);
        ar2SetTemplateSize2(ar2Handle, 6);
    }

    return [self setupPattern];
}


- (BOOL)setupPattern {
    NSString *markerConfigDataFilename = @"Data2/markers.dat";
    if ((markers = [ARMarker newMarkersFromConfigDataFile:markerConfigDataFilename arPattHandle:NULL arPatternDetectionMode:NULL]) == nil) {
        NSLog(@"Error loading markers.\n");
        return NO;
    }
//    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
//    NSString *docPath = paths[0];
//
//    NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:docPath];
//    for (int i = 0; i < subpaths.count; ++i) {
//        NSData *data = [NSData dataWithContentsOfFile:[docPath stringByAppendingFormat:@"/%@",subpaths[i]]];
//        NSLog(@"%@", [data description]);
//    }
//    ARMarkerNFT *markerNFT = [[ARMarkerNFT alloc] initWithNFTDataSetPathname:[[docPath stringByAppendingString:@"/ntf"] UTF8String]];
//    markers = @[markerNFT];
    [self loadNFTData];
    return YES;
}

- (BOOL)detect:(AR2VideoBufferT *)buffer modelMatrix:(float *)modelMatrix {
    if (threadHandle) {
        // Perform NFT tracking.
        float            err;
        int              ret;
        int              pageNo;

        if( detectedPage == -2 ) {
            trackingInitStart( threadHandle, buffer->buff );
            detectedPage = -1;
        }
        if( detectedPage == -1 ) {
            ret = trackingInitGetResult( threadHandle, trackingTrans, &pageNo);
            if( ret == 1 ) {
                if (pageNo >= 0 && pageNo < PAGES_MAX) {
                    detectedPage = pageNo;
#ifdef DEBUG
                    NSLog(@"Detected page %d.\n", detectedPage);
#endif
                    ar2SetInitTrans(surfaceSet[detectedPage], trackingTrans);
                } else {
                    NSLog(@"Detected bad page %d.\n", pageNo);
                    detectedPage = -2;
                }
            } else if( ret < 0 ) {
                detectedPage = -2;
            }
        }
        if( detectedPage >= 0 && detectedPage < PAGES_MAX) {
            int trackingResult = ar2Tracking(ar2Handle, surfaceSet[detectedPage], buffer->buff, trackingTrans, &err);
            if( trackingResult < 0 ) {
                detectedPage = -2;
            } else {
#ifdef DEBUG
//                NSLog(@"Tracked page %d.\n", detectedPage);
#endif
            }
        }
    } else detectedPage = -2;

    if (detectedPage < 0) {
        return NO;
    }
    // Update all marker objects with detected markers.
    for (ARMarker *marker in markers) {
        if ([marker isKindOfClass:[ARMarkerNFT class]]) {
            [(ARMarkerNFT *)marker updateWithNFTResultsDetectedPage:detectedPage trackingTrans:trackingTrans];
            for (int i = 0; i < 16 ; ++i) {
                modelMatrix[i] = [marker pose].T[i];
            }
            
            return YES;
        } else {
            [marker update];
        }
    }
    


    return YES;
}

- (void)loadNFTData
{
    int i;

    // If data was already loaded, stop KPM tracking thread and unload previously loaded data.
    trackingInitQuit(&threadHandle);
    for (i = 0; i < PAGES_MAX; i++) surfaceSet[i] = NULL; // Discard weak-references.

    KpmRefDataSet *refDataSet = NULL;
    int pageCount = 0;
    for (ARMarker *marker in markers) {
        if ([marker isKindOfClass:[ARMarkerNFT class]]) {
            ARMarkerNFT *markerNFT = (ARMarkerNFT *)marker;

            // Load KPM data.
            KpmRefDataSet  *refDataSet2;
            printf("Read %s.fset3\n", markerNFT.datasetPathname);
            if (kpmLoadRefDataSet(markerNFT.datasetPathname, "fset3", &refDataSet2) < 0 ) {
                NSLog(@"Error reading KPM data from %s.fset3", markerNFT.datasetPathname);
                markerNFT.pageNo = -1;
                continue;
            }
            markerNFT.pageNo = pageCount;
            if (kpmChangePageNoOfRefDataSet(refDataSet2, KpmChangePageNoAllPages, pageCount) < 0) {
                NSLog(@"Error: kpmChangePageNoOfRefDataSet");
                exit(-1);
            }
            if (kpmMergeRefDataSet(&refDataSet, &refDataSet2) < 0) {
                NSLog(@"Error: kpmMergeRefDataSet");
                exit(-1);
            }
            printf("  Done.\n");

            // For convenience, create a weak reference to the AR2 data.
            surfaceSet[pageCount] = markerNFT.surfaceSet;

            pageCount++;
            if (pageCount == PAGES_MAX) break;
        }
    }
    if (kpmSetRefDataSet(kpmHandle, refDataSet) < 0) {
        NSLog(@"Error: kpmSetRefDataSet");
        exit(-1);
    }
    kpmDeleteRefDataSet(&refDataSet);

    // Start the KPM tracking thread.
    threadHandle = trackingInitInit(kpmHandle);
    if (!threadHandle) exit(0);
}

- (CGSize)markerSize {
    return CGSizeMake(((ARMarker *)markers[0]).marker_width, ((ARMarker *)markers[0]).marker_height);
}
@end
