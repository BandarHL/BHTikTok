#import <Foundation/Foundation.h>

@protocol BHMultipleDownloadDelegate <NSObject>
- (void)downloaderProgress:(float)progress;
- (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths;
- (void)downloaderDidFailureWithError:(NSError *)error;
@end

@interface BHMultipleDownload : NSObject <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) id<BHMultipleDownloadDelegate> delegate;
- (void)downloadFiles:(NSArray<NSURL *> *)fileURLs;

@end