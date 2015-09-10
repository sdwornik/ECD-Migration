#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataMigrationController.h"

@interface CoreDataController : NSObject <CoreDataMigrationControllerDelegate>

@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataController*)sharedInstance;

- (BOOL)isMigrationNeeded;
- (BOOL)migrateWithOptions:options error:(NSError *__autoreleasing *)error;
- (void)save;
- (NSURL *)sourceStoreURL;
- (void)cleanupPersistentStoreCoordinator;
- (NSManagedObjectContext *)initializeCoreDataWithEncryption:(BOOL)encrypt;
@end