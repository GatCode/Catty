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
#import "Util.h"
#import "AppDelegate.h"
#import "Script.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@implementation Project

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray<Scene*> *scenes = [[NSMutableArray<Scene*> alloc] init];
        self.scenes = scenes;
        [scenes addObject:[self allocDefaultScene]];
        
        self.programVariableList = [[NSMutableArray<UserVariable*> alloc] init];
        self.programListOfLists = [[NSMutableArray<UserVariable*> alloc] init];
    }
    return self;
}

- (Scene*)allocDefaultScene
{
    Scene* scene = [[Scene alloc] initWithProject:self];
    scene.name = @"Scene 1";
    return scene;
}

- (NSInteger)numberOfTotalObjectsInScene:(Scene*)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    return [scene.objectList count];
}

- (NSInteger)numberOfBackgroundObjectsInScene:(Scene*)scene
{
    NSInteger numberOfTotalObjects = [self numberOfTotalObjectsInScene:scene];
    if (numberOfTotalObjects < kBackgroundObjects) {
        return numberOfTotalObjects;
    }
    return kBackgroundObjects;
}

- (NSInteger)numberOfNormalObjectsInScene:(Scene*)scene
{
    NSInteger numberOfTotalObjects = [self numberOfTotalObjectsInScene:scene];
    if (numberOfTotalObjects > kBackgroundObjects) {
        return (numberOfTotalObjects - kBackgroundObjects);
    }
    return 0;
}

- (SpriteObject*)addObjectWithName:(NSString*)objectName toScene:(Scene*)scene
{
    SpriteObject *object = [[SpriteObject alloc] init];
    //object.originalSize;
    object.spriteNode.currentLook = nil;
    
    object.name = [Util uniqueName:objectName existingNames:[self allObjectNamesForScene:scene]];
    object.project = self;
    [(NSMutableArray<SpriteObject*>*)scene.objectList addObject:object];
    [self saveToDiskWithNotification:YES];
    return object;
}

- (Scene*)addSceneWithName:(NSString*)sceneName
{
    Scene *scene = [[Scene alloc] init];
    scene.name = [Util uniqueName:sceneName existingNames:[self allSceneNames]];
    [self.scenes addObject:scene];
    return scene;
}

- (void)removeObjectFromList:(SpriteObject*)object inScene:(Scene*)scene
{
    // do not use NSArray's removeObject here
    // => if isEqual is overriden this would lead to wrong results
    NSUInteger index = 0;
    for (SpriteObject *currentObject in scene.objectList) {
        if (currentObject == object) {
            [currentObject removeSounds:currentObject.soundList AndSaveToDisk:NO];
            [currentObject removeLooks:currentObject.lookList AndSaveToDisk:NO];
            [currentObject.project removeObjectVariablesForSpriteObject:currentObject inScene:nil];
            [currentObject.project removeObjectListsForSpriteObject:currentObject inScene:nil];
            currentObject.project = nil;
            [(NSMutableArray<SpriteObject*>*)scene.objectList removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
}

- (void)removeObject:(SpriteObject*)object inScene:(Scene*)scene
{
    [self removeObjectFromList:object inScene:scene];
    [self saveToDiskWithNotification:YES];
}

- (void)removeObjects:(NSArray*)objects inScene:(Scene*)scene
{
    for (id object in objects) {
        if ([object isKindOfClass:[SpriteObject class]]) {
            [self removeObjectFromList:((SpriteObject*)object) inScene:scene];
        }
    }
    [self saveToDiskWithNotification:YES];
}

- (BOOL)objectExistsWithName:(NSString*)objectName inScene:(Scene*)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    for (SpriteObject *object in scene.objectList) {
        if ([object.name isEqualToString:objectName]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString*)projectPath
{
    return [Project projectPathForProjectWithName:[Util replaceBlockedCharactersForString:self.header.programName] projectID:self.header.programID];
}

- (void)removeFromDisk
{
    [Project removeProjectFromDiskWithProjectName:[Util enableBlockedCharactersForString:self.header.programName] projectID:self.header.programID];
}

- (void)saveToDiskWithNotification:(BOOL)notify
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    
    dispatch_queue_t saveToDiskQ = dispatch_queue_create("save to disk", NULL);
    dispatch_sync(saveToDiskQ, ^{
        // show saved view bezel
        if (notify) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:kHideLoadingViewNotification object:self];
                [notificationCenter postNotificationName:kShowSavedViewNotification object:self];
            });
        }
        
        NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [self projectPath], kProjectCodeFileName];
        CBXMLSerializer* serializer = [CBXMLSerializer alloc];
        NSString *serializationResult = [serializer serializeProjectObjcWithProject:self xmlPath:xmlPath fileManager:fileManager];
        
        if (serializationResult == nil) {
            NSDebug(@"Serialization failed!");
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideLoadingViewNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReadyToUpload object:self];
        });
    });
}

- (BOOL)isLastUsedProject
{
    return [Project isLastUsedProject:self.header.programName projectID:self.header.programID];
}

- (void)setAsLastUsedProject
{
    [Project setLastUsedProject:self];
}


- (void)renameToProjectName:(NSString*)projectName
{
    if ([self.header.programName isEqualToString:projectName]) {
        return;
    }
    BOOL isLastProject = [self isLastUsedProject];
    NSString *oldPath = [self projectPath];
    self.header.programName = [Util uniqueName:projectName existingNames:[[self class] allProjectNames]];
    NSString *newPath = [self projectPath];
    [[CBFileManager sharedManager] moveExistingDirectoryAtPath:oldPath toPath:newPath];
    if (isLastProject) {
        [Util setLastProjectWithName:self.header.programName projectID:self.header.programID];
    }
    [self saveToDiskWithNotification:YES];
}

- (void)renameObject:(SpriteObject*)object toName:(NSString*)newObjectName inScene:(Scene*  _Nullable)scene
{
    if (! [self hasObject:object inScene:scene] || [object.name isEqualToString:newObjectName]) {
        return;
    }
    object.name = [Util uniqueName:newObjectName existingNames:[self allObjectNamesForScene:scene]];
    [self saveToDiskWithNotification:YES];
}

- (void)updateDescriptionWithText:(NSString*)descriptionText
{
    self.header.programDescription = descriptionText;
    [self saveToDiskWithNotification:YES];
}

- (void)removeReferencesInScene:(Scene*)scene
{
    [scene.objectList makeObjectsPerformSelector:@selector(removeReferences)];
}

- (NSArray*)allSceneNames
{
    NSMutableArray *sceneNames = [NSMutableArray arrayWithCapacity:[self.scenes count]];
    for (id scene in self.scenes) {
        if ([scene isKindOfClass:[Scene class]]) {
            [sceneNames addObject:((Scene*)scene).name];
        }
    }
    return [sceneNames copy];
}

- (NSArray*)allObjectNamesForScene:(Scene* _Nullable)scene
{
    NSMutableArray *objectNames = [NSMutableArray arrayWithCapacity:[scene.objectList count]];
    for (id spriteObject in (scene.objectList)) {
        if ([spriteObject isKindOfClass:[SpriteObject class]]) {
            [objectNames addObject:((SpriteObject*)spriteObject).name];
        }
    }
    return [objectNames copy];
}

- (BOOL)hasObject:(SpriteObject *)object inScene:(Scene* _Nullable)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    for (Scene* selfScene in self.scenes) {
        if (selfScene.name == scene.name) {
            return [selfScene.objectList containsObject:object];
        }
    }
    return NO;
}

- (SpriteObject*)copyObject:(SpriteObject*)sourceObject inScene:(Scene* _Nullable)scene
    withNameForCopiedObject:(NSString *)nameOfCopiedObject
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    if (! [self hasObject:sourceObject inScene:scene]) {
        return nil;
    }
    CBMutableCopyContext *context = [CBMutableCopyContext new];
    NSMutableArray<UserVariable*> *copiedVariablesAndLists = [NSMutableArray new];
    
    NSMutableArray<UserVariable*> *variablesAndLists = [[NSMutableArray alloc] initWithArray:[self objectVariablesForObject:sourceObject inScene:nil]];
    [variablesAndLists addObjectsFromArray: [self objectListsForObject:sourceObject inScene:nil]];
    
    for (UserVariable *variableOrList in variablesAndLists) {
        UserVariable *copiedVariableOrList = [[UserVariable alloc] initWithVariable:variableOrList];
        
        [copiedVariablesAndLists addObject:copiedVariableOrList];
        [context updateReference:variableOrList WithReference:copiedVariableOrList];
    }
    
    SpriteObject *copiedObject = [sourceObject mutableCopyWithContext:context];
    copiedObject.name = [Util uniqueName:nameOfCopiedObject existingNames:[self allObjectNamesForScene:scene]];
    [scene addObjectToObjectList:copiedObject];
    
    for (UserVariable *variableOrList in copiedVariablesAndLists) {
        if (variableOrList.isList) {
            [self addObjectList:variableOrList forObject:copiedObject toScene:nil];
        } else {
            [self addObjectVariable:variableOrList forObject:copiedObject toScene:nil];
        }
    }
    
    [self saveToDiskWithNotification:YES];
    return copiedObject;
}

- (BOOL)isEqualToProject:(Project*)project
{
    if (! [self.header isEqualToHeader:project.header])
        return NO;
    
    for (Scene* scene in project.scenes) {
        if ([scene.objectList count] != [scene.objectList count])
            return NO;
        
        NSUInteger idx;
        for (idx = 0; idx < [scene.objectList count]; idx++) {
            SpriteObject *firstObject = [scene.objectList objectAtIndex:idx];
            SpriteObject *secondObject = nil;
            
            NSUInteger projectIdx;
            for (projectIdx = 0; projectIdx < [scene.objectList count]; projectIdx++) {
                SpriteObject *projectObject = [scene.objectList objectAtIndex:projectIdx];
                
                if ([projectObject.name isEqualToString:firstObject.name]) {
                    secondObject = projectObject;
                    break;
                }
            }
            
            if (secondObject == nil || ! [firstObject isEqualToSpriteObject:secondObject])
                return NO;
        }
    }

    return YES;
}

- (NSInteger)getRequiredResourcesInScene:(Scene*)scene
{
    if (scene == nil) {
        scene = self.scenes.firstObject;
    }
    
    NSInteger resources = kNoResources;
    
    for (SpriteObject *obj in scene.objectList) {
        resources |= [obj getRequiredResources];
    }
    return resources;

}

#pragma mark - helpers

- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"\n----------------- PROGRAM --------------------\n"];
    [ret appendFormat:@"Application Build Name: %@\n", self.header.applicationBuildName];
    [ret appendFormat:@"Application Build Number: %@\n", self.header.applicationBuildNumber];
    [ret appendFormat:@"Application Name: %@\n", self.header.applicationName];
    [ret appendFormat:@"Application Version: %@\n", self.header.applicationVersion];
    [ret appendFormat:@"Catrobat Language Version: %@\n", self.header.catrobatLanguageVersion];
    [ret appendFormat:@"Date Time Upload: %@\n", self.header.dateTimeUpload];
    [ret appendFormat:@"Description: %@\n", self.header.description];
    [ret appendFormat:@"Device Name: %@\n", self.header.deviceName];
    [ret appendFormat:@"Media License: %@\n", self.header.mediaLicense];
    [ret appendFormat:@"Platform: %@\n", self.header.platform];
    [ret appendFormat:@"Platform Version: %@\n", self.header.platformVersion];
    [ret appendFormat:@"Program License: %@\n", self.header.programLicense];
    [ret appendFormat:@"Program Name: %@\n", self.header.programName];
    [ret appendFormat:@"Remix of: %@\n", self.header.remixOf];
    [ret appendFormat:@"Screen Height: %@\n", self.header.screenHeight];
    [ret appendFormat:@"Screen Width: %@\n", self.header.screenWidth];
    [ret appendFormat:@"Screen Mode: %@\n", self.header.screenMode];
    [ret appendFormat:@"Sprite List: %@\n", (NSMutableArray<SpriteObject*>*)((NSMutableArray<Scene*>*)self.scenes).firstObject.objectList]; // TODO: this just works for one scene!
    [ret appendFormat:@"URL: %@\n", self.header.url];
    [ret appendFormat:@"User Handle: %@\n", self.header.userHandle];
    [ret appendFormat:@"------------------------------------------------\n"];
    return [ret copy];
}

#pragma mark - Manager

+ (NSString*)projectDirectoryNameForProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    return [NSString stringWithFormat:@"%@%@%@", projectName, kProjectIDSeparator,
            (projectID ? projectID : kNoProjectIDYetPlaceholder)];
}

+ (nullable ProjectLoadingInfo*)projectLoadingInfoForProjectDirectoryName:(NSString*)directoryName
{
    CBAssert(directoryName);
    NSArray *directoryNameParts = [directoryName componentsSeparatedByString:kProjectIDSeparator];
    if (directoryNameParts.count < 2) {
        return nil;
    }
    NSString *projectID = (NSString*)directoryNameParts.lastObject;
    NSString *projectName = [directoryName substringToIndex:directoryName.length - projectID.length - 1];
    return [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName projectID:projectID];
}

+ (nullable NSString *)projectNameForProjectID:(NSString*)projectID
{
    if ((! projectID) || (! [projectID length])) {
        return nil;
    }
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectLoadingInfo.projectID isEqualToString:projectID]) {
            return projectLoadingInfo.visibleName;
        }
    }
    return nil;
}

// returns true if either same projectID and/or same projectName already exists
+ (BOOL)projectExistsWithProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];

    // check if project with same ID already exists
    if (projectID && [projectID length]) {
        if ([[self class] projectExistsWithProjectID:projectID]) {
            return YES;
        }
    }

    // no projectID match => check if project with same name already exists
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectName isEqualToString:projectLoadingInfo.visibleName]) {
            return YES;
        }
    }
    return NO;
}

// returns true if either same projectID and/or same projectName already exists
+ (BOOL)projectExistsWithProjectID:(NSString*)projectID
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectID isEqualToString:projectLoadingInfo.projectID]) {
            return YES;
        }
    }
    return NO;
}

+ (instancetype)defaultProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    projectName = [Util uniqueName:projectName existingNames:[[self class] allProjectNames]];
    Project *project = [[Project alloc] init];
    project.header = [Header defaultHeader];
    project.header.programName = projectName;
    project.header.programID = projectID;

    CBFileManager *fileManager = [CBFileManager sharedManager];
    if (! [fileManager directoryExists:projectName]) {
        [fileManager createDirectory:[project projectPath]];
    }

    NSString *imagesDirName = [NSString stringWithFormat:@"%@%@", [project projectPath], kProjectImagesDirName];
    if (! [fileManager directoryExists:imagesDirName]) {
        [fileManager createDirectory:imagesDirName];
    }

    NSString *soundsDirName = [NSString stringWithFormat:@"%@%@", [project projectPath], kProjectSoundsDirName];
    if (! [fileManager directoryExists:soundsDirName]) {
        [fileManager createDirectory:soundsDirName];
    }
    
    (void)[project.scenes.firstObject addObjectWithName:kLocalizedBackground];
    [project saveToDiskWithNotification:YES];
    NSDebug(@"%@", [project description]);
    return project;
}

+ (nullable instancetype)projectWithLoadingInfo:(ProjectLoadingInfo*)loadingInfo
{
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", loadingInfo.basePath, kProjectCodeFileName];
    NSDebug(@"XML-Path: %@", xmlPath);

    Project *project = nil;
    CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:xmlPath];

    if (languageVersion == kCatrobatInvalidVersion || languageVersion > [[Util catrobatLanguageVersion] floatValue]) {
        NSDebug(@"Invalid catrobat language version!");
        return nil;
    }

    CBXMLParser *catrobatParser = [[CBXMLParser alloc] initWithPath:xmlPath];
    if ([catrobatParser parseProjectObjc] == false) {
        return nil;
    }
    project = [catrobatParser getProjectObjc];
    if (project == nil) {
        NSDebug(@"Parsing Error!");
        return nil;
    }
    project.header.programID = loadingInfo.projectID;

    NSDebug(@"ProjectResolution: width/height:  %f / %f", project.header.screenWidth.floatValue, project.header.screenHeight.floatValue);
    [self updateLastModificationTimeForProjectWithName:loadingInfo.visibleName projectID:loadingInfo.projectID];

    return project;
}

+ (instancetype)lastUsedProject
{
    return [Project projectWithLoadingInfo:[Util lastUsedProjectLoadingInfo]];
}

+ (void)updateLastModificationTimeForProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@",
                         [self projectPathForProjectWithName:projectName projectID:projectID],
                         kProjectCodeFileName];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager changeModificationDate:[NSDate date] forFileAtPath:xmlPath];
}

+ (void)copyProjectWithSourceProjectName:(NSString*)sourceProjectName
                         sourceProjectID:(NSString*)sourceProjectID
                  destinationProjectName:(NSString*)destinationProjectName
{
    NSString *sourceProjectPath = [[self class] projectPathForProjectWithName:sourceProjectName projectID:sourceProjectID];
    destinationProjectName = [Util uniqueName:destinationProjectName existingNames:[self allProjectNames]];
    NSString *destinationProjectPath = [[self class] projectPathForProjectWithName:destinationProjectName projectID:nil];

    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager copyExistingDirectoryAtPath:sourceProjectPath toPath:destinationProjectPath];
    ProjectLoadingInfo *destinationProjectLoadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:destinationProjectName projectID:nil];
    Project *project = [Project projectWithLoadingInfo:destinationProjectLoadingInfo];
    project.header.programName = destinationProjectLoadingInfo.visibleName;
    [project saveToDiskWithNotification:YES];
}

+ (void)removeProjectFromDiskWithProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    NSString *projectPath = [self projectPathForProjectWithName:projectName projectID:projectID];
    if ([fileManager directoryExists:projectPath]) {
        [fileManager deleteDirectory:projectPath];
    }

    // if this is currently set as last used project, then look for next project to set it as
    // the last used project
    if ([Project isLastUsedProject:projectName projectID:projectID]) {
        [Util setLastProjectWithName:nil projectID:nil];
        NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
        for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
            [Util setLastProjectWithName:projectLoadingInfo.visibleName projectID:projectLoadingInfo.projectID];
            break;
        }
    }

    // if there are no projects left, then automatically recreate default project
    [fileManager addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist];
}

- (void)translateDefaultProject
{
    Scene *scene = self.scenes.firstObject; // TODO: this just works for one scene!
    
    NSUInteger index = 0;
    for (SpriteObject *spriteObject in scene.objectList) {
        if (index == kBackgroundObjectIndex) {
            spriteObject.name = kLocalizedBackground;
        } else {
            NSMutableString *spriteObjectName = [NSMutableString stringWithString:spriteObject.name];
            [spriteObjectName replaceOccurrencesOfString:kDefaultProjectBundleOtherObjectsNamePrefix
                                              withString:kLocalizedMole
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, spriteObjectName.length)];
            spriteObject.name = (NSString*)spriteObjectName;
        }
        ++index;
    }
    [self renameToProjectName:kLocalizedMyFirstProject]; // saves to disk!
}

+ (NSString*)basePath
{
    return [NSString stringWithFormat:@"%@/%@/", [Util applicationDocumentsDirectory], kProjectsFolder];
}

+ (NSArray*)allProjectNames
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    NSMutableArray *projectNames = [[NSMutableArray alloc] initWithCapacity:[allProjectLoadingInfos count]];
    for (ProjectLoadingInfo *loadingInfo in allProjectLoadingInfos) {
        [projectNames addObject:loadingInfo.visibleName];
    }
    return [projectNames copy];
}

+ (NSArray*)allProjectLoadingInfos
{
    NSString *basePath = [Project basePath];
    NSError *error;
    NSArray *subdirNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);
    subdirNames = [subdirNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSMutableArray *projectLoadingInfos = [[NSMutableArray alloc] initWithCapacity:subdirNames.count];
    for (NSString *subdirName in subdirNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirName isEqualToString:@".DS_Store"]) {
            continue;
        }

        ProjectLoadingInfo *info = [[self class] projectLoadingInfoForProjectDirectoryName:subdirName];
        if (! info) {
            NSDebug(@"Unable to load project located in directory %@", subdirName);
            continue;
        }
        NSDebug(@"Adding loaded project: %@", info.basePath);
        [projectLoadingInfos addObject:info];
    }
    return projectLoadingInfos;
}

+ (BOOL)areThereAnyProjects
{
    return ((BOOL)[[self allProjectNames] count]);
}

+ (BOOL)isLastUsedProject:(NSString*)projectName projectID:(NSString*)projectID
{
    ProjectLoadingInfo *lastUsedInfo = [Util lastUsedProjectLoadingInfo];
    ProjectLoadingInfo *info = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName
                                                                              projectID:projectID];
    return [lastUsedInfo isEqualToLoadingInfo:info];
}

+ (void)setLastUsedProject:(Project*)project
{
    [Util setLastProjectWithName:project.header.programName projectID:project.header.programID];
}

+ (NSString*)projectPathForProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    return [NSString stringWithFormat:@"%@%@/", [Project basePath], [[self class] projectDirectoryNameForProjectName:[Util replaceBlockedCharactersForString:projectName] projectID:projectID]];
}







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
