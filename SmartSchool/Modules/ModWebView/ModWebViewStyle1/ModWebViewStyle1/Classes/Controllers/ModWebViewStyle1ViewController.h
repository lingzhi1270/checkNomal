//
//  ModWebViewStyle1ViewController.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/15.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/AppData.h>

@interface ModWebViewStyle1ViewController : BaseViewController <WKNavigationDelegate>
@property (nonatomic, strong)   WKWebView               *webView;
@property (nonatomic, copy)     NSURL                   *url;
@property (nonatomic, strong)   UIProgressView          *progressView;
@property (nonatomic, copy)     NSString                *htmlString;
@property (nonatomic, copy)     NSURL                   *baseUrl;
@property (nonatomic, strong)   AppData                 *appItem;

@property (nonatomic, assign)   BOOL isMainTab;

+ (void)clearWKCache;

- (instancetype)initWithUrl:(NSURL *)url;

- (instancetype)initWithHtmlString:(NSString *)htmlString
                             title:(nullable NSString *)title
                           baseUrl:(nullable NSURL *)baseUrl;

- (instancetype)initWithUrl:(NSURL *)url withTitle:(NSString *)title;

- (void)webViewLoadFailed;

@end

