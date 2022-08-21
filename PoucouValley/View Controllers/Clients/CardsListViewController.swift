//
//  CardsListViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-11.
//

import UIKit
import CRRefresh

class CardsListViewController: BaseViewController {
    
    @IBOutlet weak var searchBar: ThemeSearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var cards: [Card]? {
        didSet {
            shouldSearch(text: searchBar.text ?? "")
        }
    }
    
    private var showingCards: [Card] = []
    private var delayTimer = DelayedSearchTimer()

    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        delayTimer.delegate = self
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        loadData()
    }
    
    private func loadData() {
        cards == nil ? FullScreenSpinner().show() : nil
        
        api.fetchMerchantCards { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.tableView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success {
                    let cards = Array(response.data)
                    self.cards = cards
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }

}

extension CardsListViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        guard let cards = cards else {
            return
        }
        
        if text.count > 2 {
            showingCards = cards.filter({ card in
                return card.number.contains(string: text)
            })
        } else {
            showingCards = cards
        }
        showingCards = showingCards.sorted(by: { leftCard, rightCard in
            return leftCard.number < rightCard.number
        })
        
        tableView.reloadData()
    }
}

extension CardsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, showingCards.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingCards.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as? CardTableViewCell else {
            return CardTableViewCell()
        }
        let card = showingCards[indexPath.row]
        cell.config(card: card)
        return cell
    }
}
