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

extension CBXMLMapping {

    static func mapVariables(project: CBProject?, mappedProject: inout Project) -> VariablesContainer? {
        let container = VariablesContainer()

        container.programListOfLists = mapProgramListOfLists(project: project, mappedProject: &mappedProject)
        if container.programListOfLists == nil { return nil }

        container.programVariableList = mapProgramVariableList(project: project, mappedProject: &mappedProject)
        if container.programVariableList == nil { return nil }

        container.objectListOfLists = mapObjectListOfLists(project: project, mappedProject: &mappedProject)
        if container.objectListOfLists == nil { return nil }

        container.objectVariableList = mapObjectVariableList(project: project, mappedProject: &mappedProject)
        if container.objectVariableList == nil { return nil }

        return container
    }

    // MARK: - mapProgramListOfLists
    static func mapProgramListOfLists(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programListOfLists = project?.programListOfLists?.list else { return nil }

        var result = [UserVariable]()
        for variable in programListOfLists {
            let referencedObject = getObjectFor(reference: variable.reference, project: project, mappedProject: &mappedProject)
            let resolvedReference = resolveReferenceString(reference: variable.reference)

            let scrNr = resolvedReference?.1 ?? 0
            let brNr = resolvedReference?.2 ?? 0

            if let scrList = referencedObject?.scriptList {
                if scrNr < scrList.count, let script = referencedObject?.scriptList[scrNr] as? Script {
                    if brNr < script.brickList.count, let brick = script.brickList[brNr] as? Brick {
                        if let uVar = UnsafeMutablePointer<UserVariable>(OpaquePointer(brick.uVar))?.pointee {
                            result.append(uVar)
                        }
                    }
                }
            }
        }

        return NSMutableArray(array: result)
    }

    // MARK: - mapProgramVariableList
    static func mapProgramVariableList(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programVariableList = project?.programVariableList?.userVariable else { return nil }

        var result = [UserVariable]()
        for variable in programVariableList {
            let referencedObject = getObjectFor(reference: variable.reference, project: project, mappedProject: &mappedProject)
            let resolvedReference = resolveReferenceString(reference: variable.reference)

            let scrNr = resolvedReference?.1 ?? 0
            let brNr = resolvedReference?.2 ?? 0

            if let scrList = referencedObject?.scriptList {
                if scrNr < scrList.count, let script = referencedObject?.scriptList[scrNr] as? Script {
                    if brNr < script.brickList.count, let brick = script.brickList[brNr] as? Brick {
                        if let uVar = UnsafeMutablePointer<UserVariable>(OpaquePointer(brick.uVar))?.pointee {
                            result.append(uVar)
                        }
                    }
                }
            }
        }

        return NSMutableArray(array: result)
    }

    // MARK: - mapObjectListOfLists
    static func mapObjectListOfLists(project: CBProject?, mappedProject: inout Project) -> OrderedMapTable? {
        guard let scenes = project?.scenes else { return nil }
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        for scene in scenes {
            if let objectListOfList = scene.data?.objectListOfList?.entry {
                for entry in objectListOfList {
                    if let object = entry.object, let lists = entry.list {

                        let referencedObject = getObjectFor(reference: object, project: project, mappedProject: &mappedProject)
                        let referencedUserVariables = getUserVariablesFor(paths: lists, project: project, mappedProject: &mappedProject)

                        if let list = referencedUserVariables, let obj = referencedObject {
                            result.setObject(NSArray(array: list), forKey: obj)
                        }
                    }
                }
            }
        }

        return result
    }

    // MARK: - mapObjectListOfLists
    static func mapObjectVariableList(project: CBProject?, mappedProject: inout Project) -> OrderedMapTable? {
        guard let scenes = project?.scenes else { return nil }
        let result = OrderedMapTable.weakToStrongObjectsMapTable() as! OrderedMapTable

        for scene in scenes {
            if let objectVariableList = scene.data?.objectVariableList?.entry {
                for entry in objectVariableList {
                    if let object = entry.object, let variables = entry.list {
                        let referencedObject = getObjectFor(reference: object, project: project, mappedProject: &mappedProject)
                        let referencedUserVariables = getUserVariablesFor(paths: variables, project: project, mappedProject: &mappedProject)

                        if let list = referencedUserVariables, let obj = referencedObject {
                            result.setObject(NSArray(array: list), forKey: obj)
                        }
                    }
                }
            }
        }

        return result
    }

    // MARK: - eventually allocate new Object
    static func getObjectFor(reference: String?, project: CBProject?, mappedProject: inout Project) -> SpriteObject? {
        guard let reference = reference else { return nil }
        guard let project = project else { return nil }

        let resolvedReference = resolveReferenceString(reference: reference)
        if let oList = project.scenes?.first?.objectList?.object, let oIdx = resolvedReference?.0, oIdx < oList.count {
            if let object = checkIfObjectAlreadyAllocated(cbObject: oList[oIdx], mappedProject: mappedProject) {
                return object.pointee
            }
            if let obj = allocObject(cbObject: oList[oIdx], cbProject: project, mappedProject: &mappedProject) {
                return obj
            }
        }

        return nil
    }

    static func checkIfObjectAlreadyAllocated(cbObject: CBObject, mappedProject: Project) -> UnsafeMutablePointer<SpriteObject>? {
        for entryIdx in 0..<mappedProject.variables.objectListOfLists.count() {
            if let entry = mappedProject.variables.objectListOfLists.key(at: entryIdx) {
                if let entry = entry as? SpriteObject, entry.name == cbObject.name {
                    let object = UnsafeMutablePointer<SpriteObject>.allocate(capacity: 1)
                    object.initialize(to: entry)
                    return object
                }
            }
        }
        for entryIdx in 0..<mappedProject.variables.objectVariableList.count() {
            if let entry = mappedProject.variables.objectVariableList.key(at: entryIdx) {
                if let entry = entry as? SpriteObject, entry.name == cbObject.name {
                    let object = UnsafeMutablePointer<SpriteObject>.allocate(capacity: 1)
                    object.initialize(to: entry)
                    return object
                }
            }
        }
        return nil
    }

    static func allocObject(cbObject: CBObject?, cbProject: CBProject?, mappedProject: inout Project) -> SpriteObject? {
        guard let cbObject = cbObject else { return nil }
        guard let cbLookList = cbObject.lookList else { return nil }
        guard let cbSoundList = cbObject.soundList else { return nil }
        guard let cbScriptList = cbObject.scriptList else { return nil }

        var object = SpriteObject()

        object.name = cbObject.name
        object.lookList = mapLookListToObject(input: cbLookList)
        object.soundList = mapSoundListToObject(input: cbSoundList, cbProject: cbProject, object: cbObject)
        object.scriptList = mapScriptList(scriptList: cbScriptList, currentObject: &object, cbProject: cbProject, mappedProject: &mappedProject)
        return object
    }

    // MARK: - eventually allocate new UserVariable
    static func getUserVariablesFor(paths: [CBObjectListOfListEntryList]?, project: CBProject?, mappedProject: inout Project) -> [UserVariable]? {
        guard let paths = paths else { return nil }
        guard let project = project else { return nil }
        var result = [UserVariable]()

        for path in paths {
            let resolvedReference = resolveReferenceString(reference: path.userList)
            if let oList = project.scenes?.first?.objectList?.object, let oIdx = resolvedReference?.0, oIdx < oList.count {
                if let sList = oList[oIdx].scriptList?.script, let sIdx = resolvedReference?.1, sIdx < sList.count {
                    if let bList = sList[sIdx].brickList?.brick, let bIdx = resolvedReference?.2, bIdx < bList.count {
                        if let resolvedUvar = resolveUserVariable(brick: bList[bIdx], cbProject: project, mappedProject: &mappedProject) {
                            result.append(resolvedUvar)
                        }
                    }
                }
            }
        }

        return result
    }

    static func getUserVariablesFor(paths: [CBUserVariableList]?, project: CBProject?, mappedProject: inout Project) -> [UserVariable]? {
        guard let paths = paths else { return nil }
        guard let project = project else { return nil }
        var result = [UserVariable]()

        for path in paths {
            let resolvedReference = resolveReferenceString(reference: path.userVariable)
            if let oList = project.scenes?.first?.objectList?.object, let oIdx = resolvedReference?.0, oIdx < oList.count {
                if let sList = oList[oIdx].scriptList?.script, let sIdx = resolvedReference?.1, sIdx < sList.count {
                    if let bList = sList[sIdx].brickList?.brick, let bIdx = resolvedReference?.2, bIdx < bList.count {
                        if let resolvedUvar = resolveUserVariable(brick: bList[bIdx], cbProject: project, mappedProject: &mappedProject) {
                            result.append(resolvedUvar)
                        }
                    }
                }
            }
        }

        return result
    }

    static func resolveUserVariable(brick: CBBrick?, cbProject: CBProject?, mappedProject: inout Project) -> UserVariable? {
        guard let brick = brick else { return nil }

        if let variable = brick.userVariable {
            if let uVar = checkIfUserVariableAlreadyAllocated(userVariable: variable, mappedProject: mappedProject) {
                return uVar.pointee
            }
            return allocUserVariable(name: variable, isList: false)
        } else if let variable = brick.userList {
            if let uVar = checkIfUserVariableAlreadyAllocated(userVariable: variable, mappedProject: mappedProject) {
                return uVar.pointee
            }
            return allocUserVariable(name: variable, isList: true)
        } else if let ref = brick.userVariableReference {
//            let resolvedReference = resolveUserVariableReferenceString(reference: ref)
//            var objNr = 0
//            var scrNr = 0
//            var brNr = 0
//            if let tmpBrNr = resolvedReference?.2 {
//                brNr = tmpBrNr
//                if let tmpScrNr = resolvedReference?.1 {
//                    scrNr = tmpScrNr
//                    if let tmpObjNr = resolvedReference?.0 {
//                        objNr = tmpObjNr
//                    }
//                }
//            }
//
//            // TODO: now just working for current object brick references!!!
//            if scrNr < currentObject.scriptList.count, let currentScript = currentObject.scriptList[scrNr] as? Script {
//                if brNr < currentScript.brickList.count, let currentBrick = currentScript.brickList[brNr] as? Brick {
//                    return UnsafeMutablePointer<UserVariable>(OpaquePointer(currentBrick.uVar))?.pointee
//                }
//            }
        }

        return nil
    }

    static func checkIfUserVariableAlreadyAllocated(userVariable: String, mappedProject: Project) -> UnsafeMutablePointer<UserVariable>? {
        for entryIdx in 0..<mappedProject.variables.objectListOfLists.count() {
            if let list = mappedProject.variables.objectListOfLists.object(at: entryIdx) as? NSArray {
                for variable in list {
                    if let uVar = variable as? UserVariable, uVar.name == userVariable {
                        let res = UnsafeMutablePointer<UserVariable>.allocate(capacity: 1)
                        res.initialize(to: uVar)
                        return res
                    }
                }
            }
        }
        for entryIdx in 0..<mappedProject.variables.objectVariableList.count() {
            if let list = mappedProject.variables.objectVariableList.object(at: entryIdx) as? NSArray {
                for variable in list {
                    if let uVar = variable as? UserVariable, uVar.name == userVariable {
                        let res = UnsafeMutablePointer<UserVariable>.allocate(capacity: 1)
                        res.initialize(to: uVar)
                        return res
                    }
                }
            }
        }

        return nil
    }

    static func allocUserVariable(name: String, isList: Bool) -> UserVariable {
        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        return userVar
    }

    // MARK: - resolve reference strings
    static func resolveReferenceString(reference: String?) -> (Int?, Int?, Int?)? {
        guard let reference = reference else { return nil }
        var splittedReference = reference.split(separator: "/")
        splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
        var counter = 0
        var objectNr: Int?
        var scriptNr: Int?
        var brickNr: Int?

        if splittedReference.count == 2, let objString = splittedReference.last {
            objectNr = extractNumberInBacesFrom(string: String(objString))
        } else {
            for reference in splittedReference.reversed() {
                counter += 1
                if counter == 2 {
                    brickNr = extractNumberInBacesFrom(string: String(reference))
                }
                if counter == 4 {
                    scriptNr = extractNumberInBacesFrom(string: String(reference))
                }
                if counter == 6 {
                    objectNr = extractNumberInBacesFrom(string: String(reference))
                }
            }
        }

        return (objectNr, scriptNr, brickNr)
    }

    static func resolveUserVariableReferenceString(reference: String?) -> (Int?, Int?, Int?)? {
        guard let reference = reference else { return nil }
        var splittedReference = reference.split(separator: "/")
        splittedReference.forEach { if $0 == ".." { splittedReference.removeObject($0) } }
        var counter = 0
        var objectNr: Int?
        var scriptNr: Int?
        var brickNr: Int?

        for reference in splittedReference.reversed() {
            counter += 1
            if counter == 2 {
                brickNr = extractNumberInBacesFrom(string: String(reference))
            }
            if counter == 4 {
                scriptNr = extractNumberInBacesFrom(string: String(reference))
            }
            if counter == 6 {
                objectNr = extractNumberInBacesFrom(string: String(reference))
            }
        }

        return (objectNr, scriptNr, brickNr)
    }


    static func extractNumberInBacesFrom(string: String) -> Int {
        var firstDigit: Int?
        var secondDigit: Int?
        var thirdDigit: Int?

        let firstDigitRange = string.range(of: "[(0-9)*]", options: .regularExpression)

        if let fdr = firstDigitRange {
            firstDigit = Int(string[fdr])

            let secondPartOfString = string[Range(uncheckedBounds: (lower: fdr.upperBound, upper: string.endIndex))]
            let secondDigitRange = secondPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

            if let sdr = secondDigitRange {
                secondDigit = Int(string[sdr])

                let thirdPartOfString = string[Range(uncheckedBounds: (lower: sdr.upperBound, upper: string.endIndex))]
                let thirdDigitRange = thirdPartOfString.range(of: "[(0-9)*]", options: .regularExpression)

                if let tdr = thirdDigitRange {
                    thirdDigit = Int(string[tdr])
                }
            }
        }

        if let first = firstDigit, let second = secondDigit, let third = thirdDigit {
            return first * 100 + second * 10 + third - 1
        } else if let first = firstDigit, let second = secondDigit {
            return first * 10 + second - 1
        } else if let first = firstDigit {
            return first - 1
        } else {
            return 0
        }
    }
}
