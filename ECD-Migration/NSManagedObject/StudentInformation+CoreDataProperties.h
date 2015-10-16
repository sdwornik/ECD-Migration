//
//  StudentInformation+CoreDataProperties.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-10-16.
//  Copyright © 2015 .. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StudentInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface StudentInformation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *avgGrade;
@property (nullable, nonatomic, retain) NSData *classifieddata;
@property (nullable, nonatomic, retain) NSDate *creationdate;
@property (nullable, nonatomic, retain) NSNumber *currentAge;
@property (nullable, nonatomic, retain) NSString *firstname;
@property (nullable, nonatomic, retain) NSNumber *isOnProbation;
@property (nullable, nonatomic, retain) NSDate *lastmodifieddate;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSDecimalNumber *tutitionFee;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSSet<CourseInformation *> *courses;

@end

@interface StudentInformation (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(CourseInformation *)value;
- (void)removeCoursesObject:(CourseInformation *)value;
- (void)addCourses:(NSSet<CourseInformation *> *)values;
- (void)removeCourses:(NSSet<CourseInformation *> *)values;

@end

NS_ASSUME_NONNULL_END
