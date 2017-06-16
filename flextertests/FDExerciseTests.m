//
//  FDExerciseTests.m
//  flexter
//
//  Created by Anurag Tolety on 5/31/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FDExercise.h"
#import "FDConstants.h"

#define TEST_EXERCISE_MUSCLE_CATEGORY @1
#define TEST_EXERCISE_TITLE @"testExerciseTitle"
#define OBJECT_ID @"objectId"

@interface FDExerciseTests : XCTestCase

@property (strong, nonatomic) FDExercise* exercise;

@end

@implementation FDExerciseTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.exercise = [FDExercise objectWithClassName:EXERCISE_CLASS];
    self.exercise[EXERCISE_MUSCLE_CATEGORY] = TEST_EXERCISE_MUSCLE_CATEGORY;
    self.exercise[EXERCISE_TITLE] = TEST_EXERCISE_TITLE;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.exercise delete];
}

- (void)testSave
{
    XCTAssertTrue([self.exercise save], @"save successfull");
}

- (void)testParametersSetting
{
    NSString* exerciseObjectId = self.exercise.objectId;
    PFQuery* query = [PFQuery queryWithClassName:EXERCISE_CLASS];
    [query whereKey:OBJECT_ID equalTo:exerciseObjectId];
    NSArray* objects = [query findObjects];
    XCTAssertEqual([objects count], 1, @"exercise not stored");
    FDExercise* result = [objects firstObject];
    XCTAssertTrue([result.objectId isEqualToString:exerciseObjectId], @"object id doesn't match");
    XCTAssertTrue([result[EXERCISE_TITLE] isEqualToString:TEST_EXERCISE_TITLE], @"title doesn't match");
    XCTAssertEqual(result[EXERCISE_MUSCLE_CATEGORY], TEST_EXERCISE_MUSCLE_CATEGORY, @"muscle category doesn't match");
}

- (void)testVideoUploading
{
    XCTFail(@"No implementation for %s", __PRETTY_FUNCTION__);
    
}

- (void)testIconUploading
{
    XCTFail(@"No implementation for %s", __PRETTY_FUNCTION__);
}

- (void)testFullImageUploading
{
    XCTFail(@"No implementation for %s", __PRETTY_FUNCTION__);
}

@end
