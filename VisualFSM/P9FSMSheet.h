//
//  P9FSMSheet.h
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <Foundation/Foundation.h>
#import "P9FSMDataSrc.h"



@class P9FSMActor;



@interface P9FSMSheet : NSObject

@property (nonatomic)           int             nFileID;
@property (nonatomic, assign)   P9FSMState*     pkCurState;
@property (nonatomic, assign)   P9FSMSheetSrc*  pkSheetSrc;
@property (nonatomic, assign)   P9FSMActor*     pkActor;
@property (nonatomic, assign)   P9FSMSheet*     pkParentFSMSheet;

-(id)                   initWithInfo:(P9FSMSheetSrc*)pkFSM fsmActor:(P9FSMActor*)pkActor parentFSMSheet:(P9FSMSheet*)pkParentFSMSheet;

-(void)                 EnableSheet;
-(void)                 DisableSheet;
-(bool)                 IsActivate;

-(void)                 Update:(unsigned long)dwTime;
-(void)                 StartSheet:(P9FSMSheet*)pkParentSheet;
-(void)                 SetParentSheet:(P9FSMSheet*)pParent;
-(void)                 ChangeTimerAtCurState:(bool)bUse time:(double)dwTimer;
-(void)                 FireEvent:(int)nArcID;
-(bool)                 IsExistArcAtCurState:(int)nArcID;
-(void)                 ChangeState:(P9FSMState*)pkState;

-(void)                 AddChildFSMSheet:(P9FSMSheet*)pChildSheet;

-(P9FSMState*)          GetCurState;
-(const P9FSMSheetSrc*) GetFSMSheetSrc;
-(NSString*)            GetSheetName;

                    

@end
