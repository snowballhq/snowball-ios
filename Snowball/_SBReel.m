// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBReel.m instead.

#import "_SBReel.h"

const struct SBReelAttributes SBReelAttributes = {
	.homeFeedSession = @"homeFeedSession",
	.name = @"name",
	.remoteID = @"remoteID",
	.updatedAt = @"updatedAt",
};

const struct SBReelRelationships SBReelRelationships = {
	.clips = @"clips",
	.participants = @"participants",
	.recentParticipants = @"recentParticipants",
};

const struct SBReelFetchedProperties SBReelFetchedProperties = {
};

@implementation SBReelID
@end

@implementation _SBReel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Reel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Reel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Reel" inManagedObjectContext:moc_];
}

- (SBReelID*)objectID {
	return (SBReelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic homeFeedSession;






@dynamic name;






@dynamic remoteID;






@dynamic updatedAt;






@dynamic clips;

	
- (NSMutableSet*)clipsSet {
	[self willAccessValueForKey:@"clips"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"clips"];
  
	[self didAccessValueForKey:@"clips"];
	return result;
}
	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	

@dynamic recentParticipants;

	
- (NSMutableOrderedSet*)recentParticipantsSet {
	[self willAccessValueForKey:@"recentParticipants"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"recentParticipants"];
  
	[self didAccessValueForKey:@"recentParticipants"];
	return result;
}
	






@end
