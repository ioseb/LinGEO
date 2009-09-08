//
//  LinGOAppDelegate.m
//  LinGOs
//
//  Created by Mr.Woods on 8/2/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "LinGOAppDelegate.h"
#import "RootViewController.h"
#import "BookmarkViewController.h"
#import "EngGeo.h"
#import "Bookmark.h"
#import "MapTable.h";

static MapTable *map = nil;

@interface LinGOAppDelegate()
- (void) createEditableCopyOfDatabaseIfNeeded;
- (void) loadAllBookmarks;
+ (NSString *) convertToKA:(NSString *)str;
@end

@implementation LinGOAppDelegate

@synthesize window, navigationController, result, bookmarks;


- (id)init {
	if (self = [super init]) {
		// 
	}
	return self;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self createEditableCopyOfDatabaseIfNeeded];
	[self loadAllBookmarks];
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"ilingoka.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ilingoka.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

+ (NSString *)convertToKA:(NSString *)str {
	
	if (map == nil) {
		map = [[MapTable alloc] init];
		[map setObject:@"ა" forKey:@"a"];
		[map setObject:@"ბ" forKey:@"b"];
		[map setObject:@"გ" forKey:@"g"];
		[map setObject:@"დ" forKey:@"d"];
		[map setObject:@"ე" forKey:@"e"];
		[map setObject:@"ვ" forKey:@"v"];
		[map setObject:@"ზ" forKey:@"z"];
		[map setObject:@"თ" forKey:@"T"];
		[map setObject:@"ი" forKey:@"i"];
		[map setObject:@"კ" forKey:@"k"];
		[map setObject:@"ლ" forKey:@"l"];
		[map setObject:@"მ" forKey:@"m"];
		[map setObject:@"ნ" forKey:@"n"];
		[map setObject:@"ო" forKey:@"o"];
		[map setObject:@"პ" forKey:@"p"];
		[map setObject:@"ჟ" forKey:@"J"];
		[map setObject:@"რ" forKey:@"r"];
		[map setObject:@"ს" forKey:@"s"];
		[map setObject:@"ტ" forKey:@"t"];
		[map setObject:@"უ" forKey:@"u"];
		[map setObject:@"ფ" forKey:@"f"];
		[map setObject:@"ქ" forKey:@"q"];
		[map setObject:@"ღ" forKey:@"R"];
		[map setObject:@"ყ" forKey:@"y"];
		[map setObject:@"შ" forKey:@"S"];
		[map setObject:@"ჩ" forKey:@"C"];
		[map setObject:@"ც" forKey:@"c"];
		[map setObject:@"ძ" forKey:@"Z"];
		[map setObject:@"წ" forKey:@"w"];
		[map setObject:@"ჭ" forKey:@"W"];
		[map setObject:@"ხ" forKey:@"x"];
		[map setObject:@"ჯ" forKey:@"j"];
		[map setObject:@"ჰ" forKey:@"h"];
		[map setObject:@"ჩ" forKey:@"G"];
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
	
	const char *sql = "SELECT DISTINCT t1.id, t1.eng, t1.transcription, t2.geo, t4.name, t4.abbr FROM eng t1, geo t2, geo_eng t3, types t4 WHERE t1.eng LIKE ? AND t3.eng_id=t1.id AND t2.id=t3.geo_id AND t4.id=t2.type ORDER BY t1.eng LIMIT 30";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		
		//NSMutableString *bindValue = [[NSMutableString alloc] initWithString:word];
		NSMutableString *bindValue = [NSMutableString stringWithString:word];
		[bindValue appendString:@"%"];
		
		sqlite3_bind_text(statement, 1, [(NSString *)bindValue UTF8String], -1, SQLITE_TRANSIENT);
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			NSString *eng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *geo = [LinGOAppDelegate convertToKA:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
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
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		
		sqlite3_bind_int(statement, 1, (int)trn.pk);
		sqlite3_bind_text(statement, 2, [(NSString *)trn.eng UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [(NSString *)[trn.types componentsJoinedByString:@"~"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 4, [(NSString *)[trn.geo componentsJoinedByString:@"~"] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 5, [(NSString *)trn.transcription UTF8String], -1, SQLITE_TRANSIENT);
		
		int success = sqlite3_step(statement);
		
		if (success == SQLITE_ERROR) {
			//NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		} else {
			//NSLog(@"Primary Key: %d", sqlite3_last_insert_rowid(database));
		}
		
		sqlite3_finalize(statement);
		
	} else {
		//NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
	}
	
	[self loadAllBookmarks];
	
}

- (void)loadAllBookmarks {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"ilingoka.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
	
		[self.bookmarks release];
		self.bookmarks = [[NSMutableArray alloc] init];
		[self.bookmarks retain];
	
		const char *sql = "SELECT id, rid, eng, type, geo, date, transcription FROM bookmark ORDER BY eng, date DESC";
		sqlite3_stmt *statement;
	
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			
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
			NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		}
		
		sqlite3_finalize(statement);
	
	}
	
}

- (BOOL)bookmarkExists:(int)rid {
	
	BOOL ret = NO;
	const char *sql = "SELECT rid FROM bookmark WHERE rid=?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, rid);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			ret = YES;
		} else {
			NSLog(@"SQLite Step Error: ", sqlite3_errmsg(database));
		}
	} else {
		NSLog(@"SQLite Statement Prepare Error: ", sqlite3_errmsg(database));
	}
	
	sqlite3_finalize(statement);
		
	return ret;
	
}

- (int)countForBookmarks {
	
	const char *sql = "SELECT COUNT(*) AS bcount FROM bookmark";
	sqlite3_stmt *statement;
	int bcount = 0;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL)) {
		sqlite3_step(statement);
		bcount = sqlite3_column_int(statement, 0);
	}
	
	sqlite3_finalize(statement);
	
	return bcount;
	
}

- (void)deleteBookmark:(Bookmark *)bookmark {
	
	const char *sql = "DELETE FROM bookmark WHERE id=?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, (int)bookmark.pk);
		sqlite3_step(statement);
		[self loadAllBookmarks];
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

@end
