//
//  CompleteMyProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit
import RealmSwift

enum SetupSteps: Int {
    case gender
    case birthday
    case address
    case phone
    case completed
    
    func getGoalName() -> String? {
        switch self {
        case .gender:
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
    
    static func getSetupStepFrom(goal: Goal) -> SetupSteps? {
        switch goal.goal {
        case "Add gender to profile":
            return .gender
        case "Add birthday to profile":
            return .birthday
        case "Add address to profile":
            return .address
        case "Add phone number to profile":
            return .phone
        default:
            return nil
        }
    }
}

class CompleteMyProfileViewController: BaseViewController, SetGendersCellDelegate, SetBirthdayCellDelegate, SetAddressCellDelegate, SetPhoneCellDelegate {
    
    
    @IBOutlet var progressBars: [UIView]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: ThemeRoundedGreenBlackTextButton!
    
    private var steps: [SetupSteps] {
        guard let goals = goals else { return [] }
        
        var array: [SetupSteps]  = []
        for goal in goals {
            if let step = SetupSteps.getSetupStepFrom(goal: goal) {
                array.append(step)
            }
        }
        array.append(.completed)
        return array
    }
    
    private var currentStepIndex: Int = 0 {
        didSet {
            if steps.first == .completed {
                nextButton.setTitle("Hooray", for: .normal)
            } else if currentStepIndex == (steps.count - 1) {
                nextButton.setTitle("Finish", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
            for progressBar in progressBars {
                if progressBar.tag <= currentStepIndex  {
                    progressBar.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
                } else {
                    progressBar.backgroundColor = .lightGray
                }
            }
            tableView.reloadData()
        }
    }
    private var goals: [Goal]?
    private var completedGoals: [Goal]?
    private var imcompletedGoals: [Goal]? {
        guard let goals = goals, let completedGoals = completedGoals else {
            return nil
        }
        
        return goals.filter { goal in
            return !completedGoals.contains{ $0.goal == goal.goal }
        }
    }
    
    private var gender: String?
    private var birthday: Birthday?
    private var address: Address?
    private var contact: Contact?
    
    override func setup() {
        super.setup()
        
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
        
        navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableView),
                                               name: Notifications.RequestTableViewUpdate,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.RequestTableViewUpdate, object: nil)
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
                case .success(let response):
                    if response.success {
                        self?.goals = Array(response.data)
                    } else {
                        showErrorDialog(error: response.message)
                        isSuccess = false
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
                case .success(let response):
                    if response.success {
                        self?.completedGoals = Array(response.data)
                    } else {
                        showErrorDialog(error: response.message)
                        isSuccess = false
                    }
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
        switch steps[currentStepIndex] {
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
        
        FullScreenSpinner().show()
        let currentStep = steps[currentStepIndex]
        
        switch currentStep {
        case .gender:
            userManager.updateCardholderInfo(gender: gender) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self?.currentStepIndex += 1
                    self?.markGoalAsComplete(step: currentStep)
                case .failure:
                    break
                }
            }
        case .birthday:
            userManager.updateCardholderInfo(birthday: birthday) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self?.currentStepIndex += 1
                    self?.markGoalAsComplete(step: currentStep)
                case .failure:
                    break
                }
            }
        case .address:
            userManager.updateCardholderInfo(address: address) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self?.currentStepIndex += 1
                    self?.markGoalAsComplete(step: currentStep)
                case .failure:
                    break
                }
            }
        case .phone:
            userManager.updateCardholderInfo(contact: contact) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success:
                    self?.currentStepIndex += 1
                    self?.markGoalAsComplete(step: currentStep)
                case .failure:
                    break
                }
            }
        case .completed:
            navigationController?.popViewController(animated: true)
        }
        
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
    
    @objc private func updateTableView() {
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    private func markGoalAsComplete(step: SetupSteps, complete: ((Bool) -> Void)? = nil) {
        let completedGoal = goals?.filter({ goal in
            return goal.goal == step.getGoalName()
        }).first
        
        guard let completedGoal = completedGoal else {
            return
        }
        
        api.addAccomplishment(goal: completedGoal) { result in
            switch result {
            case .success(let response):
                if response.success {
                    complete?(true)
                } else {
                    showErrorDialog(error: response.message ?? "Unknown error")
                    complete?(false)
                }
            case .failure:
                showNetworkErrorDialog()
                complete?(false)
            }
        }
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
        guard let cardholder = currentUser.cardholder, !steps.isEmpty else { return UITableViewCell() }
        
        let step = steps[currentStepIndex]
        
        switch step {
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
