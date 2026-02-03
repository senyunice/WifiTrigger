#import <Foundation/Foundation.h>
#import <Preferences/PSListController.h>

@interface WifiTriggerRootListController : PSListController
@end

@implementation WifiTriggerRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

@end