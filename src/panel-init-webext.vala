public static void webkit_web_extension_initialize (WebKit.WebExtension web_extension) {
    web_extension.page_created.connect((extension, web_page) => {
        stdout.printf("Webext: page created signal halder from web-extension\n");
        return;
    });

    WebKit.ScriptWorld.get_default().window_object_cleared.connect((page, frame) => {
        stdout.printf("WebExt: Adding some JS\n");
        Helper.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        PanelDesktopData.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        PanelXdgData.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        PanelPlaces.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        PanelSessionManager.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        PanelUser.setup_js_class((JSCore.GlobalContext) frame.get_javascript_global_context());
        return;
    });    
}
