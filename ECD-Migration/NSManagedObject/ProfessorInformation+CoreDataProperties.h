//
//  ProfessorInformation+CoreDataProperties.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-11-27.
//  Copyright © 2015 .. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ProfessorInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfessorInformation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSDecimalNumber *annualSalary;
@property (nullable, nonatomic, retain) NSDate *creationdate;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isAvailable;
@property (nullable, nonatomic, retain) NSDate *lastmodifieddate;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSSet<CourseInformation *> *teachableCourses;

@end

@interface ProfessorInformation (CoreDataGeneratedAccessors)

- (void)addTeachableCoursesObject:(CourseInformation *)value;
- (void)removeTeachableCoursesObject:(CourseInformation *)value;
- (void)addTeachableCourses:(NSSet<CourseInformation *> *)values;
- (void)removeTeachableCourses:(NSSet<CourseInformation *> *)values;

@end

NS_ASSUME_NONNULL_END
