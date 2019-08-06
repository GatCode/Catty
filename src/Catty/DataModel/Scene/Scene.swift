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

@objc class Scene: NSObject {
    @objc var name: String?
    @objc var data: ObjectData?
    @objc var originalWidth: String?
    @objc var originalHeight: String?
    @objc var objectList = [SpriteObject]()
    @objc var project: Project?
    var sceneCounter = 1

    @objc override init() {
        self.data = ObjectData()
    }

    @objc convenience init(project: Project) {
        self.init()
        self.project = project
    }

    @objc func addObject(withName objectName: String?) -> SpriteObject? {
        let object = SpriteObject()
        object.spriteNode?.currentLook = nil

        object.name = Util.uniqueName(objectName, existingNames: self.project?.allObjectNames(for: self))
        object.project = self.project
        objectList.append(object)
        return object
    }

    @objc func addObject(toObjectList spriteObject: SpriteObject) {
        objectList.append(spriteObject)
    }
}
