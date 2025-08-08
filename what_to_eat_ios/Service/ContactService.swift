//
//  ContactService.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 8/8/25.
//

import Foundation
import Combine

class ContactService {
    private let endpoint = "contact"
    private var cancellables = Set<AnyCancellable>()
    
    // Shared instance (singleton pattern)
    static let shared = ContactService()
    
    private init() {}
    
    // MARK: - Find All Contacts
    func findAll(dto: QueryContactDto) -> AnyPublisher<ContactResponse, Error> {
        let queryParams = dto.toQueryParameters()
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/\(endpoint)")!
        
        // Add query parameters
        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if needed
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ContactResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Create Contact
    func create(dto: CreateContactDto) -> AnyPublisher<Contact, Error> {
        let url = URL(string: "\(APIConstants.baseURL)/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if needed
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode the request body
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(dto)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Contact.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Update Contact
    func update(id: String, dto: UpdateContactDto) -> AnyPublisher<Contact, Error> {
        let url = URL(string: "\(APIConstants.baseURL)/\(endpoint)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if needed
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode the request body
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(dto)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Contact.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Find One Contact
    func findOne(id: String) -> AnyPublisher<Contact, Error> {
        let url = URL(string: "\(APIConstants.baseURL)/\(endpoint)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if needed
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Contact.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Contact
    func delete(id: String) -> AnyPublisher<Contact, Error> {
        let url = URL(string: "\(APIConstants.baseURL)/\(endpoint)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication if needed
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Contact.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
