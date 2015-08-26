//
//  ToDoItem.h
//  ToDoList
//
//  Created by Andres Castillo on 8/9/15.
//  Copyright (c) 2015 aco_development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property NSString *itemName;

@property int identifier;

@property BOOL completed;

@property (readonly) NSDate *creationDate;



- (void)markAsCompleted:(BOOL)isComplete;




@end
