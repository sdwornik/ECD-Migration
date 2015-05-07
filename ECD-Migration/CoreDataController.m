#import "CoreDataController.h"
#import "EncryptedStore.h"
#import "AppDelegate.h"
#import "CocoaLumberjack.h"

/*-----------------------------------DEFINITIONS START--------------------------------------------------------------------------------*/

#define kSQLStoreName @"ECD_Migration.sqlite"

/*-----------------------------------DEFINITIONS END----------------------------------------------------------------------------------*/

@interface CoreDataController ()

/*We are redefining it inside here so that functions of this class has read and write access to these variables, but classes that try to access these variables externally only have readonly permission

   Reference:
   http://www.benjaminloulier.com/posts/private-properties-methods-and-ivars-in-objective-c/
 */

@property (nonatomic, readwrite, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) BOOL shouldEncryptCoreData;
@end

@implementation CoreDataController



/*Only access core data with sharedInstance to ensure Singleton design*/
+ (CoreDataController*)sharedInstance
{
    static CoreDataController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CoreDataController new];
    });
    return sharedInstance;
}



- (NSManagedObjectContext *)initializeCoreDataWithEncryption:(BOOL)encrypt
{
    self.shouldEncryptCoreData = encrypt;
    return [self managedObjectContext];
}



- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }

#ifdef DEBUG
    // This is strictly for enabling debug messages from Encrypted Stores
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.apple.CoreData.SQLDebug"];
#endif

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [_managedObjectContext setUndoManager:undoManager];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}



- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }

    NSDictionary*options = nil;
    NSError *error;

    // Feel free to re-enable this block of code, and commenting out the ECD part to test with stock SQLite for progressive migration.
    // STOCK SQLITE COREDATA STARTS HERE
/*
    NSURL *storeUrl = [NSURL fileURLWithPath:[[gkAPPDELEGATE applicationDocumentsDirectory]
                                              stringByAppendingPathComponent:kSQLStoreName]];

    options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                NSMigratePersistentStoresAutomaticallyOption:@YES,
                NSInferMappingModelAutomaticallyOption:@YES};

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];

    NSError*error;
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeUrl
                                                    options:options
                                                      error:&error];
 */
    // STOCK SQLITE COREDATA ENDS HERE

    // ECD STARTS HERE
    if (self.shouldEncryptCoreData)
    {
        options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                    NSMigratePersistentStoresAutomaticallyOption:@YES,
                    NSInferMappingModelAutomaticallyOption:@YES,
                    NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
                    EncryptedStoreDatabaseLocation:[self sourceStoreURL],
                    EncryptedStorePassphraseKey:@"Some Random Key String"};
    }
    else
    {
        options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                    NSMigratePersistentStoresAutomaticallyOption:@YES,
                    NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
                    NSInferMappingModelAutomaticallyOption:@YES,
                    EncryptedStoreDatabaseLocation:[self sourceStoreURL]};
    }

    if ([self isMigrationNeeded])
    {
        [self migrate:nil];
    }

    _persistentStoreCoordinator = [EncryptedStore makeStoreWithOptions:options managedObjectModel:[self managedObjectModel] error:&error];
    // ECD ENDS HERE


    if (error)
    {
        DDLogError(@"%@:%@ Error - %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
    }

    return _persistentStoreCoordinator;
}



- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }

    NSString *fileName;
    fileName = NSLocalizedString(@"ECD_Migration", nil);

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"momd"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[modelURL path]])
    {
        DDLogDebug(@"%@", [modelURL path]); // This is printed because file exists

        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        return _managedObjectModel;
    }
    else
    {
        return nil;
    }
}



- (NSURL *)sourceStoreURL
{
    return [NSURL fileURLWithPath:[[gkAPPDELEGATE applicationDocumentsDirectory]
                                   stringByAppendingPathComponent:kSQLStoreName]];
}



- (NSString *)sourceStoreType
{
    // return NSSQLiteStoreType;
    return EncryptedStoreType;
}



- (NSDictionary *)sourceMetadata:(NSError **)error
{
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[self sourceStoreType]
                                                                      URL:[self sourceStoreURL]
                                                                    error:error];
}



- (BOOL)isMigrationNeeded
{
    DDLogWarn(@"%@:%@ Determine if a core data DB migration is necessary.", THIS_FILE, THIS_METHOD);

    NSError *error = nil;

    // Check if we need to migrate
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    BOOL isMigrationNeeded = NO;

    if (sourceMetadata != nil)
    {
        NSManagedObjectModel *destinationModel = [self managedObjectModel];
        // Migration is needed if destinationModel is NOT compatible
        isMigrationNeeded = ![destinationModel isConfiguration:nil
                                   compatibleWithStoreMetadata           :sourceMetadata];

        if (isMigrationNeeded)
        {
            DDLogWarn(@"%@:%@ - DB Changed!  Coredata migration is necessary...", THIS_FILE, THIS_METHOD);
        }
        else
        {
            DDLogWarn(@"%@:%@ - No DB changes.", THIS_FILE, THIS_METHOD);
        }
    }
    else
    {
        DDLogError(@"%@:%@ : DB migration check ERROR: %@", THIS_FILE, THIS_METHOD, [error description]);
    }

    return isMigrationNeeded;
}



- (BOOL)migrate:(NSError *__autoreleasing *)error
{
    // Enable migrations to run even while user exits app
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                  bgTask = UIBackgroundTaskInvalid;
              }];

    CoreDataMigrationController *migrationManager = [CoreDataMigrationController new];
    migrationManager.delegate = self;

    BOOL OK = [migrationManager progressivelyMigrateURL:[self sourceStoreURL]
                                                 ofType:[self sourceStoreType]
                                                toModel:[self managedObjectModel]
                                                  error:error];
    if (OK)
    {
        DDLogInfo(@"%@:%@ - Migration Complete!", THIS_FILE, THIS_METHOD);
    }

    // Mark it as invalid
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
    return OK;
}



- (void)mergeChanges:(NSNotification *)notification
{
// DDLogWarn(@"%@:%@ *-*-*  DB UPGRADE - start  *-*-*", THIS_FILE, THIS_METHOD);

    NSManagedObjectContext *mainContext = [self managedObjectContext];

    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];

// DDLogWarn(@"%@:%@ *-*-*  DB UPGRADE - end  *-*-*", THIS_FILE, THIS_METHOD);
}



- (void)cleanupPersistentStoreCoordinator
{
    [_managedObjectContext reset];
    _managedObjectContext = nil;
    _managedObjectModel = nil;

    NSError *error = nil;
    for (NSPersistentStore *store in _persistentStoreCoordinator.persistentStores)
    {
        BOOL removed = [_persistentStoreCoordinator removePersistentStore:store error:&error];

        if (!removed)
        {
            DDLogError(@"%@:%@ Unable to remove persistent store: %@", THIS_FILE, THIS_METHOD, error);
        }
    }

    _persistentStoreCoordinator = nil;
    NSString *directory = [gkAPPDELEGATE applicationDocumentsDirectory];
    NSArray *contentsOfFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    if (contentsOfFile.count > 0)
    {
        for (NSString *file in contentsOfFile)
        {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@"
                                                              , directory, file] error:&error];
            if (error)
            {
                DDLogError(@"%@:%@ Unable to remove sqlite file: %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
            }
        }
    }
}



- (void)migrationManager:(CoreDataMigrationController *)migrationManager migrationProgress:(float)migrationProgress
{
    DDLogDebug(@"Migration Progress: %f", migrationProgress);
}



@end