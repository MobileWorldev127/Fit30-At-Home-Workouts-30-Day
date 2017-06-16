//
//  FDConstants.h
//  flexter
//
//  Created by Anurag Tolety on 5/31/14.
//  Copyright (c) 2014 JMJ Innovations. All rights reserved.
//

#ifndef flexter_FDConstants_h
#define flexter_FDConstants_h

//
// Constants for class names
//
#define ACTIVITY_CLASS @"Activity"
#define USER_CLASS @"User"
#define WORKOUT_CLASS @"Workout"
#define EXERCISE_CLASS @"Exercise"
#define CUSTOM_KEY_VALUE_CLASS @"CustomKeyValuePairs"
#define CHALLENGE_CLASS @"Challenge"
#define CREATED_AT @"createdAt"
#define UPDATED_AT @"updatedAt"

//
// Constants for Workout class
//
#define WORKOUT_TITLE @"title"
#define WORKOUT_COMMENT @"comment"
#define WORKOUT_CREATED_BY @"createdBy"
#define WORKOUT_MAKER @"maker"
#define WORKOUT_ICON_IMAGE @"iconImage"
#define WORKOUT_FULL_IMAGE @"fullImage"
#define WORKOUT_MUSCLE_CATEGORY_LIST @"muscleCategoryList"
#define WORKOUT_EXERCISE_LIST @"exerciseList"
#define WORKOUT_EXERCISE_CONFIG_LIST @"exerciseConfigList"
#define WORKOUT_HASHTAG_LIST @"hashtagList"
#define WORKOUT_DURATION_MIN @"durationInMin"
#define WORKOUT_TYPE @"workoutType"
#define WORKOUT_HOME @"homeWorkout"
#define WORKOUT_HOME_YES [NSNumber numberWithBool:YES]
#define WORKOUT_HOME_NO [NSNumber numberWithBool:NO]
#define WORKOUT_PUBLIC @"public"
#define WORKOUT_PRIORITY @"priority"
#define WORKOUT_PREMIUM @"premium"

#define EXERCISE_CONFIG_DAY1_REPS @"Day1Reps"
#define EXERCISE_CONFIG_DAY30_REPS @"Day30Reps"
#define EXERCISE_CONFIG_DURATION_PER_REP_IN_SEC @"DurationPerRepInSec"
#define EXERCISE_CONFIG_DEFAULT_SETS_COUNT 3
#define EXERCISE_CONFIG_DEFAULT_REPS_COUNT 10

//
// Constants for Exercise class
//
#define EXERCISE_TITLE @"title"
#define EXERCISE_VIDEO @"video"
#define EXERCISE_ICON_IMAGE @"iconImage"
#define EXERCISE_MAKER @"maker"
#define EXERCISE_MUSCLE_CATEGORY @"muscleCategory"
#define EXERCISE_HOME_WORKOUT @"isHomeWorkout"
#define EXERCISE_INSTRUCTIONS @"instructions"
#define EXERCISE_VIDEO_TYPE @"videoType"
#define EXERCISE_VIDEO_TYPE_PARSE_STORED 1
#define EXERCISE_VIDEO_TYPE_YOUTUBE 2
#define EXERCISE_YOUTUBE_ID @"youtubeId"
#define EXERCISE_START_TIME @"startTime"
#define EXERCISE_END_TIME @"endTime"

//
// Constants for muscle cateogory types
//
#define MUSCLE_CATEGORY_COUNT 12
#define MUSCLE_CATEGORY_ABS 0
#define MUSCLE_CATEGORY_BACK 1
#define MUSCLE_CATEGORY_BICEPS 2
#define MUSCLE_CATEGORY_BUTT 3
#define MUSCLE_CATEGORY_CALVES 4
#define MUSCLE_CATEGORY_CARDIO 5
#define MUSCLE_CATEGORY_CHEST 6
#define MUSCLE_CATEGORY_LEGS 7
#define MUSCLE_CATEGORY_SHOULDERS 8
#define MUSCLE_CATEGORY_TRICEPS 9
#define MUSCLE_CATEGORY_FULLBODY 10
#define MUSCLE_CATEGORY_OTHER 11

//
// Constants for custom key value pairs
//
#define CUSTOM_KEY_VALUE_KEY @"key"
#define CUSTOM_KEY_VALUE_VALUE @"value"
#define CUSTOM_KEY_SHARE_LABEL_TEXTS @"ShareLabelTexts"
#define CUSTOM_KEY_FEEDBACK_QUESTIONS @"FeedbackQuestions"
#define CUSTOM_KEY_INTRO_VIDEO @"IntroVideo"

//
// Constants for Activity class
//
#define ACTIVITY_FROM_USER @"fromUser"
#define ACTIVITY_TO_USER @"toUser"
#define ACTIVITY_WORKOUT @"workout"
#define ACTIVITY_TYPE @"type"
#define ACTIVITY_TYPE_LIKE @1

//
// Constants for User class
//
#define USER_PROFILE_IMAGE @"profileImage"
#define USER_PROFILE_THUMBNAIL @"profileThumbnail"
#define USER_BUILD_WORKOUT_ACCESS @"buildWorkoutAccess"
#define USER_PRIVATE_WORKOUT_ACCESS @"privateWorkoutAccess"
#define USER_PREMIUM_EXPIRATION_DATE @"premiumExpirationDate"

//
// Constants for Challenge class
//
#define CHALLENGE_FULL_IMAGE_FILE_NAME @"fullImageFileName"
#define CHALLENGE_COVER_IMAGE_FILE_NAME @"coverImageFileName"
#define CHALLENGE_FULL_IMAGE_FILE @"fullImageFile"
#define CHALLENGE_COVER_IMAGE_FILE @"coverImageFile"
#define CHALLENGE_TITLE @"title"
#define CHALLENGE_LEVEL @"level"
#define CHALLENGE_DESCRIPTION @"description"
#define CHALLENGE_WORKOUTS @"workouts"
#define CHALLENGE_PRIORITY @"priority"
#define CHALLENGE_PREMIUM @"premium"
#define CHALLENGE_PUBLIC @"public"
#define CHALLENGE_PURCHASE_IDENTIFIER @"purchaseIdentifier"
#define CHALLENGE_LEVEL_BEGINNER 1
#define CHALLENGE_LEVEL_INTERMEDIATE 2
#define CHALLENGE_LEVEL_ADVANCED 3

//
// General push notification channel
//
#define PUSH_NOTIFICATION_GENERAL_CHANNEL @"global"
#define PUSH_NOTIFICATION_GENERAL_CHANNEL_TEXT @"General"
#define PUSH_NOTIFICATION @"PushNotification"
#define PUSH_NOTIFICATION_MESSAGE @"alert"
#define PUSH_REGISTRATION_SUCCESSFUL_NOTIFICATION @"PushRegistrationSuccessfulNotification"
#define PUSH_REGISTRATION_FAILED_NOTIFICATION @"PushRegistrationFailedNotification"
#define PUSH_REGISTRATION_SUCCESS_KEY @"PushRegistrationSuccessKey"

//
// Local keys
//
#define LIKED_WORKOUTS_ARRAY_KEY @"LikedWorkouts"


//
// Dropbox Links
//
#define TERMS_AND_CONDITIONS_URL @"https://www.dropbox.com/s/hqqqlom3rqkwlw3/Terms%20%26%20Conditions.pdf?dl=0"
#define GENERAL_PRIVACY_POLICY_URL @"https://www.dropbox.com/s/9zdmqd9xjdjcak1/General%20Privacy%20Policy.pdf?dl=0"

#endif
