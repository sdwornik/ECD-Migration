#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataMigrationController.h"

@interface CoreDataController : NSObject <CoreDataMigrationControllerDelegate>

@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataController*)sharedInstance;

- (BOOL)isMigrationNeeded;
- (BOOL)migrate:(NSError *__autoreleasing *)error;

- (NSURL *)sourceStoreURL;
- (void)cleanupPersistentStoreCoordinator;
- (NSManagedObjectContext *)initializeCoreDataWithEncryption:(BOOL)encrypt;
@end