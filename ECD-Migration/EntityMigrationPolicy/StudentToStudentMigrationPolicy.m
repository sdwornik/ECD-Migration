//
// StudentToStudentMigrationPolicy.m
// ECD-Migration
//
// Created by Jasper Chan on 2015-09-01.
// Copyright (c) 2015 .. All rights reserved.
//

#import "StudentToStudentMigrationPolicy.h"
#import "StudentInformation.h"

/*http://9elements.com/io/index.php/customizing-core-data-migrations/*/
/*http://www.pumpmybicep.com/2014/09/17/writing-a-core-data-custom-migration/*/
@implementation StudentToStudentMigrationPolicy

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
    /*For now, modelVerion 2 and 3 have the exact same code. Later on, I will probably need to start adding specific things as needs arise in different verisons.*/
    NSNumber *modelVersion = [mapping.userInfo valueForKey:@"modelVersion"];

    if (modelVersion.integerValue == 2)
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
    else if (modelVersion.integerValue == 3)
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
    NSNumber *modelVersion = [mapping.userInfo valueForKey:@"modelVersion"];
    NSArray *sourceObject = [manager sourceInstancesForEntityMappingNamed:mapping.name destinationInstances:@[dInstance]];
    if (modelVersion.integerValue == 2)
    {
        return [super createRelationshipsForDestinationInstance:dInstance
                                                  entityMapping:mapping
                                                        manager:manager
                                                          error:error];
    }
    else if (modelVersion.integerValue == 3)
    {
        return [super createRelationshipsForDestinationInstance:dInstance
                                                  entityMapping:mapping
                                                        manager:manager
                                                          error:error];
    }
    else
    {
        return [super createRelationshipsForDestinationInstance:dInstance
                                                  entityMapping:mapping
                                                        manager:manager
                                                          error:error];
    }
}



- (BOOL)performCustomValidationForEntityMapping:(NSEntityMapping *)mapping
                                        manager:(NSMigrationManager *)manager
                                          error:(NSError *__autoreleasing *)error
{
    return YES;
}



@end