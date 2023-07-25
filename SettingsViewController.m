//
//  SettingsViewController.m
//  BHTwitter
//
//  Created by BandarHelal
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (nonatomic, assign) BOOL hasDynamicSpecifiers;
@property (nonatomic, retain) NSMutableDictionary *dynamicSpecifiers;
@end

@implementation SettingsViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAppearance];
    }
    return self;
}
- (void)setupAppearance {
    self.title = @"BHTikTok";

    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tableViewBackgroundColor = [UIColor blackColor];
        appearanceSettings.tableViewCellBackgroundColor = [UIColor colorWithRed: 25.0/255.0 green: 25.0/255.0 blue: 25.0/255.0 alpha: 1.0];
        self.hb_appearanceSettings = appearanceSettings;
    } else {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tableViewCellBackgroundColor = [UIColor whiteColor];
        self.hb_appearanceSettings = appearanceSettings;
    }
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self updateColorsForCurrentTraitCollection];
    }
}

- (void)updateColorsForCurrentTraitCollection {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tableViewBackgroundColor = [UIColor blackColor];
        appearanceSettings.tableViewCellBackgroundColor = [UIColor colorWithRed: 25.0/255.0 green: 25.0/255.0 blue: 25.0/255.0 alpha: 1.0];
        self.hb_appearanceSettings = appearanceSettings;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tableViewBackgroundColor = [UIColor systemBackgroundColor];
        appearanceSettings.tableViewCellBackgroundColor = [UIColor whiteColor];
        self.hb_appearanceSettings = appearanceSettings;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}


- (PSSpecifier *)newSectionWithTitle:(NSString *)header footer:(NSString *)footer {
    PSSpecifier *section = [PSSpecifier preferenceSpecifierNamed:header target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    if (footer != nil) {
        [section setProperty:footer forKey:@"footerText"];
    }
    return section;
}
- (PSSpecifier *)newLinkListCellWithTitle:(NSString *)titleText key:(NSString *)keyText defaultValue:(NSNumber *)defValue dynamicRule:(NSString *)rule validTitles:(NSMutableArray <NSString *> *)validTitles validValues:(NSMutableArray<NSMutableDictionary *> *)validValues {
    PSSpecifier *linkListCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:PSListItemsController.class cell:PSLinkListCell edit:nil];
    
    [linkListCell setProperty:keyText forKey:@"key"];
    [linkListCell setProperty:defValue forKey:@"default"];
    [linkListCell setValues:validValues titles:validTitles];
    
    if (rule != nil) {
        [linkListCell setProperty:rule forKey:@"dynamicRule"];
    }
    
    return linkListCell;
}
- (PSSpecifier *)newEditTextCellWithLabel:(NSString *)labeltext placeholder:(NSString *)placeholder keyboardType:(NSString *)keyboardType dynamicRule:(NSString *)rule key:(NSString *)keyText {
    PSSpecifier *editTextCell = [PSSpecifier preferenceSpecifierNamed:labeltext target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];

    [editTextCell setProperty:keyText forKey:@"key"];
    [editTextCell setProperty:keyText forKey:@"id"];
    [editTextCell setProperty:labeltext forKey:@"label"];
    [editTextCell setProperty:placeholder forKey:@"placeholder"];
    [editTextCell setProperty:keyboardType forKey:@"keyboardType"];
    [editTextCell setProperty:NSBundle.mainBundle.bundleIdentifier forKey:@"defaults"];

    if (rule != nil) {
        [editTextCell setProperty:rule forKey:@"dynamicRule"];
    }

    return editTextCell;
}
- (PSSpecifier *)newSwitchCellWithTitle:(NSString *)titleText detailTitle:(NSString *)detailText key:(NSString *)keyText defaultValue:(BOOL)defValue changeAction:(SEL)changeAction {
    PSSpecifier *switchCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
    
    [switchCell setProperty:keyText forKey:@"key"];
    [switchCell setProperty:keyText forKey:@"id"];
    [switchCell setProperty:@YES forKey:@"big"];
    [switchCell setProperty:BHSwitchTableCell.class forKey:@"cellClass"];
    [switchCell setProperty:NSBundle.mainBundle.bundleIdentifier forKey:@"defaults"];
    [switchCell setProperty:@(defValue) forKey:@"default"];
    [switchCell setProperty:NSStringFromSelector(changeAction) forKey:@"switchAction"];
    if (detailText != nil) {
        [switchCell setProperty:detailText forKey:@"subtitle"];
    }
    return switchCell;
}
- (PSSpecifier *)newButtonCellWithTitle:(NSString *)titleText detailTitle:(NSString *)detailText dynamicRule:(NSString *)rule action:(SEL)action {
    PSSpecifier *buttonCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
    
    [buttonCell setButtonAction:action];
    [buttonCell setProperty:@YES forKey:@"big"];
    [buttonCell setProperty:BHButtonTableViewCell.class forKey:@"cellClass"];
    if (detailText != nil ){
        [buttonCell setProperty:detailText forKey:@"subtitle"];
    }
    if (rule != nil) {
        [buttonCell setProperty:@44 forKey:@"height"];
        [buttonCell setProperty:rule forKey:@"dynamicRule"];
    }
    return buttonCell;
}
- (PSSpecifier *)newHBLinkCellWithTitle:(NSString *)titleText detailTitle:(NSString *)detailText url:(NSString *)url {
    PSSpecifier *HBLinkCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
    
    [HBLinkCell setButtonAction:@selector(hb_openURL:)];
    [HBLinkCell setProperty:HBLinkTableCell.class forKey:@"cellClass"];
    [HBLinkCell setProperty:url forKey:@"url"];
    if (detailText != nil) {
        [HBLinkCell setProperty:detailText forKey:@"subtitle"];
    }
    return HBLinkCell;
}
- (PSSpecifier *)newHBTwitterCellWithTitle:(NSString *)titleText twitterUsername:(NSString *)user customAvatarURL:(NSString *)avatarURL {
    PSSpecifier *TwitterCell = [PSSpecifier preferenceSpecifierNamed:titleText target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:1 edit:nil];
    
    [TwitterCell setButtonAction:@selector(hb_openURL:)];
    [TwitterCell setProperty:HBTwitterCell.class forKey:@"cellClass"];
    [TwitterCell setProperty:user forKey:@"user"];
    [TwitterCell setProperty:@YES forKey:@"big"];
    [TwitterCell setProperty:@56 forKey:@"height"];
    [TwitterCell setProperty:avatarURL forKey:@"iconURL"];
    return TwitterCell;
}
- (NSArray *)specifiers {
    if (!_specifiers) {
        NSArray *regionTitles = @[@"Saudi Arabia 🇸🇦", @"Taiwan 🇹🇼", @"Hong Kong 🇭🇰", @"Macao 🇲🇴", @"Japan 🇯🇵", @"South Korea 🇰🇷", @"United Kingdom 🇬🇧", @"United States 🇺🇸", @"Australia 🇦🇺", @"Canada 🇨🇦", @"Argentina 🇦🇷", @"Philippines 🇵🇭", @"Laos 🇱🇦", @"Malaysia 🇲🇾", @"Thailand 🇹🇭", @"Singapore 🇸🇬", @"Indonesia 🇮🇩", @"Vietnam 🇻🇳", @"Anguilla 🇦🇮", @"Panama 🇵🇦", @"Germany 🇩🇪", @"Russia 🇷🇺", @"France 🇫🇷", @"Finland 🇫🇮", @"Italy 🇮🇹", @"Pakistan 🇵🇰", @"Denmark 🇩🇰", @"Norway 🇳🇴", @"Sudan 🇸🇩", @"Romania 🇷🇴", @"United Arab Emirates 🇦🇪", @"Egypt 🇪🇬", @"Lebanon 🇱🇧", @"Mexico 🇲🇽", @"Brazil 🇧🇷", @"Turkey 🇹🇷", @"Kuwait 🇰🇼", @"Algeria 🇩🇿"];
        NSArray *regionCodes = @[
            @{
                @"area": @"Saudi Arabia 🇸🇦",
                @"code": @"SA",
                @"mcc": @"420",
                @"mnc": @"01"
            },
            @{
                @"area": @"Taiwan 🇹🇼",
                @"code": @"TW",
                @"mcc": @"466",
                @"mnc": @"01"
            },
            @{
                @"area": @"Hong Kong 🇭🇰",
                @"code": @"HK",
                @"mcc": @"454",
                @"mnc": @"00"
            },
            @{
                @"area": @"Macao 🇲🇴",
                @"code": @"MO",
                @"mcc": @"455",
                @"mnc": @"00"
            },
            @{
                @"area": @"Japan 🇯🇵",
                @"code": @"JP",
                @"mcc": @"440",
                @"mnc": @"00"
            },
            @{
                @"area": @"South Korea 🇰🇷",
                @"code": @"KR",
                @"mcc": @"450",
                @"mnc": @"05"
            },
            @{
                @"area": @"United Kingdom 🇬🇧",
                @"code": @"GB",
                @"mcc": @"234",
                @"mnc": @"30"
            },
            @{
                @"area": @"United States 🇺🇸",
                @"code": @"US",
                @"mcc": @"310",
                @"mnc": @"00"
            },
            @{
                @"area": @"Australia 🇦🇺",
                @"code": @"AU",
                @"mcc": @"505",
                @"mnc": @"02"
            },
            @{
                @"area": @"Canada 🇨🇦",
                @"code": @"CA",
                @"mcc": @"302",
                @"mnc": @"720"
            },
            @{
                @"area": @"Argentina 🇦🇷",
                @"code": @"AR",
                @"mcc": @"722",
                @"mnc": @"07"
            },
            @{
                @"area": @"Philippines 🇵🇭",
                @"code": @"PH",
                @"mcc": @"515",
                @"mnc": @"02"
            },
            @{
                @"area": @"Laos 🇱🇦",
                @"code": @"LA",
                @"mcc": @"457",
                @"mnc": @"01"
            },
            @{
                @"area": @"Malaysia 🇲🇾",
                @"code": @"MY",
                @"mcc": @"502",
                @"mnc": @"13"
            },
            @{
                @"area": @"Thailand 🇹🇭",
                @"code": @"TH",
                @"mcc": @"520",
                @"mnc": @"18"
            },
            @{
                @"area": @"Singapore 🇸🇬",
                @"code": @"SG",
                @"mcc": @"525",
                @"mnc": @"01"
            },
            @{
                @"area": @"Indonesia 🇮🇩",
                @"code": @"ID",
                @"mcc": @"510",
                @"mnc": @"01"
            },
            @{
                @"area": @"Vietnam 🇻🇳",
                @"code": @"VN",
                @"mcc": @"452",
                @"mnc": @"01"
            },
            @{
                @"area": @"Anguilla 🇦🇮",
                @"code": @"AI",
                @"mcc": @"365",
                @"mnc": @"840"
            },
            @{
                @"area": @"Panama 🇵🇦",
                @"code": @"PA",
                @"mcc": @"714",
                @"mnc": @"04"
            },
            @{
                @"area": @"Germany 🇩🇪",
                @"code": @"DE",
                @"mcc": @"262",
                @"mnc": @"01"
            },
            @{
                @"area": @"Russia 🇷🇺",
                @"code": @"RU",
                @"mcc": @"250",
                @"mnc": @"01"
            },
            @{
                @"area": @"France 🇫🇷",
                @"code": @"FR",
                @"mcc": @"208",
                @"mnc": @"10"
            },
            @{
                @"area": @"Finland 🇫🇮",
                @"code": @"FI",
                @"mcc": @"244",
                @"mnc": @"91"
            },
            @{
                @"area": @"Italy 🇮🇹",
                @"code": @"IT",
                @"mcc": @"222",
                @"mnc": @"10"
            },
            @{
                @"area": @"Pakistan 🇵🇰",
                @"code": @"PK",
                @"mcc": @"410",
                @"mnc": @"01"
            },
            @{
                @"area": @"Denmark 🇩🇰",
                @"code": @"DK",
                @"mcc": @"238",
                @"mnc": @"01"
            },
            @{
                @"area": @"Norway 🇳🇴",
                @"code": @"NO",
                @"mcc": @"242",
                @"mnc": @"01"
            },
            @{
                @"area": @"Sudan 🇸🇩",
                @"code": @"SD",
                @"mcc": @"634",
                @"mnc": @"01"
            },
            @{
                @"area": @"Romania 🇷🇴",
                @"code": @"RO",
                @"mcc": @"226",
                @"mnc": @"01"
            },
            @{
                @"area": @"United Arab Emirates 🇦🇪",
                @"code": @"AE",
                @"mcc": @"424",
                @"mnc": @"02"
            },
            @{
                @"area": @"Egypt 🇪🇬",
                @"code": @"EG",
                @"mcc": @"602",
                @"mnc": @"01"
            },
            @{
                @"area": @"Lebanon 🇱🇧",
                @"code": @"LB",
                @"mcc": @"415",
                @"mnc": @"01"
            },
            @{
                @"area": @"Mexico 🇲🇽",
                @"code": @"MX",
                @"mcc": @"334",
                @"mnc": @"030"
            },
            @{
                @"area": @"Brazil 🇧🇷",
                @"code": @"BR",
                @"mcc": @"724",
                @"mnc": @"06"
            },
            @{
                @"area": @"Turkey 🇹🇷",
                @"code": @"TR",
                @"mcc": @"286",
                @"mnc": @"01"
            },
            @{
                @"area": @"Kuwait 🇰🇼",
                @"code": @"KW",
                @"mcc": @"419",
                @"mnc": @"02"
            },
            @{
                @"area": @"Algeria 🇩🇿",
                @"code": @"DZ",
                @"mcc": @"603",
                @"mnc": @"01"
            }
        ];

        PSSpecifier *feedSection = [self newSectionWithTitle:@"Feed" footer:nil];
        PSSpecifier *profileSection = [self newSectionWithTitle:@"Profile" footer:nil];
        PSSpecifier *countrySection = [self newSectionWithTitle:@"Country" footer:nil];
        PSSpecifier *confirmationSection = [self newSectionWithTitle:@"Confirmation" footer:nil];
        PSSpecifier *fakeSection = [self newSectionWithTitle:@"Fake" footer:@"if you want the default value leave it blank."];
        PSSpecifier *securitySection = [self newSectionWithTitle:@"Security" footer:nil];
        PSSpecifier *developer = [self newSectionWithTitle:@"Developer" footer:nil];
        
        PSSpecifier *hideAds = [self newSwitchCellWithTitle:@"No Ads" detailTitle:@"Remove all Ads from TikTok app" key:@"hide_ads" defaultValue:true changeAction:nil];
        PSSpecifier *downloadVid = [self newSwitchCellWithTitle:@"Download Videos" detailTitle:@"Download Videos by log press in any video you want." key:@"dw_videos" defaultValue:true changeAction:nil];
        PSSpecifier *downloadMis = [self newSwitchCellWithTitle:@"Download Musics" detailTitle:@"Download Musics by log press in any video you want." key:@"dw_musics" defaultValue:true changeAction:nil];
        PSSpecifier *hideElementButton = [self newSwitchCellWithTitle:@"Show/Hide UI button" detailTitle:@"A button on the main page to remove UI elements" key:@"remove_elements_button" defaultValue:true changeAction:nil];
        PSSpecifier *copyVideoDecription = [self newSwitchCellWithTitle:@"Copy video decription" detailTitle:@"Show new option in long press to copy the video decription" key:@"copy_decription" defaultValue:true changeAction:nil];
        PSSpecifier *copyVideoLink = [self newSwitchCellWithTitle:@"Copy video link" detailTitle:@"Show new option in long press to copy the video link" key:@"copy_video_link" defaultValue:true changeAction:nil];
        PSSpecifier *copyMusicLink = [self newSwitchCellWithTitle:@"Copy Music link" detailTitle:@"Show new option in long press to copy the music link" key:@"copy_music_link" defaultValue:true changeAction:nil];
        PSSpecifier *autoPlay = [self newSwitchCellWithTitle:@"Auto Play Next Video" detailTitle:@"Play next video automatcilly when the post is finished" key:@"auto_play" defaultValue:false changeAction:nil];
        PSSpecifier *progressBar = [self newSwitchCellWithTitle:@"Show progress bar" detailTitle:nil key:@"show_porgress_bar" defaultValue:true changeAction:nil];
        PSSpecifier *likeConfirmation = [self newSwitchCellWithTitle:@"Confirm like" detailTitle:@"Show alert when you click the like button to confirm the like" key:@"like_confirm" defaultValue:false changeAction:nil];
        PSSpecifier *likeCommentConfirmation = [self newSwitchCellWithTitle:@"Confirm comment like" detailTitle:@"Show alert when you click the like button in comment to confirm the like" key:@"like_comment_confirm" defaultValue:false changeAction:nil];
        PSSpecifier *dislikeCommentConfirmation = [self newSwitchCellWithTitle:@"Confirm comment dislike" detailTitle:@"Show alert when you click the dislike button in comment to confirm the like" key:@"dislike_comment_confirm" defaultValue:false changeAction:nil];
        PSSpecifier *followConfirmation = [self newSwitchCellWithTitle:@"Confirm follow" detailTitle:@"Show alert when you click the follow button to confirm the like" key:@"follow_confirm" defaultValue:false changeAction:nil];

        PSSpecifier *profileSave = [self newSwitchCellWithTitle:@"Save profile image" detailTitle:@"Save profile image by long press." key:@"save_profile" defaultValue:true changeAction:nil];
        PSSpecifier *profileCopy = [self newSwitchCellWithTitle:@"Copy profile information" detailTitle:@"Copy profile information by long press." key:@"copy_profile_information" defaultValue:true changeAction:nil];
        PSSpecifier *extendedBio = [self newSwitchCellWithTitle:@"Extend bio" detailTitle:@"Extend the bio letters by 222 characters" key:@"extended_bio" defaultValue:true changeAction:nil];
        PSSpecifier *extendedComment = [self newSwitchCellWithTitle:@"Extend comment" detailTitle:@"Extend the comment letters by 240 characters" key:@"extended_comment" defaultValue:true changeAction:nil];
        PSSpecifier *alwaysOpenSafari = [self newSwitchCellWithTitle:@"Always open in Safari" detailTitle:@"Force twitter to open URLs in Safari or your default browser." key:@"openInBrowser" defaultValue:false changeAction:nil];
        
        PSSpecifier *regionSwitch = [self newSwitchCellWithTitle:@"Enable changing region" detailTitle:nil key:@"en_region" defaultValue:false changeAction:nil];
        PSSpecifier *regions = [self newLinkListCellWithTitle:@"Regions" key:@"region" defaultValue:@0 dynamicRule:@"en_region, ==, 0" validTitles:regionTitles validValues:regionCodes];
        
        PSSpecifier *fakeVerified = [self newSwitchCellWithTitle:@"Fake verify blue mark" detailTitle:nil key:@"fake_verify" defaultValue:false changeAction:nil];
        PSSpecifier *fakeChangesEnabled = [self newSwitchCellWithTitle:@"Enable fake options" detailTitle:nil key:@"en_fake" defaultValue:false changeAction:nil];
        PSSpecifier *followerCount = [self newEditTextCellWithLabel:@"Follower count" placeholder:nil keyboardType:@"decimalPad" dynamicRule:@"en_fake, ==, 0" key:@"follower_count"];
        PSSpecifier *followingCount = [self newEditTextCellWithLabel:@"Following count" placeholder:nil keyboardType:@"decimalPad" dynamicRule:@"en_fake, ==, 0" key:@"following_count"];

        PSSpecifier *appLock = [self newSwitchCellWithTitle:@"Padlock" detailTitle:@"Lock TikTok with passcode" key:@"padlock" defaultValue:false changeAction:nil];
        
        // dvelopers section
        PSSpecifier *bandarHL = [self newHBTwitterCellWithTitle:@"BandarHelal" twitterUsername:@"BandarHL" customAvatarURL:@"https://unavatar.io/twitter/BandarHL"];
        PSSpecifier *tipJar = [self newHBLinkCellWithTitle:@"Tip Jar" detailTitle:@"Donate Via Paypal" url:@"https://www.paypal.me/BandarHL"];
        
        _specifiers = [NSMutableArray arrayWithArray:@[
            
            feedSection, // 1
            hideAds,
            downloadVid,
            downloadMis,
            hideElementButton,
            copyVideoDecription,
            copyVideoLink,
            copyMusicLink,
            autoPlay,
            progressBar,

            profileSection, // 2
            profileSave,
            profileCopy,
            extendedBio,
            extendedComment,

            confirmationSection, // 3
            likeConfirmation,
            likeCommentConfirmation,
            dislikeCommentConfirmation,
            followConfirmation,

            countrySection, // 4
            regionSwitch,
            regions,

            fakeSection, // 5
            fakeVerified,
            fakeChangesEnabled,
            followerCount,
            followingCount,
            
            securitySection, // 6
            alwaysOpenSafari,
            appLock,
            
            developer, // 7
            bandarHL,
            tipJar,
        ]];
        
        [self collectDynamicSpecifiersFromArray:_specifiers];
    }
    
    return _specifiers;
}
- (void)reloadSpecifiers {
    [super reloadSpecifiers];
    
    [self collectDynamicSpecifiersFromArray:self.specifiers];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasDynamicSpecifiers) {
        PSSpecifier *dynamicSpecifier = [self specifierAtIndexPath:indexPath];
        BOOL __block shouldHide = false;
        
        [self.dynamicSpecifiers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableArray *specifiers = obj;
            if ([specifiers containsObject:dynamicSpecifier]) {
                shouldHide = [self shouldHideSpecifier:dynamicSpecifier];
                
                UITableViewCell *specifierCell = [dynamicSpecifier propertyForKey:PSTableCellKey];
                specifierCell.clipsToBounds = shouldHide;
            }
        }];
        if (shouldHide) {
            return 0;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void)collectDynamicSpecifiersFromArray:(NSArray *)array {
    if (!self.dynamicSpecifiers) {
        self.dynamicSpecifiers = [NSMutableDictionary new];
        
    } else {
        [self.dynamicSpecifiers removeAllObjects];
    }
    
    for (PSSpecifier *specifier in array) {
        NSString *dynamicSpecifierRule = [specifier propertyForKey:@"dynamicRule"];
        
        if (dynamicSpecifierRule.length > 0) {
            NSArray *ruleComponents = [dynamicSpecifierRule componentsSeparatedByString:@", "];
            
            if (ruleComponents.count == 3) {
                NSString *opposingSpecifierID = [ruleComponents objectAtIndex:0];
                if ([self.dynamicSpecifiers objectForKey:opposingSpecifierID]) {
                    NSMutableArray *specifiers = [[self.dynamicSpecifiers objectForKey:opposingSpecifierID] mutableCopy];
                    [specifiers addObject:specifier];
                    
                    
                    [self.dynamicSpecifiers removeObjectForKey:opposingSpecifierID];
                    [self.dynamicSpecifiers setObject:specifiers forKey:opposingSpecifierID];
                } else {
                    [self.dynamicSpecifiers setObject:[NSMutableArray arrayWithArray:@[specifier]] forKey:opposingSpecifierID];
                }
                
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"dynamicRule key requires three components (Specifier ID, Comparator, Value To Compare To). You have %ld of 3 (%@) for specifier '%@'.", ruleComponents.count, dynamicSpecifierRule, [specifier propertyForKey:PSTitleKey]];
            }
        }
    }
    
    self.hasDynamicSpecifiers = (self.dynamicSpecifiers.count > 0);
}
- (DynamicSpecifierOperatorType)operatorTypeForString:(NSString *)string {
    NSDictionary *operatorValues = @{ @"==" : @(EqualToOperatorType), @"!=" : @(NotEqualToOperatorType), @">" : @(GreaterThanOperatorType), @"<" : @(LessThanOperatorType) };
    return [operatorValues[string] intValue];
}
- (BOOL)shouldHideSpecifier:(PSSpecifier *)specifier {
    if (specifier) {
        NSString *dynamicSpecifierRule = [specifier propertyForKey:@"dynamicRule"];
        NSArray *ruleComponents = [dynamicSpecifierRule componentsSeparatedByString:@", "];
        
        PSSpecifier *opposingSpecifier = [self specifierForID:[ruleComponents objectAtIndex:0]];
        id opposingValue = [self readPreferenceValue:opposingSpecifier];
        id requiredValue = [ruleComponents objectAtIndex:2];
        
        if ([opposingValue isKindOfClass:NSNumber.class]) {
            DynamicSpecifierOperatorType operatorType = [self operatorTypeForString:[ruleComponents objectAtIndex:1]];
            
            switch (operatorType) {
                case EqualToOperatorType:
                    return ([opposingValue intValue] == [requiredValue intValue]);
                    break;
                    
                case NotEqualToOperatorType:
                    return ([opposingValue intValue] != [requiredValue intValue]);
                    break;
                    
                case GreaterThanOperatorType:
                    return ([opposingValue intValue] > [requiredValue intValue]);
                    break;
                    
                case LessThanOperatorType:
                    return ([opposingValue intValue] < [requiredValue intValue]);
                    break;
            }
        }
        
        if ([opposingValue isKindOfClass:NSString.class]) {
            return [opposingValue isEqualToString:requiredValue];
        }
        
        if ([opposingValue isKindOfClass:NSArray.class]) {
            return [opposingValue containsObject:requiredValue];
        }
    }
    
    return NO;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSUserDefaults *Prefs = [NSUserDefaults standardUserDefaults];
    [Prefs setValue:value forKey:[specifier identifier]];
    
    if (self.hasDynamicSpecifiers) {
        NSString *specifierID = [specifier propertyForKey:PSIDKey];
        PSSpecifier *dynamicSpecifier = [self.dynamicSpecifiers objectForKey:specifierID];
        
        if (dynamicSpecifier) {
            [self.table beginUpdates];
            [self.table endUpdates];
        }
    }
}
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSUserDefaults *Prefs = [NSUserDefaults standardUserDefaults];
    return [Prefs valueForKey:[specifier identifier]]?:[specifier properties][@"default"];
}
@end

@implementation BHButtonTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        NSString *subTitle = [specifier.properties[@"subtitle"] copy];
        BOOL isBig = specifier.properties[@"big"] ? ((NSNumber *)specifier.properties[@"big"]).boolValue : NO;
        self.detailTextLabel.text = subTitle;
        self.detailTextLabel.numberOfLines = isBig ? 0 : 1;
        self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    }
    return self;
}

@end

@implementation BHSwitchTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier])) {
        NSString *subTitle = [specifier.properties[@"subtitle"] copy];
        BOOL isBig = specifier.properties[@"big"] ? ((NSNumber *)specifier.properties[@"big"]).boolValue : NO;
        self.detailTextLabel.text = subTitle;
        self.detailTextLabel.numberOfLines = isBig ? 0 : 1;
        self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        
        if (specifier.properties[@"switchAction"]) {
            UISwitch *targetSwitch = ((UISwitch *)[self control]);
            NSString *strAction = [specifier.properties[@"switchAction"] copy];
            [targetSwitch addTarget:[self cellTarget] action:NSSelectorFromString(strAction) forControlEvents:UIControlEventValueChanged];
        }
    }
    return self;
}
@end
