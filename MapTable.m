//
//  MapTable.m
//  LinGO
//

#import "MapTable.h"

@implementation MapTable 

@synthesize keys, values;

- (id) init {
	[super init];
	keys = [[NSMutableArray alloc] init];
	values = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc {
	[keys release];
	keys = nil;
	[values release];
	keys = nil;
	[super dealloc];
}

- (id) objectForKey:(id)k {
	
	NSInteger index = [keys indexOfObject:k];
	
	if (index != NSNotFound) {
		return [values objectAtIndex:index];
	}
	
	return nil;
	
}

- (void) setObject:(id)v forKey:(id)k {
	
	NSInteger index = [keys indexOfObject:k];
	
	if (index != NSNotFound) {
		[values insertObject:v atIndex:index];
	} else {
		[keys addObject:k];
		[values addObject:v];
	}

}

@end
