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

    // MARK: - mapProgramListOfLists
    static func mapProgramListOfLists(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programListOfLists = project?.programListOfLists?.list else { return nil }
        var result = [UserVariable]()

        for variable in programListOfLists {
            if variable.reference != nil, let scenes = mappedProject.scenes as? [Scene] {

                var referencedUserVariable: UnsafeMutablePointer<UserVariable>?
                for scene in scenes {
                    referencedUserVariable = resolveUserVariableReference(reference: variable.reference, project: project, mappedProject: &mappedProject, scene: scene)
                    if let uVar = referencedUserVariable {
                        result.append(uVar.pointee)
                        break
                    }
                }
            } else if let value = variable.value {
                result.append(allocUserVariable(name: value, isList: true))
            }
        }

        return NSMutableArray(array: result)
    }

    // MARK: - mapProgramVariableList
    static func mapProgramVariableList(project: CBProject?, mappedProject: inout Project) -> NSMutableArray? {
        guard let programVariableList = project?.programVariableList?.userVariable else { return nil }
        var result = [UserVariable]()

        for variable in programVariableList {
            if variable.reference != nil, let scenes = mappedProject.scenes as? [Scene] {

                var referencedUserVariable: UnsafeMutablePointer<UserVariable>?
                for scene in scenes {
                    referencedUserVariable = resolveUserVariableReference(reference: variable.reference, project: project, mappedProject: &mappedProject, scene: scene)
                    if let uVar = referencedUserVariable {
                        result.append(uVar.pointee)
                        break
                    }
                }
            } else if let value = variable.value {
                result.append(allocUserVariable(name: value, isList: false))
            }
        }

        return NSMutableArray(array: result)
    }
}
