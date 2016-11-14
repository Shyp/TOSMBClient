//
// TOSMBSessionTask.h
// Copyright 2015-2016 Timothy Oliver
//
// This file is dual-licensed under both the MIT License, and the LGPL v2.1 License.
//
// -------------------------------------------------------------------------------
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
// -------------------------------------------------------------------------------

#import "TOSMBSessionTaskPrivate.h"

@implementation TOSMBSessionTask

- (instancetype)initWithSession:(TOSMBSession *)session {
    if((self = [super init])) {
        self.session = session;
    }
    
    return self;
}

#pragma mark - Properties

- (NSBlockOperation *)taskOperation {
    if (!_taskOperation) {
        _taskOperation = [[NSBlockOperation alloc] init];
        
        __weak typeof(self) weakSelf = self;
        __weak NSBlockOperation *weakOperation = _taskOperation;
        [_taskOperation addExecutionBlock:^{
            [weakSelf performTaskWithOperation:weakOperation];
        }];
        
        _taskOperation.completionBlock = ^{
            weakSelf.taskOperation = nil;
        };
    }
    return _taskOperation;
}

- (void (^)(smb_tid treeID, smb_fd fileID))cleanupBlock {
    return ^(smb_tid treeID, smb_fd fileID) {
        
        //Release the background task handler, making the app eligible to be suspended now
        if (self.backgroundTaskIdentifier) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = 0;
        }
        
        if (self.taskOperation && treeID) {
            smb_tree_disconnect(self.smbSession, treeID);
        }
        
        if (self.smbSession && fileID) {
            smb_fclose(self.smbSession, fileID);
        }

        
        if (self.smbSession) {
            smb_session_destroy(self.smbSession);
            self.smbSession = nil;
        }
    };
}

#pragma mark - Task Methods

- (void)performTaskWithOperation:(__weak NSBlockOperation *)operation {
    return;
}

- (void)resume {
    return;
}

- (void)suspend {
    return;
}

- (void)cancel {
    return;
}

@end