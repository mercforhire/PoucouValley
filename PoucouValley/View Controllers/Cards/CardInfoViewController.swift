//
//  CardInfoViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-24.
//

import UIKit

class CardInfoViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var points: [PoucouCardBulletPoint] = []
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    private func loadData() {
        FullScreenSpinner().show()
        
        api.fetchPoucouCardBulletPoints() { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let result):
                self?.points = Array(result.data)
                self?.tableView.reloadData()
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
}

extension CardInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let point = points[indexPath.row]
        if point.iconName == nil, point.subtitle == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableCell", for: indexPath) as! LabelTableCell
            cell.headerLabel.text = point.title
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IconLabelsCell", for: indexPath) as! IconLabelsCell
            cell.icon.image = UIImage(named: point.iconName ?? "") ?? UIImage(systemName: "keyboard.chevron.compact.left")
            cell.label.text = point.title
            cell.label2.text = point.subtitle
            return cell
        }
    }
}
