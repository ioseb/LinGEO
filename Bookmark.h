//
//  Bookmark.h
//  LinGEO
//

#import <UIKit/UIKit.h>


@interface Bookmark : NSObject {
	NSInteger *pk;
	NSInteger *rid;
	NSString *eng;
	NSString *transcription;
	NSString *type;
	NSString *geo;
	NSString *date;
	NSArray *types;
	NSArray *geoArray;
}

@property (nonatomic) NSInteger *pk;
@property (nonatomic) NSInteger *rid;
@property (nonatomic, copy) NSString *eng;
@property (nonatomic, copy) NSString *transcription;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *geo;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, retain) NSArray *types;
@property (nonatomic, retain) NSArray *geoArray;

@end
