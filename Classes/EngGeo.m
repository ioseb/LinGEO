//
//  EngGeo.m
//  LinGO
//

#import "EngGeo.h"

@implementation EngGeo

@synthesize pk, eng, transcription, type, types, geo;

- (id)init {
	[super init];
	self.types = [[NSMutableArray alloc] init];
	self.geo = [[NSMutableArray alloc] init];
	return [self autorelease];
}

- (void) addGeo:(NSString *)word {
	[geo addObject:word];
}

- (void) addGeo:(NSString *)word type:(NSString *)typeName {
	[geo addObject:word];
	[types addObject:typeName];
}

- (void)dealloc {
	[geo release];
	[type release];
	[types release];
	[transcription release];
	[eng release];
	[super dealloc];
}

@end
