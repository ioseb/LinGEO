//
//  BookmarkDetailViewController.m
//  LinGO
//
//  Created by Mr.Woods on 8/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkDetailViewController.h"
#import "LinGOAppDelegate.h"
#import "BookmarkViewController.h"

@interface BookmarkDetailViewController() 
- (void) deleteBookmark;
@end

@implementation BookmarkDetailViewController

@synthesize aTableView, bookmark;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0: return 1;
		case 1: return 1;
		case 2: return 1;
		case 3: return [bookmark.geoArray count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0: return @"Save Date";
		case 1: return @"English";
		case 2: return @"Transcription";
		case 3: return @"Georgian";
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	NSDate *date;
	NSMutableString *_geo;
	
	switch(indexPath.section) {
		case 0:
			date = [NSDate dateWithString:[NSString stringWithFormat:@"%@ +0000", bookmark.date]];
			cell.text = [date descriptionWithCalendarFormat:@"%B %e, %Y" timeZone:nil locale:nil];
			break;
		case 1: 
			cell.text = bookmark.eng; 
			break;
		case 2: 
			cell.text = bookmark.transcription; 
			break;
		case 3:
			_geo = [NSMutableString stringWithString:[bookmark.types objectAtIndex:indexPath.row]];
			[_geo appendString:@" - "];
			[_geo appendString:[bookmark.geoArray objectAtIndex:indexPath.row]];
			cell.text = _geo;
			break;
	}
	
	return cell;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
	self.title = @"Details";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
											  initWithTitle:@"Delete" 
											  style:UIBarButtonItemStyleBordered 
											  target:self 
											  action:@selector(deleteBookmark)];
}

- (void)deleteBookmark {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Bookmark?" 
									delegate:self 
									cancelButtonTitle:@"Cancel" 
									destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		LinGOAppDelegate *delegate = (LinGOAppDelegate *)[[UIApplication sharedApplication] delegate];
		[delegate deleteBookmark:self.bookmark];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"Memory Warning in BookmarkDetailView");
}


- (void)dealloc {
	[aTableView release];
	[bookmark release];
	[super dealloc];
}


@end
