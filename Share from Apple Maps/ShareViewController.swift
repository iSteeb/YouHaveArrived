//
//  ShareViewController.swift
//  Share from Apple Maps
//
//  Created by Steven Duzevich on 16/1/2024.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI

class ShareViewController: UIViewController {
    
    let DEEPLINK_BASE = "duzieyouhavearrived://"
    var deeplink: URL?
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            close()
            return
        }
        
        let urlDataType = UTType.url.identifier
        for itemProvider in extensionItem.attachments ?? [] {
            if itemProvider.hasItemConformingToTypeIdentifier(urlDataType) {
                itemProvider.loadItem(forTypeIdentifier: urlDataType, options: nil, completionHandler: { providedURL, error in
                    if let error = error {
                        self.displayView()
                        print("Error loading item: \(error.localizedDescription)")
                    } else {
                        if let url = (providedURL as? URL)?.absoluteString, let coordinates = self.getCoordinates(input: url) {
                            self.latitude = coordinates["latitude"]
                            self.longitude = coordinates["longitude"]
                            self.deeplink = URL(string: "\(self.DEEPLINK_BASE)set-pin-to-coordinate?latitude=\(self.latitude!)&longitude=\(self.longitude!)")
                            
                            self.displayView()
                        }
                    }
                })
            } else {
                displayView()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("proceed"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.openMainApp()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("cancel"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    func displayView() {
        DispatchQueue.main.async {
            let contentView = UIHostingController(rootView: ShareExtensionView(latitude: self.latitude, longitude: self.longitude))
            self.addChild(contentView)
            self.view.addSubview(contentView.view)
            contentView.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
            contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
        }
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            _ = self.openURL(self.deeplink!)
        })
    }
    
    func getCoordinates(input: String) -> [String: Double]? {
        let pattern = "ll=([-0-9.]+),([-0-9.]+)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: input.utf16.count)
            if let match = regex.firstMatch(in: input, options: [], range: range) {
                let latitudeRange = Range(match.range(at: 1), in: input)!
                let longitudeRange = Range(match.range(at: 2), in: input)!
                
                let latitude = Double(input[latitudeRange])!
                let longitude = Double(input[longitudeRange])!
                return ["latitude": latitude, "longitude": longitude]
            }
        } catch {
            print("Error creating regex: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
