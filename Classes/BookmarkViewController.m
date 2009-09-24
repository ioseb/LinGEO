//
//  BookmarkViewController.m
//  LinGEO
//

#import "LinGEOAppDelegate.h"
#import "BookmarkViewController.h"
#import "BookmarkDetailViewController.h"
#import "Bookmark.h"


@interface SortedBookmarks : NSObject {
	NSMutableArray *keys;
	NSMutableDictionary *mappings;
}

@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableDictionary *mappings;

- (id)initWithBookmarks:(NSMutableArray *)bookmarks;
- (int)numberOfRowsInSection:(int)section;
- (NSString *)sectionTitle:(int)section;
- (BOOL) rmeoveBookmark:(int)section row:(int)row;
- (Bookmark *)bookmarkForSection:(int)section row:(int)row;

@end

@implementation SortedBookmarks

@synthesize keys, mappings;

- (id)initWithBookmarks:(NSMutableArray *)bookmarks {
	
	[super init];
	
	keys = [[NSMutableArray alloc] init];
	mappings = [[NSMutableDictionary alloc] init];
	
	int i;
	
	for (i = 0; i < [bookmarks count]; i++) {
		
		Bookmark *bookmark = (Bookmark *)[bookmarks objectAtIndex:i];
		NSString *chr = [[[NSString alloc] initWithFormat:@"%c", [bookmark.eng characterAtIndex:0]] lowercaseString];
		
		if ([mappings objectForKey:chr] == nil) {
			[keys addObject:chr];
			[mappings setObject:[[NSMutableArray alloc] init] forKey:chr];
		}
		
		[(NSMutableArray *)[mappings objectForKey:chr] addObject:[bookmarks objectAtIndex:i]];
		
	}
	
	return self;
	
}

- (int)numberOfRowsInSection:(int)section {
	if ([keys count] > 0) {
		return [(NSMutableArray *)[mappings objectForKey:[keys objectAtIndex:section]] count];
	}
	return 0;
}

- (NSString *)sectionTitle:(int)section {
	if ([keys count] > 0) {
		NSString *chr = (NSString *)[keys objectAtIndex:section];
		NSMutableString *title = [NSMutableString stringWithString:chr];
		[title appendString:@" - "];
		[title appendString:[chr uppercaseString]];
		return title;
	}
	return @"List is Empty";
}

// Return YES if removed entire section, otherwise NO
- (BOOL) rmeoveBookmark:(int)section row:(int)row {
    if ([keys count] > 0) {
        
        NSString *chr = (NSString *)[keys objectAtIndex:section];
        NSMutableArray *values = [mappings objectForKey:chr];
        [values removeObjectAtIndex:row];
        
        if([values count] == 0) {
            [keys removeObjectAtIndex:section];    
            return YES;
        }
    }
    
    return NO;
}

- (Bookmark *)bookmarkForSection:(int)section row:(int)row {
    if ([keys count] > 0) {
        return (Bookmark *)[(NSMutableArray *)[mappings objectForKey:[keys objectAtIndex:section]] objectAtIndex:row];
    }
    
    return nil;
}

- (NSString *)titleForRow:(int)section row:(int)row {
	if ([keys count] > 0) {
		return [[self bookmarkForSection:section row:row] eng];
	}
	return nil;	
}

- (void) dealloc {
	[keys release];
	[mappings release];
	[super dealloc];
}

@end


@interface BookmarkViewController()
SortedBookmarks *sortedBookmarks;
@end


@implementation BookmarkViewController

@synthesize aTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
	self.title = @"Bookmarks";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	LinGEOAppDelegate *delegate = (LinGEOAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (sortedBookmarks != nil) {
		[sortedBookmarks release];
	}
	sortedBookmarks = [[SortedBookmarks alloc] initWithBookmarks:delegate.bookmarks];
	[sortedBookmarks retain];

    [self updateBarButtons];
    
	[aTableView reloadData];
}

- (void)updateBarButtons {
    if ([sortedBookmarks.keys count] == 0) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    [self.aTableView setEditing:editing animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sortedBookmarks.keys count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sortedBookmarks numberOfRowsInSection:(int)section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sortedBookmarks sectionTitle:(int)section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSString *cellText = [sortedBookmarks titleForRow:(int)indexPath.section row:(int)indexPath.row];
	if (cellText) {
		cell.textLabel.text = cellText;
	}
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView
					commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
					forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {

        [aTableView beginUpdates];
        
		LinGEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		Bookmark *bookmark = [sortedBookmarks bookmarkForSection:(int)indexPath.section row:indexPath.row];
        
        [delegate deleteBookmark:bookmark];
        
        if( [sortedBookmarks rmeoveBookmark:indexPath.section row:indexPath.row] == YES ) {
            [aTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];        
        } else {
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [aTableView endUpdates];
        
        [self updateBarButtons];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BookmarkDetailViewController *detailView = [[BookmarkDetailViewController alloc] initWithNibName:@"BookmarkDetailView" bundle:nil];
	detailView.bookmark = [sortedBookmarks bookmarkForSection:(int)indexPath.section row:indexPath.row];
	[self.navigationController pushViewController:detailView animated:YES];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[aTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Wargning in BookmarkViewController");
}


- (void)dealloc {
	[aTableView release];
	[sortedBookmarks release];
	[super dealloc];
}


@end
