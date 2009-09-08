//
//  LinGOAppDelegate.h
//  LinGO
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class EngGeo;
@class Bookmark;

@interface LinGOAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	NSMutableArray *result;
	NSMutableArray *bookmarks;
	sqlite3 *database;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *result;
@property (nonatomic, retain) NSMutableArray *bookmarks;

- (void)search:(NSString *)word;
- (void)addToBookmarks:(EngGeo *)trn;
- (void)deleteBookmark:(Bookmark *)bookmark;
- (BOOL)bookmarkExists:(int)rid;

@end

