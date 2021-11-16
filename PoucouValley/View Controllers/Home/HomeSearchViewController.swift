//
//  HomeSearchViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

protocol HomeSearchViewControllerDelegate: class {
    func requestToSearch(query: String?)
}

class HomeSearchViewController: BaseViewController {

    enum MenuSections: Int {
        case history
        case recent
        case results
        case suggested
        case deals
        case stores
        case count
        
        func title() -> String {
            switch self {
            case .history:
                return "History"
            case .recent:
                return "Recent"
            case .results:
                return "Results"
            case .suggested:
                return "More searches to try"
            case .deals:
                return "Deals"
            case .stores:
                return "Stores"
            default:
                return ""
            }
        }
        
        func showClearButton() -> Bool {
            switch self {
            case .history:
                return true
            case .recent:
                return true
            case .results:
                return false
            case .suggested:
                return false
            case .deals:
                return false
            case .stores:
                return false
            default:
                return false
            }
        }
        
        func numberRows() -> Int {
            switch self {
            case .history:
                return 1
            case .recent:
                return 0
            case .results:
                return 0
            case .suggested:
                return 0
            case .deals:
                return 1
            case .stores:
                return 1
            default:
                return 0
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var query: String = ""
    var historySearches: [String]? {
        didSet {
            tableView.reloadRows(at: [IndexPath.init(row: 0, section: MenuSections.history.rawValue)], with: .none)
        }
    }
    var recentSearches: [UnsplashPhoto]?
    var searchResults: [UnsplashSearchResult]?
    var suggestions: [UnsplashTopic]?
    var deals: [UnsplashPhoto]?
    var stores: [UnsplashPhoto]?
    var categories: [UnsplashTopic]?
    
    override func setup() {
        super.setup()
        
        let nib = UINib(nibName: "SearchSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SearchSectionHeaderView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchContent()
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        api.getDeals { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.deals = response
                self.tableView.reloadData()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
        
        api.getStores{ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.stores = response
                self.tableView.reloadData()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
        
        api.getCommonKeywords{ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.suggestions = response
                self.tableView.reloadData()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
        
        api.getCategories{ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.categories = response
                self.tableView.reloadData()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
}

extension HomeSearchViewController: HomeSearchViewControllerDelegate {
    func requestToSearch(query: String?) {
        guard let query = query else { return }
        
        self.query = query
        api.getSearchCollections(query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.searchResults = response
                self.tableView.reloadData()
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
}

extension HomeSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = MenuSections(rawValue: section) else { return nil }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchSectionHeaderView") as! SearchSectionHeaderView
        header.titleLabel.text = section.title()
        header.clearButton.isHidden = !section.showClearButton()
        return header
    }
    
    // We have only one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuSections.count.rawValue
    }
    
    // One cell is enough
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = MenuSections(rawValue: section) else { return 0 }
        
        switch section {
        case .history:
            return section.numberRows()
        case .recent:
            return recentSearches?.count ?? 0
        case .results:
            return max(1, searchResults?.count ?? 0)
        case .suggested:
            return suggestions?.count ?? 0
        case .deals:
            return section.numberRows()
        case .stores:
            return section.numberRows()
        default:
            return 0
        }
    }
    
    // Cell creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = MenuSections(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .history:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoriesCell", for: indexPath) as? SearchHistoriesCell else {
                return SearchHistoriesCell()
            }
            
            cell.config(histories: historySearches ?? [])
            
            return cell
        case .recent:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell, let recentSearch = recentSearches?[indexPath.row] else {
                return SearchResultCell()
            }
            
            cell.config(unsplashPhoto: recentSearch)
            return cell
        case .results:
            
            guard let searchResults = searchResults else {
                return SearchResultCell()
            }
            
            if searchResults.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchNoResultCell", for: indexPath) as? SearchNoResultCell else {
                    return SearchNoResultCell()
                }
                cell.config(keyWord: query)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell else {
                    return SearchResultCell()
                }
                let searchResult = searchResults[indexPath.row]
                cell.config(result: searchResult)
                return cell
            }
            
        case .suggested:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchSuggestionCell", for: indexPath) as? SearchSuggestionCell, let suggestion = suggestions?[indexPath.row] else {
                return SearchSuggestionCell()
            }
            
            cell.config(suggestion: suggestion)
            return cell
            
        case .deals:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDealsCell", for: indexPath) as? SearchDealsCell, let deals = deals, let categories = categories, !categories.isEmpty else {
                return SearchDealsCell()
            }
            
            cell.config(deals: deals, categories: categories)
            return cell
            
        case .stores:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchStoresCell", for: indexPath) as? SearchStoresCell, let stores = stores else {
                return SearchStoresCell()
            }
            
            cell.config(stores: stores)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }

}
