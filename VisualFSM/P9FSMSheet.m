//
//  P9FSMSheet.m
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9FSMSheet.h"
#import "P9FSMActor.h"
#import "P9FSMDataSrc.h"

@interface P9FSMSheet()
{
    bool            m_bActivate;
    
    NSMutableArray* m_arrChildFSMSheet;
    
    double          m_dwStartTime;
    double          m_dwChangedTime;
    bool            m_bUseChangedTime;
}

-(void)         EndSheet;
-(void)         EnterState:(P9FSMState*)pkState;
-(void)         ExitState;

-(P9FSMSheet*)  FindChildFSMSheet:(NSString*)strChildName;

@end



@implementation P9FSMSheet

#pragma mark -
#pragma mark public functions

-(id) initWithInfo:(P9FSMSheetSrc*)pkFSM fsmActor:(P9FSMActor*)pkActor parentFSMSheet:(P9FSMSheet*)pkParentFSMSheet
{
    self = [super init];
    if(self) {
        self.pkSheetSrc = pkFSM;
        self.pkCurState = nil;
        self.pkActor = pkActor;
        self.pkParentFSMSheet = pkParentFSMSheet;
        m_bActivate = false;
        
        m_arrChildFSMSheet = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) EnableSheet
{
    m_bActivate = true;
}

-(void) DisableSheet
{
    m_bActivate = false;
}

-(bool) IsActivate
{
    return m_bActivate;
}

-(void) Update:(unsigned long)dwTime
{
    // get current time
    double dwCurTime = [[NSDate date] timeIntervalSinceNow] * -1000.0;
    
    if(m_bActivate && self.pkCurState && self.pkCurState.bExistTimer) {
        
        double delaytime;
        NSUInteger cnt = [self.pkCurState.arrArc count];
        for(int i=0; i<cnt; i++) {
            P9FSMArc* pArc = [self.pkCurState.arrArc objectAtIndex:i];
            if(!pArc) continue;
            
            if(pArc.dwDelayTime > 0) {
                delaytime = m_bUseChangedTime ? m_dwChangedTime : pArc.dwDelayTime;
                if(dwCurTime >= m_dwStartTime + delaytime) {
                    [self FireEvent:pArc.nStrID];
                }
            }
        }
    }
}

-(void) StartSheet:(P9FSMSheet*)pkParentSheet
{
    self.pkParentFSMSheet = pkParentSheet;
    m_bActivate = true;
    [self ChangeState:self.pkSheetSrc.pkStartState];
}

-(void) SetParentSheet:(P9FSMSheet*)pParent
{
    self.pkParentFSMSheet = pParent;
}

-(void) ChangeTimerAtCurState:(bool)bUse time:(double)dwTimer
{
    if(!m_bActivate || !self.pkCurState || !self.pkCurState.bExistTimer)
        return;
    
    m_bUseChangedTime = bUse;
    m_dwChangedTime = dwTimer;
}

-(void) FireEvent:(int)nArcID
{
    if(!m_bActivate || !self.pkCurState)
        return;
    
    NSUInteger cnt = [self.pkCurState.arrArc count];
    for(int i=0; i<cnt; i++) {
        P9FSMArc* pArc = [self.pkCurState.arrArc objectAtIndex:i];
        if(pArc && pArc.nStrID == nArcID) {
            [self ChangeState:pArc.pkTargetState];
            return;
        }
    }
}

-(bool) IsExistArcAtCurState:(int)nArcID
{
	if(!self.pkCurState)
		return false;

    NSUInteger cnt = [self.pkCurState.arrArc count];
    for(int i=0; i<cnt; i++) {
        P9FSMArc* pArc = [self.pkCurState.arrArc objectAtIndex:i];
        if(!pArc) continue;
        
        if(pArc.nStrID == nArcID) {
            return true;
        }
    }
    
    return false;
}

-(void) AddChildFSMSheet:(P9FSMSheet*)pChildSheet
{
	if(pChildSheet) {
		[m_arrChildFSMSheet addObject:pChildSheet];
	}
}

-(P9FSMState*) GetCurState
{
    return self.pkCurState;
}

-(const P9FSMSheetSrc*) GetFSMSheetSrc
{
    return self.pkSheetSrc;
}

-(NSString*) GetSheetName
{
    return self.pkSheetSrc.strName;
}



#pragma mark -
#pragma mark private functions

-(void) EndSheet
{
	assert(self.pkCurState);
	
	P9FSMSheet* pChildFSMSheet = [self FindChildFSMSheet:self.pkCurState.strName];
	if(pChildFSMSheet)
		[pChildFSMSheet EndSheet];
    
	[self.pkActor OnChangeState:self.nFileID prevState:self.pkCurState nextState:nil fsmSheet:self];
    
	// execute exit actions
    NSUInteger cnt = [self.pkCurState.arrExitActions count];
    for(int i=0; i<cnt; i++) {
		bwFSMActionSrc* pkAct = [self.pkCurState.arrExitActions objectAtIndex:i];
		[self.pkActor OnActionFSM:self.nFileID actionSrc:pkAct fsmSheet:self];
	}
    
	P9FSMState* pkState = self.pkSheetSrc.pkEndSheetState;
	if(pkState) {
		// execute enter actions
        NSUInteger cnt = [self.pkCurState.arrEnterActions count];
        for(int i=0; i<cnt; i++) {
            bwFSMActionSrc* pkAct = [self.pkCurState.arrEnterActions objectAtIndex:i];
            [self.pkActor OnActionFSM:self.nFileID actionSrc:pkAct fsmSheet:self];
        }
	}
    
	self.pkCurState = nil;
	m_bActivate = false;
}

-(void) ChangeState:(P9FSMState*)pkState
{
	if(!m_bActivate)
		return;
    
	[self.pkActor OnChangeState:self.nFileID prevState:self.pkCurState nextState:pkState fsmSheet:self];
    
	if(self.pkCurState) [self ExitState];
	[self EnterState:pkState];
}

-(void) EnterState:(P9FSMState*)pkState
{
	if(!pkState)
		return;
    
	self.pkCurState = pkState;
    
	m_bUseChangedTime = false;
	if(self.pkCurState.bExistTimer) {
        m_dwStartTime = [[NSDate date] timeIntervalSinceNow] * -1000.0;
	}
    
	// check if branch
	if(pkState.bBranch) {
		int nArcID = [self.pkActor BranchQuestion:self.nFileID question:pkState.strName fsmSheet:self];
        
        NSUInteger cnt = [pkState.arrArc count];
        for(int i=0; i<cnt; i++) {
            P9FSMArc* pArc = [pkState.arrArc objectAtIndex:i];
            if(!pArc || pArc.nStrID != nArcID) continue;
            
            [self ChangeState:pArc.pkTargetState];
            return;
        }
		return;
	}
    
	// execute enter actions
    NSUInteger cnt = [pkState.arrEnterActions count];
    for(int i=0; i<cnt; i++) {
		bwFSMActionSrc* pkAct = [self.pkCurState.arrEnterActions objectAtIndex:i];
		[self.pkActor OnActionFSM:self.nFileID actionSrc:pkAct fsmSheet:self];
        
        if(self.pkCurState == nil)
            return;
	}
    
	// check if end state
	if(self.pkCurState.bLast) {
		if([self.pkParentFSMSheet GetCurState].pkDefaultArc)
			[self.pkParentFSMSheet ChangeState:[self.pkParentFSMSheet GetCurState].pkDefaultArc.pkTargetState];
		return;
	}
    
	// run child FSMSheet
	P9FSMSheet* pChildFSMSheet = [self FindChildFSMSheet:self.pkCurState.strName];
	if(pChildFSMSheet && self.pkCurState == pkState) {
		[pChildFSMSheet StartSheet:self];
	}
	else {
		// check if exist default arc
		if(self.pkCurState.pkDefaultArc) {
			[self ChangeState:self.pkCurState.pkDefaultArc.pkTargetState];
			return;
		}
	}
}

-(void) ExitState
{
	if(!self.pkCurState)
		return;
    
	P9FSMSheet* pChildFSMSheet = [self FindChildFSMSheet:self.pkCurState.strName];
	if(pChildFSMSheet)
		[pChildFSMSheet EndSheet];
    
	// execute exit actions
    NSUInteger cnt = [self.pkCurState.arrExitActions count];
    for(int i=0; i<cnt; i++) {
        bwFSMActionSrc* pkAct = [self.pkCurState.arrExitActions objectAtIndex:i];
        [self.pkActor OnActionFSM:self.nFileID actionSrc:pkAct fsmSheet:self];
    }
    
	m_dwStartTime = 0;
	self.pkCurState = nil;
}

-(P9FSMSheet*) FindChildFSMSheet:(NSString*)strChildName
{
	if([m_arrChildFSMSheet count] <= 0)
		return nil;
    
	NSUInteger cnt = [m_arrChildFSMSheet count];
	for(int i=0; i<cnt; i++) {
		P9FSMSheet* pFSMSheet = [m_arrChildFSMSheet objectAtIndex:i];
		if(!pFSMSheet || ![pFSMSheet GetFSMSheetSrc]) continue;
        
		if([[pFSMSheet GetFSMSheetSrc].strName isEqualToString:strChildName])
			return pFSMSheet;
	}
    
	return nil;
}

@end
