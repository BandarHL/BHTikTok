#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import "BHIManager.h"
#import "SettingsViewController.h"
#import "SecurityViewController.h"
#import "BHDownload.h"
#import "BHMultipleDownload.h"
#import "JGProgressHUD/JGProgressHUD.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
@end

@interface SparkViewController: UIViewController
@property(nonatomic, strong, readwrite) NSURL *originURL;
- (void)didTapCloseButton;
@end

@interface UIView (RCTViewUnmounting)
@property(retain, nonatomic) UIViewController *yy_viewController;
@end

@interface TikTokFeedTabControl: UIView
@end

@interface AWEFeedVideoButton: UIButton
@property(copy, nonatomic, readwrite) NSString *imageNameString;
@end

@interface AWEURLModel : NSObject
@property(retain, nonatomic) NSArray* originURLList;
- (NSURL *)recommendUrl;
- (NSURL *)bestURLtoDownload;
- (NSString *)bestURLtoDownloadFormat;
@end

@interface AWEVideoModel : NSObject
@property(readonly, nonatomic) AWEURLModel *playURL;
@property(readonly, nonatomic) AWEURLModel *downloadURL;
@property(readonly, nonatomic) NSNumber *duration;
@end

@interface AWEMusicModel : NSObject
@property(readonly, nonatomic) AWEURLModel *playURL;
@end

@interface AWEPhotoAlbumPhoto: NSObject
@property(readonly, nonatomic) AWEURLModel *originPhotoURL;
@end

@interface AWEPhotoAlbumModel: NSObject
@property(readonly, nonatomic) NSArray <AWEPhotoAlbumPhoto *> *photos;
@end

@interface AWEAwemeModel : NSObject
@property(nonatomic) BOOL isAds;
@property(retain, nonatomic) AWEVideoModel *video;
@property(retain, nonatomic) id music;
@property(retain, nonatomic) AWEPhotoAlbumModel *photoAlbum;
@property(nonatomic) NSString *music_songName;
@property(nonatomic) NSString *music_artistName;
@property(nonatomic, strong, readwrite) AWEAwemeModel *currentPlayingStory;
@end

@interface AWEUserModel: NSObject
@property(nonatomic, copy, readwrite) NSString *bioUrl;
@property(nonatomic, copy, readwrite) NSString *nickname;
@property(nonatomic, copy, readwrite) NSString *signature;
@property(nonatomic, copy, readwrite) NSString *socialName;
@end

@interface AWESettingItemModel: NSObject
@property(nonatomic, copy, readwrite) NSString *identifier;
@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, copy, readwrite) NSString *detail;
@property(nonatomic, strong, readwrite) UIImage *iconImage;
@property(nonatomic, assign, readwrite) NSUInteger type;
- (instancetype)initWithIdentifier:(NSString *)identifier;
@end

@interface TTKSettingsBaseCellPlugin: NSObject
@property(nonatomic, weak, readwrite) id context;
@property(nonatomic, strong, readwrite) AWESettingItemModel *itemModel;
- (instancetype)initWithPluginContext:(id)context;
@end

@interface AWEBaseListSectionViewModel: NSObject
@property(nonatomic, copy, readwrite) NSArray *modelsArray;
- (void)insertModel:(id)model atIndex:(NSInteger)index animated:(bool)animated;
@end

@interface AWESettingsNormalSectionViewModel: AWEBaseListSectionViewModel
@property(nonatomic, weak, readwrite) id context;
@property(nonatomic, copy, readwrite) NSString *sectionHeaderTitle;
@property(nonatomic, copy, readwrite) NSString *sectionIdentifier;
@end

@interface AWEBaseListViewModel: NSObject
- (NSArray *)sectionViewModelsArray;
@end

@interface AWEPluginBaseViewModel: AWEBaseListViewModel
@end

@interface AWESettingsBaseViewModel: AWEPluginBaseViewModel
@end

@interface TTKSettingsViewModel: AWESettingsBaseViewModel
@end

@interface TIKTOKProfileHeaderViewController: UIViewController
@property(nonatomic, strong) AWEUserModel *user;
@end

@interface TIKTOKProfileHeaderView: UIView
- (void)addHandleLongPress;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
@end

@interface AWEProfileImagePreviewView: UIView
@property(strong, nonatomic, readwrite) UIImageView *avatar;
- (void)addHandleLongPress;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
@end

@interface AWEAwemeBaseViewController: UIViewController
@property(nonatomic, strong, readwrite) AWEAwemeModel *model;
@property (nonatomic, copy, readwrite) NSString *referString;
@property (nonatomic) id interactionController;
@end


@interface TTKFeedInteractionContainerElement: NSObject
- (void)hideAllElements:(BOOL)hide exceptArray:(id)array;
@end

@interface TTKFeedInteractionMainContainerElement: TTKFeedInteractionContainerElement
@end

@interface TTKFeedInteractionLegacyMainContainerElement: TTKFeedInteractionMainContainerElement
@end

@interface AWEPlayPhotoAlbumViewController: UIViewController
@property(nonatomic, strong, readwrite) AWEAwemeModel *model;
- (NSIndexPath *)currentIndexPath;
@end

@interface TTKPhotoAlbumFeedCellController: AWEAwemeBaseViewController
{
    AWEPlayPhotoAlbumViewController *_photoAlbumController;
}
@end

@interface TTKPhotoAlbumDetailCellController: AWEAwemeBaseViewController
{
    AWEPlayPhotoAlbumViewController *_photoAlbumController;
}
@end

@interface AWEFeedCellViewController: AWEAwemeBaseViewController
@end

@interface AWEAwemeDetailCellViewController: AWEAwemeBaseViewController
@end

@interface TTKStoryContainerViewController: UIViewController
@property(nonatomic, strong, readwrite) AWEAwemeModel *model;
@property (nonatomic) id interactionController;
@end
@interface TTKStoryDetailContainerViewController: TTKStoryContainerViewController
@end


@interface AWEFeedViewTemplateCell: UITableViewCell
@property(nonatomic, strong, readwrite) UIViewController *viewController;
@property(nonatomic, strong, readwrite) UIViewController *parentVC;
@property(nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, retain) NSString *fileextension;
- (void)addHandleLongPress;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)addHideElementButton;
- (void)hideElementButtonHandler:(UIButton *)sender;
@end
@interface AWEFeedViewTemplateCell () <BHDownloadDelegate, BHMultipleDownloadDelegate>
@end

@interface AWEFeedViewCell: AWEFeedViewTemplateCell
@end

@interface AWEAwemeDetailTableViewCell: UITableViewCell
@property(nonatomic, strong, readwrite) UIViewController *viewController;
@property(nonatomic, strong, readwrite) UIViewController *parentVC;
@property(nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, retain) NSString *fileextension;
- (void)addHandleLongPress;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)addHideElementButton;
- (void)hideElementButtonHandler:(UIButton *)sender;
@end
@interface AWEAwemeDetailTableViewCell () <BHDownloadDelegate>
@end

@interface TTKStoryDetailTableViewCell: UITableViewCell
@property(nonatomic, strong, readwrite) UIViewController *viewController;
@property(nonatomic, strong, readwrite) UIViewController *parentVC;
@property(nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, retain) NSString *fileextension;
- (void)addHandleLongPress;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)addHideElementButton;
- (void)hideElementButtonHandler:(UIButton *)sender;
@end
@interface TTKStoryDetailTableViewCell () <BHDownloadDelegate>
@end

@interface TTKFeedPassthroughStackView: UIStackView
@end

@interface TUXActionSheetAction: NSObject
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *subtitle;
@property(nonatomic) NSString *imageLabel;
@property(nonatomic) UIImage *image;
- (instancetype)initWithStyle:(NSUInteger)style title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image imageLabel:(NSString *)imageLabel handler:(void (^ __nullable)(TUXActionSheetAction *action))handler;
@end

@interface TUXActionSheetController: UIViewController
@property(nonatomic, assign, readwrite) BOOL dismissOnDraggingDown;
@property(nonatomic, strong, readwrite) UITableView *tableView;
- (instancetype)initWithTitle:(NSString *)title;
- (void)addAction:(TUXActionSheetAction *)action;
@end

@interface AWEUIAlertView: UIView
+ (void)showAlertWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image actionButtonTitle:(NSString *)actionButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle actionBlock:(void (^)(void))actionBlock cancelBlock:(void (^)(void))cancelBlock;
@end

@interface AWEToast: NSObject
+ (void)showSuccess:(NSString *)title;
@end

@interface AWEPlayVideoPlayerController : NSObject
@property(nonatomic) AWEAwemeBaseViewController *container;
- (void)setPlayerSeekTime:(double)arg1 completion:(id)arg2;
@end

@interface TTKSearchEntranceButton: UIButton
@end

@interface AWEFeedContainerViewController: UIViewController
@property(nonatomic, strong, readwrite) TTKSearchEntranceButton *searchEntranceView;
@end

@interface AWENewFeedTableViewController : UIViewController
@property(nonatomic, weak, readwrite) UIViewController *tabContainerController;
- (void)scrollToNextVideo;
@end

static BOOL is_iPad() {
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        return YES;
    }
    return NO;
}

static UIViewController * _Nullable _topMostController(UIViewController * _Nonnull cont) {
    UIViewController *topController = cont;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    return (topController != cont ? topController : nil);
}
static UIViewController * _Nonnull topMostController() {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *next = nil;
    while ((next = _topMostController(topController)) != nil) {
        topController = next;
    }
    return topController;
}