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

#import <XCTest/XCTest.h>
#import "AbstractBrickTests.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface ChangeColorByNBrickTests : AbstractBrickTests
@end

@implementation ChangeColorByNBrickTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChangeColorByNBrickPositive
{
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    Scene *scene = [[Scene alloc] initWithProject:project];
    SpriteObject *object = [[SpriteObject alloc] initWithScene:scene];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@Scene 1/images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    ChangeColorByNBrick *brick = [[ChangeColorByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 0.0;
    
    brick.changeColor = [[Formula alloc] initWithInteger:70];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(70.0f, spriteNode.catrobatColor, 0.1f, @"ChangeColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testChangeColorByNBrickWrongInput
{
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    Scene *scene = [[Scene alloc] initWithProject:project];
    SpriteObject *object = [[SpriteObject alloc] initWithScene:scene];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@Scene 1/images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    ChangeColorByNBrick *brick = [[ChangeColorByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 10.0;
    
    brick.changeColor = [[Formula alloc] initWithString:@"a"];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(10.0f, spriteNode.catrobatColor, 0.1f, @"ChangeColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testChangeColorByNBrickNegative
{
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    Scene *scene = [[Scene alloc] initWithProject:project];
    SpriteObject *object = [[SpriteObject alloc] initWithScene:scene];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@Scene 1/images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    ChangeColorByNBrick* brick = [[ChangeColorByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 20.0;
    
    brick.changeColor = [[Formula alloc] initWithInteger:-10];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(10.0f, spriteNode.catrobatColor, 0.1f, @"ChangeColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testChangeColorByNBrickMoreThan2Pi
{
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    Scene *scene = [[Scene alloc] initWithProject:project];
    SpriteObject *object = [[SpriteObject alloc] initWithScene:scene];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@Scene 1/images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    ChangeColorByNBrick* brick = [[ChangeColorByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.ciHueAdjust = ColorSensor.defaultRawValue;
    
    brick.changeColor = [[Formula alloc] initWithInteger:-730];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(200-130.0f, spriteNode.catrobatColor, 0.1f, @"ChangeColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

@end
