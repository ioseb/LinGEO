//
//  LinGEOAppDelegate.h
//  LinGEO
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class EngGeo;
@class Bookmark;

@interface LinGEOAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
	NSMutableArray *result;
	NSMutableArray *bookmarks;
    
	sqlite3 *database;
	sqlite3 *databaseBookmark;
    
    UIImageView *splashView;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray *result;
@property (nonatomic, retain) NSMutableArray *bookmarks;

- (void)openDatabase;
- (void)search:(NSString *)word;
- (void)addToBookmarks:(EngGeo *)trn;
- (void)deleteBookmark:(Bookmark *)bookmark;
- (void)createBookmarkTable;
- (BOOL)bookmarkExists:(int)rid;

@end

