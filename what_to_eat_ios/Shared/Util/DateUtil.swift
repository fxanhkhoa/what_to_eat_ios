//
//  DateUtil.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 22/8/25.
//

import Foundation

struct DateUtil {
    
    // MARK: - Date Formatting
    
    /// Formats an ISO 8601 date string to a medium date style
    /// - Parameter dateString: The ISO 8601 date string (e.g., "2025-08-22T10:30:00.000Z")
    /// - Returns: A formatted date string (e.g., "Aug 22, 2025")
    static func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    /// Formats a Date object to a medium date style
    /// - Parameter date: The Date object to format
    /// - Returns: A formatted date string (e.g., "Aug 22, 2025")
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Formats an ISO 8601 date string to a relative time format (e.g., "2 hours ago")
    /// - Parameter dateString: The ISO 8601 date string
    /// - Returns: A relative time string
    static func formatRelativeDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .named
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        
        return dateString
    }
    
    /// Formats an ISO 8601 date string to a short date and time format
    /// - Parameter dateString: The ISO 8601 date string
    /// - Returns: A formatted date and time string (e.g., "8/22/25, 10:30 AM")
    static func formatDateTime(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}
