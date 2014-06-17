// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBUserAttributes {
	__unsafe_unretained NSString *avatarURL;
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *username;
} SBUserAttributes;

extern const struct SBUserRelationships {
	__unsafe_unretained NSString *clips;
	__unsafe_unretained NSString *recentReels;
	__unsafe_unretained NSString *reels;
} SBUserRelationships;

extern const struct SBUserFetchedProperties {
} SBUserFetchedProperties;

@class SBClip;
@class SBReel;
@class SBReel;








@interface SBUserID : NSManagedObjectID {}
@end

@interface _SBUser : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBUserID*)objectID;





@property (nonatomic, strong) NSString* avatarURL;



//- (BOOL)validateAvatarURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* bio;



//- (BOOL)validateBio:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *clips;

- (NSMutableSet*)clipsSet;




@property (nonatomic, strong) NSSet *recentReels;

- (NSMutableSet*)recentReelsSet;




@property (nonatomic, strong) NSSet *reels;

- (NSMutableSet*)reelsSet;





@end

@interface _SBUser (CoreDataGeneratedAccessors)

- (void)addClips:(NSSet*)value_;
- (void)removeClips:(NSSet*)value_;
- (void)addClipsObject:(SBClip*)value_;
- (void)removeClipsObject:(SBClip*)value_;

- (void)addRecentReels:(NSSet*)value_;
- (void)removeRecentReels:(NSSet*)value_;
- (void)addRecentReelsObject:(SBReel*)value_;
- (void)removeRecentReelsObject:(SBReel*)value_;

- (void)addReels:(NSSet*)value_;
- (void)removeReels:(NSSet*)value_;
- (void)addReelsObject:(SBReel*)value_;
- (void)removeReelsObject:(SBReel*)value_;

@end

@interface _SBUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAvatarURL;
- (void)setPrimitiveAvatarURL:(NSString*)value;




- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveClips;
- (void)setPrimitiveClips:(NSMutableSet*)value;



- (NSMutableSet*)primitiveRecentReels;
- (void)setPrimitiveRecentReels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReels;
- (void)setPrimitiveReels:(NSMutableSet*)value;


@end
