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

- (NSMutableArray* _Nullable)allVariablesForScene:(Scene* _Nullable)scene;
- (NSMutableArray* _Nullable)allListsForScene:(Scene* _Nullable)scene;
- (NSMutableArray* _Nullable)allVariablesAndListsForScene:(Scene* _Nullable)scene;
- (BOOL)addObjectVariable:(UserVariable* _Nullable)userVariable forObject:(SpriteObject* _Nullable)spriteObject toScene:(Scene* _Nullable)scene;
- (BOOL)addObjectList:(UserVariable* _Nullable)userList forObject:(SpriteObject* _Nullable)spriteObject toScene:(Scene* _Nullable)scene;
- (void)removeObjectVariablesForSpriteObject:(SpriteObject* _Nullable)object inScene:(Scene* _Nullable)scene;
- (void)removeObjectListsForSpriteObject:(SpriteObject* _Nullable)object inScene:(Scene* _Nullable)scene;
- (NSArray* _Nullable)objectVariablesForObject:(SpriteObject* _Nullable)spriteObject inScene:(Scene* _Nullable)scene;
- (NSArray* _Nullable)objectListsForObject:(SpriteObject* _Nullable)spriteObject inScene:(Scene* _Nullable)scene;
- (UserVariable* _Nullable)getUserVariableNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite inScene:(Scene* _Nullable)scene;
- (UserVariable* _Nullable)getUserListNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite inScene:(Scene* _Nullable)scene;
- (BOOL)removeUserVariableNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite inScene:(Scene* _Nullable)scene;
- (BOOL)removeUserListNamed:(NSString* _Nullable)name forSpriteObject:(SpriteObject* _Nullable)sprite inScene:(Scene* _Nullable)scene;

- (void)deleteFromUserList:(UserVariable* _Nullable)userList atIndex:(id _Nullable)index;
- (void)insertToUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value atIndex:(id _Nullable)position;

- (void)replaceItemInUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value atIndex:(id _Nullable)position;
- (void)changeVariable:(UserVariable* _Nullable)userVariable byValue:(double)value;
- (void)setUserVariable:(UserVariable* _Nullable)userVariable toValue:(id _Nullable)value;
- (void)addToUserList:(UserVariable* _Nullable)userList value:(id _Nullable)value;
- (NSArray* _Nullable)allVariablesForObject:(SpriteObject* _Nullable)spriteObject;
- (NSArray* _Nullable)allListsForObject:(SpriteObject* _Nullable)spriteObject;
- (BOOL)isProjectVariableOrList:(UserVariable* _Nullable)userVariable;

@end
