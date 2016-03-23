//
//  CodeResgin.m
//  CodeResign
//
//  Created by MiaoGuangfa on 3/5/16.
//  Copyright © 2016 MiaoGuangfa. All rights reserved.
//

#import "CodeResgin.h"
#import "MGFDraggedTextField.h"

NSString * const kIPA = @"ipa.folder.path";
NSString * const kMainApp = @"mainapp.mobile.provision.path";
NSString * const kExtension = @"extension.mobile.provision.path";
NSString * const kWatchApp = @"watchapp.mobile.provision.path";
NSString * const kSharedExtension = @"shared.extension.mobile.provision.path";
NSString * const kCert = @"cert.mobile.provision.path";

@interface CodeResgin ()
@property (unsafe_unretained) IBOutlet NSTextView *resignResultTextView;

//outlet
@property (weak) IBOutlet MGFDraggedTextField *ipaPathField;
@property (weak) IBOutlet MGFDraggedTextField *mainAppMPField;
@property (weak) IBOutlet MGFDraggedTextField *extensionMPField;
@property (weak) IBOutlet MGFDraggedTextField *watchAppMPField;
@property (weak) IBOutlet MGFDraggedTextField *sharedExtensionMPField;


@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *progressLabel;
@property (weak) IBOutlet NSPopUpButton *popUpButton;

//veriables
@property (nonatomic, strong) NSMutableArray *ipaPaths;
@property (nonatomic, strong) NSTask *certTask;

@property (nonatomic, copy) NSString *selectedCert;
@property (nonatomic, strong) NSMutableArray *certsResult;

@property (nonatomic, copy) NSString *ipaFolderPath;
@property (nonatomic, copy) NSString *mainAppMobileProvisionPath;
@property (nonatomic, copy) NSString *extensionMobiieProvisionPath;
@property (nonatomic, copy) NSString *watchAppMobileProvisionPath;
@property (nonatomic, copy) NSString *sharedExtensionMobileProvisionPath;
@property (nonatomic, copy) NSString *certIndex;

@property (nonatomic, strong) dispatch_group_t blockGroup;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) BOOL bSelectedFolder;
@property (nonatomic, copy) NSString * result;
@end


@implementation CodeResgin

- (void)initializeData {
    
    _ipaPaths = [NSMutableArray new];

    NSString *ipaPath = [[NSUserDefaults standardUserDefaults]objectForKey:kIPA];
    NSString *mainApp = [[NSUserDefaults standardUserDefaults]objectForKey:kMainApp];
    NSString *extensionApp = [[NSUserDefaults standardUserDefaults]objectForKey:kExtension];
    NSString *watchApp = [[NSUserDefaults standardUserDefaults]objectForKey:kWatchApp];
    NSString *sharedExtension = [[NSUserDefaults standardUserDefaults]objectForKey:kSharedExtension];

    if (![self checkIsNull:ipaPath]) {
        [_ipaPathField setStringValue:ipaPath];
        //_ipaFolderPath = ipaPath;
    }
    if (![self checkIsNull:mainApp]) {
        [_mainAppMPField setStringValue:mainApp];
    }
    if (![self checkIsNull:extensionApp]) {
        [_extensionMPField setStringValue:extensionApp];
    }
    if (![self checkIsNull:watchApp]) {
        [_watchAppMPField setStringValue:watchApp];
    }
    if (![self checkIsNull:sharedExtension]) {
        [_sharedExtensionMPField setStringValue:sharedExtension];
    }
    
    [self getCerts];
    
}

- (IBAction)ipaBrowser:(NSButton *)sender {
    NSLog(@"%s", __FUNCTION__);

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:TRUE];
    [openPanel setCanChooseFiles:TRUE];
    [openPanel setAllowsMultipleSelection:FALSE];
    [openPanel setAllowsOtherFileTypes:FALSE];
    [openPanel setAllowedFileTypes:@[@"ipa", @"IPA"]];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        _ipaFolderPath = [[openPanel URLs]objectAtIndex:0].path;
        if ([[[_ipaFolderPath pathExtension]lowercaseString] isEqualToString:@"ipa"]) {
            //selected the ipa
            [_ipaPaths addObject:_ipaFolderPath];
            _bSelectedFolder = FALSE;
        }else{
            NSArray *files = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_ipaFolderPath error:nil];
            if (files != nil) {
                for (NSString *file in files) {
                    NSString *extension = [[file pathExtension] lowercaseString];
                    if([extension isEqualToString:@"ipa"]) {
                        NSString *absolutPath = [_ipaFolderPath stringByAppendingPathComponent:file];
                        NSLog(@"%@", absolutPath);
                        //select the folder
                        [_ipaPaths addObject:absolutPath];
                    }
                }
                _bSelectedFolder = TRUE;
            }
        }
        
        [_ipaPathField setStringValue:_ipaFolderPath];
    }
}

- (IBAction)mainAppMobileProvisionBrowser:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        _mainAppMobileProvisionPath = [[[openDlg URLs] objectAtIndex:0] path];
        [_mainAppMPField setStringValue:_mainAppMobileProvisionPath];
    }
}

- (IBAction)extensionMobileProvisionBrowser:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        _extensionMobiieProvisionPath = [[[openDlg URLs] objectAtIndex:0] path];
        [_extensionMPField setStringValue:_extensionMobiieProvisionPath];

    }
}

- (IBAction)watchAppMobileProvisionBrowser:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        _watchAppMobileProvisionPath = [[[openDlg URLs] objectAtIndex:0] path];
        [_watchAppMPField setStringValue:_watchAppMobileProvisionPath];
        
    }
}

- (IBAction)SharedExtensionBrowser:(id)sender {
    
    NSLog(@"%s", __FUNCTION__);
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setAllowsOtherFileTypes:FALSE];
    [openDlg setAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]];
    
    if ([openDlg runModal] == NSModalResponseOK)
    {
        _sharedExtensionMobileProvisionPath = [[[openDlg URLs] objectAtIndex:0] path];
        [_sharedExtensionMPField setStringValue:_sharedExtensionMobileProvisionPath];
        
    }
}


- (IBAction)openPopUp:(NSPopUpButton *)sender {
    NSLog(@"%s", __FUNCTION__);
    NSMenuItem *menuItem  = [sender selectedItem];
    _certIndex = menuItem.title;
    [sender setTitle:_certIndex];
    [[NSUserDefaults standardUserDefaults]setObject:_certIndex forKey:kCert];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (IBAction)StartToResign:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    _result = @"";
    [_ipaPaths removeAllObjects];
    [_progressIndicator startAnimation:nil];
    _mainAppMobileProvisionPath = _mainAppMPField.stringValue;
    
    
    
    _ipaFolderPath = _ipaPathField.stringValue;
    
    if ([self checkIsNull:_mainAppMobileProvisionPath]) {
        [_progressLabel setStringValue:@"Main app mobile provision path is empty"];
        [_progressIndicator stopAnimation:nil];
        return;
    }
    
    if ([self checkIsNull:_extensionMPField.stringValue]) {
        _extensionMobiieProvisionPath = _mainAppMobileProvisionPath;
    }else{
        _extensionMobiieProvisionPath = _extensionMPField.stringValue;
    }
    
    if ([self checkIsNull:_watchAppMPField.stringValue]) {
        _watchAppMobileProvisionPath = _mainAppMobileProvisionPath;
    }else{
        _watchAppMobileProvisionPath = _watchAppMPField.stringValue;
    }
    
    
    if ([self checkIsNull:_sharedExtensionMPField.stringValue]) {
        _sharedExtensionMobileProvisionPath = _mainAppMobileProvisionPath;
    }else{
        _sharedExtensionMobileProvisionPath = _sharedExtensionMPField.stringValue;
    }
    
    if (_certsResult == nil || _certsResult.count  == 0) {
        [_progressLabel setStringValue:@"No cert is available"];
        [_progressIndicator stopAnimation:nil];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:_ipaFolderPath forKey:kIPA];
    [[NSUserDefaults standardUserDefaults]setObject:_watchAppMobileProvisionPath forKey:kWatchApp];
    [[NSUserDefaults standardUserDefaults]setObject:_sharedExtensionMobileProvisionPath forKey:kSharedExtension];
    [[NSUserDefaults standardUserDefaults]setObject:_extensionMobiieProvisionPath forKey:kExtension];
    [[NSUserDefaults standardUserDefaults]setObject:_mainAppMobileProvisionPath forKey:kMainApp];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (_ipaPaths == nil || _ipaPaths.count == 0) {
        if ([[[_ipaFolderPath pathExtension]lowercaseString] isEqualToString:@"ipa"]) {
            [_ipaPaths addObject:_ipaFolderPath];
        }else{
            NSArray *files = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_ipaFolderPath error:nil];
            if (files != nil) {
                for (NSString *file in files) {
                    NSString *extension = [[file pathExtension] lowercaseString];
                    if([extension isEqualToString:@"ipa"]) {
                        NSString *absolutPath = [_ipaFolderPath stringByAppendingPathComponent:file];
                        NSLog(@"%@", absolutPath);
                        [_ipaPaths addObject:absolutPath];
                    }
                }
            }
        }
    }
    _count = _ipaPaths.count;
    dispatch_queue_t queue = dispatch_queue_create("coderesign.sub.queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSString *ipa in _ipaPaths) {
        dispatch_async(queue, ^{
            [self coderesign:ipa];
        });
    }

    
}

- (void) coderesign:(NSString *)ipaPath {
    [_progressLabel setStringValue:@"resigning ..."];
    NSTask *resignTask = [[NSTask alloc]init];
    NSString *tool_path = [[NSBundle mainBundle]pathForResource:@"coderesign" ofType:nil];
    [resignTask setLaunchPath:tool_path];
    NSLog(@"%@,%@,%@,%@,%@,%@", _mainAppMobileProvisionPath, _extensionMobiieProvisionPath, _watchAppMobileProvisionPath, _sharedExtensionMobileProvisionPath, _certIndex, ipaPath);
    [resignTask setArguments:[NSArray arrayWithObjects:@"-p", _mainAppMobileProvisionPath, @"-ex", _extensionMobiieProvisionPath, @"-wp", _watchAppMobileProvisionPath, @"-se", _sharedExtensionMobileProvisionPath, @"-ci", _certIndex, @"-d", ipaPath, nil]];
    NSPipe *pipe=[NSPipe pipe];
    [resignTask setStandardOutput:pipe];
    [resignTask setStandardError:pipe];
    NSFileHandle *handle=[pipe fileHandleForReading];
    
    [resignTask launch];
    
    [self watchResignProcess:handle];
}

- (void) watchResignProcess:(NSFileHandle *)streamHandle {
    @autoreleasepool {
        NSString *stream = [[NSString alloc] initWithData:[streamHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        NSLog(@"重签输出结果: %@", stream);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRange R_begin_MainAppInfo = [stream rangeOfString:@"<MainAppInfo>"];
            NSRange R_end_MainAppInfo = [stream rangeOfString:@"</MainAppInfo>"];
            NSRange sub_range;
            sub_range.location = R_begin_MainAppInfo.location;
            sub_range.length = R_end_MainAppInfo.location - R_begin_MainAppInfo.location;
            NSString *result = [stream substringWithRange:sub_range];
            _result = [_result stringByAppendingFormat:@" %@", result];
            [self.resignResultTextView setString:_result];
        });
        
        _count--;
        if (_count <=0) {
            [_progressLabel setStringValue:@"Done"];
            [_progressIndicator stopAnimation:nil];
        }
    }
}


#pragma mark - private methods

- (BOOL) checkIsNull:(NSString *) obj  {
    return (nil == obj) || (obj.lowercaseString.length == 0);
}

- (void) getCerts {
    NSLog(@"Getting Certificate IDs");
    [_progressLabel setStringValue:@"Getting Signing Certificates IDs"];
    
    _certTask = [[NSTask alloc]init];
    [_certTask setLaunchPath:@"/usr/bin/security"];
    [_certTask setArguments:[NSArray arrayWithObjects:@"find-identity", @"-v", @"-p", @"codesigning", nil]];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCerts:) userInfo:nil repeats:TRUE];
    
    NSPipe *pipe=[NSPipe pipe];
    [_certTask setStandardOutput:pipe];
    [_certTask setStandardError:pipe];
    NSFileHandle *handle=[pipe fileHandleForReading];
    
    [_certTask launch];
    
    [NSThread detachNewThreadSelector:@selector(watchGetCerts:) toTarget:self withObject:handle];
    
}

- (void)watchGetCerts:(NSFileHandle*)streamHandle {
    @autoreleasepool {
        
        NSString *securityResult = [[NSString alloc] initWithData:[streamHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        // Verify the security result
        if (securityResult == nil || securityResult.length < 1) {
            // Nothing in the result, return
            return;
        }
        NSArray *rawResult = [securityResult componentsSeparatedByString:@"\""];
        
        NSString *_cert_cache_title = [[NSUserDefaults standardUserDefaults]objectForKey:kCert];
        _certsResult = [NSMutableArray new];
        for (int i = 0; i <= [rawResult count] - 2; i+=2) {
            if (rawResult.count - 1 < i + 1) {
                // Invalid array, don't add an object to that position
            } else {
                // Valid object
                NSString *cer = [rawResult objectAtIndex:i+1];
                [_certsResult addObject:cer];
            }
        }
        [_popUpButton addItemsWithTitles:_certsResult];
        if ([_certsResult containsObject:_cert_cache_title]) {
            [_popUpButton setTitle:_cert_cache_title];
            _certIndex = _cert_cache_title;
        }
    }
}

- (void)checkCerts:(NSTimer *)timer {
    if ([_certTask isRunning] == 0) {
        [timer invalidate];
        _certTask = nil;
        
        if ([_certsResult count] > 0) {
            NSLog(@"Get Certs done");
            [_progressLabel setStringValue:@"Signing Certificate IDs extracted"];
        }
    }
}

@end
