//
//  ViewController.m
//  SampleVisualFSM_01
//
//  Created by Simon Kim on 2/28/15.
//  Copyright (c) 2015 P9SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "ViewController.h"



@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *txtviewLog;
@property (strong, nonatomic) SampleFSMActor* fsmActor;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtviewLog.text = @"";
}

- (IBAction)OnClickedStartVisualFSM:(id)sender
{
    if(self.fsmActor)
        self.fsmActor = nil;
    
    self.fsmActor = [[SampleFSMActor alloc] init];
    if(self.fsmActor) {
        self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"\r\nRun VisualFSM!\r\n\r\n"];

        self.fsmActor.delegate = self;
        [self.fsmActor FireEvent:FSM_FILEID_SAMPLE_01 arcID:FSM_ARC_START fsmSheet:nil];
    }
}



#pragma mark - SampleFSMActorDelegate

-(void) OnEnterInitState
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"ENTER \"InitState\" STATE.\r\n"];
    
    [self.fsmActor FireEvent:FSM_FILEID_SAMPLE_01 arcID:FSM_ARC_RUNSUBSTATE fsmSheet:nil];
}

-(void) OnExitInitState
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"EXIT \"InitState\" STATE.\r\n"];
}

-(void) OnEnterTerminate
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"ENTER \"Terminate\" STATE.\r\n"];
}

-(void) OnEnterStartSubLogic
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"ENTER \"StartSubLogic\" STATE.\r\n"];
    [self.fsmActor FireEvent:FSM_FILEID_SAMPLE_01 arcID:FSM_ARC_GONEXTSTEP fsmSheet:nil];
}

-(void) OnEnterGood
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"ENTER \"Good\" STATE.\r\n"];
    [self.fsmActor FireEvent:FSM_FILEID_SAMPLE_01 arcID:FSM_ARC_GOTOTERMINATE fsmSheet:nil];
}

-(void) OnEnterBad
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"ENTER \"Bad\" STATE.\r\n"];
}

-(bool) OnBranchIsThisGood
{
    self.txtviewLog.text = [self.txtviewLog.text stringByAppendingString:@"BRANCH STATE. \"IsThisGood? : Said YES.\"\r\n"];
    return true;
}

@end
