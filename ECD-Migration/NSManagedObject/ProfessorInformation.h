//
//  ProfessorInformation.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-09-10.
//  Copyright (c) 2015 .. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseInformation;

@interface ProfessorInformation : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDecimalNumber * annualSalary;
@property (nonatomic, retain) NSDate * creationdate;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isAvailable;
@property (nonatomic, retain) NSDate * lastmodifieddate;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *teachableCourses;
@end

@interface ProfessorInformation (CoreDataGeneratedAccessors)

- (void)addTeachableCoursesObject:(CourseInformation *)value;
- (void)removeTeachableCoursesObject:(CourseInformation *)value;
- (void)addTeachableCourses:(NSSet *)values;
- (void)removeTeachableCourses:(NSSet *)values;

@end
