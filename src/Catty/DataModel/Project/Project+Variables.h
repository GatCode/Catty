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

#import "Project.h"

@class Scene;

@interface Project(Variables)

// Array of Variables
- (NSMutableArray* _Nullable)allVariables;
// Array of Lists
- (NSMutableArray* _Nullable)allLists;
// Array of Variables and Lists
- (NSMutableArray* _Nullable)allVariablesAndLists;

- (UserVariable* _Nullable)getUserVariableNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite;
- (UserVariable* _Nullable)getUserListNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite;
- (BOOL)removeUserVariableNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite;
- (BOOL)removeUserListNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite;
- (void)deleteFromUserList:(UserVariable* _Nullable)userList atIndex:(id _Nullable)index;
- (void)setUserVariable:(UserVariable* _Nullable)userVariable toValue:(id _Nullable)value;
- (void)replaceItemInUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value atIndex:(id _Nullable)position;
- (void)addToUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value;
- (void)changeVariable:(UserVariable* _Nullable)userVariable byValue:(double)value;
- (void)insertToUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value atIndex:(id _Nullable)position;
- (NSArray* _Nullable)allVariablesForObject:(SpriteObject* _Nullable)spriteObject;
- (NSArray* _Nullable)allListsForObject:(SpriteObject* _Nullable)spriteObject;
- (BOOL)addObjectVariable:(UserVariable* _Nullable)userVariable forObject:(SpriteObject* _Nullable)spriteObject;
- (BOOL)addObjectList:(UserVariable* _Nullable)userList forObject:(SpriteObject* _Nullable)spriteObject;
- (void)removeObjectVariablesForSpriteObject:(SpriteObject* _Nullable)object;
- (void)removeObjectListsForSpriteObject:(SpriteObject* _Nullable)object;
- (NSArray* _Nullable)objectVariablesForObject:(SpriteObject* _Nullable)spriteObject;
- (NSArray* _Nullable)objectListsForObject:(SpriteObject* _Nullable)spriteObject;
- (BOOL)isProjectVariableOrList:(UserVariable* _Nullable)userVariable;

@end
