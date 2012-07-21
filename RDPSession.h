//
//  RDPSession.h
//  rdpmanager
//
//  Created by Keith Johnson on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDPSession : NSObject {
    NSString *hostname;
    NSString *username;
    NSString *domain;
    NSString *name;
}
@property (retain) NSString *name;
@property (retain) NSString *hostname;
@property (retain) NSString *username;
@property (retain) NSString *domain;

@end
