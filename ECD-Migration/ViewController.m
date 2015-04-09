/*************************************** READ ME STARTS *********************************************/
/*
   This project was created for the purpose of serving as a project experiment in using progressive migration with the module Encrypted-Core-Data (ECD). Currently, ECD does not respond to the signals being sent to progressively migrate and this project will serve as the place to experiment/tinker with in hopes of solving this problem.

   HOW TO USE THIS PROJECT:
   This project has 4 interfaceable objects for the user the use. The switch is used to allow the user to control whether or not they want database to be encrypted. It is advantageous to have this functionality as it makes it easier to look into the sqlite file with software such as SQLiteManager when the file is not encrypted. The rest of the buttons are self-explanatory. This project expects the user to ALWAYS initialize core data using the original data model (ie. ECD_Migration.xcdatamodel), and to have the corresponding NSManagedObject classes built for the data model version being used. Once this is true, the user may click on the 'Initialize CoreData' button to create the database. In order to test migration, the user must then choose which data model version they wish to use, replace the corresponding NSManagedObject classes. Afterwards, the user must go to the IBAction initializeCoreDataAction and comment out [self initializeDefaultData] and [self verifyInitialData] before running the app. Notice this time, the button 'Initialize CoreData' will be disabled. The user will then press 'Start Migration' and can then watch the console for error logs.

    A test case has been written for each model. Please visit the IBAction startMigrationAction and read the comments there to enable the proper test cases.

    Please take the time to skim through the code if compilation arises as comments have been placed in appropriate places to remind the user what to do depending on test cases being run.
 */
/*************************************** READ ME END ***********************************************/

#import "ViewController.h"
#import "StudentInformation.h"
#import "ProfessorInformation.h"

// Comment this out if migrating to version 2, or upon initial setup (ie. using version 1 data model)
// #import "CourseDetailInformation.h"

// Comment this out if migrating to version 3
#import "CourseInformation.h"


#define k_EyeColour @"eyeColour"
#define k_Height @"Height"

@interface ViewController ()
@property (nonatomic) BOOL shouldEncryptCoreData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);
    // Do any additional setup after loading the view, typically from a nib.

    NSString *sqliteFile = [[gkAPPDELEGATE applicationDocumentsDirectory] stringByAppendingPathComponent:@"ECD_Migration.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sqliteFile isDirectory:nil])
    {
        self.restCoreDataBtn.enabled = NO;
        self.startMigrationBtn.enabled = NO;
    }
    else
    {
        self.encryptCoreDataSwitch.enabled = NO;
        self.initializeCoreDataBtn.enabled = NO;
    }

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)encryptCoreDataAction:(id)sender
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);

    self.shouldEncryptCoreData = ((UISwitch *)sender).isOn;

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



- (IBAction)initializeCoreDataAction:(id)sender
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);

    NSString *progressHUDMsg = [NSString stringWithFormat:@"Initializing Core Data with Encryption %@", (self.shouldEncryptCoreData ? @"on" : @"off")];
    [SVProgressHUD showInfoWithStatus:progressHUDMsg];

    self.initializeCoreDataBtn.enabled = NO;


    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [[CoreDataController sharedInstance] initializeCoreDataWithEncryption:self.shouldEncryptCoreData];
        dispatch_async(dispatch_get_main_queue(), ^{
            @try
            {
                // Comment out initializeDefaultData and verifyInitialData when you are not initializing the Core Data with a version 1 data model.
                [self initializeDefaultData];
                [self verifyInitialData];


                self.encryptCoreDataSwitch.enabled = NO;
                self.startMigrationBtn.enabled = YES;
                self.restCoreDataBtn.enabled = YES;
            }
            @catch (NSException *exception) {
                ;
            }

            [SVProgressHUD dismiss];
        });
    });



    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



- (IBAction)restartCoreData:(id)sender
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);

    [[CoreDataController sharedInstance] cleanupPersistentStoreCoordinator];

    self.initializeCoreDataBtn.enabled = YES;
    self.startMigrationBtn.enabled = NO;
    self.encryptCoreDataSwitch.enabled = YES;
    self.restCoreDataBtn.enabled = NO;

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



- (IBAction)startMigrationAction:(id)sender
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);

    self.startMigrationBtn.enabled = NO;

    [[CoreDataController sharedInstance] managedObjectContext];
    if ([[CoreDataController sharedInstance] isMigrationNeeded])
    {
        [[CoreDataController sharedInstance] migrate:nil];
    }

    // Comment this out when not checking your inital model data is correct
    // [self verifyInitialData];

    // Comment this out when not migrating from initial version to version 2
    // [self testCaseInitialToVersion2];

    // Comment this out when not migrating from initial version to version 3
    // [self testCaseInitialToVersion3];
    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



#pragma mark Initialize CoreData with default data
// Function name: initializeDefaultData
// Dependency: Must be used with the initial data model ONLY.
// Purpose: Insert some initial data in preparation for migration tests.
- (void)initializeDefaultData
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);

    NSDecimalNumberHandler *roundCurrency = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                            scale:2
                                                                 raiseOnExactness:NO
                                                                  raiseOnOverflow:NO
                                                                 raiseOnUnderflow:NO
                                                              raiseOnDivideByZero:YES];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:10];
    [comps setMonth:10];
    [comps setYear:2010];
    [comps setHour:12];
    [comps setMinute:30];
    [comps setSecond:10];

    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] managedObjectContext];
    ProfessorInformation *firstProfessor = [NSEntityDescription insertNewObjectForEntityForName:@"ProfessorInformation"
                                                                         inManagedObjectContext:context];
    firstProfessor.firstName = @"Harry";
    firstProfessor.lastName = @"Potter";
    firstProfessor.age = [NSNumber numberWithInteger:31];
    firstProfessor.isAvailable = [NSNumber numberWithBool:YES];
    firstProfessor.annualSalary = [[[NSDecimalNumber alloc] initWithFloat:80000.00f]decimalNumberByRoundingAccordingToBehavior:roundCurrency];
    firstProfessor.creationdate = date;
    firstProfessor.lastmodifieddate = date;

    CourseInformation *firstCourse = [NSEntityDescription insertNewObjectForEntityForName:@"CourseInformation"
                                                                   inManagedObjectContext:context];
    firstCourse.courseId = [NSNumber numberWithInteger:1];
    firstCourse.courseCode = @"HP123";
    firstCourse.courseTitle = @"How to survive the unblockable curse";
    firstCourse.isAvailable = [NSNumber numberWithBool:YES];
    firstCourse.creationdate = date;
    firstCourse.lastmodifieddate = date;

    [firstCourse setTeachingProfessor:firstProfessor];
    [firstProfessor addTeachableCoursesObject:firstCourse];

    CourseInformation *secondCourse = [NSEntityDescription insertNewObjectForEntityForName:@"CourseInformation"
                                                                    inManagedObjectContext:context];
    secondCourse.courseId = [NSNumber numberWithInteger:2];
    secondCourse.courseCode = @"HP234";
    secondCourse.courseTitle = @"How to ride a hypogriff";
    secondCourse.isAvailable = [NSNumber numberWithBool:NO];
    secondCourse.creationdate = date;
    secondCourse.lastmodifieddate = date;

    [secondCourse setTeachingProfessor:firstProfessor];
    [firstProfessor addTeachableCoursesObject:secondCourse];

    StudentInformation *firstStudent = [NSEntityDescription insertNewObjectForEntityForName:@"StudentInformation"
                                                                     inManagedObjectContext:context];
    firstStudent.year = [NSNumber numberWithInteger:1];
    firstStudent.firstname = @"Good Billy";
    firstStudent.lastname = @"Jean";
    firstStudent.currentAge = [NSNumber numberWithLongLong:18];
    firstStudent.tutitionFee = [[[NSDecimalNumber alloc] initWithFloat:10000.23f]decimalNumberByRoundingAccordingToBehavior:roundCurrency];
    firstStudent.avgGrade = [NSNumber numberWithInteger:83];
    firstStudent.isOnProbation = [NSNumber numberWithBool:NO];
    firstStudent.creationdate = date;
    firstStudent.lastmodifieddate = date;

    NSMutableDictionary *physicalAttributes = [[NSMutableDictionary alloc] init];
    [physicalAttributes setObject:@"Blue" forKey:k_EyeColour];
    [physicalAttributes setObject:@"153 cm" forKey:k_Height];
    firstStudent.classifieddata = [NSPropertyListSerialization dataWithPropertyList:physicalAttributes
                                                                             format:NSPropertyListBinaryFormat_v1_0
                                                                            options:0
                                                                              error:nil];
    [firstStudent addCoursesObject:firstCourse];
    [firstCourse addStudentsObject:firstStudent];

    StudentInformation *secondStudent = [NSEntityDescription insertNewObjectForEntityForName:@"StudentInformation"
                                                                      inManagedObjectContext:context];
    secondStudent.year = [NSNumber numberWithInteger:1];
    secondStudent.firstname = @"Bad Joel";
    secondStudent.lastname = @"Nottingham";
    secondStudent.currentAge = [NSNumber numberWithLongLong:22];
    secondStudent.tutitionFee = [[[NSDecimalNumber alloc] initWithFloat:21000.23f]decimalNumberByRoundingAccordingToBehavior:roundCurrency];
    secondStudent.avgGrade = [NSNumber numberWithInteger:53];
    secondStudent.isOnProbation = [NSNumber numberWithBool:YES];
    secondStudent.creationdate = date;
    secondStudent.lastmodifieddate = date;

    NSMutableDictionary *physicalAttributes2 = [[NSMutableDictionary alloc] init];
    [physicalAttributes2 setObject:@"Green" forKey:k_EyeColour];
    [physicalAttributes2 setObject:@"188 cm" forKey:k_Height];
    secondStudent.classifieddata = [NSPropertyListSerialization dataWithPropertyList:physicalAttributes2
                                                                              format:NSPropertyListBinaryFormat_v1_0
                                                                             options:0
                                                                               error:nil];
    [secondStudent addCoursesObject:firstCourse];
    [firstCourse addStudentsObject:secondStudent];

    NSError *error;
    if (![context save:&error])
    {
        DDLogError(@"%@:%@ - unable to initialize core data information: %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
    }

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



#pragma mark verifyInitialData
// Function Name: verifyInitialData
// Dependency: Must be used with the initial data model ONLY.
// Purpose: Verify initial data is correct.
- (void)verifyInitialData
{
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);
    NSDecimalNumberHandler *roundCurrency = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                            scale:2
                                                                 raiseOnExactness:NO
                                                                  raiseOnOverflow:NO
                                                                 raiseOnUnderflow:NO
                                                              raiseOnDivideByZero:YES];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:10];
    [comps setMonth:10];
    [comps setYear:2010];
    [comps setHour:12];
    [comps setMinute:30];
    [comps setSecond:10];

    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] managedObjectContext];
    NSError *error;

    NSFetchRequest *fetchFirstProfessor = [[NSFetchRequest alloc] initWithEntityName:@"ProfessorInformation"];
    NSArray *firstProfessorResult = [context executeFetchRequest:fetchFirstProfessor error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch professor Harry Potter: %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
    }
    else
    {
        ProfessorInformation *harryPotter = [firstProfessorResult firstObject];
        if (![harryPotter.firstName isEqualToString:@"Harry"])
        {
            DDLogError(@"%@:%@ firstName of professor is %@; expected Harry", THIS_FILE, THIS_METHOD, harryPotter.firstName);
        }

        if (![harryPotter.lastName isEqualToString:@"Potter"])
        {
            DDLogError(@"%@:%@ lastName of professor is %@; expected Potter", THIS_FILE, THIS_METHOD, harryPotter.lastName);
        }

        if (harryPotter.age.integerValue != 31)
        {
            DDLogError(@"%@:%@ age of professor is %d; expected 31", THIS_FILE, THIS_METHOD, harryPotter.age.integerValue);
        }

        if (harryPotter.isAvailable.integerValue != 1)
        {
            DDLogError(@"%@:%@ isAvailable of professor is %@, expected TRUE", THIS_FILE, THIS_METHOD, (harryPotter.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
        }

        if ([[harryPotter.annualSalary decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[NSDecimalNumber decimalNumberWithString:@"80000.00"] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ annualSalary of professor is %f, expected 80000.00", THIS_FILE, THIS_METHOD, harryPotter.annualSalary.doubleValue);
        }

        if (![harryPotter.creationdate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ creationDate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.creationdate, date);
        }

        if (![harryPotter.lastmodifieddate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ lastmodifieddate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.lastmodifieddate, date);
        }

        if (harryPotter.teachableCourses.count != 2)
        {
            DDLogError(@"%@:%@ - TeachableCourses relationship is lost", THIS_FILE, THIS_METHOD);
        }
        else
        {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"courseId" ascending:YES selector:nil];
            NSArray *sortedTeachables = [harryPotter.teachableCourses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            CourseInformation *firstCourse = [sortedTeachables objectAtIndex:0];

            if (firstCourse.courseId.integerValue != 1)
            {
                DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
            }

            if (![firstCourse.courseCode isEqualToString:@"HP123"])
            {
                DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
            }

            if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
            {
                DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
            }

            if (firstCourse.isAvailable.integerValue != 1)
            {
                DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (firstCourse.students.count != 2)
            {
                DDLogError(@"%@:%@ firstCourse students count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.students.count);
            }

            if (![firstCourse.creationdate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstCourse creationdate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationdate, date);
            }

            if (![firstCourse.lastmodifieddate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstCourse lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastmodifieddate, date);
            }

            CourseInformation *secondCourse = [sortedTeachables objectAtIndex:1];

            if (secondCourse.courseId.integerValue != 2)
            {
                DDLogError(@"%@:%@ courseId is %d, expected 2", THIS_FILE, THIS_METHOD, secondCourse.courseId.integerValue);
            }

            if (![secondCourse.courseCode isEqualToString:@"HP234"])
            {
                DDLogError(@"%@:%@ courseCode is %@, expected HP234", THIS_FILE, THIS_METHOD, secondCourse.courseCode);
            }

            if (![secondCourse.courseTitle isEqualToString:@"How to ride a hypogriff"])
            {
                DDLogError(@"%@:%@ courseTitle is %@, expected How to ride a hypogriff", THIS_FILE, THIS_METHOD, secondCourse.courseTitle);
            }

            if (secondCourse.isAvailable.integerValue != 0)
            {
                DDLogError(@"%@:%@ isAvailable is %@, expected FALSE", THIS_FILE, THIS_METHOD, (secondCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (secondCourse.students.count != 0)
            {
                DDLogError(@"%@:%@ secondCourse students count is %d, expected 0", THIS_FILE, THIS_METHOD, secondCourse.students.count);
            }

            if (![secondCourse.creationdate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondCourse creationdate is %@, expected %@", THIS_FILE, THIS_METHOD, secondCourse.creationdate, date);
            }

            if (![secondCourse.lastmodifieddate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondCourse lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, secondCourse.lastmodifieddate, date);
            }
        }
    }

    NSFetchRequest *fetchFirstStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
    NSPredicate *firstStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Good Billy'"];
    [fetchFirstStudent setPredicate:firstStudentPredicate];
    NSArray *firstStudentResult = [context executeFetchRequest:fetchFirstStudent error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch student Good Billy", THIS_FILE, THIS_METHOD);
    }
    else
    {
        StudentInformation *firstStudent = [firstStudentResult firstObject];

        if (![firstStudent.firstname isEqualToString:@"Good Billy"])
        {
            DDLogError(@"%@:%@ firstStudent firstname is %@, expected Good Billy", THIS_FILE, THIS_METHOD, firstStudent.firstname);
        }

        if (![firstStudent.lastname isEqualToString:@"Jean"])
        {
            DDLogError(@"%@:%@ firstStudent lastname is %@, expected Jean", THIS_FILE, THIS_METHOD, firstStudent.lastname);
        }

        if (firstStudent.currentAge.longLongValue != 18)
        {
            DDLogError(@"%@:%@ firstStudent currentAge is %d, expected 18", THIS_FILE, THIS_METHOD, firstStudent.currentAge.integerValue);
        }

        if ([[firstStudent.tutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:10000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ firstStudent tutitionFee is %f, expected 10000.23", THIS_FILE, THIS_METHOD, firstStudent.tutitionFee.doubleValue);
        }

        if (firstStudent.avgGrade.integerValue != 83)
        {
            DDLogError(@"%@:%@ firstStudent avgGrade is %d, expected 83", THIS_FILE, THIS_METHOD, firstStudent.avgGrade.integerValue);
        }

        if (firstStudent.isOnProbation.integerValue != 0)
        {
            DDLogError(@"%@:%@ firstStudent isOnProbation is %@, expected FALSE", THIS_FILE, THIS_METHOD, (firstStudent.isOnProbation.integerValue ? @"TRUE" : @"FALSE"));
        }

        if (firstStudent.classifieddata)
        {
            NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                       [NSPropertyListSerialization propertyListWithData:firstStudent.classifieddata
                                                                                                 options:0
                                                                                                  format:nil
                                                                                                   error:&error]];
            if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Blue"])
            {
                DDLogError(@"%@:%@ firstStudent classifiedData Eye Color is %@, expected Blue", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
            }

            if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"153 cm"])
            {
                DDLogError(@"%@:%@ firstStudent classifiedData Height is %@, expected 153 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
            }
        }

        if (![firstStudent.creationdate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ firstStudent creationdate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.creationdate, date);
        }

        if (![firstStudent.lastmodifieddate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ firstStudent lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.lastmodifieddate, date);
        }

        if (firstStudent.courses.count != 1)
        {
            DDLogError(@"%@:%@ - firstStudent's courses count is %d, expected 1", THIS_FILE, THIS_METHOD, firstStudent.courses.count);
        }
        else
        {
            NSArray *firstStudentCoursesArray = [firstStudent.courses allObjects];
            for (CourseInformation *firstCourse in firstStudentCoursesArray)
            {
                if (firstCourse.courseId.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                }

                if (![firstCourse.courseCode isEqualToString:@"HP123"])
                {
                    DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
                }

                if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
                {
                    DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
                }

                if (firstCourse.isAvailable.integerValue != 1)
                {
                    DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (firstCourse.students.count != 2)
                {
                    DDLogError(@"%@:%@ firstCourse students count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.students.count);
                }

                if (![firstCourse.creationdate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse creationdate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationdate, date);
                }

                if (![firstCourse.lastmodifieddate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastmodifieddate, date);
                }
            }
        }
    }

    NSFetchRequest *fetchSecondStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
    NSPredicate *secondStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Bad Joel'"];
    [fetchSecondStudent setPredicate:secondStudentPredicate];
    NSArray *secondStudentResult = [context executeFetchRequest:fetchSecondStudent error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch student Bad Joel", THIS_FILE, THIS_METHOD);
    }
    else
    {
        StudentInformation *secondStudent = [secondStudentResult firstObject];

        if (![secondStudent.firstname isEqualToString:@"Bad Joel"])
        {
            DDLogError(@"%@:%@ secondStudent firstname is %@, expected Bad Joel", THIS_FILE, THIS_METHOD, secondStudent.firstname);
        }

        if (![secondStudent.lastname isEqualToString:@"Nottingham"])
        {
            DDLogError(@"%@:%@ secondStudent lastname is %@, expected Nottingham", THIS_FILE, THIS_METHOD, secondStudent.lastname);
        }

        if (secondStudent.currentAge.longLongValue != 22)
        {
            DDLogError(@"%@:%@ secondStudent currentAge is %d, expected 22", THIS_FILE, THIS_METHOD, secondStudent.currentAge.integerValue);
        }

        if ([[secondStudent.tutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:21000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ secondStudent tutitionFee is %f, expected 21000.23", THIS_FILE, THIS_METHOD, secondStudent.tutitionFee.doubleValue);
        }

        if (secondStudent.avgGrade.integerValue != 53)
        {
            DDLogError(@"%@:%@ secondStudent avgGrade is %d, expected 53", THIS_FILE, THIS_METHOD, secondStudent.avgGrade.integerValue);
        }

        if (secondStudent.isOnProbation.integerValue != 1)
        {
            DDLogError(@"%@:%@ secondStudent isOnProbation is %@, expected TRUE", THIS_FILE, THIS_METHOD, (secondStudent.isOnProbation.integerValue ? @"TRUE" : @"FALSE"));
        }

        if (secondStudent.classifieddata)
        {
            NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                       [NSPropertyListSerialization propertyListWithData:secondStudent.classifieddata
                                                                                                 options:0
                                                                                                  format:nil
                                                                                                   error:&error]];
            if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Green"])
            {
                DDLogError(@"%@:%@ secondStudent classifiedData Eye Color is %@, expected Green", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
            }

            if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"188 cm"])
            {
                DDLogError(@"%@:%@ secondStudent classifiedData Height is %@, expected 188 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
            }
        }

        if (![secondStudent.creationdate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ secondStudent creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.creationdate, date);
        }

        if (![secondStudent.lastmodifieddate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ secondStudent lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.lastmodifieddate, date);
        }

        if (secondStudent.courses.count != 1)
        {
            DDLogError(@"%@:%@ - secondStudent's courses count is %d, expected 1", THIS_FILE, THIS_METHOD, secondStudent.courses.count);
        }
        else
        {
            NSArray *secondStudentCoursesArray = [secondStudent.courses allObjects];
            for (CourseInformation *firstCourse in secondStudentCoursesArray)
            {
                if (firstCourse.courseId.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                }

                if (![firstCourse.courseCode isEqualToString:@"HP123"])
                {
                    DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
                }

                if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
                {
                    DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
                }

                if (firstCourse.isAvailable.integerValue != 1)
                {
                    DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (firstCourse.students.count != 2)
                {
                    DDLogError(@"%@:%@ firstCourse students count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.students.count);
                }

                if (![firstCourse.creationdate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse creationdate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationdate, date);
                }

                if (![firstCourse.lastmodifieddate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse lastmodifieddate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastmodifieddate, date);
                }
            }
        }
    }

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
}



#pragma mark TestCaseInitialToVersion2
// Function Name: testCaseInitialToVersion2
// Dependency: Must be run with only data model version 2
// Purpose: Verify data is complete and correct after migrating from initial data model to version 2
/*- (void)testCaseInitialToVersion2
   {
    DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);
    NSDecimalNumberHandler *roundCurrency = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                            scale:2
                                                                 raiseOnExactness:NO
                                                                  raiseOnOverflow:NO
                                                                 raiseOnUnderflow:NO
                                                              raiseOnDivideByZero:YES];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:10];
    [comps setMonth:10];
    [comps setYear:2010];
    [comps setHour:12];
    [comps setMinute:30];
    [comps setSecond:10];

    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];

    NSManagedObjectContext *context = [[CoreDataController sharedInstance] managedObjectContext];
    NSError *error;

    NSFetchRequest *fetchFirstProfessor = [[NSFetchRequest alloc] initWithEntityName:@"ProfessorInformation"];
    NSArray *firstProfessorResult = [context executeFetchRequest:fetchFirstProfessor error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch professor Harry Potter: %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
    }
    else
    {
        ProfessorInformation *harryPotter = [firstProfessorResult firstObject];
        if (![harryPotter.firstName isEqualToString:@"Harry"])
        {
            DDLogError(@"%@:%@ firstName of professor is %@; expected Harry", THIS_FILE, THIS_METHOD, harryPotter.firstName);
        }

        if (![harryPotter.lastName isEqualToString:@"Potter"])
        {
            DDLogError(@"%@:%@ lastName of professor is %@; expected Potter", THIS_FILE, THIS_METHOD, harryPotter.lastName);
        }

        if (harryPotter.age.integerValue != 31)
        {
            DDLogError(@"%@:%@ age of professor is %d; expected 31", THIS_FILE, THIS_METHOD, harryPotter.age.integerValue);
        }

        if (harryPotter.isAvailable.integerValue != 1)
        {
            DDLogError(@"%@:%@ isAvailable of professor is %@, expected TRUE", THIS_FILE, THIS_METHOD, (harryPotter.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
        }

        if ([[harryPotter.salary decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[NSDecimalNumber decimalNumberWithString:@"80000.00"] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ annualSalary of professor is %f, expected 80000.00", THIS_FILE, THIS_METHOD, harryPotter.salary.doubleValue);
        }

        if (![harryPotter.creationDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ creationDate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.creationDate, date);
        }

        if (![harryPotter.lastModifiedDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ lastModifiedDate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.lastModifiedDate, date);
        }

        if (harryPotter.teachableCourses.count != 2)
        {
            DDLogError(@"%@:%@ - TeachableCourses relationship is lost", THIS_FILE, THIS_METHOD);
        }
        else
        {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"courseId" ascending:YES selector:nil];
            NSArray *sortedTeachables = [harryPotter.teachableCourses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            CourseInformation *firstCourse = [sortedTeachables objectAtIndex:0];

            if (firstCourse.courseId.integerValue != 1)
            {
                DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
            }

            if (![firstCourse.courseCode isEqualToString:@"HP123"])
            {
                DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
            }

            if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
            {
                DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
            }

            if (firstCourse.isAvailable.integerValue != 1)
            {
                DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (firstCourse.enrolledStudents.count != 2)
            {
                DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
            }

            if (![firstCourse.creationDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
            }

            if (![firstCourse.lastModifiedDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
            }

            CourseInformation *secondCourse = [sortedTeachables objectAtIndex:1];

            if (secondCourse.courseId.integerValue != 2)
            {
                DDLogError(@"%@:%@ courseId is %d, expected 2", THIS_FILE, THIS_METHOD, secondCourse.courseId.integerValue);
            }

            if (![secondCourse.courseCode isEqualToString:@"HP234"])
            {
                DDLogError(@"%@:%@ courseCode is %@, expected HP234", THIS_FILE, THIS_METHOD, secondCourse.courseCode);
            }

            if (![secondCourse.courseTitle isEqualToString:@"How to ride a hypogriff"])
            {
                DDLogError(@"%@:%@ courseTitle is %@, expected How to ride a hypogriff", THIS_FILE, THIS_METHOD, secondCourse.courseTitle);
            }

            if (secondCourse.isAvailable.integerValue != 0)
            {
                DDLogError(@"%@:%@ isAvailable is %@, expected FALSE", THIS_FILE, THIS_METHOD, (secondCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (![secondCourse.creationDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondCourse.creationDate, date);
            }

            if (![secondCourse.lastModifiedDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondCourse.lastModifiedDate, date);
            }

            if (secondCourse.enrolledStudents.count != 0)
            {
                DDLogError(@"%@:%@ secondCourse enrolledStudents count is %d, expected 0", THIS_FILE, THIS_METHOD, secondCourse.enrolledStudents.count);
            }
        }
    }

    NSFetchRequest *fetchFirstStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
    NSPredicate *firstStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Good Billy'"];
    [fetchFirstStudent setPredicate:firstStudentPredicate];
    NSArray *firstStudentResult = [context executeFetchRequest:fetchFirstStudent error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch student Good Billy", THIS_FILE, THIS_METHOD);
    }
    else
    {
        StudentInformation *firstStudent = [firstStudentResult firstObject];

        if (![firstStudent.firstName isEqualToString:@"Good Billy"])
        {
            DDLogError(@"%@:%@ firstStudent firstname is %@, expected Good Billy", THIS_FILE, THIS_METHOD, firstStudent.firstName);
        }

        if (![firstStudent.lastName isEqualToString:@"Jean"])
        {
            DDLogError(@"%@:%@ firstStudent lastname is %@, expected Jean", THIS_FILE, THIS_METHOD, firstStudent.lastName);
        }

        if (firstStudent.age.longLongValue != 18)
        {
            DDLogError(@"%@:%@ firstStudent currentAge is %d, expected 18", THIS_FILE, THIS_METHOD, firstStudent.age.integerValue);
        }

        if ([[firstStudent.annualTutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:10000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ firstStudent tutitionFee is %f, expected 10000.23", THIS_FILE, THIS_METHOD, firstStudent.annualTutitionFee.doubleValue);
        }

        if (firstStudent.grade.integerValue != 83)
        {
            DDLogError(@"%@:%@ firstStudent avgGrade is %d, expected 83", THIS_FILE, THIS_METHOD, firstStudent.grade.integerValue);
        }

        if (firstStudent.onProbation.integerValue != 0)
        {
            DDLogError(@"%@:%@ firstStudent isOnProbation is %@, expected FALSE", THIS_FILE, THIS_METHOD, (firstStudent.onProbation.integerValue ? @"TRUE" : @"FALSE"));
        }

        if (firstStudent.classifiedData)
        {
            NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                       [NSPropertyListSerialization propertyListWithData:firstStudent.classifiedData
                                                                                                 options:0
                                                                                                  format:nil
                                                                                                   error:&error]];
            if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Blue"])
            {
                DDLogError(@"%@:%@ firstStudent classifiedData Eye Color is %@, expected Blue", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
            }

            if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"153 cm"])
            {
                DDLogError(@"%@:%@ firstStudent classifiedData Height is %@, expected 153 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
            }
        }

        if (![firstStudent.creationDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ firstStudent creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.creationDate, date);
        }

        if (![firstStudent.lastModifiedDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ firstStudent lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.lastModifiedDate, date);
        }

        if (firstStudent.selectedCourses.count != 1)
        {
            DDLogError(@"%@:%@ - firstStudent's selectedCourses count is %d, expected 1", THIS_FILE, THIS_METHOD, firstStudent.selectedCourses.count);
        }
        else
        {
            NSArray *firstStudentCoursesArray = [firstStudent.selectedCourses allObjects];
            for (CourseInformation *firstCourse in firstStudentCoursesArray)
            {
                if (firstCourse.courseId.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                }

                if (![firstCourse.courseCode isEqualToString:@"HP123"])
                {
                    DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
                }

                if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
                {
                    DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
                }

                if (firstCourse.isAvailable.integerValue != 1)
                {
                    DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (firstCourse.enrolledStudents.count != 2)
                {
                    DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
                }

                if (![firstCourse.creationDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                }

                if (![firstCourse.lastModifiedDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                }
            }
        }
    }

    NSFetchRequest *fetchSecondStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
    NSPredicate *secondStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Bad Joel'"];
    [fetchSecondStudent setPredicate:secondStudentPredicate];
    NSArray *secondStudentResult = [context executeFetchRequest:fetchSecondStudent error:&error];
    if (error)
    {
        DDLogError(@"%@:%@ - Failed to fetch student Bad Joel", THIS_FILE, THIS_METHOD);
    }
    else
    {
        StudentInformation *secondStudent = [secondStudentResult firstObject];

        if (![secondStudent.firstName isEqualToString:@"Bad Joel"])
        {
            DDLogError(@"%@:%@ secondStudent firstname is %@, expected Bad Joel", THIS_FILE, THIS_METHOD, secondStudent.firstName);
        }

        if (![secondStudent.lastName isEqualToString:@"Nottingham"])
        {
            DDLogError(@"%@:%@ secondStudent lastname is %@, expected Nottingham", THIS_FILE, THIS_METHOD, secondStudent.lastName);
        }

        if (secondStudent.age.longLongValue != 22)
        {
            DDLogError(@"%@:%@ secondStudent currentAge is %d, expected 22", THIS_FILE, THIS_METHOD, secondStudent.age.integerValue);
        }

        if ([[secondStudent.annualTutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:21000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
        {
            DDLogError(@"%@:%@ secondStudent tutitionFee is %f, expected 21000.23", THIS_FILE, THIS_METHOD, secondStudent.annualTutitionFee.doubleValue);
        }

        if (secondStudent.grade.integerValue != 53)
        {
            DDLogError(@"%@:%@ secondStudent avgGrade is %d, expected 53", THIS_FILE, THIS_METHOD, secondStudent.grade.integerValue);
        }

        if (secondStudent.onProbation.integerValue != 1)
        {
            DDLogError(@"%@:%@ secondStudent isOnProbation is %@, expected TRUE", THIS_FILE, THIS_METHOD, (secondStudent.onProbation.integerValue ? @"TRUE" : @"FALSE"));
        }

        if (secondStudent.classifiedData)
        {
            NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                       [NSPropertyListSerialization propertyListWithData:secondStudent.classifiedData
                                                                                                 options:0
                                                                                                  format:nil
                                                                                                   error:&error]];
            if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Green"])
            {
                DDLogError(@"%@:%@ secondStudent classifiedData Eye Color is %@, expected Green", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
            }

            if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"188 cm"])
            {
                DDLogError(@"%@:%@ secondStudent classifiedData Height is %@, expected 188 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
            }
        }

        if (![secondStudent.creationDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ secondStudent creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.creationDate, date);
        }

        if (![secondStudent.lastModifiedDate isEqualToDate:date])
        {
            DDLogError(@"%@:%@ secondStudent lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.lastModifiedDate, date);
        }

        if (secondStudent.selectedCourses.count != 1)
        {
            DDLogError(@"%@:%@ - secondStudent's selectedCourses count is %d, expected 1", THIS_FILE, THIS_METHOD, secondStudent.selectedCourses.count);
        }
        else
        {
            NSArray *secondStudentCoursesArray = [secondStudent.selectedCourses allObjects];
            for (CourseInformation *firstCourse in secondStudentCoursesArray)
            {
                if (firstCourse.courseId.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                }

                if (![firstCourse.courseCode isEqualToString:@"HP123"])
                {
                    DDLogError(@"%@:%@ courseCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseCode);
                }

                if (![firstCourse.courseTitle isEqualToString:@"How to survive the unblockable curse"])
                {
                    DDLogError(@"%@:%@ courseTitle is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseTitle);
                }

                if (firstCourse.isAvailable.integerValue != 1)
                {
                    DDLogError(@"%@:%@ isAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (firstCourse.enrolledStudents.count != 2)
                {
                    DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
                }

                if (![firstCourse.creationDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                }

                if (![firstCourse.lastModifiedDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                }
            }
        }
    }

    DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
   }*/



#pragma mark TestCaseInitialToVersion3
// Function Name: testCaseInitialToVersion3
// Dependency: Must be run with only data model version 3
// Purpose: Verify data is complete and correct after progressively migrating from initial data model to version 3
/*- (void)testCaseInitialToVersion3
   {
    {
        DDLogInfo(@"%@:%@ - Started", THIS_FILE, THIS_METHOD);
        NSDecimalNumberHandler *roundCurrency = [NSDecimalNumberHandler
                                                 decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                scale:2
                                                                     raiseOnExactness:NO
                                                                      raiseOnOverflow:NO
                                                                     raiseOnUnderflow:NO
                                                                  raiseOnDivideByZero:YES];

        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:10];
        [comps setMonth:10];
        [comps setYear:2010];
        [comps setHour:12];
        [comps setMinute:30];
        [comps setSecond:10];

        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];

        NSManagedObjectContext *context = [[CoreDataController sharedInstance] managedObjectContext];
        NSError *error;

        NSFetchRequest *fetchFirstProfessor = [[NSFetchRequest alloc] initWithEntityName:@"ProfessorInformation"];
        NSArray *firstProfessorResult = [context executeFetchRequest:fetchFirstProfessor error:&error];
        if (error)
        {
            DDLogError(@"%@:%@ - Failed to fetch professor Harry Potter: %@", THIS_FILE, THIS_METHOD, [error localizedDescription]);
        }
        else
        {
            ProfessorInformation *harryPotter = [firstProfessorResult firstObject];
            if (![harryPotter.firstName isEqualToString:@"Harry"])
            {
                DDLogError(@"%@:%@ firstName of professor is %@; expected Harry", THIS_FILE, THIS_METHOD, harryPotter.firstName);
            }

            if (![harryPotter.lastName isEqualToString:@"Potter"])
            {
                DDLogError(@"%@:%@ lastName of professor is %@; expected Potter", THIS_FILE, THIS_METHOD, harryPotter.lastName);
            }

            if (harryPotter.age.integerValue != 31)
            {
                DDLogError(@"%@:%@ age of professor is %d; expected 31", THIS_FILE, THIS_METHOD, harryPotter.age.integerValue);
            }

            if (harryPotter.isAvailable.integerValue != 1)
            {
                DDLogError(@"%@:%@ isAvailable of professor is %@, expected TRUE", THIS_FILE, THIS_METHOD, (harryPotter.isAvailable.integerValue ? @"TRUE" : @"FALSE"));
            }

            if ([[harryPotter.salary decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[NSDecimalNumber decimalNumberWithString:@"80000.00"] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
            {
                DDLogError(@"%@:%@ annualSalary of professor is %f, expected 80000.00", THIS_FILE, THIS_METHOD, harryPotter.salary.doubleValue);
            }

            if (![harryPotter.creationDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ creationDate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.creationDate, date);
            }

            if (![harryPotter.lastModifiedDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ lastModifiedDate of professor is %@, expected %@", THIS_FILE, THIS_METHOD, harryPotter.lastModifiedDate, date);
            }

            if (harryPotter.teachableCourses.count != 2)
            {
                DDLogError(@"%@:%@ - TeachableCourses relationship is lost", THIS_FILE, THIS_METHOD);
            }
            else
            {
                NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"courseId" ascending:YES selector:nil];
                NSArray *sortedTeachables = [harryPotter.teachableCourses sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                CourseInformation *firstCourse = [sortedTeachables objectAtIndex:0];

                if (firstCourse.courseId.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                }

                if (![firstCourse.courseSerialCode isEqualToString:@"HP123"])
                {
                    DDLogError(@"%@:%@ courseSerialCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseSerialCode);
                }

                if (![firstCourse.courseName isEqualToString:@"How to survive the unblockable curse"])
                {
                    DDLogError(@"%@:%@ courseName is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseName);
                }

                if (firstCourse.courseIsAvailable.integerValue != 1)
                {
                    DDLogError(@"%@:%@ courseIsAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.courseIsAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (firstCourse.enrolledStudents.count != 2)
                {
                    DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
                }

                if (![firstCourse.creationDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                }

                if (![firstCourse.lastModifiedDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                }

                if ((firstCourse.courseCapacity != nil) || (firstCourse.courseCapacity.integerValue != 0))
                {
                    DDLogError(@"%@:%@ firstCourse courseCapacity is %d, expected 0", THIS_FILE, THIS_METHOD, firstCourse.courseCapacity.integerValue);
                }

                CourseInformation *secondCourse = [sortedTeachables objectAtIndex:1];

                if (secondCourse.courseId.integerValue != 2)
                {
                    DDLogError(@"%@:%@ courseId is %d, expected 2", THIS_FILE, THIS_METHOD, secondCourse.courseId.integerValue);
                }

                if (![secondCourse.courseSerialCode isEqualToString:@"HP234"])
                {
                    DDLogError(@"%@:%@ courseSerialCode is %@, expected HP234", THIS_FILE, THIS_METHOD, secondCourse.courseSerialCode);
                }

                if (![secondCourse.courseName isEqualToString:@"How to ride a hypogriff"])
                {
                    DDLogError(@"%@:%@ courseName is %@, expected How to ride a hypogriff", THIS_FILE, THIS_METHOD, secondCourse.courseName);
                }

                if (secondCourse.courseIsAvailable.integerValue != 0)
                {
                    DDLogError(@"%@:%@ courseIsAvailable is %@, expected FALSE", THIS_FILE, THIS_METHOD, (secondCourse.courseIsAvailable.integerValue ? @"TRUE" : @"FALSE"));
                }

                if (![secondCourse.creationDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ secondCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                }

                if (![secondCourse.lastModifiedDate isEqualToDate:date])
                {
                    DDLogError(@"%@:%@ secondCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                }

                if (secondCourse.enrolledStudents.count != 0)
                {
                    DDLogError(@"%@:%@ secondCourse enrolledStudents count is %d, expected 0", THIS_FILE, THIS_METHOD, secondCourse.enrolledStudents.count);
                }

                if ((secondCourse.courseCapacity != nil) || (firstCourse.courseCapacity.integerValue != 0))
                {
                    DDLogError(@"%@:%@ secondCourse courseCapacity is %d, expected 0", THIS_FILE, THIS_METHOD, firstCourse.courseCapacity.integerValue);
                }
            }
        }

        NSFetchRequest *fetchFirstStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
        NSPredicate *firstStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Good Billy'"];
        [fetchFirstStudent setPredicate:firstStudentPredicate];
        NSArray *firstStudentResult = [context executeFetchRequest:fetchFirstStudent error:&error];
        if (error)
        {
            DDLogError(@"%@:%@ - Failed to fetch student Good Billy", THIS_FILE, THIS_METHOD);
        }
        else
        {
            StudentInformation *firstStudent = [firstStudentResult firstObject];

            if (![firstStudent.firstName isEqualToString:@"Good Billy"])
            {
                DDLogError(@"%@:%@ firstStudent firstname is %@, expected Good Billy", THIS_FILE, THIS_METHOD, firstStudent.firstName);
            }

            if (![firstStudent.lastName isEqualToString:@"Jean"])
            {
                DDLogError(@"%@:%@ firstStudent lastname is %@, expected Jean", THIS_FILE, THIS_METHOD, firstStudent.lastName);
            }

            if (firstStudent.age.longLongValue != 18)
            {
                DDLogError(@"%@:%@ firstStudent currentAge is %d, expected 18", THIS_FILE, THIS_METHOD, firstStudent.age.integerValue);
            }

            if ([[firstStudent.annualTutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:10000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
            {
                DDLogError(@"%@:%@ firstStudent tutitionFee is %f, expected 10000.23", THIS_FILE, THIS_METHOD, firstStudent.annualTutitionFee.doubleValue);
            }

            if (firstStudent.grade.integerValue != 83)
            {
                DDLogError(@"%@:%@ firstStudent avgGrade is %d, expected 83", THIS_FILE, THIS_METHOD, firstStudent.grade.integerValue);
            }

            if (firstStudent.onProbation.integerValue != 0)
            {
                DDLogError(@"%@:%@ firstStudent isOnProbation is %@, expected FALSE", THIS_FILE, THIS_METHOD, (firstStudent.onProbation.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (firstStudent.classifiedData)
            {
                NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                           [NSPropertyListSerialization propertyListWithData:firstStudent.classifiedData
                                                                                                     options:0
                                                                                                      format:nil
                                                                                                       error:&error]];
                if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Blue"])
                {
                    DDLogError(@"%@:%@ firstStudent classifiedData Eye Color is %@, expected Blue", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
                }

                if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"153 cm"])
                {
                    DDLogError(@"%@:%@ firstStudent classifiedData Height is %@, expected 153 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
                }
            }

            if (![firstStudent.creationDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstStudent creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.creationDate, date);
            }

            if (![firstStudent.lastModifiedDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ firstStudent lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstStudent.lastModifiedDate, date);
            }

            if (firstStudent.selectedCourses.count != 1)
            {
                DDLogError(@"%@:%@ - firstStudent's selectedCourses count is %d, expected 1", THIS_FILE, THIS_METHOD, firstStudent.selectedCourses.count);
            }
            else
            {
                NSArray *firstStudentCoursesArray = [firstStudent.selectedCourses allObjects];
                for (CourseInformation *firstCourse in firstStudentCoursesArray)
                {
                    if (firstCourse.courseId.integerValue != 1)
                    {
                        DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                    }

                    if (![firstCourse.courseSerialCode isEqualToString:@"HP123"])
                    {
                        DDLogError(@"%@:%@ courseSerialCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseSerialCode);
                    }

                    if (![firstCourse.courseName isEqualToString:@"How to survive the unblockable curse"])
                    {
                        DDLogError(@"%@:%@ courseName is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseName);
                    }

                    if (firstCourse.courseIsAvailable.integerValue != 1)
                    {
                        DDLogError(@"%@:%@ courseIsAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.courseIsAvailable.integerValue ? @"TRUE" : @"FALSE"));
                    }

                    if (firstCourse.enrolledStudents.count != 2)
                    {
                        DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
                    }

                    if (![firstCourse.creationDate isEqualToDate:date])
                    {
                        DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                    }

                    if (![firstCourse.lastModifiedDate isEqualToDate:date])
                    {
                        DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                    }

                    if ((firstCourse.courseCapacity != nil) || (firstCourse.courseCapacity.integerValue != 0))
                    {
                        DDLogError(@"%@:%@ firstCourse courseCapacity is %d, expected 0", THIS_FILE, THIS_METHOD, firstCourse.courseCapacity.integerValue);
                    }
                }
            }
        }

        NSFetchRequest *fetchSecondStudent = [[NSFetchRequest alloc] initWithEntityName:@"StudentInformation"];
        NSPredicate *secondStudentPredicate = [NSPredicate predicateWithFormat:@"firstname = 'Bad Joel'"];
        [fetchSecondStudent setPredicate:secondStudentPredicate];
        NSArray *secondStudentResult = [context executeFetchRequest:fetchSecondStudent error:&error];
        if (error)
        {
            DDLogError(@"%@:%@ - Failed to fetch student Bad Joel", THIS_FILE, THIS_METHOD);
        }
        else
        {
            StudentInformation *secondStudent = [secondStudentResult firstObject];

            if (![secondStudent.firstName isEqualToString:@"Bad Joel"])
            {
                DDLogError(@"%@:%@ secondStudent firstname is %@, expected Bad Joel", THIS_FILE, THIS_METHOD, secondStudent.firstName);
            }

            if (![secondStudent.lastName isEqualToString:@"Nottingham"])
            {
                DDLogError(@"%@:%@ secondStudent lastname is %@, expected Nottingham", THIS_FILE, THIS_METHOD, secondStudent.lastName);
            }

            if (secondStudent.age.longLongValue != 22)
            {
                DDLogError(@"%@:%@ secondStudent currentAge is %d, expected 22", THIS_FILE, THIS_METHOD, secondStudent.age.integerValue);
            }

            if ([[secondStudent.annualTutitionFee decimalNumberByRoundingAccordingToBehavior:roundCurrency] compare:[[[NSDecimalNumber alloc] initWithFloat:21000.23f] decimalNumberByRoundingAccordingToBehavior:roundCurrency]] != NSOrderedSame)
            {
                DDLogError(@"%@:%@ secondStudent tutitionFee is %f, expected 21000.23", THIS_FILE, THIS_METHOD, secondStudent.annualTutitionFee.doubleValue);
            }

            if (secondStudent.grade.integerValue != 53)
            {
                DDLogError(@"%@:%@ secondStudent avgGrade is %d, expected 53", THIS_FILE, THIS_METHOD, secondStudent.grade.integerValue);
            }

            if (secondStudent.onProbation.integerValue != 1)
            {
                DDLogError(@"%@:%@ secondStudent isOnProbation is %@, expected TRUE", THIS_FILE, THIS_METHOD, (secondStudent.onProbation.integerValue ? @"TRUE" : @"FALSE"));
            }

            if (secondStudent.classifiedData)
            {
                NSMutableDictionary *classifiedDataDict = [NSMutableDictionary dictionaryWithDictionary:
                                                           [NSPropertyListSerialization propertyListWithData:secondStudent.classifiedData
                                                                                                     options:0
                                                                                                      format:nil
                                                                                                       error:&error]];
                if (![[classifiedDataDict objectForKey:k_EyeColour] isEqualToString:@"Green"])
                {
                    DDLogError(@"%@:%@ secondStudent classifiedData Eye Color is %@, expected Green", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_EyeColour]);
                }

                if (![[classifiedDataDict objectForKey:k_Height] isEqualToString:@"188 cm"])
                {
                    DDLogError(@"%@:%@ secondStudent classifiedData Height is %@, expected 188 cm", THIS_FILE, THIS_METHOD, [classifiedDataDict objectForKey:k_Height]);
                }
            }

            if (![secondStudent.creationDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondStudent creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.creationDate, date);
            }

            if (![secondStudent.lastModifiedDate isEqualToDate:date])
            {
                DDLogError(@"%@:%@ secondStudent lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, secondStudent.lastModifiedDate, date);
            }

            if (secondStudent.selectedCourses.count != 1)
            {
                DDLogError(@"%@:%@ - secondStudent's selectedCourses count is %d, expected 1", THIS_FILE, THIS_METHOD, secondStudent.selectedCourses.count);
            }
            else
            {
                NSArray *secondStudentCoursesArray = [secondStudent.selectedCourses allObjects];
                for (CourseInformation *firstCourse in secondStudentCoursesArray)
                {
                    if (firstCourse.courseId.integerValue != 1)
                    {
                        DDLogError(@"%@:%@ courseId is %d, expected 1", THIS_FILE, THIS_METHOD, firstCourse.courseId.integerValue);
                    }

                    if (![firstCourse.courseSerialCode isEqualToString:@"HP123"])
                    {
                        DDLogError(@"%@:%@ courseSerialCode is %@, expected HP123", THIS_FILE, THIS_METHOD, firstCourse.courseSerialCode);
                    }

                    if (![firstCourse.courseName isEqualToString:@"How to survive the unblockable curse"])
                    {
                        DDLogError(@"%@:%@ courseName is %@, expected How to survive the unblockable curse", THIS_FILE, THIS_METHOD, firstCourse.courseName);
                    }

                    if (firstCourse.courseIsAvailable.integerValue != 1)
                    {
                        DDLogError(@"%@:%@ courseIsAvailable is %@, expected TRUE", THIS_FILE, THIS_METHOD, (firstCourse.courseIsAvailable.integerValue ? @"TRUE" : @"FALSE"));
                    }

                    if (firstCourse.enrolledStudents.count != 2)
                    {
                        DDLogError(@"%@:%@ firstCourse enrolledStudents count is %d, expected 2", THIS_FILE, THIS_METHOD, firstCourse.enrolledStudents.count);
                    }

                    if (![firstCourse.creationDate isEqualToDate:date])
                    {
                        DDLogError(@"%@:%@ firstCourse creationDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.creationDate, date);
                    }

                    if (![firstCourse.lastModifiedDate isEqualToDate:date])
                    {
                        DDLogError(@"%@:%@ firstCourse lastModifiedDate is %@, expected %@", THIS_FILE, THIS_METHOD, firstCourse.lastModifiedDate, date);
                    }

                    if ((firstCourse.courseCapacity != nil) || (firstCourse.courseCapacity.integerValue != 0))
                    {
                        DDLogError(@"%@:%@ firstCourse courseCapacity is %d, expected 0", THIS_FILE, THIS_METHOD, firstCourse.courseCapacity.integerValue);
                    }
                }
            }
        }

        DDLogInfo(@"%@:%@ - Ended", THIS_FILE, THIS_METHOD);
    }
   }*/



@end