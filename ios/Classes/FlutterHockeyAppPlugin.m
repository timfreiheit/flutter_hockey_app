#import "FlutterHockeyAppPlugin.h"
#import <flutter_hockey_app/flutter_hockey_app-Swift.h>

@implementation FlutterHockeyAppPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterHockeyAppPlugin registerWithRegistrar:registrar];
}
@end
