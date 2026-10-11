import Cocoa
import WebKit
import UniformTypeIdentifiers
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKUIDelegate, NSWindowDelegate {
    var window: NSWindow!
    var web: WKWebView!
    let dataDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Mario To Do")
    var dataURL: URL { dataDir.appendingPathComponent("tasks.json") }
    func applicationDidFinishLaunching(_ notification: Notification) {
        try? FileManager.default.createDirectory(at: dataDir.appendingPathComponent("Attachments"), withIntermediateDirectories: true)
        let menu = NSMenu(); let item = NSMenuItem(); menu.addItem(item)
        let appMenu = NSMenu(); item.submenu = appMenu
        appMenu.addItem(withTitle: "About Mario To Do", action: #selector(about), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator()); appMenu.addItem(withTitle:"Quit Mario To Do", action:#selector(NSApplication.terminate(_:)), keyEquivalent:"q")
        let editItem = NSMenuItem(); menu.addItem(editItem); let edit = NSMenu(title:"Edit"); editItem.submenu = edit
        for (title, sel, key) in [("Undo", "undo:", "z"),("Cut", "cut:", "x"),("Copy", "copy:", "c"),("Paste", "paste:", "v"),("Select All", "selectAll:", "a")] { edit.addItem(withTitle:title, action:Selector(sel), keyEquivalent:key) }
        NSApp.mainMenu = menu
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name:"native")
        let raw = (try? String(contentsOf:dataURL)) ?? "null"
        let payload = Data(raw.utf8).base64EncodedString()
        config.userContentController.addUserScript(WKUserScript(source:"window.__initialData=JSON.parse(new TextDecoder().decode(Uint8Array.from(atob('\(payload)'),c=>c.charCodeAt(0))));", injectionTime:.atDocumentStart, forMainFrameOnly:true))
        web = WKWebView(frame:.zero, configuration:config); web.uiDelegate = self
        window = NSWindow(contentRect:NSRect(x:0,y:0,width:1240,height:790),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
        window.title = "Mario To Do"; window.minSize = NSSize(width:850,height:570); window.center(); window.contentView = web; window.delegate = self
        window.setFrameAutosaveName("MarioToDoMain")
        let url = Bundle.main.url(forResource:"index",withExtension:"html")!
        web.loadFileURL(url, allowingReadAccessTo:url.deletingLastPathComponent())
        window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps:true)
    }
    @objc func about() { NSApp.orderFrontStandardAboutPanel(options:[.applicationName:"Mario To Do",.applicationVersion:"1.0",.credits:NSAttributedString(string:"Independent local task manager. Made for Mario.")]) }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool { true }
    func windowWillClose(_ notification:Notification) { web.evaluateJavaScript("persist()", completionHandler:nil) }
    func send(_ fn:String,_ object:Any) { if let data = try? JSONSerialization.data(withJSONObject:object,options:[.fragmentsAllowed]), let json=String(data:data,encoding:.utf8) { web.evaluateJavaScript("\(fn)(\(json))",completionHandler:nil) } }
    func userContentController(_ userContentController:WKUserContentController,didReceive message:WKScriptMessage) {
        guard let obj=message.body as? [String:Any],let action=obj["action"] as? String else { return }
        switch action {
        case "save":
            guard let state=obj["state"], let bytes=try? JSONSerialization.data(withJSONObject:state,options:[.prettyPrinted,.sortedKeys]) else { return }
            do { if FileManager.default.fileExists(atPath:dataURL.path) { let backup=dataDir.appendingPathComponent("tasks.previous.json"); try? FileManager.default.removeItem(at:backup); try? FileManager.default.copyItem(at:dataURL,to:backup) }; try bytes.write(to:dataURL,options:.atomic); send("saved",true) } catch { send("nativeError",error.localizedDescription) }
        case "checkpoint":
            let url=dataDir.appendingPathComponent("Backup-"+UUID().uuidString+".json"); if FileManager.default.fileExists(atPath:dataURL.path) { try? FileManager.default.copyItem(at:dataURL,to:url) }
        case "export":
            let panel=NSSavePanel(); panel.nameFieldStringValue="Mario To Do Backup.json"; panel.allowedContentTypes=[.json]
            panel.beginSheetModal(for:window) { result in if result == .OK,let url=panel.url,let state=obj["state"],let bytes=try? JSONSerialization.data(withJSONObject:state,options:[.prettyPrinted]) { do { try bytes.write(to:url,options:.atomic); self.send("toast","Backup exported") } catch { self.send("nativeError",error.localizedDescription) } } }
        case "import":
            let panel=NSOpenPanel(); panel.allowedContentTypes=[.json]; panel.beginSheetModal(for:window) { result in if result == .OK,let url=panel.url { do { let bytes=try Data(contentsOf:url); if bytes.count>20_000_000 { self.send("nativeError","Backup is too large"); return }; let state=try JSONSerialization.jsonObject(with:bytes); self.send("importData",state) } catch { self.send("nativeError",error.localizedDescription) } } }
        case "attach":
            let panel=NSOpenPanel(); panel.beginSheetModal(for:window) { result in if result == .OK,let url=panel.url,let id=obj["id"] as? String { let name=UUID().uuidString+"-"+url.lastPathComponent; let target=self.dataDir.appendingPathComponent("Attachments").appendingPathComponent(name); do { try FileManager.default.copyItem(at:url,to:target); self.send("attached",["id":id,"name":url.lastPathComponent,"file":name]) } catch { self.send("nativeError",error.localizedDescription) } } }
        case "openAttachment":
            if let file=obj["file"] as? String, !file.contains("/"), !file.contains("..") { NSWorkspace.shared.open(dataDir.appendingPathComponent("Attachments").appendingPathComponent(file)) }
        case "notify":
            let center=UNUserNotificationCenter.current(); center.requestAuthorization(options:[.alert,.sound]) { allowed,error in if allowed { let note=UNMutableNotificationContent();note.title="Mario To Do";note.body=obj["title"] as? String ?? "Task reminder";note.sound = .default;center.add(UNNotificationRequest(identifier:UUID().uuidString,content:note,trigger:nil)) } }
        case "print": web.printOperation(with:NSPrintInfo.shared).run()
        default: break
        }
    }
    func webView(_ webView:WKWebView,runJavaScriptAlertPanelWithMessage message:String,initiatedByFrame frame:WKFrameInfo,completionHandler:@escaping()->Void) { let a=NSAlert();a.messageText=message;a.beginSheetModal(for:window){_ in completionHandler()} }
    func webView(_ webView:WKWebView,runJavaScriptConfirmPanelWithMessage message:String,initiatedByFrame frame:WKFrameInfo,completionHandler:@escaping(Bool)->Void) { let a=NSAlert();a.messageText=message;a.addButton(withTitle:"Continue");a.addButton(withTitle:"Cancel");a.beginSheetModal(for:window){r in completionHandler(r == .alertFirstButtonReturn)} }
    func webView(_ webView:WKWebView,runJavaScriptTextInputPanelWithPrompt prompt:String,defaultText:String?,initiatedByFrame frame:WKFrameInfo,completionHandler:@escaping(String?)->Void) { let a=NSAlert();a.messageText=prompt;let input=NSTextField(frame:NSRect(x:0,y:0,width:300,height:24));input.stringValue=defaultText ?? "";a.accessoryView=input;a.addButton(withTitle:"Save");a.addButton(withTitle:"Cancel");a.beginSheetModal(for:window){r in completionHandler(r == .alertFirstButtonReturn ? input.stringValue : nil)} }
}
let app=NSApplication.shared
let delegate=AppDelegate()
app.delegate=delegate
app.setActivationPolicy(.regular)
app.run()
