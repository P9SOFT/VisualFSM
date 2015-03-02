//
//  P9FSMActor.h
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <Foundation/Foundation.h>


#define ACTION_CASE(actionname, delefunction)         case actionname: \
[self.delegate delefunction]; \
bExecuted = true; \
break;

#define ACTION_CASE_LOCALFUNC(actionname, func)         case actionname: \
[self func]; \
bExecuted = true; \
break;


@class P9FSMSheet;
@class P9FSMData;
@class bwFSMActionSrc;
@class P9FSMState;



@interface P9FSMActor : NSObject

@property (nonatomic, retain) NSMutableArray* arrFileIDs;

-(id)           initWithFSM;
-(void)         UpdateFSM:(unsigned long)dwTime;
-(bool)         OnActionFSM:(int)nID actionSrc:(bwFSMActionSrc*)pkAct fsmSheet:(P9FSMSheet*)pkFSMSheet;
-(void)         OnChangeState:(int)nFileID 
                    prevState:(P9FSMState*)pkPrevState 
                    nextState:(P9FSMState*)pkNextState 
                     fsmSheet:(P9FSMSheet*)pkFSMSheet;

-(int)			BranchQuestion:(int)nFileID question:(NSString*)strQuestion fsmSheet:(P9FSMSheet*)pFSMSheet;

-(P9FSMSheet*)  AddFSMSheet:(int)nFileID fileName:(NSString*)strFileName;
-(bool)			FireEvent:(int)nFileID arcID:(int)nArcID fsmSheet:(P9FSMSheet*)pkFSMSheet;
-(P9FSMSheet*)	FindFSMSheet:(int)nFileID name:(NSString*)strName;
-(P9FSMSheet*)	FindYoungestCurSheet:(int)nFileID;

@end
