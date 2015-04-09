#import <Foundation/Foundation.h>

@class CoreDataMigrationController;

@protocol  CoreDataMigrationControllerDelegate <NSObject>

@optional
- (void)migrationManager:(CoreDataMigrationController *)migrationManager migrationProgress:(float)migrationProgress;
- (NSArray *)migrationManager:(CoreDataMigrationController *)migrationManager mappingModelsForSourceModel:(NSManagedObjectModel *)sourceModel;

@end

@interface CoreDataMigrationController : NSObject

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error;

@property (nonatomic, weak) id<CoreDataMigrationControllerDelegate> delegate;
@end