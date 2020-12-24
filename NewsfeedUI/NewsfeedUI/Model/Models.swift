//
//  Models.swift
//  NewsfeedUI
//
//  Created by Fatima Arshad on 12/22/20.
//

import Foundation

class NewsFeed: ObservableObject {
    @Published var general = [NewsArticle]()
    @Published var sports = [NewsArticle]()
    @Published var health = [NewsArticle]()
    @Published var entertainment = [NewsArticle]()

    /// For previews
    static var sampleData: [NewsArticle] {
        guard let pathString = Bundle(for: NewsFeed.self).path(forResource: Constants.ResponsePayload.everything, ofType: "json"),
              let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue),
              let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue),
              let response = try? JSONDecoder().decode(NewsApiResponse.self, from: jsonData) else {
            return []
        }

        return response.articles ?? []
    }

    init(mockResponses: Bool = false) {
        if mockResponses {
            startLoadingFromJSON()
        } else {
            startLoadingNewsFeeds()
        }
    }
}

// MARK: - Make API Call by hitting NewsAPI Endpoint
extension NewsFeed {
    /// Make API Call to fetch news feeds
    func startLoadingNewsFeeds() {
        if let generalUrl = URL(string: Constants.Endpoint.general) {
            URLSession.shared.dataTask(with: generalUrl) { (data, response, error) in
                let generalArticles = self.parseAPIResponse(data: data, response: response, error: error)
                DispatchQueue.main.async {
                    self.general.append(contentsOf: generalArticles)
                }
            }.resume()
        }

        if let sportsUrl = URL(string: Constants.Endpoint.sports) {
            URLSession.shared.dataTask(with: sportsUrl) { (data, response, error) in
                let sportsArticles = self.parseAPIResponse(data: data, response: response, error: error)
                DispatchQueue.main.async {
                    self.sports.append(contentsOf: sportsArticles)
                }
            }.resume()
        }

        if let healthUrl = URL(string: Constants.Endpoint.health) {
            URLSession.shared.dataTask(with: healthUrl) { (data, response, error) in
                let healthArticles = self.parseAPIResponse(data: data, response: response, error: error)
                DispatchQueue.main.async {
                    self.health.append(contentsOf: healthArticles)
                }
            }.resume()
        }

        if let entertainmentUrl = URL(string: Constants.Endpoint.entertainment) {
            URLSession.shared.dataTask(with: entertainmentUrl) { (data, response, error) in
                let entertainmentArticles = self.parseAPIResponse(data: data, response: response, error: error)
                DispatchQueue.main.async {
                    self.entertainment.append(contentsOf: entertainmentArticles)
                }
            }.resume()
        }
    }
    
    // MARK :- Parse API Response
    func parseAPIResponse(data: Data?, response: URLResponse?, error: Error?) -> [NewsArticle] {
        guard error == nil else {
            print("Error: \(error!)")
            return []
        }
        guard let data = data else {
            print("No data found to be displayed.")
            return []
        }
        
        return parseJSONData(data)
    }
}

// MARK: - Read from JSON File
extension NewsFeed {
    /// Load API Response from JSON File
    func startLoadingFromJSON() {
        guard let jsonData = readJsonFromFile(resourceName: Constants.ResponsePayload.everything) else { return }
        let mockArticles = parseJSONData(jsonData)

        self.general.append(contentsOf: mockArticles)
        self.sports.append(contentsOf: mockArticles)
        self.health.append(contentsOf: mockArticles)
        self.entertainment.append(contentsOf: mockArticles)
    }
    
    func readJsonFromFile(resourceName: String) -> Data? {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: resourceName, ofType: "json") else {
            return nil
        }
        guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        guard let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue) else {
            return nil
        }
        return jsonData
    }
}

// MARK:- Helper Method | Parse JSON Data
extension NewsFeed {
    private func parseJSONData(_ data: Data) -> [NewsArticle] {
        var response: NewsApiResponse
        do {
            response = try JSONDecoder().decode(NewsApiResponse.self, from: data)
        } catch {
            print("Error parsing the API response: \(error)")
            return []
        }
        
        if response.status != Constants.APIResponse.statusOK {
            print("API response status is not OK: \(response.status)")
            return []
        }

        return response.articles ?? []
    }
}

