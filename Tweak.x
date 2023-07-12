#import "TikTokHeaders.h"

NSArray *jailbreakPaths;

static void showConfirmation(void (^okHandler)(void)) {
  [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"Are you sure?" image:nil actionButtonTitle:@"Yes" cancelButtonTitle:@"No" actionBlock:^{
    okHandler();
  } cancelBlock:nil];
}

%hook AppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BHTikTokFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"BHTikTokFirstRun" forKey:@"BHTikTokFirstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"dw_videos"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"dw_musics"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"remove_elements_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_decription"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_video_link"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_music_link"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"show_porgress_bar"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_profile_information"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extended_bio"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extendedComment"];
    }
    [BHIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 { // app lock
  %orig;

  if ([BHIManager appLock] && !isAuthenticationShowed) {
    UIViewController *rootController = [[self window] rootViewController];
    SecurityViewController *securityViewController = [SecurityViewController new];
    securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootController presentViewController:securityViewController animated:YES completion:nil];
    isAuthenticationShowed = TRUE;
  }
}

- (void)applicationWillEnterForeground:(id)arg1 {
  %orig;
  isAuthenticationShowed = FALSE;
}
%end

%hook TTKSettingsBaseCellPlugin
- (void)didSelectItemAtIndex:(NSInteger)index {
    if ([self.itemModel.identifier isEqualToString:@"bhtiktok_settings"]) {
        UINavigationController *BHTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
        [topMostController() presentViewController:BHTikTokSettings animated:true completion:nil];
    } else {
        return %orig;
    }
}
%end

%hook AWESettingsNormalSectionViewModel
- (void)viewDidLoad {
    %orig;
    if ([self.sectionIdentifier isEqualToString:@"account"]) {
        TTKSettingsBaseCellPlugin *BHTikTokSettingsPluginCell = [[%c(TTKSettingsBaseCellPlugin) alloc] initWithPluginContext:self.context];

        AWESettingItemModel *BHTikTokSettingsItemModel = [[%c(AWESettingItemModel) alloc] initWithIdentifier:@"bhtiktok_settings"];
        [BHTikTokSettingsItemModel setTitle:@"BHTikTok settings"];
        [BHTikTokSettingsItemModel setDetail:@"BHTikTok settings"];
        [BHTikTokSettingsItemModel setIconImage:[UIImage systemImageNamed:@"gear"]];
        [BHTikTokSettingsItemModel setType:99];

        [BHTikTokSettingsPluginCell setItemModel:BHTikTokSettingsItemModel];

        [self insertModel:BHTikTokSettingsPluginCell atIndex:0 animated:true];
    }
}
%end

%hook SparkViewController // alwaysOpenSafari
- (void)viewWillAppear:(BOOL)animated {
    if (![BHIManager alwaysOpenSafari]) {
        return %orig;
    }
    
    // NSURL *url = self.originURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *searchParameter = @"url";
    NSString *searchValue = nil;
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:searchParameter]) {
            searchValue = queryItem.value;
            break;
        }
    }
    
    // In-app browser is used for two-factor authentication with security key,
    // login will not complete successfully if it's redirected to Safari
    // if ([urlStr containsString:@"twitter.com/account/"] || [urlStr containsString:@"twitter.com/i/flow/"]) {
    //     return %orig;
    // }

    if (searchValue) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchValue] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        return %orig;
    }
}
%end

%hook CTCarrier // changes country
- (NSString *)mobileCountryCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"mcc"];
        }
        return %orig;
    }
    return %orig;
}

- (void)setIsoCountryCode:(NSString *)arg1 {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}

- (NSString *)isoCountryCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}

- (NSString *)mobileNetworkCode {
    if ([BHIManager regionChangingEnabled]) {
        if ([BHIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BHIManager selectedRegion];
            return selectedRegion[@"mnc"];
        }
        return %orig;
    }
    return %orig;
}
%end

%hook AWEAwemeModel // no ads, show porgress bar
- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}
- (id)init {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}

- (BOOL)progressBarDraggable {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)progressBarVisible {
    return [BHIManager progressBar] || %orig;
}
%end

%hook AWEPlayVideoPlayerController // auto play next video and stop looping video
- (void)playerWillLoopPlaying:(id)arg1 {
    if ([BHIManager autoPlay]) {
        if ([self.container.parentViewController isKindOfClass:%c(AWENewFeedTableViewController)]) {
            [((AWENewFeedTableViewController *)self.container.parentViewController) scrollToNextVideo];
            return;
        }
    }
    %orig;
}
%end

%hook TIKTOKProfileHeaderExtraViewController // follow confirmation
- (void)relationBtnClicked:(id)sender {
    if ([BHIManager followConfirmation]) {
        showConfirmation(^(void) { %orig; });
    } else {
        return %orig;
    }
}
%end
%hook AWEPlayInteractionUserAvatarElement
- (void)onFollowViewClicked:(id)sender {
    if ([BHIManager followConfirmation]) {
        showConfirmation(^(void) { %orig; });
    } else {
        return %orig;
    }
}
%end
%hook AWEFeedVideoButton // like feed confirmation
- (void)_onTouchUpInside {
    if ([BHIManager likeConfirmation] && [self.imageNameString isEqualToString:@"icon_home_like_before"]) {
        showConfirmation(^(void) { %orig; });
    } else {
        %orig;
    }
}
%end
%hook AWECommentPanelCell // like/dislike comment confirmation
- (void)likeButtonTapped {
    if ([BHIManager likeCommentConfirmation]) {
        showConfirmation(^(void) { %orig; });
    } else {
        return %orig;
    }
}
- (void)dislikeButtonTapped {
    if ([BHIManager dislikeCommentConfirmation]) {
        showConfirmation(^(void) { %orig; });
    } else {
        return %orig;
    }
}
%end

%hook AWEUserModel // follower, following Count fake
- (NSNumber *)followerCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"follower_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
- (NSNumber *)followingCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"following_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
- (BOOL)isVerifiedUser {
    if ([BHIManager fakeVerified]) {
        return true;
    }
    return %orig;
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    if ([BHIManager extendedComment]) {
        return 240;
    }

    return %orig;
}
%end
%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    if ([BHIManager extendedBio]) {
        return 222;
    }

    return %orig;
}
%end

%hook TIKTOKProfileHeaderView // copy profile information
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BHIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.yy_viewController isKindOfClass:%c(TIKTOKProfileHeaderViewController)]) {
            TIKTOKProfileHeaderViewController *rootVC = self.yy_viewController;
            TUXActionSheetController *alert = [[%c(TUXActionSheetController) alloc] initWithTitle:@"Select option to copy."];
            if (rootVC.user.socialName) {
                NSString *accountName = rootVC.user.socialName;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy soical name" subtitle:accountName image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = accountName;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (rootVC.user.nickname) {
                NSString *nickName = rootVC.user.nickname;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy nick name" subtitle:nickName image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = nickName;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (rootVC.user.signature) {
                NSString *bio = rootVC.user.signature;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy bio" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = bio;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (rootVC.user.bioUrl) {
                NSString *bioURL = rootVC.user.bioUrl;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy URL inbio" subtitle:bioURL image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = bioURL;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }

            [alert setTitle:@"Select option to copy."];
            [alert setDismissOnDraggingDown:true];
            [self.yy_viewController presentViewController:alert animated:YES completion:nil];
        }
    }
}
%end

%hook AWEProfileImagePreviewView // save profile image
- (id)initWithFrame:(CGRect)arg1 image:(id)arg2 imageURL:(id)arg3 backgroundColor:(id)arg4 userID:(id)arg5 type:(NSUInteger)arg6 {
    self = %orig;
    if ([BHIManager profileSave]) {
        [self addHandleLongPress];
    }
    return self;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [BHIManager showSaveVC:@[self.avatar.image]];
    }
}
%end

%hook AWEFeedViewTemplateCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    NSString *video_description;
    TUXActionSheetController *alert = [[%c(TUXActionSheetController) alloc] initWithTitle:video_description];

    if ([self.viewController isKindOfClass:%c(AWEFeedCellViewController)]) {
        AWEFeedCellViewController *rootVC = self.viewController;
        video_description = rootVC.model.music_songName;

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download video" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];
        }

        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyMusicLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable music link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyVideoLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable video link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }]];
        }

    } else if ([self.viewController isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        TTKPhotoAlbumFeedCellController *rootVC = self.viewController;
        video_description = rootVC.model.music_songName;
        AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download current photo" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSIndexPath *currentPhotoIndexPath = [photoAlbumController currentIndexPath];
                NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
                AWEPhotoAlbumPhoto *currentPhoto = photos[currentPhotoIndexPath.item];
                NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];

                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];

            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download all photos" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
                NSMutableArray<NSURL *> *fileURLs = [NSMutableArray array];

                for (AWEPhotoAlbumPhoto *currentPhoto in photos) {
                    NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                    self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];
                    if (downloadableURL) {
                        [fileURLs addObject:downloadableURL];
                    }
                }

                BHMultipleDownload *dwManager = [[BHMultipleDownload alloc] init];
                [dwManager setDelegate:self];
                [dwManager downloadFiles:fileURLs];
                self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                self.hud.textLabel.text = @"Downloading";
                [self.hud showInView:topMostController().view];

            }]];
        }

        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

    } else if ([self.viewController isKindOfClass:%c(TTKPhotoAlbumDetailCellController)]) {
        TTKPhotoAlbumDetailCellController *rootVC = self.viewController;
        video_description = rootVC.model.music_songName;
        AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download current photo" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSIndexPath *currentPhotoIndexPath = [photoAlbumController currentIndexPath];
                NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
                AWEPhotoAlbumPhoto *currentPhoto = photos[currentPhotoIndexPath.item];
                NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];

                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];

            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download all photos" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
                NSMutableArray<NSURL *> *fileURLs = [NSMutableArray array];

                for (AWEPhotoAlbumPhoto *currentPhoto in photos) {
                    NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                    self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];
                    if (downloadableURL) {
                        [fileURLs addObject:downloadableURL];
                    }
                }

                BHMultipleDownload *dwManager = [[BHMultipleDownload alloc] init];
                [dwManager setDelegate:self];
                [dwManager downloadFiles:fileURLs];
                self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                self.hud.textLabel.text = @"Downloading";
                [self.hud showInView:topMostController().view];

            }]];
        }
        
        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }  

    } else if ([self.viewController isKindOfClass:%c(TTKStoryContainerViewController)]) {
        TTKStoryContainerViewController *rootVC = self.viewController;
        video_description = rootVC.model.music_songName;

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download video" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];
        }

        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyMusicLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable music link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:nil cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyVideoLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable video link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }]];
        }
    }

    if ([BHIManager copyVideoDecription]) {
        [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy description" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = video_description;
        }]];
    }

    [alert setTitle:video_description];
    [alert setDismissOnDraggingDown:true];
    [self.yy_viewController presentViewController:alert animated:YES completion:nil];
  }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.elementsHidden) {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    } else {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
        }
    }
}

%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    [BHIManager showSaveVC:downloadedFilePaths];
}
%new - (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];

    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

%hook AWEAwemeDetailTableViewCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    NSString *video_description;
    TUXActionSheetController *alert = [[%c(TUXActionSheetController) alloc] initWithTitle:video_description];

    if ([self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) {
        AWEAwemeDetailCellViewController *rootVC = self.viewController;
        video_description = rootVC.model.music_songName;

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download video" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];
        }

        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyMusicLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable music link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyVideoLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable video link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }]];
        }

    }

    if ([BHIManager copyVideoDecription]) {
        [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy description" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = video_description;
        }]];
    }

    [alert setTitle:video_description];
    [alert setDismissOnDraggingDown:true];
    [self.yy_viewController presentViewController:alert animated:YES completion:nil];
  }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.elementsHidden) {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    } else {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];

    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

%hook TTKStoryDetailTableViewCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;

    if ([BHIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    NSString *video_description;
    TUXActionSheetController *alert = [[%c(TUXActionSheetController) alloc] initWithTitle:video_description];

    if ([self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) {
        TTKStoryDetailContainerViewController *rootVC = self.viewController;
        video_description = rootVC.model.currentPlayingStory.music_songName;

        if ([BHIManager downloadVideos]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download video" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.currentPlayingStory.video.playURL bestURLtoDownload];
                self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                }
            }]];
        }

        if ([BHIManager downloadMusics]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Download music" subtitle:nil image:[UIImage systemImageNamed:@"arrow.down"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.currentPlayingStory.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.currentPlayingStory.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:topMostController().view];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyMusicLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable music link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.currentPlayingStory.music).playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                } else {
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"The video dosen't have music to download." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            }]];
        }

        if ([BHIManager copyVideoLink]) {
            [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy downloadable video link" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
                NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }]];
        }

    }

    if ([BHIManager copyVideoDecription]) {
        [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy description" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = video_description;
        }]];
    }

    [alert setTitle:video_description];
    [alert setDismissOnDraggingDown:true];
    [self.yy_viewController presentViewController:alert animated:YES completion:nil];
  }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.elementsHidden) {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
    } else {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    TTKStoryDetailContainerViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.slash.fill"] forState:UIControlStateNormal];
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.fill"] forState:UIControlStateNormal];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];

    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSURL *bestURLFormat;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"]) {
            bestURLFormat = @"mp4";
        } else if ([url containsString:@".jpeg"]) {
            bestURLFormat = @"jpeg";
        } else if ([url containsString:@".png"]) {
            bestURLFormat = @"png";
        } else if ([url containsString:@".mp3"]) {
            bestURLFormat = @"mp3";
        } else if ([url containsString:@".m4a"]) {
            bestURLFormat = @"m4a";
        }
    }
    if (bestURLFormat == nil) {
        bestURLFormat = @"m4a";
    }

    return bestURLFormat;
}
%new - (NSURL *)bestURLtoDownload {
    NSURL *bestURL;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"] || [url containsString:@".jpeg"] || [url containsString:@".mp3"]) {
            bestURL = [NSURL URLWithString:url];
        }
    }

    if (bestURL == nil) {
        bestURL = [NSURL URLWithString:[self.originURLList firstObject]];
    }

    return bestURL;
}
%end

%hook NSFileManager
-(BOOL)fileExistsAtPath:(id)arg1 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) {
			return NO;
		}
	}
	return %orig;
}
-(BOOL)fileExistsAtPath:(id)arg1 isDirectory:(BOOL*)arg2 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) {
			return NO;
		}
	}
	return %orig;
}
%end
%hook BDADeviceHelper
+(bool)isJailBroken {
	return NO;
}
%end

%hook UIDevice
+(bool)btd_isJailBroken {
	return NO;
}
%end

%hook TTInstallUtil
+(bool)isJailBroken {
	return NO;
}
%end

%hook AppsFlyerUtils
+(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 {
	return NO;
}
%end

%hook PIPOIAPStoreManager
-(bool)_pipo_isJailBrokenDeviceWithProductID:(id)arg2 orderID:(id)arg3 {
	return NO;
}
%end

%hook IESLiveDeviceInfo
+(bool)isJailBroken {
	return NO;
}
%end

%hook PIPOStoreKitHelper
-(bool)isJailBroken {
	return NO;
}
%end

%hook BDInstallNetworkUtility
+(bool)isJailBroken {
	return NO;
}
%end

%hook TTAdSplashDeviceHelper
+(bool)isJailBroken {
	return NO;
}
%end

%hook GULAppEnvironmentUtil
+(bool)isFromAppStore {
	return YES;
}
+(bool)isAppStoreReceiptSandbox {
	return NO;
}
+(bool)isAppExtension {
	return YES;
}
%end

%hook FBSDKAppEventsUtility
+(bool)isDebugBuild {
	return NO;
}
%end

%hook AWEAPMManager
+(id)signInfo {
	return @"AppStore";
}
%end

%hook NSBundle
-(id)pathForResource:(id)arg1 ofType:(id)arg2 {
	if ([arg2 isEqualToString:@"mobileprovision"]) {
		return nil;
	}
	return %orig;
}
%end
%hook AWESecurity
- (void)resetCollectMode {
	return;
}
%end
%hook MSManagerOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end
%hook MSConfigOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end

%hook HBForceCepheiPrefs
+ (BOOL)forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear {
    return YES;
}
%end

%ctor {
    jailbreakPaths = @[
        @"/Applications/Cydia.app", @"/Applications/blackra1n.app",
        @"/Applications/FakeCarrier.app", @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app", @"/Applications/MxTube.app",
        @"/Applications/RockApp.app", @"/Applications/SBSettings.app", @"/Applications/WinterBoard.app",
        @"/.cydia_no_stash", @"/.installed_unc0ver", @"/.bootstrapped_electra",
        @"/usr/libexec/cydia/firmware.sh", @"/usr/libexec/ssh-keysign", @"/usr/libexec/sftp-server",
        @"/usr/bin/ssh", @"/usr/bin/sshd", @"/usr/sbin/sshd",
        @"/var/lib/cydia", @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
        @"/var/log/apt", @"/usr/share/jailbreak/injectme.plist", @"/usr/sbin/frida-server",
        @"/Library/MobileSubstrate/CydiaSubstrate.dylib", @"/Library/TweakInject",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib", @"Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist", @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist", @"/System/Library/CoreServices/SystemVersion.plist",
        @"/private/var/mobile/Library/SBSettings/Themes", @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log", @"/private/var/log/syslog",
        @"/private/var/cache/apt/", @"/private/var/lib/apt",
        @"/private/var/Users/", @"/private/var/stash",
        @"/usr/lib/libjailbreak.dylib", @"/usr/lib/libz.dylib",
        @"/usr/lib/system/introspectionNSZombieEnabled",
        @"/usr/lib/dyld",
        @"/jb/amfid_payload.dylib", @"/jb/libjailbreak.dylib",
        @"/jb/jailbreakd.plist", @"/jb/offsets.plist",
        @"/jb/lzma",
        @"/hmd_tmp_file",
        @"/etc/ssh/sshd_config", @"/etc/apt/undecimus/undecimus.list",
        @"/etc/apt/sources.list.d/sileo.sources", @"/etc/apt/sources.list.d/electra.list",
        @"/etc/apt", @"/etc/ssl/certs", @"/etc/ssl/cert.pem",
        @"/bin/sh", @"/bin/bash",
    ];
    %init;
}