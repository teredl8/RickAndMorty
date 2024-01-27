//
//  ViewController.swift
//  RickAndMorty
//
//  Created by Tere Durán on 01/12/23.
//

import UIKit

class ViewController: UIViewController {
    var currentPage: Int = 1
    var totalPages: Int = 5
    
    let restClient = RESTClient<PaginatedResponse<Character>>(client: Client("https://rickandmortyapi.com"))
    var characters: [Character]? {
        didSet {
            table.reloadData()
        }
    }
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        
        loadPage(page: currentPage)
    }
    
    func loadPage(page: Int) {
        restClient.show("/api/character/", page: page) { [weak self] response in
            guard let self = self else { return }
            self.characters = response.results
            self.currentPage = page
            self.totalPages = response.info.pages
        }
    }
    
    @IBAction func prevPageButtonTapped(_ sender: Any) {
        if currentPage > 1 {
            loadPage(page: currentPage - 1)
        }
    }
    
    @IBAction func nextPageButtonTapped(_ sender: Any) {
        if currentPage < totalPages {
            loadPage(page: currentPage + 1)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = characters?[indexPath.row].name
        cell.detailTextLabel?.text = characters?[indexPath.row].species
        
        return cell
    }
}

