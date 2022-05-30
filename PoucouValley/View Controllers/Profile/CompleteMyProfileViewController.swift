//
//  CompleteMyProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit
import RealmSwift

class CompleteMyProfileViewController: BaseViewController, SetPronounsCellDelegate, SetGendersCellDelegate, SetBirthdayCellDelegate, SetAddressCellDelegate, SetPhoneCellDelegate {
    
    private enum SetupSteps: Int {
        case pronoun
        case gender
        case birthday
        case address
        case phone
        case completed
        
        func getGoalName() -> String? {
            switch self {
            case .pronoun, .gender:
                return "Add gender to profile"
            case .birthday:
                return "Add birthday to profile"
            case .address:
                return "Add address to profile"
            case .phone:
                return "Add phone number to profile"
            default:
                break
            }
            return nil
        }
        
        static func goalsNames() -> [String] {
            return [SetupSteps.gender.getGoalName()!, SetupSteps.birthday.getGoalName()!,  SetupSteps.address.getGoalName()!,
                    SetupSteps.phone.getGoalName()!]
        }
        
        static func goals() -> [SetupSteps] {
            return [.gender, .birthday, .address, .phone]
        }
    }
    
    @IBOutlet var progressBars: [UIView]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: ThemeRoundedGreenBlackTextButton!
    
    private var steps: [SetupSteps] = [.completed]
    private var currentStep: Int = 0 {
        didSet {
            if steps.first == .completed {
                nextButton.setTitle("Hooray", for: .normal)
            } else if currentStep == (steps.count - 1) {
                nextButton.setTitle("Finish", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
            switch steps[currentStep] {
            case .pronoun:
                for progressBar in progressBars {
                    progressBar.backgroundColor = .lightGray
                }
            case .gender:
                for progressBar in progressBars {
                    progressBar.backgroundColor = .lightGray
                }
            case .birthday:
                for progressBar in progressBars {
                    if progressBar.tag == 0  {
                        progressBar.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
                    } else {
                        progressBar.backgroundColor = .lightGray
                    }
                }
            case .address:
                for progressBar in progressBars {
                    if progressBar.tag == 0 || progressBar.tag == 1 {
                        progressBar.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
                    } else {
                        progressBar.backgroundColor = .lightGray
                    }
                }
            case .phone:
                for progressBar in progressBars {
                    if progressBar.tag == 0 || progressBar.tag == 1 || progressBar.tag == 2 {
                        progressBar.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
                    } else {
                        progressBar.backgroundColor = .lightGray
                    }
                }
            case .completed:
                for progressBar in progressBars {
                    progressBar.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
                }
            }
            tableView.reloadData()
        }
    }
    private var goals: [Goal]?
    private var completedGoals: [Goal]?
    
    private var pronoun: String?
    private var gender: String?
    private var birthday: Birthday?
    private var address: Address?
    private var contact: Contact?
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        
        pronoun = currentUser.cardholder?.pronoun
        gender = currentUser.cardholder?.gender
        birthday = currentUser.cardholder?.birthday
        address = currentUser.cardholder?.address
        contact = currentUser.cardholder?.contact
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
        for progressBar in progressBars {
            progressBar.backgroundColor = .lightGray
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadData() {
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.fetchGoals() { [weak self] result in
                switch result {
                case .success(let result):
                    self?.goals? = []
                    for goal in Array(result.data) {
                        if SetupSteps.goalsNames().contains(goal.goal) {
                            self?.goals?.append(goal)
                        }
                    }
                case .failure:
                    showNetworkErrorDialog()
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.api.fetchCompletedGoals { [weak self] result in
                switch result {
                case .success(let result):
                    self?.completedGoals = Array(result.data)
                case .failure:
                    showNetworkErrorDialog()
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                if isSuccess {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func validateCurrentStep() -> Bool {
        switch steps[currentStep] {
        case .pronoun:
            return pronoun != nil
        case .gender:
            return gender != nil
        case .birthday:
            return birthday != nil
        case .address:
            return address?.isComplete() ?? false
        case .phone:
            return !(contact?.phoneAreaCode?.isEmpty ?? true) && !(contact?.phoneNumber?.isEmpty ?? true)
        default:
            return true
        }
    }
    
    @IBAction private func nextPressed(_ sender: ThemeRoundedGreenBlackTextButton) {
        if !validateCurrentStep() {
            return
        }
        
        switch steps[currentStep] {
        case .pronoun:
            userManager.updateCardholderInfo(pronoun: pronoun) { [weak self] result in
                switch result {
                case .success:
                    self?.currentStep += 1
                case .failure:
                    break
                }
            }
        case .gender:
            userManager.updateCardholderInfo(gender: gender) { [weak self] result in
                switch result {
                case .success:
                    self?.currentStep += 1
                case .failure:
                    break
                }
            }
        case .birthday:
            userManager.updateCardholderInfo(birthday: birthday) { [weak self] result in
                switch result {
                case .success:
                    self?.currentStep += 1
                case .failure:
                    break
                }
            }
        case .address:
            userManager.updateCardholderInfo(address: address) { [weak self] result in
                switch result {
                case .success:
                    self?.currentStep += 1
                case .failure:
                    break
                }
            }
        case .phone:
            userManager.updateCardholderInfo(contact: contact) { [weak self] result in
                switch result {
                case .success:
                    self?.currentStep += 1
                case .failure:
                    break
                }
            }
        default:
            break
        }
        
    }
    
    func setPronounsCellUpdated(pronoun: String?) {
        self.pronoun = pronoun
    }
    
    func setGendersCellUpdated(gender: String?) {
        self.gender = gender
    }
    
    func setBirthdayCellUpdated(birthday: Birthday?) {
        self.birthday = birthday
    }
    
    func setAddressCellAddressUpdated(address: Address) {
        self.address = address
    }
    
    func setPhoneCellPhoneUpdated(contact: Contact) {
        self.contact = contact
    }
    
    private func getProgressBarView(nth: Int) -> UIView? {
        for view in progressBars {
            if view.tag == nth {
                return view
            }
        }
        
        return nil
    }
}

extension CompleteMyProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cardholder = currentUser.cardholder else { return UITableViewCell() }
        
        let step = steps[currentStep]
        
        switch step {
        case .pronoun:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPronounsCell", for: indexPath) as? SetPronounsCell else {
                return SetPronounsCell()
            }
            cell.config(data: cardholder)
            cell.delegate = self
            return cell
        case .gender:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetGendersCell", for: indexPath) as? SetGendersCell else {
                return SetGendersCell()
            }
            cell.config(data: cardholder)
            cell.delegate = self
            return cell
        case .birthday:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetBirthdayCell", for: indexPath) as? SetBirthdayCell else {
                return SetBirthdayCell()
            }
            cell.config(data: cardholder.birthday)
            cell.delegate = self
            return cell
        case .address:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetAddressCell", for: indexPath) as? SetAddressCell else {
                return SetAddressCell()
            }
            cell.config(data: cardholder.address)
            cell.delegate = self
            return cell
        case .phone:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPhoneCell", for: indexPath) as? SetPhoneCell else {
                return SetPhoneCell()
            }
            cell.config(data: cardholder.contact)
            cell.delegate = self
            return cell
        case .completed:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCompleteCell", for: indexPath) as? ProfileCompleteCell else {
                return ProfileCompleteCell()
            }
            return cell
        }
    }
}
