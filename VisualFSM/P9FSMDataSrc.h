//
//  P9FSMDataSrc.h
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <Foundation/Foundation.h>



#define df_XML_START_SHEET				@"Sht_Start"			// start sheet name
#define df_XML_ATT_TIMER				@"Timer"				// timer

//////////////////////////////////////////////////////////////////////////
// reserved string and ID
#define df_XML_ACTION_CHANGE_ANI		@"Change_Ani"		// play animation
#define df_XML_ACTION_BLEND_ANI			@"Blend_Ani"		// activate blending animation
#define dx_XML_ACTION_DEACTIVATE_ANI	@"Deactivate_Ani"	// deactivate blending animation
#define dx_XML_ACTION_SAVE_LASTANI		@"Save_LastAni"		// last played animation ID

#define df_FSM_ACT_CHANGE_ANI_ID		1
#define df_FSM_ACT_BLEND_ANI_ID			2
#define df_FSM_ACT_DEACTIVATE_ANI_ID	4
#define df_FSM_ACT_SAVE_LASTANI_ID		3



typedef	double	EVENTID;
typedef double	ACTID;

@class P9FSMSheetSrc;
@class P9FSMState;
@class P9FSMArc;



//////////////////////////////////////////////////////////////////////////
// P9FSMArc
@interface P9FSMArc : NSObject

@property (nonatomic, copy) NSString*       strSrc;
@property (nonatomic) int                   nStrID;
@property (nonatomic, assign) P9FSMState*   pkTargetState;
@property (nonatomic) double                dwDelayTime;

@end

typedef NSMutableArray* bwFSMArcs;



//////////////////////////////////////////////////////////////////////////
// bwFSMActionSrc
@interface bwFSMActionSrc : NSObject

@property (nonatomic, copy) NSString*       strSrc;
@property (nonatomic)       int             nActID;

@end

typedef NSMutableArray* arrBwFSMActions;



//////////////////////////////////////////////////////////////////////////
// P9FSMState
@interface P9FSMState : NSObject

@property (nonatomic, copy)     NSString*       strName;
@property (nonatomic)           bool            bLast;
@property (nonatomic)           bool            bBranch;
@property (nonatomic)           bool            bExistTimer;

@property (nonatomic, retain)   bwFSMArcs       arrArc;
@property (nonatomic, assign)   P9FSMArc*       pkDefaultArc;

@property (nonatomic, retain)   arrBwFSMActions arrEnterActions;
@property (nonatomic, retain)   arrBwFSMActions arrExitActions;

@property (nonatomic, assign)   P9FSMSheetSrc*  pkFSM;

@end

typedef NSMutableArray* bwFSMStates;



//////////////////////////////////////////////////////////////////////////
// P9FSMSheetSrc
@interface P9FSMSheetSrc : NSObject

@property (nonatomic, copy)     NSString*       strName;
@property (nonatomic, retain)   bwFSMStates     arrFSMStates;
@property (nonatomic, assign)   P9FSMState*     pkStartState;
@property (nonatomic, assign)   P9FSMState*     pkEndState;
@property (nonatomic, assign)   P9FSMState*     pkEndSheetState;

@end



//////////////////////////////////////////////////////////////////////////
// P9FSMData
@interface P9FSMData : NSObject

@property (nonatomic, retain)   NSMutableArray*     arrFSMSheetSrc;
@property (nonatomic, assign)   P9FSMSheetSrc*      pkStartFSMSheetSrc;

@end



//////////////////////////////////////////////////////////////////////////
// P9FSMLoader
@interface P9FSMLoader : NSObject <NSXMLParserDelegate>

+(id)           sharedInstance;
-(P9FSMData*)   GetFSM:(NSString*)strFileName;
-(P9FSMData*)   FindFSMData:(NSString*)strFileName;

@end











