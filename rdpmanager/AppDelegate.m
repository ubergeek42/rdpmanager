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

NSString *rdpDir;
NSRegularExpression *resolutionRegex;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    resolutionRegex = [[NSRegularExpression alloc] initWithPattern:@"(.+)x(.+)" options:0 error:nil];
    NSRegularExpression *hostnameRegex = [[NSRegularExpression alloc] initWithPattern:@"full address:s:(.+)" options:0 error:nil];
    NSRegularExpression *usernameRegex = [[NSRegularExpression alloc] initWithPattern:@"username:s:(.+)" options:0 error:nil];
    NSRegularExpression *domainRegex = [[NSRegularExpression alloc] initWithPattern:@"domain:s:(.+)" options:0 error:nil];
    NSRegularExpression *widthRegex = [[NSRegularExpression alloc] initWithPattern:@"desktopwidth:i:(.+)" options:0 error:nil];
    NSRegularExpression *heightRegex = [[NSRegularExpression alloc] initWithPattern:@"desktopheight:i:(.+)" options:0 error:nil];

    rdpSessions = [[NSMutableArray alloc] init];

    
    NSMutableString *defaultString = [[NSMutableString alloc] init];
    //[defaultString appendFormat:@"desktopwidth:i:%i\n",rdpWidth];
    //[defaultString appendFormat:@"desktopheight:i:%i\n",rdpHeight];
    [defaultString appendFormat:@"session bpp:i:%i\n",rdpBPP];
    [defaultString appendFormat:@"disable wallpaper:i:%i\n",rdpDisableWallpaper];
    rdpDefaults = [[NSString alloc] initWithString:defaultString];
    
    NSMutableString *temp = [[NSMutableString alloc] init];
    [temp appendFormat:@"%@/%@",NSHomeDirectory(),@"Desktop/rdp"];
    rdpDir = [[NSString alloc] initWithString:temp];

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
            
            NSTextCheckingResult *widthMatch = [widthRegex firstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
            NSTextCheckingResult *heightMatch = [heightRegex firstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
            if (widthMatch != nil && heightMatch !=nil) {
                session.width = [[contents substringWithRange:[widthMatch rangeAtIndex:1]] intValue];
                session.height = [[contents substringWithRange:[heightMatch rangeAtIndex:1]] intValue];
            } else {
                // set a default resolution(1440x900)
                session.width = rdpWidth;
                session.height = rdpHeight;
            }
            
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
    
    NSArray *resolutions = [[NSArray alloc] initWithObjects:@"600x480",@"640x480",@"800x600",@"1024x640",@"1024x768",@"1280x800",@"1280x1024",@"1440x900", @"1600x1200",@"1680x1050",@"1920x1080",@"1920x1200", @"2400x1500",@"2560x1600", nil];
    [resolutionSelector removeAllItems];
    [resolutionSelector addItemsWithTitles:resolutions];
}

-(IBAction)newSession:(id)sender {
    RDPSession *session = [[RDPSession alloc] init];
    session.name = @"New Session";
    session.hostname = @"";
    session.username = @"";
    session.domain = @"";
    session.width = rdpWidth;
    session.height = rdpHeight;
    [rdpSessions addObject:session];
    [sessionList reloadData];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[rdpSessions count]-1];
    [sessionList selectRowIndexes:indexSet byExtendingSelection:NO];

}

-(IBAction)deleteSession:(id)sender {
    int selectedIndex = [sessionList selectedRow];
    if (selectedIndex > [rdpSessions count] || selectedIndex <0) return;
    
    RDPSession *session = [rdpSessions objectAtIndex:selectedIndex];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.rdp",rdpDir,session.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // delete the file
        NSLog(@"Deleting file: %@", filePath);
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!success) {
            NSLog(@"Error deleting file %@: %@\n",filePath, [error localizedFailureReason]);
        }
    }
    [rdpSessions removeObject:session];
    [sessionList reloadData];
    
    if (selectedIndex >= [rdpSessions count]) {
        selectedIndex = [rdpSessions count] -1;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedIndex];
    [sessionList selectRowIndexes:indexSet byExtendingSelection:NO];
}

-(IBAction)saveSession:(id)sender {
    if ([sessionList selectedRow] > [rdpSessions count] || [sessionList selectedRow] <0) return;
    
    RDPSession *session = [rdpSessions objectAtIndex:[sessionList selectedRow]];

    // Delete the file before we write a new one
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.rdp",rdpDir,session.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!success) {
            NSLog(@"Error deleting file %@: %@\n",filePath, [error localizedFailureReason]);
        }
    }
    
    
    session.name = [sessionnameText stringValue];
    session.hostname = [hostnameText stringValue];
    session.username = [usernameText stringValue];
    session.domain = [domainText stringValue];
    
    NSString *resolutionStr = [resolutionSelector titleOfSelectedItem];
    NSTextCheckingResult *res = [resolutionRegex firstMatchInString:resolutionStr options:0 range:NSMakeRange(0,[resolutionStr length])];
    session.width = [[resolutionStr substringWithRange:[res rangeAtIndex:1]] intValue];
    session.height = [[resolutionStr substringWithRange:[res rangeAtIndex:2]] intValue];
    
    
    NSMutableString *rdpStr = [[NSMutableString alloc] init];
    [rdpStr appendFormat:@"full address:s:%@\n",session.hostname];
    [rdpStr appendFormat:@"username:s:%@\n",session.username];
    [rdpStr appendFormat:@"domain:s:%@\n",session.domain];
    [rdpStr appendFormat:@"desktopwidth:i:%i\n",session.width];
    [rdpStr appendFormat:@"desktopheight:i:%i\n",session.height];
    [rdpStr appendFormat:@"%@",rdpDefaults];

    // Write the settings to a file
    NSString *rdpFilename = [[NSString alloc] initWithFormat:@"%@/%@.rdp",rdpDir,session.name];
    NSLog(@"%@",rdpFilename);
    NSError *error;
    BOOL success = [rdpStr writeToFile:rdpFilename atomically:TRUE encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        NSLog(@"Error writing file %@: %@\n",rdpFilename, [error localizedFailureReason]);
    }
    
    [sessionList reloadData];    
}
-(IBAction)launchSession:(id)sender
{
    NSMutableString *rdpStr = [[NSMutableString alloc] init];
    [rdpStr appendFormat:@"full address:s:%@\n",[hostnameText stringValue]];
    [rdpStr appendFormat:@"username:s:%@\n",[usernameText stringValue]];
    [rdpStr appendFormat:@"domain:s:%@\n",[domainText stringValue]];
    
    
    NSString *resolutionStr = [resolutionSelector titleOfSelectedItem];
    NSTextCheckingResult *res = [resolutionRegex firstMatchInString:resolutionStr options:0 range:NSMakeRange(0,[resolutionStr length])];
    int width = [[resolutionStr substringWithRange:[res rangeAtIndex:1]] intValue];
    int height = [[resolutionStr substringWithRange:[res rangeAtIndex:2]] intValue];
    
    [rdpStr appendFormat:@"desktopwidth:i:%i\n",width];
    [rdpStr appendFormat:@"desktopheight:i:%i\n",height];
    [rdpStr appendFormat:@"%@",rdpDefaults];
    NSLog(@"RDP File:\n\n%@",rdpStr);
    
    NSString *rdpFilename = @"/tmp/temp.rdp";
    // Write the settings to a file
    NSError *error;
    BOOL success = [rdpStr writeToFile:rdpFilename atomically:TRUE encoding:NSUTF8StringEncoding error:&error];
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
    [sessionnameText setStringValue:session.name];
    
    [resolutionSelector selectItemWithTitle:[NSString stringWithFormat:@"%dx%d", session.width, session.height]];
    
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
