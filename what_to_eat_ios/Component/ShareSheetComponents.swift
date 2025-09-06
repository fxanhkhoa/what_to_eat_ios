//
//  ShareSheet.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 6/9/25.
//

import SwiftUI
import UIKit

// MARK: - Basic ShareSheet
struct BasicShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    @Environment(\.dismiss) private var dismiss
    
    init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Custom Share Activity for Copy Link
class CopyLinkActivity: UIActivity {
    private let url: URL
    private let localization = LocalizationService.shared
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    override var activityType: UIActivity.ActivityType? {
        UIActivity.ActivityType("com.whattoeat.copylink")
    }
    
    override var activityTitle: String? {
        localization.localizedString(for: "copy_link")
    }
    
    override var activityImage: UIImage? {
        UIImage(systemName: "doc.on.clipboard")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        UIPasteboard.general.url = url
        UIPasteboard.general.string = url.absoluteString
        
        // Show success feedback
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let alert = UIAlertController(
                    title: nil,
                    message: self.localization.localizedString(for: "link_copied"),
                    preferredStyle: .alert
                )
                window.rootViewController?.present(alert, animated: true)
                
                // Auto dismiss after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    alert.dismiss(animated: true)
                }
            }
        }
        
        activityDidFinish(true)
    }
}

// MARK: - Enhanced ShareSheet with Custom Activities
struct EnhancedShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let shareURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    init(activityItems: [Any], shareURL: URL? = nil) {
        self.activityItems = activityItems
        self.shareURL = shareURL
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var applicationActivities: [UIActivity] = []
        
        // Add custom copy link activity if URL is available
        if let url = shareURL {
            applicationActivities.append(CopyLinkActivity(url: url))
        }
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // Exclude certain activity types if needed
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
