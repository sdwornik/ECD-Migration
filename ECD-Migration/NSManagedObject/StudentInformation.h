//
//  StudentInformation.h
//  ECD-Migration
//
//  Created by Jasper Chan on 2015-09-10.
//  Copyright (c) 2015 .. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseInformation;

@interface StudentInformation : NSManagedObject

@property (nonatomic, retain) NSNumber * avgGrade;
@property (nonatomic, retain) NSData * classifieddata;
@property (nonatomic, retain) NSDate * creationdate;
@property (nonatomic, retain) NSNumber * currentAge;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSNumber * isOnProbation;
@property (nonatomic, retain) NSDate * lastmodifieddate;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSDecimalNumber * tutitionFee;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSSet *courses;
@end

@interface StudentInformation (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(CourseInformation *)value;
- (void)removeCoursesObject:(CourseInformation *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
