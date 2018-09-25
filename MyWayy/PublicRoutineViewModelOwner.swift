//
//  PublicRoutineViewModelOwner.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/2/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

protocol PublicRoutineViewModelOwner: class {
    var routineViewModel: PublicRoutineViewModel? { get set }
}
