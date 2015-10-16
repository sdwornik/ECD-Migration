//
//  CourseInformation+CoreDataProperties.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-10-16.
//  Copyright © 2015 .. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CourseInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourseInformation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *courseCode;
@property (nullable, nonatomic, retain) NSNumber *courseId;
@property (nullable, nonatomic, retain) NSString *courseTitle;
@property (nullable, nonatomic, retain) NSDate *creationdate;
@property (nullable, nonatomic, retain) NSNumber *isAvailable;
@property (nullable, nonatomic, retain) NSDate *lastmodifieddate;
@property (nullable, nonatomic, retain) NSSet<StudentInformation *> *students;
@property (nullable, nonatomic, retain) ProfessorInformation *teachingProfessor;

@end

@interface CourseInformation (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(StudentInformation *)value;
- (void)removeStudentsObject:(StudentInformation *)value;
- (void)addStudents:(NSSet<StudentInformation *> *)values;
- (void)removeStudents:(NSSet<StudentInformation *> *)values;

@end

NS_ASSUME_NONNULL_END
