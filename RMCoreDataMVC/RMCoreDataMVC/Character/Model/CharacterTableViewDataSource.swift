//
//  CharacterTableViewDataSource.swift
//  RMCoreDataMVC
//
//  Created by Ибрагим Габибли on 06.01.2025.
//

import Foundation
import UIKit

final class CharacterTableViewDataSource: NSObject, UITableViewDataSource {
    var characters = [Entity]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CharacterTableViewCell.id,
            for: indexPath) as? CharacterTableViewCell else {
            return UITableViewCell()
        }

        let character = characters[indexPath.row]

        guard let imageData = CoreDataManager.shared.fetchImageData(forCharacterId: character.id),
              let image = UIImage(data: imageData) else {
            return cell
        }

        cell.configure(with: character, image: image)

        return cell
    }
}
