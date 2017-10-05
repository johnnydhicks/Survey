//
//  EmojiController.swift
//  Survey v2
//
//  Created by Johnny Hicks on 10/5/17.
//  Copyright © 2017 Hicks Enterprises. All rights reserved.
//

import Foundation

class SurveyController {
    static let shared = SurveyController()
    
    // MARK: - SOURCE FO TRUTH
    var surveys: [Survey] = []
    
    private let baseURL = URL(string: "https://favemoji.firebaseio.com/")
    
    func putSurvey(with name: String, emoji: String, completion: @escaping(_ success: Bool) -> Void){
        
        // Create an instance of Survey
        let survey = Survey(name: name, emoji: emoji)
        
        guard let url = baseURL else { fatalError("BAD URL")}
        
        // Build the url
        let requestURL = url.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        request.httpBody = survey.jsonData
    
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
        
        var success = false
        
        defer { completion(success) }
        
            if let error = error {
                print("Brian broke our request \(error.localizedDescription) \(#function)")
    }
            guard let data = data,
                let responseDataString = String(data: data, encoding: .utf8) else { return }
            if let error = error {
                print("Error: \(error.localizedDescription) \(#function)")
            } else {
                print("Sucdcessfully saved data to endpoint: \(responseDataString)")
            }
            
            self.surveys.append(survey)
            
            success = true
        }
        dataTask.resume()
    }
    
    
    func fetchData(completion: @escaping ([Survey]?) -> Void) {
        
        guard let url = baseURL?.appendingPathExtension("json") else { print("Bad baseURL"); completion([]); return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error { print("Error fetching \(error.localizedDescription) \(#function) \(#file)"); completion([]); return }
            
            guard let data = data else { print("No data returned from data task"); completion([]); return }
            
            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: String]]) else { print("Fetching from JSONObject"); completion([]); return }
            
            guard let surveys = jsonDictionary?.flatMap( { Survey(dictionary: $0.value, identifier: $0.key) }) else { return }
            
            self.surveys = surveys
            completion(surveys)
        }.resume()
    }
}
