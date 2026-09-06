#import "WSFRootListController.h"

#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

static NSString * const WSFPrefsDomain = @"com.551.wajetsamserviceextensionfix";
static NSString * const WSFRepoURL = @"https://github.com/551UK/WAJetsam-ServiceExtensionFix";

@implementation WSFRootListController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIImage *image = [UIImage imageNamed:@"icon.png"
                                inBundle:bundle
           compatibleWithTraitCollection:nil];

    if (image) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:image];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"WAJetsam-ServiceExtensionFix";
        titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        titleLabel.textColor = UIColor.labelColor;

        UIStackView *titleView = [[UIStackView alloc] initWithArrangedSubviews:@[iconView, titleLabel]];
        titleView.axis = UILayoutConstraintAxisHorizontal;
        titleView.alignment = UIStackViewAlignmentCenter;
        titleView.spacing = 6.0;

        [NSLayoutConstraint activateConstraints:@[
            [iconView.widthAnchor constraintEqualToConstant:22.0],
            [iconView.heightAnchor constraintEqualToConstant:22.0]
        ]];

        self.navigationItem.titleView = titleView;
    } else {
        self.title = @"WAJetsam-ServiceExtensionFix";
    }
}

- (NSArray *)specifiers {
    if (_specifiers) return _specifiers;

    NSMutableArray *specifiers = [NSMutableArray array];

    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"WAJetsam-ServiceExtensionFix"];
    [group setProperty:@"Keeps WhatsApp's ServiceExtension stable with a 40 MB memory floor and patches WatusiTools' checkExpiryDate exit path so it returns normally instead of calling _exit(0) and closing the extension."
                forKey:@"footerText"];
    [specifiers addObject:group];

    PSSpecifier *enabled = [PSSpecifier preferenceSpecifierNamed:@"Enable Patch"
                                                           target:self
                                                              set:@selector(setPreferenceValue:specifier:)
                                                              get:@selector(readPreferenceValue:)
                                                           detail:nil
                                                             cell:PSSwitchCell
                                                             edit:nil];
    [enabled setProperty:WSFPrefsDomain forKey:@"defaults"];
    [enabled setProperty:@"Enabled" forKey:@"key"];
    [enabled setProperty:@YES forKey:@"default"];
    [specifiers addObject:enabled];

    PSSpecifier *note = [PSSpecifier groupSpecifierWithName:nil];
    [note setProperty:@"If you use Choicy, make sure WatusiExpiryFix is allowed for net.whatsapp.WhatsApp.ServiceExtension and is not blocked. The switch controls the Watusi exit patch; the 40 MB memory floor remains enabled."
               forKey:@"footerText"];
    [specifiers addObject:note];

    PSSpecifier *repo = [PSSpecifier preferenceSpecifierNamed:@"GitHub Repository"
                                                        target:self
                                                           set:nil
                                                           get:nil
                                                        detail:nil
                                                          cell:PSButtonCell
                                                          edit:nil];
    [repo setButtonAction:@selector(openRepo)];
    [repo setProperty:NSStringFromSelector(@selector(openRepo)) forKey:@"action"];
    [specifiers addObject:repo];

    _specifiers = [specifiers copy];
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *domain = [specifier propertyForKey:@"defaults"] ?: WSFPrefsDomain;
    NSString *key = [specifier propertyForKey:@"key"];
    id defaultValue = [specifier propertyForKey:@"default"];

    if (!key) return defaultValue;

    CFPreferencesAppSynchronize((__bridge CFStringRef)domain);
    CFPropertyListRef value = CFPreferencesCopyAppValue((__bridge CFStringRef)key,
                                                        (__bridge CFStringRef)domain);
    if (value) return CFBridgingRelease(value);
    return defaultValue;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *domain = [specifier propertyForKey:@"defaults"] ?: WSFPrefsDomain;
    NSString *key = [specifier propertyForKey:@"key"];

    if (!key) return;

    CFPreferencesSetAppValue((__bridge CFStringRef)key,
                             (__bridge CFPropertyListRef)value,
                             (__bridge CFStringRef)domain);
    CFPreferencesAppSynchronize((__bridge CFStringRef)domain);
}

- (void)openRepo {
    NSURL *url = [NSURL URLWithString:WSFRepoURL];
    if (!url) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *application = UIApplication.sharedApplication;
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:url options:@{} completionHandler:nil];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [application openURL:url];
#pragma clang diagnostic pop
        }
    });
}

- (void)openRepo:(id)sender {
    (void)sender;
    [self openRepo];
}

@end
