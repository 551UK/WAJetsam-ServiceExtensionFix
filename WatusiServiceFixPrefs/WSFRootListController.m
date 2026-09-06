#import "WSFRootListController.h"

#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

static NSString * const WSFPrefsDomain = @"com.551.wajetsamserviceextensionfix";

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
        titleLabel.text = @"WAJetsam&ServiceExtensionFIx";
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
        self.title = @"WAJetsam&ServiceExtensionFIx";
    }
}

- (NSArray *)specifiers {
    if (_specifiers) return _specifiers;

    NSMutableArray *specifiers = [NSMutableArray array];

    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"WAJetsam&ServiceExtensionFIx"];
    [group setProperty:@"Prevents WatusiTools' checkExpiryDate worker from closing WhatsApp's ServiceExtension, which can leave messages stuck on one tick. A 40 MB ServiceExtension memory floor is also kept active."
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
    [note setProperty:@"The switch controls the Watusi exit patch. Changes apply the next time WhatsApp's ServiceExtension starts. The 40 MB memory floor remains enabled."
               forKey:@"footerText"];
    [specifiers addObject:note];

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

@end
