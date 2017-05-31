//
//  P9FSMState.swift
//  CBSNCommon
//
//  Created by Kim, Simon on 5/31/17.
//  Copyright © 2017 CBS Interactive. All rights reserved.
//

import Foundation


open class P9FSMState {
    var strName: String?
    var bLast: Bool?
    var bBranch: Bool?
    var bExistTimer: Bool?
    
    var arrArc = [P9FSMArc]()
    var pkDefaultArc: P9FSMArc?
    
    var arrEnterActions = [P9FSMActionSrc]()
    var arrExitActions = [P9FSMActionSrc]()
    
    var pkFSM: P9FSMSheetSrc?
}

