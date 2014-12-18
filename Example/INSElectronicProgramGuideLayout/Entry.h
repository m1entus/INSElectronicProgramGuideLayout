//
//  Entry.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 05.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Channel *channel;

@end
