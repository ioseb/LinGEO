//
//  LinGEOAppDelegate.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "RootViewController.h"
#import "BookmarkViewController.h"
#import "EngGeo.h"
#import "Bookmark.h"

static NSDictionary *map = nil;

@interface LinGEOAppDelegate()
- (void) loadAllBookmarks;
+ (NSString *) convertToKA:(NSString *)str;
- (void)showSplashView;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@interface UINavigationBar (MyCustomNavBar)
@end
@implementation UINavigationBar (MyCustomNavBar)
- (void) drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"background.png"];
    [barImage drawInRect:rect];
}
@end

@implementation LinGEOAppDelegate

@synthesize window, navigationController, result, bookmarks;


- (id)init {
	if (self = [super init]) {
		// 
	}
	return self;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    [self openDatabase];
    
	[self loadAllBookmarks];
	    
    // Set navigation button color
    [[navigationController navigationBar] setTintColor:[UIColor colorWithRed:51.0f/255.0f green:24.0f/255.0f blue:10.0f/255.0f alpha:1.0f]];
    
    [window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
    
    [self showSplashView];
}

// Open readonly database from main Bundle
- (void)openDatabase
{
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ilingoka.sqlite"];    
    if (sqlite3_open([defaultDBPath UTF8String], &database ) != SQLITE_OK) {
		NSLog(@"Error: failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
    
    if (sqlite3_close(databaseBookmark) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(databaseBookmark));
    }
}

+ (NSString *)convertToKA:(NSString *)str {
    
    if(map == nil) {
        map = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"ა", @"ბ", @"გ", @"დ", @"ე", @"ვ", @"ზ", @"თ", @"ი", @"კ", @"ლ", @"მ",
                                                                             @"ნ", @"ო", @"პ", @"ჟ", @"რ", @"ს", @"ტ", @"უ", @"ფ", @"ქ", @"ღ", @"ყ", 
                                                                             @"შ", @"ჩ", @"ც", @"ძ", @"წ", @"ჭ", @"ხ", @"ჯ", @"ჰ", @"ჩ", nil] 
                                           forKeys:[NSArray arrayWithObjects:@"a", @"b", @"g", @"d", @"e", @"v", @"z", @"T", @"i", @"k", @"l", @"m", 
                                                                             @"n", @"o", @"p", @"J", @"r", @"s", @"t", @"u", @"f", @"q", @"R", @"y", 
                                                                             @"S", @"C", @"c", @"Z", @"w", @"W", @"x", @"j", @"h", @"G", nil] ] retain];
    }
	
	NSMutableString *ret = [[[NSMutableString alloc] init] autorelease];
	int i;	
	
	for (i = 0; i < [str length]; i++) {
		
		NSString *chr = [NSString stringWithFormat:@"%c", [str characterAtIndex:i]];
		NSString *tmp = (NSString *)[map objectForKey:chr];
		
		if (tmp != nil) {
			[ret appendString:tmp];
		} else {
			[ret appendString:chr];
		}
		
	}
	
	return ret;
}

- (void)search:(NSString *)word {
	
    self.result = [NSMutableArray arrayWithCapacity:30];
	
	if ([word length] == 0) return;
	
	const char *sql = "SELECT t1.id, t1.eng, t1.transcription, t2.geo, t4.name, t4.abbr FROM eng t1, geo t2, geo_eng t3, types t4 WHERE t1.eng >= ? AND t3.eng_id=t1.id AND t2.id=t3.geo_id AND t4.id=t2.type ORDER BY t1.eng LIMIT 20";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		
		//NSMutableString *bindValue = [[NSMutableString alloc] initWithString:word];
		NSMutableString *bindValue = [NSMutableString stringWithString:word];
		//[bindValue appendString:@"%"];
		
		sqlite3_bind_text(statement, 1, [(NSString *)bindValue UTF8String], -1, SQLITE_TRANSIENT);

		while (sqlite3_step(statement) == SQLITE_ROW) {

			NSString *eng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *geo = [LinGEOAppDelegate convertToKA:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
			EngGeo *prev = nil;
			
			if ([self.result count] > 0) {
				prev = (EngGeo *)[self.result objectAtIndex:[self.result count] - 1];
			}
			
			if (prev && [prev.eng isEqualToString:eng]) {
				[prev addGeo:geo type:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
			} else {
				EngGeo *item = [[EngGeo alloc] init];
				item.pk = (NSInteger *)sqlite3_column_int(statement, 0);
				item.eng = eng;
				item.transcription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				item.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
				[item addGeo:geo type:item.type];
				[self.result addObject:item];
			}
			
		}
        
		
	} else {
		//NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_finalize(statement);
        
	
}

- (void)addToBookmarks:(EngGeo *)trn {
	
	const char *sql = "INSERT INTO bookmark (rid,eng,type,geo,date,transcription) VALUES (?,?,?,?,datetime('now'),?)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL) == SQLITE_OK) {
		
		sqlite3_bind_int(statement, 1, (int)trn.pk);
		sqlite3_bind_text(statement, 2, [(NSString *)trn.eng UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [(NSString *)[trn.types componentsJoinedByString:@"~"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 4, [(NSString *)[trn.geo componentsJoinedByString:@"~"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 5, [(NSString *)trn.transcription UTF8String], -1, SQLITE_TRANSIENT);
		
		int success = sqlite3_step(statement);
		
		if (success == SQLITE_ERROR) {
			//NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(databaseBookmark));
		} else {
			//NSLog(@"Primary Key: %d", sqlite3_last_insert_rowid(databaseBookmark));
		}
		
		sqlite3_finalize(statement);
		
	} else {
		//NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(databaseBookmark));
	}
	
	[self loadAllBookmarks];
	
}

- (void)loadAllBookmarks {
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"ilingoka_bookmarks.sqlite"];
    BOOL success = [fileManager fileExistsAtPath:path];
    
    if (sqlite3_open([path UTF8String], &databaseBookmark ) == SQLITE_OK) {
	
        if( !success ) {
            [self createBookmarkTable];
        } else {
        
            [self.bookmarks release];
             self.bookmarks = [[NSMutableArray alloc] init];
            [self.bookmarks retain];
        
            const char *sql = "SELECT id, rid, eng, type, geo, date, transcription FROM bookmark ORDER BY eng, date DESC";
            sqlite3_stmt *statement;
        
            if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL) == SQLITE_OK) {
                
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    Bookmark *item = [[Bookmark alloc] init];
                    item.pk = (NSInteger *)sqlite3_column_int(statement, 0);
                    item.rid = (NSInteger *)sqlite3_column_int(statement, 1);
                    item.eng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    item.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
                    item.types = [item.type componentsSeparatedByString:@"~"];
                    item.geo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
                    item.geoArray = [item.geo componentsSeparatedByString:@"~"];
                    item.date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
                    item.transcription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
                    [self.bookmarks addObject:item];
                }
            
            }  else {
                NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(databaseBookmark));
            }
            
            sqlite3_finalize(statement);
        }
	
	}
	
}

- (BOOL)bookmarkExists:(int)rid {
	
	BOOL ret = NO;
	const char *sql = "SELECT rid FROM bookmark WHERE rid=?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, rid);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			ret = YES;
		}
	} else {
		NSLog(@"SQLite Statement Prepare Error: ", sqlite3_errmsg(databaseBookmark));
	}
	
	sqlite3_finalize(statement);
		
	return ret;
	
}

- (int)countForBookmarks {
	
	const char *sql = "SELECT COUNT(*) AS bcount FROM bookmark";
	sqlite3_stmt *statement;
	int bcount = 0;
	
	if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL)) {
		sqlite3_step(statement);
		bcount = sqlite3_column_int(statement, 0);
	}
	
	sqlite3_finalize(statement);
	
	return bcount;
	
}

- (void)deleteBookmark:(Bookmark *)bookmark {
	
	const char *sql = "DELETE FROM bookmark WHERE id=?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, (int)bookmark.pk);
		sqlite3_step(statement);
		[self loadAllBookmarks];
	}
		
	sqlite3_finalize(statement);
}
            
- (void)createBookmarkTable {
    
    const char *sql = "CREATE TABLE `bookmark` (`id` INTEGER PRIMARY KEY  DEFAULT '', `rid` INTEGER DEFAULT '', \
    `eng` VARCHAR DEFAULT '', `type` CHAR DEFAULT '', `geo` VARCHAR DEFAULT '', `date` DATETIME DEFAULT '', `transcription` VARCHAR DEFAULT '')";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(databaseBookmark, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}
            

- (void)dealloc {
	[navigationController release];
	[window release];
	[bookmarks release];
	[result release];
	[map release];
	[super dealloc];
}

#pragma mark -
#pragma mark Splash screen methods

- (void)showSplashView {
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    splashView.alpha = 0.0;
    splashView.frame = CGRectMake(-60, -60, 440, 600);
    [UIView commitAnimations];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [splashView removeFromSuperview];
    [splashView release];
}

@end
