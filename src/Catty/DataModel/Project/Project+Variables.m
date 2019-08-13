/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "Project+Variables.h"
#import "Pocket_Code-Swift.h"

@implementation Project(Variables)

static pthread_mutex_t variablesLock;

- (NSMutableArray*)allVariablesForScene:(Scene *)scene
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programVariableList];
    
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    for(NSUInteger index = 0; index < [scene.data.objectVariableList count]; index++) {
        NSMutableArray *variableList = [scene.data.objectVariableList objectAtIndex:index];
        if([variableList count] > 0)
            [vars addObjectsFromArray:variableList];
    }
    
    return vars;
}

- (NSMutableArray*)allListsForScene:(Scene *)scene
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programListOfLists];
    
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    for(NSUInteger index = 0; index < [scene.data.objectListOfLists count]; index++) {
        NSMutableArray *listOfLists = [scene.data.objectListOfLists objectAtIndex:index];
        if([listOfLists count] > 0)
            [vars addObjectsFromArray:listOfLists];
    }
    
    return vars;
}

- (NSMutableArray*)allVariablesAndListsForScene:(Scene *)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    NSMutableArray *vars = [self allVariablesForScene:scene ];
    NSMutableArray *lists = [self allListsForScene:scene ];
    if([vars count] > 0){
        [vars addObjectsFromArray:lists];
    }
    
    return vars;
}

- (UserVariable*)getUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    NSArray *objectUserVariables = [scene.data.objectVariableList objectForKey:sprite];
    UserVariable *variable = [self findUserVariableNamed:name inArray:objectUserVariables];
    
    if (! variable) {
        variable = [self findUserVariableNamed:name inArray:self.programVariableList];
    }
    return variable;
}

- (UserVariable*)getUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    NSArray *objectUserLists = [scene.data.objectListOfLists objectForKey:sprite];
    UserVariable *list = [self findUserVariableNamed:name inArray:objectUserLists];
    
    if (! list) {
        list = [self findUserVariableNamed:name inArray:self.programListOfLists];
    }
    return list;
    
    return nil;
}

- (BOOL)removeUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:sprite]) {
        NSMutableArray *objectUserVariables = [scene.data.objectVariableList objectForKey:sprite];
        UserVariable *variable = [self findUserVariableNamed:name inArray:objectUserVariables];
        if (variable) {
            [self removeObjectUserVariableNamed:name inArray:objectUserVariables forSpriteObject:sprite];
            return YES;
        } else {
            variable = [self findUserVariableNamed:name inArray:self.programVariableList];
            if (variable) {
                [self removeProjectUserVariableNamed:name];
                return YES;
            }
        }
        return NO;
    }
    
    return NO;
}

- (BOOL)removeUserListNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:sprite]) {
        NSMutableArray *objectUserLists = [scene.data.objectListOfLists objectForKey:sprite];
        UserVariable *list = [self findUserVariableNamed:name inArray:objectUserLists];
        if (list) {
            [self removeObjectUserListNamed:name inArray:objectUserLists forSpriteObject:sprite];
            return YES;
        } else {
            list = [self findUserVariableNamed:name inArray:self.programListOfLists];
            if (list) {
                [self removeProjectUserListNamed:name];
                return YES;
            }
        }
        return NO;
    }
    
    return NO;
}

- (void)deleteFromUserList:(UserVariable*)userList atIndex:(id)position
{
    pthread_mutex_lock(&variablesLock);
    if((![userList.value isKindOfClass:[NSMutableArray class]]) && (userList.value != nil)){
        NSError(@"Found a UserList that is not of class NSMutableArray.");
    }
    
    NSMutableArray *array;
    if(userList.value == nil){
        array = [[NSMutableArray alloc] init];
    } else {
        array = (NSMutableArray*)userList.value;
    }
    
    NSUInteger size = [array count];
    NSUInteger castedPosition = [(NSNumber*)position unsignedIntegerValue];
    
    if ((castedPosition > size) || (castedPosition < 1)) {
        pthread_mutex_unlock(&variablesLock);
        return;
    }
    [array removeObjectAtIndex:castedPosition - 1];
    
    userList.value = array;
    pthread_mutex_unlock(&variablesLock);
}

- (void)setUserVariable:(UserVariable*)userVariable toValue:(id)value
{
    pthread_mutex_lock(&variablesLock);
    if([value isKindOfClass:[NSString class]]){
        NSString *stringValue = (NSString*)value;
        userVariable.value = stringValue;
    } else if([value isKindOfClass:[NSNumber class]]){
        NSNumber *numberValue = (NSNumber*)value;
        userVariable.value = numberValue;
    } else {
        userVariable.value = [NSNumber numberWithInt:0];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)replaceItemInUserList:(UserVariable*)userList value:(id)value atIndex:(id)position
{
    pthread_mutex_lock(&variablesLock);
    if((![userList.value isKindOfClass:[NSMutableArray class]]) && (userList.value != nil)){
        NSError(@"Found a UserList that is not of class NSMutableArray.");
    }
    
    NSMutableArray *array;
    if(userList.value == nil){
        array = [[NSMutableArray alloc] init];
    } else {
        array = (NSMutableArray*)userList.value;
    }
    
    NSUInteger size = [array count];
    NSUInteger castedPosition = [(NSNumber*) position unsignedIntegerValue];
    
    if ((castedPosition > size) || (castedPosition < 1)) {
        pthread_mutex_unlock(&variablesLock);
        return;
    }
    
    if([value isKindOfClass:[NSString class]]){
        [array replaceObjectAtIndex:castedPosition - 1 withObject:(NSString*)value];
    } else if([value isKindOfClass:[NSNumber class]]){
        [array replaceObjectAtIndex:castedPosition - 1 withObject:(NSNumber*)value];
    }
    userList.value = array;
    pthread_mutex_unlock(&variablesLock);
}

- (void)addToUserList:(UserVariable*)userList value:(id)value
{
    pthread_mutex_lock(&variablesLock);
    if((![userList.value isKindOfClass:[NSMutableArray class]]) && (userList.value != nil)){
        NSError(@"Found a UserList that is not of class NSMutableArray.");
    }
    
    NSMutableArray *array;
    if(userList.value == nil){
        array = [[NSMutableArray alloc] init];
    } else {
        array = (NSMutableArray*)userList.value;
    }
    
    if([value isKindOfClass:[NSString class]]){
        [array addObject:(NSString*)value];
    } else if([value isKindOfClass:[NSNumber class]]){
        [array addObject:(NSNumber*)value];
    } else {
        [array addObject:[NSNumber numberWithInt:0]];
    }
    userList.value = array;
    pthread_mutex_unlock(&variablesLock);
}

- (void)changeVariable:(UserVariable*)userVariable byValue:(double)value
{
    pthread_mutex_lock(&variablesLock);
    if ([userVariable.value isKindOfClass:[NSNumber class]]){
        userVariable.value = [NSNumber numberWithFloat:(CGFloat)(([userVariable.value doubleValue] + value))];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)insertToUserList:(UserVariable*)userList value:(id)value atIndex:(id)position
{
    pthread_mutex_lock(&variablesLock);
    if((![userList.value isKindOfClass:[NSMutableArray class]]) && (userList.value != nil)){
        NSError(@"Found a UserList that is not of class NSMutableArray.");
    }
    
    NSMutableArray *array;
    if(userList.value == nil){
        array = [[NSMutableArray alloc] init];
    } else {
        array = (NSMutableArray*)userList.value;
    }
    
    NSUInteger size = [array count];
    NSUInteger castedPosition = [(NSNumber*)position unsignedIntegerValue];
    
    
    if ((castedPosition > (size + 1)) || (castedPosition < 1)) {
        pthread_mutex_unlock(&variablesLock);
        return;
    }
    
    if([value isKindOfClass:[NSString class]]){
        [array insertObject:(NSString*)value atIndex:castedPosition - 1];
    } else if([value isKindOfClass:[NSNumber class]]){
        [array insertObject:(NSNumber*)value atIndex:castedPosition - 1];
    } else {
        [array insertObject:[NSNumber numberWithInt:0] atIndex:castedPosition - 1];
    }
    userList.value = array;
    pthread_mutex_unlock(&variablesLock);
}

- (NSArray*)allVariablesForObject:(SpriteObject*)spriteObject
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programVariableList];
    [vars addObjectsFromArray:[self objectVariablesForObject:spriteObject inScene:nil]];
    return vars;
}

- (NSArray*)allListsForObject:(SpriteObject*)spriteObject
{
    NSMutableArray *lists = [NSMutableArray arrayWithArray:self.programListOfLists];
    [lists addObjectsFromArray:[self objectListsForObject:spriteObject inScene:nil]];
    return lists;
}

- (BOOL)addObjectVariable:(UserVariable*)userVariable forObject:(SpriteObject*)spriteObject toScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:spriteObject]) {
        NSMutableArray *array = [scene.data.objectVariableList objectForKey:spriteObject];
        
        if (!array) {
            array = [NSMutableArray new];
        } else {
            for (UserVariable *userVariableToCompare in array) {
                if ([userVariableToCompare.name isEqualToString:userVariable.name]) {
                    return NO;
                }
            }
        }
        
        [array addObject:userVariable];
        [scene.data.objectVariableList setObject:array forKey:spriteObject];
        return YES;
    }
    
    return NO;
}

- (BOOL)addObjectList:(UserVariable*)userList forObject:(SpriteObject*)spriteObject toScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:spriteObject]) {
        NSMutableArray *array = [scene.data.objectListOfLists objectForKey:spriteObject];
        
        if (!array) {
            array = [NSMutableArray new];
        } else {
            for (UserVariable *userListToCompare in array) {
                if ([userListToCompare.name isEqualToString:userList.name]) {
                    return NO;
                }
            }
        }
        
        [array addObject:userList];
        [scene.data.objectListOfLists setObject:array forKey:spriteObject];
        return YES;
    }
    
    return NO;
}

- (void)removeObjectVariablesForSpriteObject:(SpriteObject*)object inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:object]) {
        [scene.data.objectVariableList removeObjectForKey:object];
    }
}

- (void)removeObjectListsForSpriteObject:(SpriteObject*)object inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:object]) {
        [scene.data.objectListOfLists removeObjectForKey:object];
    }
}

- (NSArray*)objectVariablesForObject:(SpriteObject*)spriteObject inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:spriteObject]) {
        NSMutableArray *vars = [NSMutableArray new];
        if([scene.data.objectVariableList objectForKey:spriteObject]) {
            for(UserVariable *var in [scene.data.objectVariableList objectForKey:spriteObject]) {
                [vars addObject:var];
            }
        }
        return vars;
    }
    
    return nil;
}

- (NSArray*)objectListsForObject:(SpriteObject*)spriteObject inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if ([scene.objectList containsObject:spriteObject]) {
        NSMutableArray *lists = [NSMutableArray new];
        if([scene.data.objectListOfLists objectForKey:spriteObject]) {
            for(UserVariable *list in [scene.data.objectListOfLists objectForKey:spriteObject]) {
                [lists addObject:list];
            }
        }
        return lists;
    }
    
    return nil;
}

- (UserVariable*)findUserVariableNamed:(NSString*)name inArray:(NSArray*)userVariables
{
    UserVariable *variable = nil;
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [userVariables count]; ++i) {
        UserVariable *var = [userVariables objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    return variable;
}

- (void)removeObjectUserVariableNamed:(NSString*)name inArray:(NSMutableArray*)userVariables forSpriteObject:(SpriteObject*)sprite
{
    for (Scene* scene in self.scenes) {
        if ([scene.objectList containsObject:sprite]) {
            pthread_mutex_lock(&variablesLock);
            for (int i = 0; i < [userVariables count]; ++i) {
                UserVariable *var = [userVariables objectAtIndex:i];
                if ([var.name isEqualToString:name]) {
                    [userVariables removeObjectAtIndex:i];
                    [scene.data.objectVariableList setObject:userVariables forKey:sprite];
                    break;
                }
            }
            pthread_mutex_unlock(&variablesLock);
        }
    }
}

- (void)removeObjectUserListNamed:(NSString*)name inArray:(NSMutableArray*)userLists forSpriteObject:(SpriteObject*)sprite
{
    for (Scene* scene in self.scenes) {
        if ([scene.objectList containsObject:sprite]) {
            pthread_mutex_lock(&variablesLock);
            for (int i = 0; i < [userLists count]; ++i) {
                UserVariable *list = [userLists objectAtIndex:i];
                if ([list.name isEqualToString:name]) {
                    [userLists removeObjectAtIndex:i];
                    [scene.data.objectListOfLists setObject:userLists forKey:sprite];
                    break;
                }
            }
            pthread_mutex_unlock(&variablesLock);
        }
    }
}

- (void)removeProjectUserVariableNamed:(NSString*)name
{
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [self.programVariableList count]; ++i) {
        UserVariable *var = [self.programVariableList objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            [self.programVariableList removeObjectAtIndex:i];
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)removeProjectUserListNamed:(NSString*)name
{
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [self.programListOfLists count]; ++i) {
        UserVariable *list = [self.programListOfLists objectAtIndex:i];
        if ([list.name isEqualToString:name]) {
            [self.programListOfLists removeObjectAtIndex:i];
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
}

- (BOOL)isProjectVariableOrList:(UserVariable*)userVarOrList
{
    if (!userVarOrList.isList) {
        for (UserVariable *userVariableToCompare in self.programVariableList) {
            if ([userVariableToCompare.name isEqualToString:userVarOrList.name]) {
                return YES;
            }
        }
    } else {
        for (UserVariable *userListToCompare in self.programListOfLists) {
            if ([userListToCompare.name isEqualToString:userVarOrList.name]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
