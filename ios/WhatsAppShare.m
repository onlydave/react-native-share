//
//  FacebookShare.m
//  RNShare
//
//  Created by Diseño Uno BBCL on 23-07-16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "WhatsAppShare.h"

@implementation WhatsAppShare
static UIDocumentInteractionController *documentInteractionController;

- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {

    NSLog(@"Try open view");

    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
        NSString *text = [RCTConvert NSString:options[@"message"]];
        if ([options[@"url"] rangeOfString:@"data:image\/([a-zA-Z]*);base64,([^\"]*)" options:NSRegularExpressionSearch].location == NSNotFound) {
            text = [text stringByAppendingString: [@" " stringByAppendingString: options[@"url"]] ];
        }

        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]) {
            NSLog(@"WhatsApp installed");
        } else {
            // Cannot open whatsapp
            NSString *stringURL = @"http://itunes.apple.com/app/whatsapp-messenger/id310633997";
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];

            NSString *errorMessage = @"Not installed";
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];

            NSLog(errorMessage);
            return failureCallback(error);
        }

        if ([options[@"url"] rangeOfString:@"data:image\/([a-zA-Z]*);base64,([^\"]*)" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSLog(@"Sending whatsapp image");

            NSData *data = [[NSData alloc]initWithBase64EncodedString:options[@"url"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            // UIImage *image = [UIImage imageWithData:data];

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            // NSString *filePath;

            // if ([options[@"url"] rangeOfString:@"data:image\/png;base64,([^\"]*)" options:NSRegularExpressionSearch].location != NSNotFound) {
              // NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"betshare.png"];
              // [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
            // } else {
              NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"betshare.wai"];
              // [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
              [data writeToFile:filePath atomically:YES];
            // }

            documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
             // documentInteractionController.UTI = @"net.whatsapp.image";
//            documentInteractionController.UTI = @"public.image";
            documentInteractionController.delegate = self;
            
            NSLog(@"Try open menu from thing");
            UIViewController *rootCtrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            
            [documentInteractionController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, 0.0, 0.0) inView:rootCtrl.view animated:YES];
            // [documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] animated:YES];


            NSLog(@"Done whatsapp image");
            successCallback(@[]);
        } else {
            text = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) text, NULL,CFSTR("!*'();:@&=+$,/?%#[]"),kCFStringEncodingUTF8));
            
            NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
            NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
                successCallback(@[]);
            }
        }
    }
}

@end
