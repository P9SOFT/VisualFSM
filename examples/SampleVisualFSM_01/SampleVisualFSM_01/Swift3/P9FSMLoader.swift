//
//  P9FSMDataSrc.swift
//  CBSNCommon
//
//  Created by Kim, Simon on 5/30/17.
//  Copyright © 2017 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import Foundation


open class P9FSMLoader: NSObject, XMLParserDelegate {
    
        /*

    // Internal..
    let df_XML_ROOT					= "Root"
    let df_XML_FSM					= "FSM"
    let df_XML_ATT_ST_ENDSHEET		= "EndSheet"
    
    let df_XML_STATE                 = "State"
    let df_XML_ATT_STATETYPE         = "State_Type"
    let df_XML_ATT_ST_START			= "Start"
    let df_XML_ATT_ST_END			= "End"
    let df_XML_ATT_ENTERACTION		= "Enter_Actions"
    let df_XML_ATT_EXITACTION		= "Exit_Actions"
    let df_XML_ATT_ENTERACTIONSTRID	= "Enter_Actions_StrID"
    let df_XML_ATT_EXITACTIONSTRID	= "Exit_Actions_StrID"
    
    let df_XML_BRANCH				= "Branch"
    let df_XML_ATT_FUNCTION			= "Function"
    
    let df_XML_ARC					= "Arc"
    let df_XML_ATT_STRID             = "StrID"
    let df_XML_ATT_EVENT             = "Event"
    let df_XML_ATT_LINK1             = "Link1"
    let df_XML_ATT_LINK2             = "Link2"
    
    let df_XML_ATT_NAME				= "Name"
    let df_XML_ATT_ID				= "ID"
    
    static let shardInstance = P9FSMLoader()
    
    private var curLoadingFSMData: P9FSMData?
    private var curLoadingFSMSheetSrc: P9FSMSheetSrc?
    private var dicFSMSheetSrcList = [String: P9FSMSheetSrc]()
    private var dicFSMStateList = [String: P9FSMState]()
    private var dicFSMData = [String: P9FSMData]()
    
    
    func getFSM(_ strFileName: String) -> P9FSMData? {
        if let fsmData = findFSMData(strFileName) {
            return fsmData
        }
        if loadFSM(strFileName) {
            return findFSMData(strFileName)
        }
        return nil
    }

    func findFSMData(_ strFileName: String) -> P9FSMData? {
        if let fsmData = dicFSMData[strFileName] {
            return fsmData
        }
        return nil
    }
    
    private func loadFSM(_ strFileName: String) -> Bool {
        if let originPath = Bundle.main.path(forResource: strFileName, ofType: "xml"),
        let xmlData = FileManager.default.contents(atPath: originPath) {
            let fsmData = P9FSMData()
            dicFSMData[strFileName] = fsmData
            curLoadingFSMData = fsmData
            
            let xmlParser = XMLParser.init(data: xmlData)
            xmlParser.delegate = self
            xmlParser.shouldResolveExternalEntities = true
            xmlParser.parse()
            curLoadingFSMData = nil
        }
        else {
            return false
        }
        
        return false
    }
    
    // MARK: XMLParserDelegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        // FSM
        if elementName == P9FSMConst.df_XML_FSM {
            if let strName = attributeDict[P9FSMConst.df_XML_ATT_NAME] {
                dicFSMSheetSrcList.removeAll()
                dicFSMStateList.removeAll()
                
                let pkFSM = P9FSMSheetSrc()
                pkFSM.strName = strName
                curLoadingFSMSheetSrc = pkFSM
                
                // Save P9FSMSheetSrc
                dicFSMSheetSrcList[strName] = pkFSM
                curLoadingFSMData?.arrFSMSheetSrc.append(pkFSM)
                
                if strName == P9FSMConst.df_XML_START_SHEET {
                    curLoadingFSMData?.pkStartFSMSheetSrc = pkFSM
                }
            }
        }
        
        // State
        else if elementName == P9FSMConst.df_XML_STATE {
            let pkState = P9FSMState()
            curLoadingFSMSheetSrc?.arrFSMStates.append(pkState)
            
            // Get Name
            pkState.strName = attributeDict[P9FSMConst.df_XML_ATT_NAME]
            
            // Get EndSheet
            if pkState.strName == attributeDict[P9FSMConst.df_XML_ATT_ST_ENDSHEET] {
                curLoadingFSMSheetSrc?.pkEndState = pkState
            }
            
            // Find linked FSM
            let sheetSrc = dicFSMSheetSrcList[pkState.strName!]
            pkState.pkFSM = sheetSrc
            
            // Get ID
            if let strID = attributeDict[P9FSMConst.df_XML_ATT_ID] {
                dicFSMStateList[strID] = pkState
            }
            
            // Get State Type
            if let strStateType = attributeDict[P9FSMConst.df_XML_ATT_STATETYPE] {
                if strStateType == P9FSMConst.df_XML_ATT_ST_START {
                    curLoadingFSMSheetSrc?.pkStartState = pkState
                }
                else if strStateType == P9FSMConst.df_XML_ATT_ST_END {
                    curLoadingFSMSheetSrc?.pkEndState = pkState
                }
            }
            
            var pkEnterAction: P9FSMActionSrc?
            var pkExitAction: P9FSMActionSrc?
            
            // Get Enter Actions (just support ONE action.)
            if let strEnterAction = attributeDict[df_XML_ATT_ENTERACTION], strEnterAction.characters.count > 0 {
                let pkAct = P9FSMActionSrc()
                pkEnterAction = pkAct
                pkAct.strSrc = strEnterAction
                pkState.arrEnterActions.append(pkAct)
            }
            
            // Get Exit Actions (just support ONE action.)
            if let strExitAction = attributeDict[df_XML_ATT_EXITACTION], strExitAction.characters.count > 0 {
                let pkAct = P9FSMActionSrc()
                pkExitAction = pkAct
                pkAct.strSrc = strExitAction
                pkState.arrExitActions.append(pkAct)
            }
            
            // Get EnterAction String ID
            if let strEnterActionStringID = attributeDict[df_XML_ATT_ENTERACTIONSTRID], strEnterActionStringID.characters.count > 0 {
                pkEnterAction?.strActID = strEnterActionStringID
            }
            
            // Get ExitAction String ID
            if let strExitActionStringID = attributeDict[df_XML_ATT_EXITACTIONSTRID], strExitActionStringID.characters.count > 0 {
                pkExitAction?.strActID = strExitActionStringID
            }
        }

        // Branch
        else if elementName == df_XML_BRANCH {
            let pkState = P9FSMState()
            pkState.bBranch = true
            curLoadingFSMSheetSrc?.arrFSMStates.append(pkState)
            
            // Get Function
            pkState.strName = attributeDict[df_XML_ATT_FUNCTION]
            
            // Get ID
            if let strID = attributeDict[df_XML_ATT_ID] {
                dicFSMStateList[strID] = pkState
            }
        }

        // Arc
        else if elementName == df_XML_ARC {
            let pkArc = P9FSMArc()
            
            // Get Event type
            if let strEventName = attributeDict[df_XML_ATT_EVENT] {
                pkArc.strSrc = strEventName
                
                // Get ID
                pkArc.strID = attributeDict[df_XML_ATT_STRID]
                
                // Timer
                var bTimer = false
                if strEventName.hasPrefix(P9FSMConst.df_XML_ATT_TIMER) {
                    bTimer = true
                    let nStartPos: Int = P9FSMConst.df_XML_ATT_TIMER.characters.count + 1
                    let dwDelayTime = Double(strEventName.substring(from: strEventName.index(after: nStartPos-1)))
                    pkArc.dwDelayTime = dwDelayTime
                }
            }
            
            // Get Start State
            if let strIDLink1 = attributeDict[df_XML_ATT_LINK1] {
                if let kStateLink1 = dicFSMStateList[nIDLink1] {
                    kStateLink1.arrArc.append(pkArc)
                }
            }
        }
    }
         */
}






