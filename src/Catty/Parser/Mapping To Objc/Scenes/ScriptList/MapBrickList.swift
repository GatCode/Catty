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

let kBroadcastBrick: String = "BroadcastBrick"
let kBroadcastWaitBrick: String = "BroadcastWaitBrick"
let kForeverBrick: String = "ForeverBrick"

let kIfThenLogicBeginBrick: String = "IfThenLogicBeginBrick"

extension CBXMLMapping {

    static func mapBrickListToScript(input: CBScript?) -> NSMutableArray {
        var brickList = [Brick]()
        guard let script = input else { return  NSMutableArray(array: brickList) }
        guard let input = input?.brickList?.brick else { return  NSMutableArray(array: brickList) }

        for brick in input {
            switch brick.type {
            case kBroadcastBrick:
                brickList.append(BroadcastBrick(message: brick.broadcastMessage ?? ""))
            case kBroadcastWaitBrick:
                brickList.append(BroadcastWaitBrick(message: brick.broadcastMessage ?? ""))
            case kForeverBrick:
                brickList.append(ForeverBrick())
            case .none:
                print("")
            case .some(_):
                print("")
            }
        }

        return NSMutableArray(array: brickList)
    }
}
