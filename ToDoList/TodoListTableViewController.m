//
//  TodoListTableViewController.m
//  ToDoList
//
//  Created by Andres Castillo on 8/9/15.
//  Copyright (c) 2015 aco_development. All rights reserved.
//
#import "AddToDoItemViewController.h"
#import "TodoListTableViewController.h"
#import "ToDoItem.h"

@interface TodoListTableViewController ()

@property NSMutableArray *toDoItems;


@end

@implementation TodoListTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(fetchTasks)
                  forControlEvents:UIControlEventValueChanged];

 
    self.toDoItems = [[NSMutableArray alloc] init];
    [self loadInitialData];
    [self fetchTasks];
    
}

- (void)loadInitialData{
    ToDoItem *item1 = [[ToDoItem alloc] init];
    item1.itemName = @"Buy Bananas";
    [self.toDoItems addObject:item1];
    ToDoItem *item2 = [[ToDoItem alloc] init];
    item2.itemName = @"Implement ajax call";
    [self.toDoItems addObject:item2];
    ToDoItem *item3 = [[ToDoItem alloc] init];
    item3.itemName = @"Cats";
    [self.toDoItems addObject:item3];
    
}

- (void)fetchTasks
{
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/tasks"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
            [self.toDoItems removeAllObjects];
             NSMutableArray * tasks = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             for(int i=0; i < [tasks count]; i++){
             
             ToDoItem *item = [[ToDoItem alloc] init];
             item.itemName = [[tasks objectAtIndex:i ] objectForKey:@"name"];
             item.completed =[[[tasks objectAtIndex:i ] objectForKey:@"completed"] boolValue];
             item.identifier = [[[tasks objectAtIndex:i] objectForKey:@"id"] unsignedIntValue];
                  NSLog(@"%@", item.itemName);
                  NSLog(item.completed ? @"Yes" : @"No");
             [self.toDoItems addObject:item];
             }
             
             [self.tableView reloadData];
         }
     }];
    
    [self.refreshControl endRefreshing];

}

- (void)createTask:(ToDoItem *)item {
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/tasks"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
        NSString * task =  [NSString stringWithFormat:@"name=%@&completed=%i",item.itemName, item.completed];
        [request setHTTPBody:[task dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary * tasks = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
                 NSLog(@"%@", tasks );
                 ToDoItem *item = [[ToDoItem alloc] init];
                 item.itemName = [tasks objectForKey:@"name"];
                 item.completed =[[tasks objectForKey:@"completed"] boolValue];
                 item.identifier = [[tasks  objectForKey:@"id"] unsignedIntValue] ;
                 NSLog(@"%@", item);
                [self.toDoItems addObject:item];
                 NSLog(@"%@", item);
             
             
             [self.tableView reloadData];
         }
     }];

    
    

}

-(void)updateTask:(NSInteger)index{

    ToDoItem *tappedItem = [self.toDoItems objectAtIndex: index];
    tappedItem.completed = !tappedItem.completed;
    NSString *escapedItemName = [tappedItem.itemName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * stringURL =  [NSString stringWithFormat:@"http://localhost:3000/tasks/%i?name=%@&completed=%i", tappedItem.identifier, escapedItemName, tappedItem.completed ];
    NSLog(@"id of tapped item: %i", tappedItem.identifier);
    NSLog(@"url: %@", stringURL);
    NSURL *url = [NSURL URLWithString:stringURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    //NSString * task =  [NSString stringWithFormat:@"name=%@&completed=%i",tappedItem.itemName, tappedItem.completed];
    //[request setHTTPBody:[task dataUsingEncoding:NSUTF8StringEncoding]];
    //NSDictionary * dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:tappedItem.itemName,@"name", nil];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary * tasks = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:NULL];

             ToDoItem *item = [[ToDoItem alloc] init];
             item.itemName = [tasks objectForKey:@"name"];
             item.completed =[[tasks objectForKey:@"completed"] boolValue];
             item.identifier = [[tasks  objectForKey:@"id"] unsignedIntValue];
             [self.toDoItems replaceObjectAtIndex:index withObject:item];
             NSLog(@"%@", item);
             
             
             
         }
     }];

    
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return  [self.toDoItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    ToDoItem *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.itemName;
    
    if (toDoItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
       //[tableView deselectRowAtIndexPath:indexPath animated:NO];

    [self updateTask: indexPath.row];
    for (int i=0; i < [self.toDoItems count]; i++){
        ToDoItem *current = [self.toDoItems objectAtIndex:i];
        NSLog(@"name: %@, completed: %i", current.itemName, current.completed);
        
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
    AddToDoItemViewController *source = [segue sourceViewController];
    ToDoItem *item = source.toDoItem;
    if (item != nil) {
         [self createTask: item ];
    }
    
   
    
}


@end
