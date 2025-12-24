//
//  FetchResults.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import Foundation
import Supabase

struct ApexResults: Identifiable, Codable {
    var id: Int
    var event_name: String
    var date: String
    var athlete_rank: Int
    var athlete_name: String
    var apex_score: Int
    var gender: String
    var speed_score: Int
    var power_score: Int
    var strength_score: Int
    var endurance_score: Int
    var fast_forty: String
    var max_toss: String
    var the_vertical: String
    var the_broad: String
    var the_push: Int
    var the_pull: Int
    var the_mile: String
    var instagram_handle: String?
}

struct Events: Codable, Hashable {
    var event_name: String
    var date: String
}

struct Athletes: Codable, Hashable {
    var id: Int
    var athlete_name: String
}

@MainActor @Observable
class ResultsModel {
    var isLoading: Bool = false
    var error: Error?
    var results: [ApexResults] = []
    var eventResults: [ApexResults] = []
    var events: [Events] = []
    var athletes: [Athletes] = []
    var specificAthlete: [ApexResults] = []

    
    func fetchResults(gender: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_event_results")
                .select()
                .eq("gender", value: gender)
                .execute()
            
            let row = try JSONDecoder().decode([ApexResults].self, from: response.data)
            
            self.results.removeAll()
            self.results = row
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchResultsByEvent(gender: String, event: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_event_results")
                .select()
                .eq("event_name", value: event)
                .eq("gender", value: gender)
                .execute()
            
            let row = try JSONDecoder().decode([ApexResults].self, from: response.data)
            
            self.eventResults.removeAll()
            self.eventResults = row
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchEvents() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_event_results")
                .select("event_name, date")
                .execute()

            let row = try JSONDecoder().decode([Events].self, from: response.data)
            let deduplicated = Array(Set(row))
            
            self.events.removeAll()
            self.events = deduplicated
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchAthletes(gender: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_event_results")
                .select("id, athlete_name")
                .eq("gender", value: gender)
                .execute()
            
            let row = try JSONDecoder().decode([Athletes].self, from: response.data)
            
            self.athletes.removeAll()
            self.athletes = row
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchSpecificAthlete(name: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_event_results")
                .select()
                .eq("athlete_name", value: name)
                .execute()
            
            let row = try JSONDecoder().decode([ApexResults].self, from: response.data)
            
            self.specificAthlete.removeAll()
            self.specificAthlete = row
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
}
