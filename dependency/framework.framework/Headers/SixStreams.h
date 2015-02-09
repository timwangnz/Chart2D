//
//  SixStreams.h
//  SixStreams
//
//  Created by Anping Wang on 11/3/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//
#import "DebugLogger.h"


#ifndef SixStreams_ParseStorageHeader_h
#define SixStreams_ParseStorageHeader_h

#define OBJECT_FIELD @"org.sixstreams.ObjectField"
#define APPLICATION @"org.sixstreams.Application"
#define COLUMN_DEF @"org.sixstreams.ColumnDef"
#define APP_CATEGORY @"org.sixstreams.Category"


#define APP_VIEW @"org.sixstreams.View"
#define APP_VIEW_SUBSCRIPTION @"org.sixstreams.view.Subscription"
#define APP_VIEW_ID @"viewId"

#define WIDGET @"org.sixstreams.Widget"
#define OBJECT_TYPE @"org.sixstreams.ObjectType"

#define BASE_URL @"http://www.parse.com"

#define REF_ID_NAME @"refId"
#define ROLE_ID @"roleId"
#define APPLICATION_ID @"appId"
#define PACKAGE_ID @"packageId"

#define CONTEXT @"context"
#define CONTEXT_TYPE @"contextType"
//store display values for attributes that are lookups
#define DISPLAY_VALUES @"displayValues"

#define AUTHOR @"ss_author"
#define PICTURE_URL @"pictureURL"

#define GROUP @"group"
#define IS_ADMIN @"ss_admin"
#define ICON @"icon"
#define ERROR @"Error"
#define SETTINGS @"Settings"

#define SS_OBJECT_TYPE @"objectType"
#define SS_FIELD_DEF_KEY @"fieldsDef"

#define STORAGE @"storage"

#define CATEGORY @"category"
#define VISIBILITY @"visibility"
#define ACCESS_CONTROL_LIST @"ss_acl"
//
//this is the network can be created by user
//stored on sixstreams
//
#define NETWORK_CLASS @"org.sixstreams.user.Network"
#define PROFILE_CLASS @"org.sixstreams.user.Profile"
#define FRIEND_CLASS @"org.sixstreams.user.Friend"
#define GROUP_CLASS @"org.sixstreams.user.Group"
//#define GROUP_CLASS @"Role"

#define MEMBERSHIP_CLASS @"org.sixstreams.user.Membership"
#define INVITATION_CLASS @"org.sixstreams.user.Invitation"
#define INVITATION_RESTRICTIONS @"restriction"
#define PUBLIC_ACCESS @"0"

#define EVENT_TYPE @"eventType"


#define SOCIAL_ACTIVITY @"org.sixstreams.social.Activity"
#define SOCIAL_COMMENT @"org.sixstreams.social.Comment"
#define SOCIAL_LIKE @"org.sixstreams.social.Like"
#define SOCIAL_FOLLOW @"org.sixstreams.social.Follow"

#define COMPANY_CLASS @"org.sixstreams.Company"

#define FOLLOWERS @"followers"
#define FOLLOWING @"following"
#define FOLLOW @"follow"

#define SEARCHABLE_WORDS @"searchableWords"
#define ACTION @"action"

#define FIRST_NAME @"firstName"
#define LAST_NAME @"lastName"
#define GENDER @"gender"
#define ABOUT_ME @"aboutMe"
#define AGE @"age"
#define COMMENT @"comment"
#define COMMENTED_ON @"commentedOn"
#define RATING @"rating"

#define USER_TYPE @"userType"
#define GROUPS @"groups"

#define JOB_TITLE @"jobTitle"

#define INVIVATION_ID @"invitationId"


#define JOB_TITLES @"jobTitles"
//#define JOB_TYPE @"jobType"
#define EMAIL_2ND @"email2"

#define GROUP_NAME @"groupName"
#define GROUP_ID @"groupId"
#define USER_ID @"userId"
#define PROFILE_ID @"profileId"

#define EMAIL @"email"
#define PHONE @"phone"
#define DOMAIN_NAME @"domain"
#define WEB_SITE @"website"
#define FACEBOOK @"facebook"

#define NAME @"name"

#define READ_ONLY @"readonly"
#define VISIBLE @"visible"
#define EXPRESSION @"expression"


#define ORGANIZER @"organizer"
#define USERNAME @"username"
#define PERSON_DEFAULT_ICON @"person-icon"

#define DESC @"desc"
#define REQUIRED @"required"
#define DATA_TYPE @"dataType"
#define META_TYPE @"metaType"
#define META_DATA @"metaData"
#define OBJECT_TYPE_ID @"objectTypeId"
#define OBJECT_ID @"objectId"
#define MEETING_ID @"meetingId"
#define SPOT_LIGHTS @"spotlights"


#define PRODUCT @"product"
#define PRICE @"price"

#define CALENDAR @"Calendar"
#define BROWSE @"Browse"

#define DATE @"date"
#define DATE_FROM @"dateFrom"
#define DATE_TO @"dateTo"
#define CREATED_AT @"createdAt"
#define UPDATED_AT @"updatedAt"
#define IS_UPDATE @"isUpdate"

#define DURATION_IN_MINUTES @"durationInMin"
#define SEATS @"seats"
#define BLIND @"blind"
#define PAYMENT_METHOD @"paymentMethod"

#define ADDRESS_ENTITY @"addressObject"
#define ADDRESS @"address"
#define GET_POINT @"geoPoint"

#define ADDRESS_LINE @"place"
#define TITLE @"title"
#define SUBTITLE @"subtitle"
#define NOTE @"note"
#define STATUS @"status"
#define SCORE @"score"

#define ATTENDEES @"attendees"

#define ACCEPTED @"Accepted"
#define REQUESTED @"Requested"
#define REQUESTER @"Requester"
#define CONNECTION @"connection"

#define COLUMN_DEFS @"columnDefs"
#define FIELD_NAME @"fieldName"
#define BINDING @"binding"
#define SEQUENCE @"sequence"
#define MALE @"Male"
#define STREET_ADDRESS @"street"
#define CITY @"city"
#define METRO @"metro"
#define AREA @"area"

#define STATE @"state"
#define COUNTRY @"country"
#define POSTAL_CODE @"postalCode"
#define ZIP_CODE @"zipCode"
#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define LOCATION @"location"
#define APPLICATION_KEY @"application"
#define PRIVACY @"privacy"

#define INVITEE @"invitee"
#define INVITEES @"invitees"
#define INVITEE_ID @"inviteeId"

#define EVENT @"event"
#define SERVICE @"service"
#define SUB_CATEGORY @"subcategory"


#define PAYLOAD @"data"
#define CACHED_AT @"cachedAt"
#define ONE_DAY 24 * 3600
#define CACHED_DATA @"cachedData"

#define FILE_CLASS @"org.sixstreams.file.File"

#define MEETING_CLASS @"org.sixstreams.gloofy.Event"
#define INVITE_CLASS @"org.sixstreams.gloofy.Invite"

#define FILE_NAME_KEY @"filename"
#define FILE_KEY @"file"
#define FILE_TYPE @"fileType"
#define FILE_SIZE @"fileSize"
#define SS_TYPE @"type"

#define FILE_TYPE_IMG @"img"
#define FILE_TYPE_VIDEO @"video"



#define RELATED_TYPE @"relatedType"
#define RELATED_ID @"relatedId"

#define USER @"user"
#define USER_INFO @"userInfo"

#define MESSAGING_CLASS @"org.sixstreams.social.user.Message"
#define MESSAGE_TO @"to"
#define CHAT_ID @"chatId"
#define MESSAGE_FROM @"from"
#define MESSAGE @"message"
#define DIRECTION @"direction"

#define GRAPH_CLASS @"org.sixstreams.tutor.graph"
#define SHAPE_CLASS @"org.sixstreams.tutor.graph.shape"
#define ACTION_CLASS @"org.sixstreams.tutor.graph.action"

#define GRAPH @"graph"
#define BOOK @"book"
#define SEARCH @"search"
#define HIGHLIGHTS @"highlight"

#define JOB_STATUS @"jobStatus"
#define INDUSTRY @"industry"
#define JOB @"job"
#define JOB_DETAILS @"jobDetails"
#define JOBS @"Jobs"
#define RESUME @"resume"
#define APPLICANT_ID @"applicantId"
#define APPLICANT @"applicant"

#define RESUME_CLASS @"org.sixstreams.jobs.Resume"
#define JOB_CLASS @"org.sixstreams.jobs.Job"
#define JOB_APPLICATION_CLASS @"org.sixstreams.jobs.Application"

#define POSITION @"position"
#define WORK_AUTH @"workAuthorization"
#define OBJECTIVES @"objectives"
#define KEYWORDS @"keywords"
#define DATE_AVAILABLE @"dateAvailable"
#define EXPERIENCE @"experience"
#define EDUCATION @"education"
#define SKILL_SET @"skillset"


#define TAX_TERM @"taxTerm"
#define JOB_DESC @"jobDesc"
#define EDUCATION_LEVEL @"educationLevel"
#define TELECOMMUTE @"telecommute"
#define PUBLISHED @"published"

#define EXPERIENCE_YEARS @"yearsOFExp"
#define CAREER_LEVEL @"careerLevel"
#define TRAVEL_REQ @"travel"
#define PAY_RATE @"payRate"
#define COMPANY @"company"
#define EMPLOYMENT_TYPE @"employmentType"

#define SKILL @"skill"
#define SOFT_SKILL @"softskill"

#define SKILL_LEVEL @"skillLevel"

#define DEGREE @"degree"
#define YEAR_END @"yearTo"
#define YEAR_START @"yearFrom"
#define SCHOOL @"school"

#define METRO_AREA @"metro"


#define WORD_CLASS @"org.sixstreams.sat.Word"
#define WORD @"word"
#define MEANING @"meaning"
#define SAMPLE @"sample"


#define DEFAULT_FONT_SIZE 17

typedef NS_ENUM(NSInteger, SSPrivacy) {
    SSPrivate,
    SSGroup,
    SSCompany,
    SSPublic
};

#endif

