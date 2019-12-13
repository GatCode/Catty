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

extension CBXMLMappingToObjc {

    static func getLocalVariablesFromObject(project: CBProject?, object: CBObject?, isList: Bool) -> [String] {
        guard let project = project else { return [String]() }
        var localVariables = [String]()

        if let objctVariableList = project.scenes?.first?.data?.objectVariableList?.entry, isList == false {
            for entry in objctVariableList {
                let resolvedReference = resolveReferenceString(reference: entry.object, project: project)
                if let objectIndex = resolvedReference?.0 {
                    let referencedObject = project.scenes?.first?.objectList?.objects?[objectIndex]

                    if referencedObject?.name == object?.name, let entryList = entry.list {
                        for variable in entryList {
                            let resolvedVariableReference = resolveReferenceString(reference: variable.reference, project: project)
                            if let scIdx = resolvedVariableReference?.1, scIdx < referencedObject?.scriptList?.scripts?.count ?? 0 {
                                if let brIdx = resolvedVariableReference?.2, brIdx < referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?.count ?? 0 {
                                    if let localVar = referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?[brIdx].userVariable {
                                        localVariables.append(localVar)
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }

        if let objctVariableList = project.scenes?.first?.data?.objectListOfList?.entry, isList == true {
            for entry in objctVariableList {
                let resolvedReference = resolveReferenceString(reference: entry.object, project: project)
                if let objectIndex = resolvedReference?.0 {
                    let referencedObject = project.scenes?.first?.objectList?.objects?[objectIndex]

                    if referencedObject?.name == object?.name, let entryList = entry.list {
                        for variable in entryList {
                            let resolvedVariableReference = resolveReferenceString(reference: variable.reference, project: project)
                            if let scIdx = resolvedVariableReference?.1, let brIdx = resolvedVariableReference?.2 {
                                if let localVar = referencedObject?.scriptList?.scripts?[scIdx].brickList?.bricks?[brIdx].userList {
                                    localVariables.append(localVar)
                                }
                            }
                        }
                        break
                    }
                }
            }
        }

        return localVariables
    }

    static func resolveUserVariable(project: CBProject?, object: CBObject?, script: CBScript?, brick: CBBrick?, isList: Bool) -> UserVariable? {
        guard let project = project else { return nil }
        guard let object = object else { return nil }
        guard let script = script else { return nil }
        guard let brick = brick else { return nil }

        if let reference = brick.userVariableReference {
            var splittedReference = reference.split(separator: "/")
            splittedReference = splittedReference.filter { $0 != ".." }
            if splittedReference.count == 2 {
                let resolvedReference = resolveReferenceStringExtraShort(reference: reference, project: project, script: script)
                if let bIdx = resolvedReference, let brickList = script.brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                    return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                }
            } else if splittedReference.count == 4 {
                let resolvedReference = resolveReferenceStringShort(reference: reference, project: project, object: object)
                if let sIdx = resolvedReference?.0, let bIdx = resolvedReference?.1 {
                    if let scriptList = object.scriptList?.scripts, sIdx < scriptList.count {
                        if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                            return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                        }
                    }
                }
            } else if splittedReference.count == 6 {
                let resolvedReference = resolveReferenceString(reference: reference, project: project)
                if let oIdx = resolvedReference?.0, let sIdx = resolvedReference?.1, let bIdx = resolvedReference?.2 {
                    if let objectList = project.scenes?.first?.objectList?.objects, oIdx < objectList.count {
                        if let scriptList = objectList[oIdx].scriptList?.scripts, sIdx < scriptList.count {
                            if let brickList = scriptList[sIdx].brickList?.bricks, bIdx < brickList.count, brickList[bIdx].userVariable != nil || brickList[bIdx].userList != nil {
                                return resolveUserVariable(project: project, object: object, script: script, brick: brickList[bIdx], isList: isList)
                            }
                        }
                    }
                }
            }
        } else if let variable = brick.userVariable {
            let localVariableNames = getLocalVariablesFromObject(project: project, object: object, isList: false)
            if let variable = brick.userVariable, localVariableNames.contains(variable) {
                return allocLocalUserVariable(name: variable, isList: false)
            }
            return allocUserVariable(name: variable, isList: false)
        } else if let variable = brick.userList {
            let localVariableNames = getLocalVariablesFromObject(project: project, object: object, isList: true)
            if let variable = brick.userList, localVariableNames.contains(variable) {
                return allocLocalUserVariable(name: variable, isList: true)
            }
            return allocUserVariable(name: variable, isList: true)
        }

        return nil
    }

    static func allocUserVariable(name: String, isList: Bool) -> UserVariable {
        for variable in mappingVariableListGlobal where variable.name == name && variable.isList == isList {
            return variable
        }

        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        mappingVariableListGlobal.append(userVar)
        return userVar
    }

    static func allocLocalUserVariable(name: String, isList: Bool) -> UserVariable {
        for variable in mappingVariableListLocal where variable.name == name && variable.isList == isList {
            return variable
        }

        let userVar = UserVariable()
        userVar.name = name
        userVar.isList = isList ? true : false
        mappingVariableListLocal.append(userVar)
        return userVar
    }
}
