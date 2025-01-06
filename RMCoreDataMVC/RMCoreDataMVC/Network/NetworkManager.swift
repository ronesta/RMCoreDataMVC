//
//  NetworkManager.swift
//  RMCoreDataMVC
//
//  Created by Ибрагим Габибли on 29.12.2024.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    var counter = 1

    let urlString = "https://rickandmortyapi.com/api/character"

    func getCharacters(completion: @escaping ([Character]?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil, NetworkError.invalidURL)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            guard let data else {
                print("No data")
                DispatchQueue.main.async {
                    completion(nil, NetworkError.noData)
                }
                return
            }

            do {
                let characters = try JSONDecoder().decode(PostCharacters.self, from: data)
                DispatchQueue.main.async {
                    completion(characters.results, nil)
                }
                print("Load data \(self.counter)")
                self.counter += 1
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }

    func fetchImage(from urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL for image")
            completion(nil, NetworkError.invalidURL)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("Failed to load image: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let data else {
                print("No data for image")
                completion(nil, NetworkError.noData)
                return
            }
            completion(data, nil)
        }.resume()
    }
}
