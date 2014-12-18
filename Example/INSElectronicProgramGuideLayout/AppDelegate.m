//
//  AppDelegate.m
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 29.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "AppDelegate.h"
#import "Channel.h"
#import "Entry.h"
#import "NSDate+INSUtils.h"
#import <LoremIpsum.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    if ([Channel MR_countOfEntities] <= 0) {
        for (NSInteger i=0; i < 16; i++) {
            Channel *channel = [Channel MR_createEntity];
            channel.iD = @(i);
            channel.name = [NSString stringWithFormat:@"CHANNEL %ld",(long)i];
            
            NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-3600*24];
            NSDate *lastDate = [startDate copy];
            NSDate *endDate = [startDate dateByAddingTimeInterval:3600*72];
            
            while ([lastDate ins_isEarlierThan:endDate]) {
                Entry *entry = [Entry MR_createEntity];
                entry.startDate = lastDate;
                NSInteger duration = arc4random_uniform(6300) +  900;
                NSDate *newLastDate = [lastDate dateByAddingTimeInterval:duration];
                entry.endDate = newLastDate;
                entry.channel = channel;
                lastDate = newLastDate;
                
                entry.title = [[LoremIpsum wordsWithNumber:arc4random_uniform(5) + 2] uppercaseString];
            }
        }
    }

    

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
