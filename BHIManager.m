#import "BHIManager.h"
#import "TikTokHeaders.h"

@implementation BHIManager
+ (BOOL)hideAds {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_ads"];
}
+ (BOOL)downloadVideos {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dw_videos"];
}
+ (BOOL)downloadMusics {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dw_musics"];
}
+ (BOOL)hideElementButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_elements_button"];
}
+ (BOOL)copyVideoDecription {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_decription"];
}
+ (BOOL)copyMusicLink {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_music_link"];
}
+ (BOOL)copyVideoLink {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_video_link"];
}
+ (BOOL)autoPlay {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_play"];
}
+ (BOOL)progressBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_porgress_bar"];
}
+ (BOOL)likeConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_confirm"];
}
+ (BOOL)likeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_comment_confirm"];
}
+ (BOOL)dislikeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dislike_comment_confirm"];
}
+ (BOOL)followConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"follow_confirm"];
}
+ (BOOL)profileSave {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"save_profile"];
}
+ (BOOL)profileCopy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_profile_information"];
}
+ (BOOL)alwaysOpenSafari {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"openInBrowser"];
}
+ (BOOL)regionChangingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_region"];
}
+ (NSDictionary *)selectedRegion {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
}
+ (BOOL)fakeChangesEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_fake"];
}
+ (BOOL)fakeVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fake_verify"];
}
+ (BOOL)extendedBio {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extended_bio"];
}
+ (BOOL)extendedComment {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extendedComment"];
}
+ (BOOL)appLock {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"padlock"];
}
+ (void)cleanCache {
    NSArray <NSURL *> *DocumentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in DocumentFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"png"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp3"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
    }
    
    NSArray <NSURL *> *TempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in TempFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mov"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"tmp"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"png"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"jpeg"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp3"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file hasDirectoryPath]) {
            if ([BHIManager isEmpty:file]) {
                [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
            }
        }
    }
}
+ (BOOL)isEmpty:(NSURL *)url {
    NSArray *FolderFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    if (FolderFiles.count == 0) {
        return true;
    } else {
        return false;
    }
}
+ (void)showSaveVC:(id)item {
    UIActivityViewController *acVC = [[UIActivityViewController alloc] initWithActivityItems:item applicationActivities:nil];
    if (is_iPad()) {
        acVC.popoverPresentationController.sourceView = topMostController().view;
        acVC.popoverPresentationController.sourceRect = CGRectMake(topMostController().view.bounds.size.width / 2.0, topMostController().view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [topMostController() presentViewController:acVC animated:true completion:nil];
}

+ (NSString *)getDownloadingPersent:(float)per {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSNumber *number = [NSNumber numberWithFloat:per];
    return [numberFormatter stringFromNumber:number];
}
@end