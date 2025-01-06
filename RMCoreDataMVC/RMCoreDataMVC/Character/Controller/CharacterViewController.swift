//
//  ViewController.swift
//  RMCoreDataMVC
//
//  Created by Ибрагим Габибли on 29.12.2024.
//

import UIKit
import SnapKit
import CoreData

final class CharacterViewController: UIViewController {
    lazy var characterView: CharacterView = {
        let view = CharacterView(frame: .zero)
        return view
    }()

    let characterTableViewDataSource = CharacterTableViewDataSource()

    override func loadView() {
        super.loadView()
        view = characterView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        getCharacters()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        characterView.configureTableView(dataSource: characterTableViewDataSource)
    }

    private func setupNavigationBar() {
        title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
    }

    private func getCharacters() {
        self.characterTableViewDataSource.characters = CoreDataManager.shared.fetchCharacters()

        guard self.characterTableViewDataSource.characters.isEmpty else {
            DispatchQueue.main.async {
                self.characterView.tableView.reloadData()
            }
            return
        }

        NetworkManager.shared.getCharacters { [weak self] result, error in
            if let error {
                print("Error getting characters: \(error)")
                return
            }

            guard let result else {
                print("No result returned.")
                return
            }

            var charactersToSave: [(character: Character, imageData: Data)] = []

            let group = DispatchGroup()

            result.forEach { res in
                group.enter()
                NetworkManager.shared.fetchImage(from: res.image) { data, error in
                    if let error {
                        print("Failed to load image: \(error)")
                        return
                    }

                    guard let data else {
                        print("No data for image")
                        return
                    }

                    charactersToSave.append((character: res, imageData: data))

                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                CoreDataManager.shared.saveCharacters(charactersToSave)

                DispatchQueue.main.async {
                    self?.characterTableViewDataSource.characters = CoreDataManager.shared.fetchCharacters()
                    self?.characterView.tableView.reloadData()
                }
            }
        }
    }
}
