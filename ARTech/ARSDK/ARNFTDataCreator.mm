#import "ARNFTDataCreator.h"
#import "UIImage+GL.h"

#ifdef _WIN32
#include <windows.h>
#  define truncf(x) floorf(x) // These are the same for positive numbers.
#endif
#include <stdio.h>
#include <string.h>
#include <AR/ar.h>
#include <AR2/config.h>
#include <AR2/imageFormat.h>
#include <AR2/imageSet.h>
#include <AR2/featureSet.h>
#include <AR2/util.h>
#include <KPM/kpm.h>
#ifdef _WIN32
#  define MAXPATHLEN MAX_PATH
#else
#  include <sys/param.h> // MAXPATHLEN
#endif
#if defined(__APPLE__) || defined(__linux__)
#  define HAVE_DAEMON_FUNC 1
#  include <unistd.h>
#endif
#include <time.h> // time(), localtime(), strftime()
#import <UIKit/UIKit.h>
#import "imageSet.h"

#define          KPM_SURF_FEATURE_DENSITY_L0    70
#define          KPM_SURF_FEATURE_DENSITY_L1   100
#define          KPM_SURF_FEATURE_DENSITY_L2   150
#define          KPM_SURF_FEATURE_DENSITY_L3   200

#define          TRACKING_EXTRACTION_LEVEL_DEFAULT 2
#define          INITIALIZATION_EXTRACTION_LEVEL_DEFAULT 1
#define KPM_MINIMUM_IMAGE_SIZE 28 // Filter size for 1 octaves plus 1.
//#define KPM_MINIMUM_IMAGE_SIZE 196 // Filter size for 4 octaves plus 1.

#ifndef MIN
#  define MIN(x,y) (x < y ? x : y)
#endif

enum {
    E_NO_ERROR = 0,
    E_BAD_PARAMETER = 64,
    E_INPUT_DATA_ERROR = 65,
    E_USER_INPUT_CANCELLED = 66,
    E_BACKGROUND_OPERATION_UNSUPPORTED = 69,
    E_DATA_PROCESSING_ERROR = 70,
    E_UNABLE_TO_DETACH_FROM_CONTROLLING_TERMINAL = 71,
    E_GENERIC_ERROR = 255
};

static float                dpiMin = -1.0f;
static float                dpiMax = -1.0f;
static float               *dpi_list;
static int                  dpi_num = 0;

static int                  featureDensity = -1;
static int                  occ_size = -1;

int setDPI( int dpi , int xsize, int ysize);

void gen_main(ARNFTDataGenParam param, uint8_t *imageData, CGSize imageSize, int dpi, int numberOfChannel, const char *resultSavePath)
{
    // resultSavePath may be /var/folder/nft_sets/snapshot_01
    // /var/folder/nft_sets/snapshot_01.iset  /var/folder/nft_sets/snapshot_01.fset
    AR2JpegImageT       *jpegImage = NULL;
    ARUint8             *image = NULL;
    AR2ImageSetT        *imageSet = NULL;
    AR2FeatureMapT      *featureMap = NULL;
    AR2FeatureSetT      *featureSet = NULL;
    KpmRefDataSet       *refDataSet = NULL;
    float                scale1, scale2;
    int                  procMode;
    char                 buf[1024];
    int                  num;
    int                  i, j;
    char                *sep = NULL;
    time_t				 clock;
    int                  maxFeatureNum;
    int                  err;

    if (param.genFSet) {
        switch (param.trackingExtractionLevel) {
            case 0:
                param.sdThresh  = AR2_DEFAULT_SD_THRESH_L0;
                param.minThresh = AR2_DEFAULT_MIN_SIM_THRESH_L0;
                param.maxThresh = AR2_DEFAULT_MAX_SIM_THRESH_L0;
                if( occ_size   == -1    ) occ_size   = AR2_DEFAULT_OCCUPANCY_SIZE;
                break;
            case 1:
                param.sdThresh = AR2_DEFAULT_SD_THRESH_L1;
                param.minThresh = AR2_DEFAULT_MIN_SIM_THRESH_L1;
                param.maxThresh = AR2_DEFAULT_MAX_SIM_THRESH_L1;
                if( occ_size   == -1    ) occ_size   = AR2_DEFAULT_OCCUPANCY_SIZE;
                break;
            case 2:
                param.sdThresh  = AR2_DEFAULT_SD_THRESH_L2;
                param.minThresh = AR2_DEFAULT_MIN_SIM_THRESH_L2;
                param.maxThresh = AR2_DEFAULT_MAX_SIM_THRESH_L2;
                if( occ_size   == -1    ) occ_size   = AR2_DEFAULT_OCCUPANCY_SIZE*2/3;
                break;
            case 3:
                param.sdThresh  = AR2_DEFAULT_SD_THRESH_L3;
                param.minThresh = AR2_DEFAULT_MIN_SIM_THRESH_L3;
                param.maxThresh = AR2_DEFAULT_MAX_SIM_THRESH_L3;
                if( occ_size   == -1    ) occ_size   = AR2_DEFAULT_OCCUPANCY_SIZE*2/3;
                break;
            case 4: // Same as 3, but with smaller AR2_DEFAULT_OCCUPANCY_SIZE.
                param.sdThresh  = AR2_DEFAULT_SD_THRESH_L3;
                param.minThresh = AR2_DEFAULT_MIN_SIM_THRESH_L3;
                param.maxThresh = AR2_DEFAULT_MAX_SIM_THRESH_L3;
                if( occ_size   == -1    ) occ_size   = AR2_DEFAULT_OCCUPANCY_SIZE*1/2;
                break;
            default: // We only get to here if the parameters are already set.
                break;
        }
    }
    if (param.genFSet3) {
        switch(param.initExtractionLevel) {
            case 0:
                if( featureDensity  == -1 ) featureDensity  = KPM_SURF_FEATURE_DENSITY_L0;
                break;
            default:
            case 1:
                if( featureDensity  == -1 ) featureDensity  = KPM_SURF_FEATURE_DENSITY_L1;
                break;
            case 2:
                if( featureDensity  == -1 ) featureDensity  = KPM_SURF_FEATURE_DENSITY_L2;
                break;
            case 3:
                if( featureDensity  == -1 ) featureDensity  = KPM_SURF_FEATURE_DENSITY_L3;
                break;
        }
        ARLOGi("SURF_FEATURE = %d\n", featureDensity);
    }

    setDPI(dpi, imageSize.width, imageSize.height);
    

    ARLOGi("Generating ImageSet...\n");
    imageSet = ar2GenImageSet( imageData, imageSize.width, imageSize.height, numberOfChannel, dpi, dpi_list, dpi_num );
    
    ARLOGi("Saving to %s.iset...\n", resultSavePath);
    if( ar2WriteImageSet( (char *)resultSavePath, imageSet ) < 0 ) {
        ARLOGe("Save error: %s.iset\n", resultSavePath );
    }
    ARLOGi("  Done.\n");

    if (param.genFSet) {
        arMalloc( featureSet, AR2FeatureSetT, 1 );                      // A featureSet with a single image,
        arMalloc( featureSet->list, AR2FeaturePointsT, imageSet->num ); // and with 'num' scale levels of this image.
        featureSet->num = imageSet->num;

        ARLOGi("Generating FeatureList...\n");
        for( i = 0; i < imageSet->num; i++ ) {
            ARLOGi("Start for %f dpi image.\n", imageSet->scale[i]->dpi);

            featureMap = ar2GenFeatureMap( imageSet->scale[i],
                    AR2_DEFAULT_TS1*AR2_TEMP_SCALE, AR2_DEFAULT_TS2*AR2_TEMP_SCALE,
                    AR2_DEFAULT_GEN_FEATURE_MAP_SEARCH_SIZE1, AR2_DEFAULT_GEN_FEATURE_MAP_SEARCH_SIZE2,
                    AR2_DEFAULT_MAX_SIM_THRESH2, AR2_DEFAULT_SD_THRESH2 );
            if( featureMap == NULL ) {
                ARLOGe("Error!!\n");
            }
            ARLOGi("  Done.\n");


            featureSet->list[i].coord = ar2SelectFeature2( imageSet->scale[i], featureMap,
                    AR2_DEFAULT_TS1*AR2_TEMP_SCALE, AR2_DEFAULT_TS2*AR2_TEMP_SCALE, AR2_DEFAULT_GEN_FEATURE_MAP_SEARCH_SIZE2,
                    occ_size,
                    param.maxThresh, param.minThresh, param.sdThresh, &num );
            if( featureSet->list[i].coord == NULL ) num = 0;
            featureSet->list[i].num   = num;
            featureSet->list[i].scale = i;

            scale1 = 0.0f;
            for( j = 0; j < imageSet->num; j++ ) {
                if( imageSet->scale[j]->dpi < imageSet->scale[i]->dpi ) {
                    if( imageSet->scale[j]->dpi > scale1 ) scale1 = imageSet->scale[j]->dpi;
                }
            }
            if( scale1 == 0.0f ) {
                featureSet->list[i].mindpi = imageSet->scale[i]->dpi * 0.5f;
            }
            else {
                /*
                 scale2 = imageSet->scale[i]->dpi;
                 scale = sqrtf( scale1 * scale2 );
                 featureSet->list[i].mindpi = scale2 / ((scale2/scale - 1.0f)*1.1f + 1.0f);
                 */
                featureSet->list[i].mindpi = scale1;
            }

            scale1 = 0.0f;
            for( j = 0; j < imageSet->num; j++ ) {
                if( imageSet->scale[j]->dpi > imageSet->scale[i]->dpi ) {
                    if( scale1 == 0.0f || imageSet->scale[j]->dpi < scale1 ) scale1 = imageSet->scale[j]->dpi;
                }
            }
            if( scale1 == 0.0f ) {
                featureSet->list[i].maxdpi = imageSet->scale[i]->dpi * 2.0f;
            }
            else {
                //scale2 = imageSet->scale[i]->dpi * 1.2f;
                scale2 = imageSet->scale[i]->dpi;
                /*
                 scale = sqrtf( scale1 * scale2 );
                 featureSet->list[i].maxdpi = scale2 * ((scale/scale2 - 1.0f)*1.1f + 1.0f);
                 */
                featureSet->list[i].maxdpi = scale2*0.8f + scale1*0.2f;
            }

            ar2FreeFeatureMap( featureMap );
        }
        ARLOGi("  Done.\n");

        ARLOGi("Saving FeatureSet...\n");
        if( ar2SaveFeatureSet( (char *)resultSavePath, "fset", featureSet ) < 0 ) {
            ARLOGe("Save error: %s.fset\n", resultSavePath );
        }
        ARLOGi("  Done.\n");
        ar2FreeFeatureSet( &featureSet );
    }

    if (param.genFSet3) {
        ARLOGi("Generating FeatureSet3...\n");
        refDataSet  = NULL;
        procMode    = KpmProcFullSize;
        for( i = 0; i < imageSet->num; i++ ) {
            maxFeatureNum = featureDensity * imageSet->scale[i]->xsize * imageSet->scale[i]->ysize / (480*360);
            ARLOGi("(%d, %d) %f[dpi]\n", imageSet->scale[i]->xsize, imageSet->scale[i]->ysize, imageSet->scale[i]->dpi);
            if( kpmAddRefDataSet (
#if AR2_CAPABLE_ADAPTIVE_TEMPLATE
                    imageSet->scale[i]->imgBWBlur[1],
#else
                    imageSet->scale[i]->imgBW,
#endif
                    imageSet->scale[i]->xsize,
                    imageSet->scale[i]->ysize,
                    imageSet->scale[i]->dpi,
                    procMode, KpmCompNull, maxFeatureNum, 1, i, &refDataSet) < 0 ) { // Page number set to 1 by default.
                ARLOGe("Error at kpmAddRefDataSet.\n");
            }
        }
        ARLOGi("  Done.\n");
        ARLOGi("Saving FeatureSet3...\n");
        if( kpmSaveRefDataSet((char *)resultSavePath, "fset3", refDataSet) != 0 ) {
            ARLOGe("Save error: %s.fset2\n", resultSavePath );
        }
        ARLOGi("  Done.\n");
        kpmDeleteRefDataSet( &refDataSet );
    }

    ar2FreeImageSet( &imageSet );
}

// Reads dpiMinAllowable, xsize, ysize, dpi, background, dpiMin, dpiMax.
// Sets dpiMin, dpiMax, dpi_num, dpi_list.
int setDPI( int dpi , int xsize, int ysize)
{
    float       dpiWork, dpiMinAllowable;
    char		buf1[256];
    int			i;

    // Determine minimum allowable DPI, truncated to 3 decimal places.
    dpiMinAllowable = truncf(((float)KPM_MINIMUM_IMAGE_SIZE / (float)(MIN(xsize, ysize))) * dpi * 1000.0) / 1000.0f;

    if (dpiMin == -1.0f) dpiMin = dpiMinAllowable + (dpi - dpiMinAllowable) * 0.4;
    if (dpiMax == -1.0f) dpiMax = dpiMinAllowable + (dpi - dpiMinAllowable) * 0.6;

    // Decide how many levels we need.
    if (dpiMin == dpiMax) {
        dpi_num = 1;
    } else {
        dpiWork = dpiMin;
        for( i = 1;; i++ ) {
            dpiWork *= powf(2.0f, 1.0f/3.0f); // *= 1.25992104989487
            if( dpiWork >= dpiMax*0.95f ) {
                break;
            }
        }
        dpi_num = i + 1;
    }
    arMalloc(dpi_list, float, dpi_num);

    // Determine the DPI values of each level.
    dpiWork = dpiMin;
    for( i = 0; i < dpi_num; i++ ) {
        ARLOGi("Image DPI (%d): %f\n", i+1, dpiWork);
        dpi_list[dpi_num - i - 1] = dpiWork; // Lowest value goes at tail of array, highest at head.
        dpiWork *= powf(2.0f, 1.0f/3.0f);
        if( dpiWork >= dpiMax*0.95f ) dpiWork = dpiMax;
    }

    return 0;
}


@implementation ARNFTDataCreator
+ (NSString *)savePath {
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *nftSetsDir = [NSURL fileURLWithPathComponents:@[docPath, @"nft_sets"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[nftSetsDir path]]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:nftSetsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * filename = @"test";//[NSString stringWithFormat:@"%llx", (long long)[NSDate timeIntervalSinceReferenceDate] * 1000];
    NSURL *savePathUrl = [NSURL fileURLWithPathComponents:@[nftSetsDir.path, filename]];
    return savePathUrl.path;
}

+ (void)genNFTDataWithImage:(UIImage *)image {
    NSString *savePath = [self savePath];
    NSString *imageSavePath = [NSString stringWithFormat:@"%@.jpg", savePath];
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * 0.7, image.size.height* 0.7));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, image.size.width* 0.7, image.size.height * 0.7)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    [imgData writeToFile:imageSavePath atomically:YES];
    
    [self genNFTData:imageSavePath];
}

+ (void)genNFTDataWithARBuffer:(AR2VideoBufferT *)buff size:(CGSize)imageSize channel:(int)channel {
    [self saveImage:buff->bufPlanes[0] width:imageSize.width height:imageSize.height channel:1];
}

+ (void)genNFTData:(NSString *)imagePath {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *nftSetsDir = [NSURL fileURLWithPathComponents:@[docPath, @"nft_sets"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[nftSetsDir path]]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:nftSetsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *paths = [[NSFileManager defaultManager] subpathsAtPath:nftSetsDir.path];
    for (int i=0; i<paths.count; ++i) {
        NSLog(paths[i]);
    }
    
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    NSURL *savePathUrl = [NSURL fileURLWithPathComponents:@[nftSetsDir.path, imageUrl.lastPathComponent.stringByDeletingPathExtension]];
    
    int width,height,dpi,channel;
    uint8_t * imageData = [self dataFromImage:imagePath width:&width height:&height dpi:&dpi channel:&channel];
    AR2JpegImageT *jpimage = ar2ReadJpegImage([imagePath.stringByDeletingPathExtension UTF8String], [imagePath.pathExtension UTF8String]);
    width = jpimage->xsize;
    height = jpimage->ysize;
    channel = jpimage->nc;
    //dpi = jpimage->dpi;
    
    gen_main([self defaultGenParam], jpimage->image, CGSizeMake(width, height), dpi, channel, [savePathUrl.path UTF8String]);
}

+ (ARNFTDataGenParam)defaultGenParam {
    ARNFTDataGenParam param;
    param.initExtractionLevel = 1;
    param.trackingExtractionLevel = 2;
    param.sdThresh = 8;
    param.maxThresh = 0.9;
    param.minThresh = 0.55;
    param.genFSet = YES;
    param.genFSet3 = YES;
    return param;
}

+ (UIImage *)saveImage:(uint8_t *)imageData width:(GLsizei)width height:(GLsizei)height channel:(int)channel {
 
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imageData, (width * height * channel), NULL);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    NSUInteger bytesPerPixel = channel;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerComponent * channel, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
    
    img = [UIImage imageWithData:imgData];
    
    return img;
}

+ (GLubyte *)dataFromImage:(NSString *)imageName width:(GLsizei *)pWidth height:(GLsizei *)pHeight dpi:(int *)pDPI channel:(int *)pChannel {
    UIImage *img = [UIImage imageNamed:imageName];
    *pDPI = img.scale * 72.0f;
    *pChannel = 4;
    CGImageRef imageRef = [img CGImage];
    *pWidth = CGImageGetWidth(imageRef);
    *pHeight = CGImageGetHeight(imageRef);
    
    size_t width = *pWidth;
    size_t height = *pHeight;
    
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return textureData;
}
@end
