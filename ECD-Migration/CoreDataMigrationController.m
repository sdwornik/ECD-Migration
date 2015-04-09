#import "CoreDataMigrationController.h"

@implementation CoreDataMigrationController

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error
{
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                              URL:sourceStoreURL
                                                                                            error:error];
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

    NSURL *destinationStoreURL = [self destinationStoreURLWithSourceStoreURL:sourceStoreURL];
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
                                          options:nil
                                 withMappingModel:mappingModel
                                 toDestinationURL:destinationStoreURL
                                  destinationType:type
                               destinationOptions:nil
                                            error:error];
    }
    [manager removeObserver:self
                 forKeyPath:@"migrationProgress"];
    if (!didMigrate)
    {
        return NO;
    }

    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL
                                  ofType:type
                                 toModel:finalModel
                                   error:error];
}



- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]
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
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]]
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
    storePath = [NSString stringWithFormat:@"%@.%@", storePath, storeExtension];
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