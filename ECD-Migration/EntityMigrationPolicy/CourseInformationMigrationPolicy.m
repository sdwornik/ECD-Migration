//
// CourseInformationMigrationPolicy.m
// ECD-Migration
//
// Created by Jasper Chan on 2015-09-01.
// Copyright (c) 2015 .. All rights reserved.
//

#import "CourseInformationMigrationPolicy.h"

@implementation CourseInformationMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError *__autoreleasing *)error
{
    NSNumber *modelVersion = [mapping.userInfo valueForKey:@"modelVersion"];
    if (true)
    {
        NSMutableArray *sourceKeys = [sInstance.entity.attributesByName.allKeys mutableCopy];
        NSDictionary *sourceValues = [sInstance dictionaryWithValuesForKeys:sourceKeys];
        NSManagedObject *destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:mapping.destinationEntityName
                                                                             inManagedObjectContext:manager.destinationContext];

        // attribute migration
        for (NSPropertyMapping *attributeMap in mapping.attributeMappings)
        {
            id value = [sourceValues valueForKey:[attributeMap.valueExpression.arguments.firstObject constantValue]];
            // Avoid NULL values
            if (value && ![value isEqual:[NSNull null]])
            {
                [destinationInstance setValue:value forKey:attributeMap.name];
            }
        }

        for (NSPropertyMapping *relationshipMap in mapping.relationshipMappings)
        {
        }
        /*
           NSMutableDictionary *authorLookup = [manager lookupWithKey:@"StudentInformation"];
           // Check if we’ve already created this author
           NSString *authorName = [sInstance valueForKey:@"author"];
           NSManagedObject *author = [authorLookup valueForKey:authorName];
           if (!author)
           {
           // Create the author
           // Populate lookup for reuse
           [authorLookup setValue:author forKey:authorName];
           }

           [destinationInstance performSelector:@selector(addCoursesObject:) withObject:author];

           [manager associateSourceInstance:sInstance
           withDestinationInstance:destinationInstance
           forEntityMapping:mapping];
           return YES;*/
    }

    return YES;
}



@end