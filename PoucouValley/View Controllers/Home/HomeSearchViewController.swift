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
    var historySearches: [String] = [] {
        didSet {
            tableView.reloadRows(at: [IndexPath.init(row: 0, section: MenuSections.history.rawValue)], with: .none)
        }
    }

    var recents: [UnsplashSearchResult] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchResults: [UnsplashSearchResult]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var suggestions: [UnsplashTopic]?
    var deals: [UnsplashPhoto]?
    var stores: [UnsplashPhoto]?
    var categories: [UnsplashTopic]?
    
    weak var delegate: HomeExploreViewControllerDelegate?
    
    override func setup() {
        super.setup()
        
        let nib = UINib(nibName: "SearchSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SearchSectionHeaderView")
        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        historySearches = AppSettingsManager.shared.getSearchHistory()
        recents = AppSettingsManager.shared.getSearchRecents()
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
    
    @objc private func clearHistory() {
        historySearches = []
        AppSettingsManager.shared.setSearchHistory(searchHistory: [])
    }
    
    @objc private func clearRecents() {
        recents = []
        AppSettingsManager.shared.setSearchRecents(searchRecents: [])
    }
}

extension HomeSearchViewController: HomeSearchViewControllerDelegate {
    func requestToSearch(query: String?) {
        guard let query = query, !query.isEmpty else {
            self.query = ""
            self.searchResults = nil
            return
        }
        
        self.query = query
        api.getSearchCollections(query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.searchResults = response
                let maxCount = 5
                if response.count > maxCount {
                    self.recents = Array(response[(response.count - 1 - maxCount)...(response.count - 1)])
                } else {
                    self.recents = response
                }
                AppSettingsManager.shared.setSearchRecents(searchRecents: self.recents)
                
                if !self.historySearches.contains(query) {
                    self.historySearches.append(query)
                    let maxCount = 10
                    if self.historySearches.count > maxCount {
                        let count = self.historySearches.count
                        self.historySearches = Array(self.historySearches[(count - 1 - maxCount)...(count - 1)])
                    }
                    AppSettingsManager.shared.setSearchHistory(searchHistory: self.historySearches)
                }
                
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: MenuSections.results.rawValue), at: .top, animated: false)
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
        guard let section = MenuSections(rawValue: section) else { return 0 }
        
        switch section {
        case .history:
            if !query.isEmpty {
                return 0
            }
        case .recent:
            if !query.isEmpty {
                return 0
            }
        case .results:
            if query.isEmpty {
                return 0
            }
        case .suggested:
            if query.isEmpty {
                return 0
            }
        case .deals:
            if query.isEmpty {
                return 0
            }
        case .stores:
            if query.isEmpty {
                return 0
            }
        default:
            break
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = MenuSections(rawValue: section) else { return nil }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchSectionHeaderView") as! SearchSectionHeaderView
        
        header.titleLabel.text = section.title()
        header.clearButton.isHidden = !section.showClearButton()
        header.clearButton.removeTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        header.clearButton.removeTarget(self, action: #selector(clearRecents), for: .touchUpInside)
        
        switch section {
        case .history:
            header.clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        case .recent:
            header.clearButton.addTarget(self, action: #selector(clearRecents), for: .touchUpInside)
        default:
            break
        }
        
        return header
    }
    
    // We have only one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuSections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = MenuSections(rawValue: indexPath.section) else { return 0 }
        
        switch section {
        case .history:
            if !query.isEmpty {
                return 0
            }
        case .recent:
            if !query.isEmpty {
                return 0
            }
        case .results:
            if query.isEmpty {
                return 0
            }
        case .suggested:
            if query.isEmpty {
                return 0
            }
        case .deals:
            if query.isEmpty {
                return 0
            }
        case .stores:
            if query.isEmpty {
                return 0
            }
        default:
            break
        }
        
        return UITableView.automaticDimension
    }
    
    // One cell is enough
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = MenuSections(rawValue: section) else { return 0 }
        
        switch section {
        case .history:
            if query.isEmpty {
                return section.numberRows()
            }
            return 0
        case .recent:
            if query.isEmpty {
                return recents.count
            }
            
            return 0
            
        case .results:
            guard let searchResults = searchResults else {
                return 0
            }
            
            return max(1, searchResults.count)
            
        case .suggested:
            if query.isEmpty {
                return 0
            }
            
            return suggestions?.count ?? 0
            
        case .deals:
            if query.isEmpty {
                return 0
            }
            
            return section.numberRows()
            
        case .stores:
            if query.isEmpty {
                return 0
            }
            
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
            
            cell.config(histories: historySearches) { [weak self] searchString in
                guard let self = self else { return }
                
                self.requestToSearch(query: searchString)
                self.delegate?.updateSearchBarText(text: searchString)
            }
            
            return cell
            
        case .recent:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell else {
                return SearchResultCell()
            }
            let recentSearch = recents[indexPath.row]
            cell.config(result: recentSearch)
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
