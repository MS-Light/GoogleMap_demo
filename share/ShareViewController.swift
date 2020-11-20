//
//  ShareViewController.swift
//  share
//
//  Created by User on 11/5/20.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
          let contentType = kUTTypeText as String
          for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
              provider.loadItem(forTypeIdentifier: contentType,
                                options: nil) { [unowned self] (data, error) in
              // Handle the error here if you want
              guard error == nil else { return }
                save(data as! Data, key: "String", value: data)
             
                // Handle this situation as you prefer
                fatalError("Impossible to save image")
              }
            }
          }
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
     
    private func save(_ data: Data, key: String, value: Any) {
        let userDefaults = UserDefaults()
        userDefaults.set(data, forKey: key)
    }
}
