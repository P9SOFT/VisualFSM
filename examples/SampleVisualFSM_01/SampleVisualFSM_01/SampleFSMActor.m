//
//  SampleFSMActor.m
//  SampleVisualFSM_01
//
//  Created by Simon on 2/28/15.
//  Copyright (c) 2015 P9SOFT. All rights reserved.
//
//  Licensed under the MIT license.

#import "SampleFSMActor.h"
#import "P9FSMSheet.h"



@implementation SampleFSMActor

-(id) init
{
    self = [super initWithFSM];
    if(self) {
        P9FSMSheet* pkStartSheet = [self AddFSMSheet:FSM_FILEID_SAMPLE_01 fileName:@"SampleVisualFSM_01"];
        if(pkStartSheet) {
            [pkStartSheet StartSheet:nil];
        }
    }
    
    return self;
}



#pragma mark - Override methods

-(bool) OnActionFSM:(int)nID actionSrc:(bwFSMActionSrc*)pkAct fsmSheet:(P9FSMSheet*)pkFSMSheet
{
    bool bExecuted = false;
    
    // Sht_Start
    if([pkFSMSheet.pkSheetSrc.strName isEqualToString:FSM_SHT_START]) {
        
        switch (pkAct.nActID) {
                
            case FSM_ACT_ENTERINITSTATE: {
                [self.delegate OnEnterInitState];
                bExecuted = true;
                break;
            }
            case FSM_ACT_EXITINITSTATE: {
                [self.delegate OnExitInitState];
                bExecuted = true;
                break;
            }
            case FSM_ACT_ENTERTERMINATE: {
                [self.delegate OnEnterTerminate];
                bExecuted = true;
                break;
            }
        }
    }
    
    // Sht_SubLogic
    else if([pkFSMSheet.pkSheetSrc.strName isEqualToString:FSM_SHT_SUBLOGIC]) {

        switch (pkAct.nActID) {
            case FSM_ACT_STARTSUBLOGIC: {
                [self.delegate OnEnterStartSubLogic];
                bExecuted = true;
                break;
            }
            case FSM_ACT_ENTERBAD: {
                [self.delegate OnEnterBad];
                bExecuted = true;
                break;
            }
            case FSM_ACT_ENTERGOOD: {
                [self.delegate OnEnterGood];
                bExecuted = true;
                break;
            }
        }
    }
    
    return bExecuted;
}

-(int) BranchQuestion:(int)nFileID question:(NSString*)strQuestion fsmSheet:(P9FSMSheet*)pFSMSheet
{
    if(nFileID == FSM_FILEID_SAMPLE_01) {

        if([strQuestion isEqualToString:FSM_BRANCH_ISTHISGOOD]) {

            int nArcID = [self.delegate OnBranchIsThisGood] ? FSM_ARC_YES : FSM_ARC_NO;
            [self FireEvent:nFileID arcID:nArcID fsmSheet:pFSMSheet];
        }
    }
    
    return 0;
}



@end
