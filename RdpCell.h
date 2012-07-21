//
//  RdpCell.h
//  rdpmanager
//
//  Created by Keith Johnson on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RdpCell : NSTableCellView
@property(nonatomic, retain) IBOutlet NSTextField *title;
@property(nonatomic, retain) IBOutlet NSTextField *subtitle;
@end
