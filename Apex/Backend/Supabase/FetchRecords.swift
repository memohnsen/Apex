//
//  FetchRecords.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import Foundation
import Supabase

struct ApexRecords: Identifiable, Codable {
    var id: Int
    var category: String
    var event_name: String
    var gender: String
    var record_holder: String
    var record_value: String
    var instagram_handle: String?
}

@MainActor @Observable
class RecordsModel {
    var isLoading: Bool = false
    var error: Error?
    var records: [ApexRecords] = []
    
func fetchRecords(gender: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await supabase
                .from("apex_record_holders")
                .select()
                .eq("gender", value: gender)
                .execute()
            
            let row = try JSONDecoder().decode([ApexRecords].self, from: response.data)
            
            self.records.removeAll()
            self.records = row
            
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
