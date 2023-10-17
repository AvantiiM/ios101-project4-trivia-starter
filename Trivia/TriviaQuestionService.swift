//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Avanti Manjunath on 10/16/23.
//

import Foundation

class TriviaQuestionService {
    static func fetchTriviaQuestions(numQuestions: Int, completion: (([TriviaQuestion]) -> Void)? = nil) {
        let parameters = "amount=\(numQuestions)"
        let url = URL(string: "https://opentdb.com/api.php?\(parameters)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion?([])
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion?([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TriviaAPIResponse.self, from: data)
                completion?(response.results)
            } catch {
                print("Error decoding JSON: \(error)")
                completion?([])
            }
        }
        task.resume()
    }
    
    
    private static func parse(data: Data) -> [TriviaQuestion] {
        // Parse the JSON data into a dictionary
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            assertionFailure("Invalid JSON data structure")
            return []
        }

        // Extract the "results" array
        if let results = jsonDictionary["results"] as? [[String: Any]] {
            // Process each result in the array
            return results.map { result in
                let category = result["category"] as? String ?? ""
                let question = result["question"] as? String ?? ""
                let correctAnswer = result["correct_answer"] as? String ?? ""
                let incorrectAnswers = result["incorrect_answers"] as? [String] ?? []

                return TriviaQuestion(category: category, question: question, correctAnswer: correctAnswer, incorrectAnswers: incorrectAnswers)
            }
            
        } else {
            assertionFailure("No 'results' found in JSON data")
            // Handle the error gracefully or return an empty array of TriviaQuestion
            return []
        }
    }

    
}
