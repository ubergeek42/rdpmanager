//
//  AppDelegate.m
//  rdpmanager
//
//  Created by Keith Johnson on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize sessionList;
@synthesize window = _window;
NSMutableArray *rdpSessions;
NSString *rdpDefaults;
const int rdpWidth = 1440;
const int rdpHeight = 900;
const int rdpBPP = 24;
const int rdpDisableWallpaper = 1;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSRegularExpression *hostnameRegex = [[NSRegularExpression alloc] initWithPattern:@"full address:s:(.+)" options:0 error:nil];
    NSRegularExpression *usernameRegex = [[NSRegularExpression alloc] initWithPattern:@"username:s:(.+)" options:0 error:nil];
    NSRegularExpression *domainRegex = [[NSRegularExpression alloc] initWithPattern:@"domain:s:(.+)" options:0 error:nil];

    rdpSessions = [[NSMutableArray alloc] init];

    
    NSMutableString *rdpDir = [[NSMutableString alloc] init];
    [rdpDir appendFormat:@"%@/%@",NSHomeDirectory(),@"Desktop/rdp"];

    // Insert code here to initialize your application
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rdpDir error:nil];
    NSArray *rdpFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.rdp'"]];
    
    for(id file in rdpFiles) {
        // Grab the file contents, and parse them into objects
        NSString *fullPath = [[NSString alloc] initWithFormat:@"%@/%@",rdpDir,file];
        NSError *error;
        NSString *contents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"%@",file);
        // Parse out the information we need
        NSTextCheckingResult *hostnameMatch = [hostnameRegex firstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
        NSTextCheckingResult *usernameMatch = [usernameRegex firstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
        NSTextCheckingResult *domainMatch = [domainRegex firstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
        if (hostnameMatch == nil || usernameMatch == nil || domainMatch == nil) {
            NSLog(@"Error parsing file");
        } else {
            
            
            RDPSession *session = [[RDPSession alloc] init];
            session.name = [file substringWithRange:NSMakeRange(0, [file length]-4)];
            session.hostname = [contents substringWithRange:[hostnameMatch rangeAtIndex:1]];
            session.username = [contents substringWithRange:[usernameMatch rangeAtIndex:1]];
            session.domain = [contents substringWithRange:[domainMatch rangeAtIndex:1]];
            [rdpSessions addObject:session];
            
            NSLog(@"Session name: %@",session.name);
            NSLog(@"Server name:  %@",session.hostname);
            NSLog(@"Username:     %@",session.username);
            NSLog(@"Domain:       %@",session.domain);
            NSLog(@"");
        }
    }
    NSLog(@"%lu", [rdpSessions count]);
    [sessionList reloadData];
    [sessionList setDoubleAction:NSSelectorFromString(@"doubleClick:")];
}

-(IBAction)launchSession:(id)pID
{
    NSMutableString *defaultString = [[NSMutableString alloc] init];
    [defaultString appendFormat:@"desktopwidth:i:%i\n",rdpWidth];
    [defaultString appendFormat:@"desktopheight:i:%i\n",rdpHeight];
    [defaultString appendFormat:@"session bpp:i:%i\n",rdpBPP];
    [defaultString appendFormat:@"disable wallpaper:i:%i\n",rdpDisableWallpaper];
    rdpDefaults = [[NSString alloc] initWithString:defaultString];
    
    NSMutableString *rdpStr = [[NSMutableString alloc] init];
    [rdpStr appendFormat:@"full address:s:%@\n",[hostnameText stringValue]];
    [rdpStr appendFormat:@"username:s:%@\n",[usernameText stringValue]];
    [rdpStr appendFormat:@"domain:s:%@\n",[domainText stringValue]];
    [rdpStr appendFormat:@"%@",rdpDefaults];
    NSLog(@"RDP File:\n\n%@",rdpStr);
    
    NSString *rdpFilename = @"/Users/ubergeek/Desktop/temp.rdp";
    // Write the settings to a file
    NSError *error;
    BOOL success = [rdpStr writeToFile:rdpFilename atomically:TRUE encoding:NSUnicodeStringEncoding error:&error];
    if (!success) {
        NSLog(@"Error writing file %@: %@\n",rdpFilename, [error localizedFailureReason]);
    } else {
        [[NSWorkspace sharedWorkspace] openFile:rdpFilename];
    }
}

-(void)doubleClick:(id)nid {
    NSLog(@"Doubleclicked");
    [self launchSession:nil];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSLog(@"Selected: %lu", [sessionList selectedRow]);
    if ([sessionList selectedRow] > [rdpSessions count] || [sessionList selectedRow] <0) return;
    
    RDPSession *session = [rdpSessions objectAtIndex:[sessionList selectedRow]];
    [hostnameText setStringValue:session.hostname];
    [usernameText setStringValue:session.username];
    [domainText setStringValue:session.domain];
    
}
-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [rdpSessions count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RDPSession *session = [rdpSessions objectAtIndex:row];
    RdpCell *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    //Item *item = [self.items objectAtIndex:row];
    result.title.stringValue = session.name;
    result.subtitle.stringValue = session.hostname;
    return result;
}

@end
