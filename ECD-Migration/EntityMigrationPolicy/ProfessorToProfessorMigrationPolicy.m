//
// ProfessorToProfessorMigrationPolicy.m
// ECD-Migration
//
// Created by Jasper Chan on 2015-09-01.
// Copyright (c) 2015 .. All rights reserved.
//

#import "ProfessorToProfessorMigrationPolicy.h"

@implementation ProfessorToProfessorMigrationPolicy

- (BOOL)beginEntityMapping:(NSEntityMapping *)mapping
                   manager:(NSMigrationManager *)manager
                     error:(NSError *__autoreleasing *)error
{
    return YES;
}



/*Only attributes are manipulated in this stage*/
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

        [manager associateSourceInstance:sInstance
                 withDestinationInstance:destinationInstance
                        forEntityMapping:mapping];

        return YES;
    }
    else
    {
        return [super createDestinationInstancesForSourceInstance:sInstance
                                                    entityMapping:mapping
                                                          manager:manager
                                                            error:error];
    }
}



- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance
                                    entityMapping:(NSEntityMapping *)mapping
                                          manager:(NSMigrationManager *)manager
                                            error:(NSError *__autoreleasing *)error
{
    return YES;
}



- (BOOL)performCustomValidationForEntityMapping:(NSEntityMapping *)mapping
                                        manager:(NSMigrationManager *)manager
                                          error:(NSError *__autoreleasing *)error
{
    return YES;
}



@end