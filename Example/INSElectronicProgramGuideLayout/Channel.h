//
//  Channel.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 05.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Channel : NSManagedObject

@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject *entries;

@end
