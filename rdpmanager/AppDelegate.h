//
//  AppDelegate.h
//  rdpmanager
//
//  Created by Keith Johnson on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RdpCell.h"
#import "RDPSession.h"
@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *rdpList;
    
    IBOutlet NSTextField *sessionnameText;
    IBOutlet NSTextField *hostnameText;
    IBOutlet NSTextField *usernameText;
    IBOutlet NSTextField *domainText;
    
    IBOutlet NSPopUpButton *resolutionSelector;
}

@property(nonatomic, retain) IBOutlet NSTableView *sessionList;
@property (assign) IBOutlet NSWindow *window;

-(IBAction)newSession:(id)sender;
-(IBAction)deleteSession:(id)sender;
-(IBAction)launchSession:(id)sender;
-(IBAction)saveSession:(id)sender;
- (void)doubleClick:(id)nid;

@end
