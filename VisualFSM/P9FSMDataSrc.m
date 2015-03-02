//
//  P9FSMDataSrc.m
//  LibBaseWare
//
//  Created by Simon Kim on 12. 4. 7..
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9FSMDataSrc.h"



#define df_XML_ROOT					@"Root"
#define df_XML_FSM					@"FSM"
#define df_XML_ATT_ST_ENDSHEET		@"EndSheet"

#define df_XML_STATE				@"State"
#define df_XML_ATT_STATETYPE		@"State_Type"
#define df_XML_ATT_ST_START			@"Start"
#define df_XML_ATT_ST_END			@"End"
#define df_XML_ATT_ENTERACTION		@"Enter_Actions"
#define df_XML_ATT_EXITACTION		@"Exit_Actions"
#define df_XML_ATT_ENTERACTIONSTRID	@"Enter_Actions_StrID"
#define df_XML_ATT_EXITACTIONSTRID	@"Exit_Actions_StrID"

#define df_XML_BRANCH				@"Branch"
#define df_XML_ATT_FUNCTION			@"Function"

#define df_XML_ARC					@"Arc"
#define df_XML_ATT_STRID			@"StrID"
#define df_XML_ATT_EVENT			@"Event"
#define df_XML_ATT_LINK1			@"Link1"
#define df_XML_ATT_LINK2			@"Link2"

#define df_XML_ATT_NAME				@"Name"
#define df_XML_ATT_ID				@"ID"



//////////////////////////////////////////////////////////////////////////
// P9FSMArc
@implementation P9FSMArc

@end



//////////////////////////////////////////////////////////////////////////
// bwFSMActionSrc
@implementation bwFSMActionSrc


@end



//////////////////////////////////////////////////////////////////////////
// P9FSMState
@implementation P9FSMState

-(id) init
{
    self = [super init];
    if(self) {
        self.arrArc = [[NSMutableArray alloc] init];
        self.arrEnterActions = [[NSMutableArray alloc] init];
        self.arrExitActions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end



//////////////////////////////////////////////////////////////////////////
// P9FSMSheetSrc
@implementation P9FSMSheetSrc

-(id) init
{
    self = [super init];
    if(self) {
        self.arrFSMStates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end



//////////////////////////////////////////////////////////////////////////
// P9FSMData

@interface P9FSMData()


@end

@implementation P9FSMData

-(id) init
{
    self = [super init];
    if(self) {
        self.arrFSMSheetSrc = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end




//////////////////////////////////////////////////////////////////////////
// P9FSMLoader


@interface P9FSMLoader()

@property (nonatomic, retain) P9FSMData*              curLoadingFSMData;
@property (nonatomic, retain) P9FSMSheetSrc*          curLoadingFSMSheetSrc;
@property (nonatomic, retain) NSMutableDictionary*    dicFSMSheetSrcList;
@property (nonatomic, retain) NSMutableDictionary*    dicFSMStateList;
@property (nonatomic, retain) NSMutableDictionary*    dicFSMData;

-(bool)   LoadFSM:(NSString*)strFileName;

@end

@implementation P9FSMLoader

+(id) sharedInstance
{
    static P9FSMLoader *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [P9FSMLoader new];
    });
    return shared;
}

-(id) init
{
    self = [super init];
    if(self) {
        self.dicFSMSheetSrcList = [[NSMutableDictionary alloc] init];
        self.dicFSMStateList = [[NSMutableDictionary alloc] init];
        self.dicFSMData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(P9FSMData*) GetFSM:(NSString*)strFileName
{
    P9FSMData* fsmData = [self FindFSMData:strFileName];
    if(fsmData)
        return fsmData;
    
    if([self LoadFSM:strFileName])
        return [self FindFSMData:strFileName];

    return nil;
}

-(P9FSMData*) FindFSMData:(NSString*)strFileName
{
    if(strFileName == nil || [self.dicFSMData count] <= 0)
        return nil;
    
    P9FSMData* fsmData = [self.dicFSMData valueForKey:strFileName];
    return fsmData;
}

-(bool) LoadFSM:(NSString*)strFileName
{
    if(strFileName == nil)
        return false;
    
    NSString* originPath = [[NSBundle mainBundle] pathForResource:strFileName ofType:@"xml"];
    NSData* xmlData = [[NSFileManager defaultManager] contentsAtPath:originPath];
    if(xmlData == nil)
        return false;

    P9FSMData* fsmData = [[P9FSMData alloc] init];
    [self.dicFSMData setObject:fsmData forKey:strFileName];
    self.curLoadingFSMData = fsmData;
    
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];

    self.curLoadingFSMData = nil;

    return true;
}



#pragma mark -
#pragma mark NSXMLParserDelegate

-(void) parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // FSM
    if([elementName isEqualToString:df_XML_FSM]) {
        
        // Get Name
        NSString* strName = [attributeDict objectForKey:df_XML_ATT_NAME];
        if(strName) {
            // init
            [self.dicFSMSheetSrcList removeAllObjects];
            [self.dicFSMStateList removeAllObjects];
            
            P9FSMSheetSrc* pkFSM = [[P9FSMSheetSrc alloc] init];
            pkFSM.strName = strName;
            self.curLoadingFSMSheetSrc = pkFSM;
            
            // Save P9FSMSheetSrc
            [self.dicFSMSheetSrcList setObject:pkFSM forKey:strName];
            
            [self.curLoadingFSMData.arrFSMSheetSrc addObject:pkFSM];
            
            if([strName isEqualToString:df_XML_START_SHEET])
            {
                self.curLoadingFSMData.pkStartFSMSheetSrc = pkFSM;
            }
        }
    }
    
    // State
    else if([elementName isEqualToString:df_XML_STATE]) {
        P9FSMState* pkState = [[P9FSMState alloc] init];
        [self.curLoadingFSMSheetSrc.arrFSMStates addObject:pkState];
        
        // Get Name
        pkState.strName = [attributeDict objectForKey:df_XML_ATT_NAME];
        
        // Get EndSheet
        if([pkState.strName isEqualToString:df_XML_ATT_ST_ENDSHEET])
            self.curLoadingFSMSheetSrc.pkEndSheetState = pkState;
        
        // Find linked FSM
        P9FSMSheetSrc* sheetSrc = [self.dicFSMSheetSrcList objectForKey:pkState.strName];
        pkState.pkFSM = sheetSrc;
        
        // Get ID
        int nID = [[attributeDict objectForKey:df_XML_ATT_ID] intValue];
        [self.dicFSMStateList setObject:pkState forKey:[NSNumber numberWithInt:nID]];
        
        // Get State Type
        NSString* strStateType = [attributeDict objectForKey:df_XML_ATT_STATETYPE];
        if([strStateType isEqualToString:df_XML_ATT_ST_START]) {
            self.curLoadingFSMSheetSrc.pkStartState = pkState;
        }
        else if([strStateType isEqualToString:df_XML_ATT_ST_END]) {
            pkState.bLast = true;
            self.curLoadingFSMSheetSrc.pkEndState = pkState;
        }
        
        bwFSMActionSrc* pkEnterAction = nil;
        bwFSMActionSrc* pkExitAction = nil;
        
        // Get Enter Actions (just support ONE action.)
        NSString* strEnterAction = [attributeDict objectForKey:df_XML_ATT_ENTERACTION];
        if(strEnterAction && [strEnterAction length] > 0) {
            bwFSMActionSrc* pkAct = [[bwFSMActionSrc alloc] init];
            pkEnterAction = pkAct;
            pkAct.strSrc = strEnterAction;
            [pkState.arrEnterActions addObject:pkAct];
        }
        
        // Get Exit Actions (just support ONE action.)
        NSString* strExitAction = [attributeDict objectForKey:df_XML_ATT_EXITACTION];
        if(strExitAction && [strExitAction length] > 0) {
            bwFSMActionSrc* pkAct = [[bwFSMActionSrc alloc] init];
            pkExitAction = pkAct;
            pkAct.strSrc = strExitAction;
            [pkState.arrExitActions addObject:pkAct];
        }
        
        // Get EnterAction String ID
        NSString* strEnterActionStringID = [attributeDict objectForKey:df_XML_ATT_ENTERACTIONSTRID];
        if(strEnterActionStringID && [strEnterActionStringID length] > 0) {
            int nStrID = [strEnterActionStringID intValue];
            pkEnterAction.nActID = nStrID;
        }
        
        // Get ExitAction String ID
        NSString* strExitActionStringID = [attributeDict objectForKey:df_XML_ATT_EXITACTIONSTRID];
        if(strExitActionStringID && [strExitActionStringID length] > 0) {
            int nStrID = [strExitActionStringID intValue];
            pkExitAction.nActID = nStrID;
        }
    }
    
    // Branch
    else if([elementName isEqualToString:df_XML_BRANCH]) {
        P9FSMState* pkState = [[P9FSMState alloc] init];
        pkState.bBranch = true;
        [self.curLoadingFSMSheetSrc.arrFSMStates addObject:pkState];
        
        // Get Function
        NSString* strFunction = [attributeDict objectForKey:df_XML_ATT_FUNCTION];
        pkState.strName = strFunction;
        
        // Get ID
        int nID = [[attributeDict objectForKey:df_XML_ATT_ID] intValue];
        [self.dicFSMStateList setObject:pkState forKey:[NSNumber numberWithInt:nID]];
    }
    
    // Arc
    else if([elementName isEqualToString:df_XML_ARC]) {
        P9FSMArc* pkArc = [[P9FSMArc alloc] init];
        
        // Get Event type
        NSString* strEventName = [attributeDict objectForKey:df_XML_ATT_EVENT];
        pkArc.strSrc = strEventName;
        
        // Get ID
        int nStrID = [[attributeDict objectForKey:df_XML_ATT_STRID] intValue];
        pkArc.nStrID = nStrID;
        
        // Timer
        bool bTimer = false;
        if([strEventName hasPrefix:df_XML_ATT_TIMER]) {
            bTimer = true;
            NSUInteger nStartPos = [df_XML_ATT_TIMER length] + 1;
            double dwDelayTime = [[strEventName substringFromIndex:nStartPos] doubleValue];
            pkArc.dwDelayTime = dwDelayTime;
        }
        
        // Get Start State
        int nIDLink1 = [[attributeDict objectForKey:df_XML_ATT_LINK1] intValue];
        P9FSMState* kStateLink1 = [self.dicFSMStateList objectForKey:[NSNumber numberWithInt:nIDLink1]];
        [kStateLink1.arrArc addObject:pkArc];
        kStateLink1.bExistTimer = bTimer;
        
        // Check if default arc
        if(!pkArc.strSrc || [pkArc.strSrc length] == 0) {
            kStateLink1.pkDefaultArc = pkArc;
        }
        
        // Get Target State
        int nIDLink2 = [[attributeDict objectForKey:df_XML_ATT_LINK2] intValue];
        P9FSMState* kStateLink2 = [self.dicFSMStateList objectForKey:[NSNumber numberWithInt:nIDLink2]];
        pkArc.pkTargetState = kStateLink2;
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

@end


