//
//  P9FSMConst.swift
//  CBSNCommon
//
//  Created by Kim, Simon on 5/31/17.
//  Copyright © 2017 CBS Interactive. All rights reserved.
//

import Foundation


class P9FSMConst {
    static let df_XML_START_SHEET       = "Sht_Start"			// start sheet name
    static let df_XML_ATT_TIMER         = "Timer"				// timer
    
    //////////////////////////////////////////////////////////////////////////
    // reserved string and ID
    static let df_XML_ACTION_CHANGE_ANI     = "Change_Ani"		// play animation
    static let df_XML_ACTION_BLEND_ANI		= "Blend_Ani"		// activate blending animation
    static let dx_XML_ACTION_DEACTIVATE_ANI	= "Deactivate_Ani"	// deactivate blending animation
    static let dx_XML_ACTION_SAVE_LASTANI	= "Save_LastAni"		// last played animation ID
    
    static let df_FSM_ACT_CHANGE_ANI_ID		= 1
    static let df_FSM_ACT_BLEND_ANI_ID		= 2
    static let df_FSM_ACT_DEACTIVATE_ANI_ID	= 4
    static let df_FSM_ACT_SAVE_LASTANI_ID	= 3
    
}



