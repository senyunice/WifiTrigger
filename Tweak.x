#import <UIKit/UIKit.h>
#include <spawn.h>
#include <unistd.h>

extern char **environ;

@interface SBWiFiManager : NSObject
+(id)sharedInstance;
-(id)currentNetworkSSID;
@end

static void runShortcut(NSString *name) {
	if (!name || [name isEqualToString:@""]) return;
	
	// 使用 posix_spawn 替代 system() 函数，因为 system() 在 iOS 上不可用
	pid_t pid;
	char * const args[] = {"/var/jb/usr/bin/shortcuts", "run", (char *)[name UTF8String], NULL};
	posix_spawn(&pid, "/var/jb/usr/bin/shortcuts", NULL, NULL, args, environ);
}

static NSString *lastSSID = @"";

%hook SBWiFiManager
-(void)_updateWiFiState {
	%orig;
	
	// 读取多巴胺环境下的偏好设置 plist
	NSString *settingsPath = @"/var/jb/var/mobile/Library/Preferences/com.tom.wifitrigger.plist";
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
	
	// 检查插件是否启用
	if (!settings || ![settings[@"enabled"] boolValue]) return;
	
	NSString *targetWifi = settings[@"targetWifi"];
	NSString *targetShortcut = settings[@"targetShortcut"];
	NSString *currentSSID = [self currentNetworkSSID];
	
	// 连接状态改变且匹配目标WiFi时触发
	if (currentSSID && ![currentSSID isEqualToString:lastSSID]) {
		if ([currentSSID isEqualToString:targetWifi]) {
			runShortcut(targetShortcut);
		}
		lastSSID = [currentSSID copy];
	} else if (!currentSSID) {
		lastSSID = @"";
	}
}
%end