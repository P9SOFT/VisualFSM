//
//  P9FSMActor.m
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9FSMActor.h"
#import "P9FSMDataSrc.h"
#import "P9FSMSheet.h"



//////////////////////////////////////////////////////////////////////////
// t_fsmdata

@interface t_fsmdata : NSObject
{
@public
    NSMutableArray*     m_arrFSMSheets;
}

@property (nonatomic, assign) P9FSMData*    pFSMData;
@end



@implementation t_fsmdata

-(id) init
{
    self = [super init];
    if(self) {
        m_arrFSMSheets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end



//////////////////////////////////////////////////////////////////////////
// P9FSMActor

@interface P9FSMActor()
{
    NSMutableDictionary*    m_dicFSMFiles;
}

-(t_fsmdata*)   CreateFSMSheets:(int)nFileID fsmData:(P9FSMData*)pFSMData fileName:(NSString*)StrFileName;
-(void)			DestroyFSMSheets:(int)nFileID;
-(void)			DestroyFSMSheetsAll;
-(bool)			_FireEvent:(int)nFileID arcID:(int)nArcID fsmSheet:(P9FSMSheet*)pFSMSheet;
-(bool)			IsExistFileID:(int)nFileID;

@end



@implementation P9FSMActor

-(id) initWithFSM
{
    self = [super init];
    if(self) {
        m_dicFSMFiles = [[NSMutableDictionary alloc] init];
        self.arrFileIDs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) UpdateFSM:(unsigned long)dwTime
{
	NSArray *keys = [m_dicFSMFiles allKeys];
    for (NSString *key in keys) {
		t_fsmdata* pData = [m_dicFSMFiles objectForKey:key];
        if(!pData) continue;

        NSUInteger cnt = [pData->m_arrFSMSheets count];
		for(int j=0; j<cnt; j++) {
			P9FSMSheet* pFSMSheet = [pData->m_arrFSMSheets objectAtIndex:j];
			if(pFSMSheet && [pFSMSheet IsActivate]) {
				[pFSMSheet Update:dwTime];
			}
		}
    }
}

-(bool) OnActionFSM:(int)nID actionSrc:(bwFSMActionSrc*)pkAct fsmSheet:(P9FSMSheet*)pkFSMSheet
{
    return false;
}

-(void) OnChangeState:(int)nFileID 
            prevState:(P9FSMState*)pkPrevState 
            nextState:(P9FSMState*)pkNextState 
             fsmSheet:(P9FSMSheet*) pkFSMSheet
{
    
}

-(int) BranchQuestion:(int)nFileID question:(NSString*)strQuestion fsmSheet:(P9FSMSheet*)pFSMSheet
{
    return 0;
}

-(P9FSMSheet*) AddFSMSheet:(int)nFileID fileName:(NSString*)strFileName
{
    P9FSMData* pFSMData = [[P9FSMLoader sharedInstance] GetFSM:strFileName];
    if(!pFSMData || !pFSMData.pkStartFSMSheetSrc)
        return nil;
 
	t_fsmdata* pData = [self CreateFSMSheets:nFileID fsmData:pFSMData fileName:strFileName];
	if(!pData)
		return nil;
    
	P9FSMSheet* pStartFSMSheet = [self FindFSMSheet:nFileID name:pFSMData.pkStartFSMSheetSrc.strName];
	if(!pStartFSMSheet) {
		[self DestroyFSMSheets:nFileID];
		return nil;
	}
    
	if([self IsExistFileID:nFileID]) {
        NSLog(@"- ERROR!    IsExistFileID() is TRUE.");
        return pStartFSMSheet;
    }
    
    [self.arrFileIDs addObject:[NSNumber numberWithInt:nFileID]];
    
	return pStartFSMSheet;
}

-(bool) FireEvent:(int)nFileID arcID:(int)nArcID fsmSheet:(P9FSMSheet*)pkFSMSheet
{
	P9FSMSheet* pkFSMSheetAt = pkFSMSheet;
    
	if(pkFSMSheetAt == NULL)
		pkFSMSheetAt = [self FindFSMSheet:nFileID name:df_XML_START_SHEET];
    
	if(!pkFSMSheetAt || ![pkFSMSheetAt GetCurState]) return false;
    
	return [self _FireEvent:nFileID arcID:nArcID fsmSheet:pkFSMSheetAt];
}

-(P9FSMSheet*) FindFSMSheet:(int)nFileID name:(NSString*)strName
{
	if([m_dicFSMFiles count] <= 0)
		return nil;
    
	t_fsmdata* pData = [m_dicFSMFiles objectForKey:[NSNumber numberWithInt:nFileID]];
	if(!pData) return nil;
    
	if([pData->m_arrFSMSheets count] <= 0)
		return nil;
    
	NSUInteger cnt = [pData->m_arrFSMSheets count];
	for(int i=0; i<cnt; i++) {
		P9FSMSheet* pFSMSheet = [pData->m_arrFSMSheets objectAtIndex:i];
		if(pFSMSheet && [pFSMSheet GetFSMSheetSrc] && [[pFSMSheet GetFSMSheetSrc].strName isEqualToString:strName]) {
			return pFSMSheet;
		}
	}
    
	return nil;
}

-(P9FSMSheet*) FindYoungestCurSheet:(int)nFileID
{
	P9FSMSheet* pkFSMSheet = [self FindFSMSheet:nFileID name:df_XML_START_SHEET];
    
	while(pkFSMSheet && [pkFSMSheet GetCurState]) {
		P9FSMSheet* pkFSMSheetChild = [self FindFSMSheet:nFileID name:[pkFSMSheet GetCurState].strName];
		if(pkFSMSheetChild == NULL)
			return pkFSMSheet;
        
		pkFSMSheet = pkFSMSheetChild;
	}
    
	return nil;
}

-(t_fsmdata*) CreateFSMSheets:(int)nFileID fsmData:(P9FSMData*)pFSMData fileName:(NSString*)StrFileName
{
    if(!pFSMData) return nil;
    
    t_fsmdata* pData = [[t_fsmdata alloc] init];
    pData.pFSMData = pFSMData;
    [m_dicFSMFiles setObject:pData forKey:[NSNumber numberWithInt:nFileID]];
    
	// create P9FSMSheet
    NSMutableArray* arrSheetSrc = pFSMData.arrFSMSheetSrc;
    NSUInteger cnt = [arrSheetSrc count];
    for(int i=0; i<cnt; i++) {
        P9FSMSheetSrc* pFSM = [arrSheetSrc objectAtIndex:i];
        if(pFSM) {
            P9FSMSheet* pFSMSheet = [[P9FSMSheet alloc] initWithInfo:pFSM fsmActor:self parentFSMSheet:nil];
            if(!pFSMSheet) continue;

            pFSMSheet.nFileID = nFileID;
			[pData->m_arrFSMSheets addObject:pFSMSheet];
        }
    }

	// setting child and parent
	cnt = [pData->m_arrFSMSheets count];
	for(int i=0; i<cnt; i++) {
		P9FSMSheet* pFSMSheet = [pData->m_arrFSMSheets objectAtIndex:i];
		if(!pFSMSheet || ![pFSMSheet GetFSMSheetSrc]) continue;
        
        NSUInteger cnt2 = [[pFSMSheet GetFSMSheetSrc].arrFSMStates count];
        for(int j=0; j<cnt2; j++) {
            P9FSMState* pState = [[pFSMSheet GetFSMSheetSrc].arrFSMStates objectAtIndex:j];
			if(!pState) continue;
            
			P9FSMSheet* pFSMSheetChild = [self FindFSMSheet:nFileID name:pState.strName];
			if(pFSMSheetChild) {
				[pFSMSheetChild SetParentSheet:pFSMSheet];
				[pFSMSheet AddChildFSMSheet:pFSMSheetChild];
			}
        }
	}
    
    return pData;
}

-(void) DestroyFSMSheets:(int)nFileID
{
	if([m_dicFSMFiles count] <= 0)
		return;
    
    [m_dicFSMFiles removeObjectForKey:[NSNumber numberWithInt:nFileID]];
}

-(void) DestroyFSMSheetsAll
{
    [m_dicFSMFiles removeAllObjects];
}

-(bool) _FireEvent:(int)nFileID arcID:(int)nArcID fsmSheet:(P9FSMSheet*)pFSMSheet
{
	if(!pFSMSheet || ![pFSMSheet IsActivate] || ![pFSMSheet GetFSMSheetSrc] || ![pFSMSheet GetCurState] || nArcID < 0)
		return false;
    
	if([pFSMSheet IsExistArcAtCurState:nArcID]) {
		[pFSMSheet FireEvent:nArcID];
		return true;
	}
    
    P9FSMSheet* sheet = [self FindFSMSheet:nFileID name:[pFSMSheet GetCurState].strName];
	bool bDone = [self _FireEvent:nFileID arcID:nArcID fsmSheet:sheet];
	if(bDone)
		return true;
    
	return false;
}

-(bool) IsExistFileID:(int)nFileID
{
	if([self.arrFileIDs count] <= 0)
		return false;

    for(NSNumber* num in self.arrFileIDs) {
        if(num && [num intValue] == nFileID) {
            return true;
        }
    }
    
	return false;
}




@end
