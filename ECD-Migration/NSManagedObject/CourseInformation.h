//
//  CourseInformation.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-05-10.
//  Copyright (c) 2015 .. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProfessorInformation, StudentInformation;

@interface CourseInformation : NSManagedObject

@property (nonatomic, retain) NSString * courseCode;
@property (nonatomic, retain) NSNumber * courseId;
@property (nonatomic, retain) NSString * courseTitle;
@property (nonatomic, retain) NSDate * creationdate;
@property (nonatomic, retain) NSNumber * isAvailable;
@property (nonatomic, retain) NSDate * lastmodifieddate;
@property (nonatomic, retain) NSSet *students;
@property (nonatomic, retain) ProfessorInformation *teachingProfessor;
@end

@interface CourseInformation (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(StudentInformation *)value;
- (void)removeStudentsObject:(StudentInformation *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
