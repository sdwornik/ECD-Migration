#import "CoreDataMigrationController.h"

@implementation CoreDataMigrationController

/*http://stackoverflow.com/questions/14974336/cant-add-destination-store-core-data-migration-error*/

// START:progressivelyMigrateURLMethodName
/*- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL
                         ofType:(NSString*)type
                        toModel:(NSManagedObjectModel*)finalModel
                          error:(NSError**)error
   {
   // END:progressivelyMigrateURLMethodName
   // START:progressivelyMigrateURLHappyCheck
    NSDictionary *sourceMetadata =
        [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                   URL:sourceStoreURL
                                                                 error:error];
    if (!sourceMetadata)
    {
        return NO;
    }

    if ([finalModel isConfiguration:nil
         compatibleWithStoreMetadata:sourceMetadata])
    {
 * error = nil;
        return YES;
    }

   // END:progressivelyMigrateURLHappyCheck
   // START:progressivelyMigrateURLFindModels
   // Find the source model
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel
                                         mergedModelFromBundles:nil
                                               forStoreMetadata:sourceMetadata];
    NSAssert(sourceModel != nil, ([NSString stringWithFormat:
                                   @"Failed to find source model\n%@",
                                   sourceMetadata]));

   // Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                            inDirectory:nil];
    for (NSString *momdPath in momdArray)
    {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle]
                          pathsForResourcesOfType:@"mom"
                                      inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray*otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                             inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];

    if (!modelPaths || ![modelPaths count])
    {
        // Throw an error if there are no models
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle"
                forKey:NSLocalizedDescriptionKey];
        // Populate the error
 * error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dict];
        return NO;
    }

    // END:progressivelyMigrateURLFindModels

    // See if we can find a matching destination model
    // START:progressivelyMigrateURLFindMap
    NSMappingModel *mappingModel = nil;
    NSManagedObjectModel *targetModel = nil;
    NSString *modelPath = nil;
    for (modelPath in modelPaths)
    {
        targetModel = [[NSManagedObjectModel alloc]
                       initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                forSourceModel:sourceModel
                                              destinationModel:targetModel];
   // If we found a mapping model then proceed
        if (mappingModel)
        {
            break;
        }

   // Release the target model and keep looking
        [targetModel release], targetModel = nil;
    }
   // We have tested every model, if nil here we failed
    if (!mappingModel)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle"
                forKey:NSLocalizedDescriptionKey];
 * error = [NSError errorWithDomain:@"Zarra"
                                     code:8001
                                 userInfo:dict];
        return NO;
    }

   // END:progressivelyMigrateURLFindMap
   // We have a mapping model and a destination model.  Time to migrate
   // START:progressivelyMigrateURLMigrate
    NSMigrationManager *manager = [[NSMigrationManager alloc]
                                   initWithSourceModel:sourceModel
                                      destinationModel:targetModel];

    NSString *modelName = [[modelPath lastPathComponent]
                           stringByDeletingPathExtension];
    NSString *storeExtension = [[sourceStoreURL path] pathExtension];
    NSString *storePath = [[sourceStoreURL path] stringByDeletingPathExtension];
   // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath,
                 modelName, storeExtension];
    NSURL *destinationStoreURL = [NSURL fileURLWithPath:storePath];

    if (![manager migrateStoreFromURL:sourceStoreURL
                                 type:type
                              options:nil
                     withMappingModel:mappingModel
                     toDestinationURL:destinationStoreURL
                      destinationType:type
                   destinationOptions:nil
                                error:error])
    {
        return NO;
    }

    // END:progressivelyMigrateURLMigrate
    // Migration was successful, move the files around to preserve the source
    // START:progressivelyMigrateURLMoveAndRecurse
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    guid = [guid stringByAppendingPathExtension:modelName];
    guid = [guid stringByAppendingPathExtension:storeExtension];
    NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
    NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:[sourceStoreURL path]
                              toPath:backupPath
                               error:error])
    {
        // Failed to copy the file
        return NO;
    }

    // Move the destination to the source path
    if (![fileManager moveItemAtPath:storePath
                              toPath:[sourceStoreURL path]
                               error:error])
    {
        // Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath
                             toPath:[sourceStoreURL path]
                              error:nil];
        return NO;
    }

    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL
                                  ofType:type
                                 toModel:finalModel
                                   error:error];
    // END:progressivelyMigrateURLMoveAndRecurse
   }*/



- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                        options:(NSDictionary *)options
                          error:(NSError **)error
{
    NSURL *destinationStoreURL = [self destinationStoreURLWithSourceStoreURL:sourceStoreURL];
    NSDictionary *sourceMetadata;
    if ([destinationStoreURL checkResourceIsReachableAndReturnError:nil] == NO)
    {
        sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                    URL:sourceStoreURL
                                                                                  error:error];
    }
    else
    {
        sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                    URL:destinationStoreURL
                                                                                  error:error];
    }

    if (!sourceMetadata)
    {
        return NO;
    }

    if ([finalModel isConfiguration:nil
         compatibleWithStoreMetadata:sourceMetadata])
    {
        if (NULL != error)
        {
            *error = nil;
        }

        return YES;
    }

    NSManagedObjectModel *sourceModel = [self sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel = nil;
    NSMappingModel *mappingModel = nil;
    if (![self getDestinationModel:&destinationModel
                      mappingModel:&mappingModel
                    forSourceModel:sourceModel
                             error:error])
    {
        return NO;
    }

    NSArray *mappingModels = @[mappingModel];
    if ([self.delegate respondsToSelector:@selector(migrationManager:mappingModelsForSourceModel:)])
    {
        NSArray *explicitMappingModels = [self.delegate migrationManager:self mappingModelsForSourceModel:sourceModel];
        if (0 < explicitMappingModels.count)
        {
            mappingModels = explicitMappingModels;
        }
    }

    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                 destinationModel:destinationModel];
    [manager addObserver:self
              forKeyPath:@"migrationProgress"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    BOOL didMigrate = NO;

    for (NSMappingModel *mappingModel in mappingModels)
    {
        didMigrate = [manager migrateStoreFromURL:sourceStoreURL
                                             type:type
                                          options:options
                                 withMappingModel:mappingModel
                                 toDestinationURL:destinationStoreURL
                                  destinationType:type
                               destinationOptions:options
                                            error:error];
    }
    [manager removeObserver:self
                 forKeyPath:@"migrationProgress"];
    if (!didMigrate)
    {
        return NO;
    }

    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:destinationStoreURL
                                  ofType:type
                                 toModel:finalModel
                                 options:options
                                   error:error];
}



- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    return [NSManagedObjectModel mergedModelFromBundles:nil
                                       forStoreMetadata:sourceMetadata];
}



- (NSArray *)modelPaths
{
    // Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                            inDirectory:nil];
    for (NSString *momdPath in momdArray)
    {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                            inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                              inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    return modelPaths;
}



- (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel
               mappingModel:(NSMappingModel **)mappingModel
             forSourceModel:(NSManagedObjectModel *)sourceModel
                      error:(NSError **)error
{
    NSArray *modelPaths = [self modelPaths];
    if (!modelPaths.count)
    {
        // Throw an error if there are no models
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"Zarra"
                                         code:8001
                                     userInfo:@{ NSLocalizedDescriptionKey : @"No models found!" }];
        }

        return NO;
    }

    // See if we can find a matching destination model
    NSManagedObjectModel *model = nil;
    NSMappingModel *mapping = nil;
    NSString *modelPath = nil;
    for (modelPath in modelPaths)
    {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:nil
                                           forSourceModel:sourceModel
                                         destinationModel:model];
        // If we found a mapping model then proceed
        if (mapping)
        {
            break;
        }
    }
    // We have tested every model, if nil here we failed
    if (!mapping)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithDomain:@"Zarra"
                                         code:8001
                                     userInfo:@{ NSLocalizedDescriptionKey : @"No mapping model found in bundle" }];
        }

        return NO;
    }
    else
    {
        *destinationModel = model;
        *mappingModel = mapping;
    }

    return YES;
}



- (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL
{
    // We have a mapping model, time to migrate
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@_T.%@", storePath, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"])
    {
        if ([self.delegate respondsToSelector:@selector(migrationManager:migrationProgress:)])
        {
            [self.delegate migrationManager:self migrationProgress:[(NSMigrationManager *)object migrationProgress]];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}



@end