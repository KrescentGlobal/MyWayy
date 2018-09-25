//
//  AddActivitiesViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/30/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
class ActivityViewCell: UICollectionViewCell {
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityIconImage: UIImageView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var activitySelectedCheckmark: UIImageView!
}

class ActivityCollectionViewModel {
    let activityTemplate: ActivityTemplate
    var selected = false
    init(activity: ActivityTemplate) {
        self.activityTemplate = activity
    }
}

class SelectedActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var selectedActivityIcon: UIImageView!
    @IBOutlet weak var selectedActivityIconBackground: UIView!
    @IBOutlet weak var selectedActivityName: UILabel!
    @IBOutlet weak var selectedActivityDuration: UILabel!
}

class AddActivitiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, BusyOverlayOwner {
    static let storyboardId = String(describing: AddActivitiesViewController.self)
    weak var routineCreationDelegate: RoutineCreationDelegate?
    var arrSelectedActivities = [Dictionary<String, String>]()
    /// Set this when a new routine template is being created
    var routineTemplate: RoutineTemplate?
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    /// Set this when a routine and its template are being edited
    var routine: Routine? {
        didSet {
            guard let r = routine else {
                return
            }
            isEdit = true
            routineTemplate = r.getTemplate()
            guard routineTemplate != nil else {
                logError("Canot get routine template!")
                return
            }
        }
    }
    private var isEdit = false
    private var totalDurationTime = 0

    @IBOutlet weak var startTimeCalculatedLabel: UILabel!
    @IBOutlet private weak var startTimeCalculated: UILabel!
    @IBOutlet private weak var durationTimeCalculatedLabel: UILabel!
    @IBOutlet private weak var durationTimeCalculated: UILabel!
   
//    @IBOutlet private weak var activitiesSearchBar: UISearchBar!
    var shouldUp = false
    @IBOutlet private weak var activitiesCollectionView: UICollectionView!
    @IBOutlet private weak var selectedActivitiesTableView: UITableView!
    @IBOutlet private weak var selectedActivitiesTableViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var selectedActivitiesHeaderView: UIView!
    @IBOutlet private weak var selectedActivitiesHeaderTitleLabel: UILabel!
     @IBOutlet private weak var startTimeCalculatedHeaderLabel: UILabel!
     @IBOutlet private weak var startTimeCalculatedHeader: UILabel!
   
    @IBOutlet weak var mainView: UIView!
    @IBOutlet private weak var numSelectedActivitiesHeaderTitleLabel: UILabel!
    var dict : [Int : Int] = [Int: Int]()
    
    var activityTemplates = [ActivityTemplate]() {
        didSet {
            if masterActivityCollectionViewModels.isEmpty {
                masterActivityCollectionViewModels = activityTemplates.map { (thisActivityTemplate) in
                    let model = ActivityCollectionViewModel(activity: thisActivityTemplate)

                    // When editing a routine, determine which activities are selected to begin with
                    if let r = routine, r.hasActivity(with: thisActivityTemplate.id) {
                        model.selected = true
                        let selection = RtaSelectionModel(routineId: r.id,
                                                          routineTemplateId: routineTemplate?.id,
                                                          activityTemplateId: thisActivityTemplate.id,
                                                          activityTemplateDuration: thisActivityTemplate.duration,
                                                          activityTemplateVersion: thisActivityTemplate.version)
                        addSelection(selection)
                    }

                    return model
                }
                workingActivityCollectionViewModels = masterActivityCollectionViewModels
 
                rtaSelections = RtaSelectionModel.sort(models: rtaSelections, accordingTo: routineTemplate)
            } else {
                if activityTemplates.count != masterActivityCollectionViewModels.count {
                    let newActivity = ActivityCollectionViewModel(activity: activityTemplates.last!)
                    newActivity.selected = true
                    masterActivityCollectionViewModels.append(newActivity)
                    workingActivityCollectionViewModels.append(newActivity)
                    let selection = RtaSelectionModel(routineId: routine?.id,
                                                      routineTemplateId: routineTemplate?.id,
                                                      activityTemplateId: newActivity.activityTemplate.id,
                                                      activityTemplateDuration: newActivity.activityTemplate.duration,
                                                      activityTemplateVersion: newActivity.activityTemplate.version)
                    addSelection(selection)
                }
            }
        }
    }
    
    var masterActivityCollectionViewModels = [ActivityCollectionViewModel]()
    var workingActivityCollectionViewModels = [ActivityCollectionViewModel]()
    var rtaSelections = [RtaSelectionModel]()
    var dictOfCollectionIndex : [Int] = [Int]()
    var activitiesTableViewExpanded = false
    var expandedActivitiesTableViewCellHeight = 56
    var maximimSelectedActivitiesTableViewHeight = (UIScreen.main.bounds.height * 0.6)
    
    let overlay = BusyOverlayView.create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        setupHeaderLabels()
        setupActivitiesCollectionView()
        setupTableViewHeaderLabels()
        selectedActivitiesTableView.setEditing(true, animated: true)
        selectedActivitiesTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateContent()
        blurView.backgroundColor = UIColor(red: 242.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: 0.8)
    }

    fileprivate func updateContent() {
        guard let activityTemplates = MyWayyService.shared.profile?.activityTemplates else {
            print("Error: no activity templates")
            return
        }
        self.activityTemplates = activityTemplates
        activitiesCollectionView.reloadData()
        selectedActivitiesTableView.reloadData()
        updateDurationAndStartTime()
    }
    
    
    func setupHeaderLabels() {
        self.title = "SET UP WAYY"
    }
    
    func setupActivitiesCollectionView() {
        activitiesCollectionView.delegate = self
        activitiesCollectionView.dataSource = self
        activitiesCollectionView.allowsMultipleSelection = true
    }
    
    func setupTableViewHeaderLabels() {
        selectedActivitiesTableView.layer.borderWidth = 1
        selectedActivitiesTableView.layer.borderColor = UIColor.paleGrey.cgColor
        selectedActivitiesHeaderTitleLabel.text = NSLocalizedString("ACTIVITIES SELECTED", comment: "")
        startTimeCalculatedHeaderLabel.text = NSLocalizedString("Start Time:", comment: "")
        selectedActivitiesHeaderView.layer.masksToBounds = false
        selectedActivitiesHeaderView.layer.shadowRadius = 6
        selectedActivitiesHeaderView.layer.shadowOffset = CGSize.zero
        selectedActivitiesHeaderView.layer.shadowOpacity = Float(Alpha.shadowLow)
        selectedActivitiesHeaderView.layer.shadowColor = UIColor.black.cgColor
        
        let swipeup = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeup.direction = UISwipeGestureRecognizerDirection.up
        selectedActivitiesHeaderView.addGestureRecognizer(swipeup)
        
        let swipedown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipedown.direction = UISwipeGestureRecognizerDirection.down
        selectedActivitiesHeaderView.addGestureRecognizer(swipedown)
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                if rtaSelections.count > 0{
                    nextButton.isHidden = true
                    shouldUp = true
                    toggleExpandTableView()
                }
                
               
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                nextButton.isHidden = false
                selectedActivitiesTableViewHeight.constant = 0
                view.removeBlurToBackground(view: self.view, blurView: blurView)
                shouldUp = false
                
            default:
                break
            }
        }
    }
    @IBAction func backAc(_ sender: Any) {
         navigationController?.popViewController(animated: true)
    }
    
    @IBAction func next(_ sender: UIButton) {
        showOverlay()

        if isEdit {
            saveEditedRoutine()
        } else {
            saveNewRoutine()
        }
    }

    // MARK: Backend save/edit methods

    private func saveNewRoutine() {
        saveRoutineTemplateActivities(old: nil, selections: rtaSelections) { (success, error) in
            guard success else {
                logError(String(describing: error?.localizedDescription))
                self.completeServerUpdates(for: nil, success, error)
                return
            }

            var routineFields = [String: Any]()
            routineFields["profile"] = MyWayyService.shared.profile?.id
            routineFields["routineTemplate"] = self.routineTemplate?.id
            routineFields["endTime"] = self.routineTemplate?.endTime
            routineFields["sunday"] = self.routineTemplate?.sunday
            routineFields["monday"] = self.routineTemplate?.monday
            routineFields["tuesday"] = self.routineTemplate?.tuesday
            routineFields["wednesday"] = self.routineTemplate?.wednesday
            routineFields["thursday"] = self.routineTemplate?.thursday
            routineFields["friday"] = self.routineTemplate?.friday
            routineFields["saturday"] = self.routineTemplate?.saturday
            routineFields["alertStyle"] = self.routineTemplate?.alertStyle
            routineFields["reminder"] = self.routineTemplate?.reminder
            routineFields["image"] = self.routineTemplate?.image
            let routine = Routine(routineFields)

            MyWayyService.shared.createRoutine(routine, { (success, error) in
                self.completeServerUpdates(for: routine, success, error)
            })
        }
    }

    private func saveEditedRoutine() {
        guard let r = routine, let template = routineTemplate else {
            logError()
            hideOverlay()
            return
        }

        saveRoutineTemplateActivities(old: template.routineTemplateActivities, selections: rtaSelections) { (success, error) in
            guard success else {
                logError(String(describing: error?.localizedDescription))
                self.completeServerUpdates(for: r, success, error)
                return
            }

            // Update the routine template on the server
            // Increment the version since updating routineTemplateActivities doesn't do so automatically.
            template.maybeIncrementVersion()
            MyWayyService.shared.updateRoutineTemplate(template: template, { (templateSuccess, templateError) in
                guard templateSuccess else {
                    logError(String(describing: templateError?.localizedDescription))
                    self.completeServerUpdates(for: r, templateSuccess, templateError)
                    return
                }

                // Update the routine fields according to the template changes.
                RoutineHelper.updateFields(for: r, from: template)

                // Update the routine on the server
                MyWayyService.shared.updateRoutine(routine: r, { (routineSuccess, routineError) in
                    self.completeServerUpdates(for: r, routineSuccess, routineError)
                })
            })
        }
    }

   
    private func saveRoutineTemplateActivities(old oldRtas: [RoutineTemplateActivity]?,
                                               selections rtaSelections: [RtaSelectionModel],
                                               mainThreadCompletion: @escaping (Bool, NSError?)->()) {
        let processor = RtaProcessor(oldRtas: oldRtas, selections: rtaSelections)

        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            let routineTemplateActivityGroup = DispatchGroup()
            let leaveGroup: (Int, Bool, NSError?) -> Void = { (lineNumber, success, error) in
                if !success {
                    logError("Line \(lineNumber): \(String(describing: error?.localizedDescription)): \(String(describing: error?.userInfo)))")
                }
                routineTemplateActivityGroup.leave()
            }

            processor.rtasToDelete.forEach { (template) in
                // Delete this RoutineTemplateActivity
                routineTemplateActivityGroup.enter()
                MyWayyService.shared.deleteRoutineTemplateActivity(template: template, { (success, error) in
                    guard success else {
                        leaveGroup(#line, success, error)
                        return
                    }
                    // Find the related Activity and delete it
                    guard let activity = self.getActivity(with: template.activityTemplate) else {
                        leaveGroup(#line, success, error)
                        return
                    }
                    MyWayyService.shared.deleteActivity(activity: activity) { (success, error) in
                        leaveGroup(#line, success, error)
                    }
                })
            }

            for (order,selection) in processor.rtaSelections.enumerated() {
                let template = selection.routineTemplateActivity
                template.displayOrder = order+1

                // Lack of an ID indicates creation
                if template.id == nil {
                    routineTemplateActivityGroup.enter()
                    // template.routineTemplate is validated above!
                    MyWayyService.shared.createRoutineTemplateActivity(with: template, routineTemplateId: selection.routineTemplateId) { (success, error) in
                        if !success || !self.isEdit {
                            leaveGroup(#line, success, error)
                        } else {
                            if let rtaId = template.routineTemplate,
                               let newActivity = selection.generateNewActivity(routineTemplateActivityId: rtaId) {
                                MyWayyService.shared.createActivity(newActivity, { (success, error) in
                                    leaveGroup(#line, success, error)
                                })
                            } else {
                                leaveGroup(#line, false, nil)
                            }
                        }
                    }
                } else if template.hasUpdates() {
                    routineTemplateActivityGroup.enter()
                    MyWayyService.shared.updateRoutineTemplateActivity(template: template) { (success, error) in
                        leaveGroup(#line, success, error)
                    }
                }
            }

            routineTemplateActivityGroup.notify(queue: DispatchQueue.main, execute: {
                mainThreadCompletion(true, nil)
            })
        }
    }

    private func getActivity(with activityTemplateId: Int?) -> Activity? {
        guard let r = routine, let targetId = activityTemplateId else {
            logError()
            return nil
        }

        for activity in r.activities {
            if let thisTemplateId = activity.activityTemplate, thisTemplateId == targetId {
                return activity
            }
        }

        logError("Could not find activity in routine with activityTemplateId \(targetId)")
        return nil
    }

    private func completeServerUpdates(for routine: Routine?, _ success: Bool, _ error: NSError?) {
        if !success || error != nil {
            logError(String(describing: error?.localizedDescription))
        }

        hideOverlay()

        guard success else {
            logError("\(String(describing: error?.localizedDescription)): \(String(describing: error?.userInfo)))")
            showErrorAlert(message: error?.getAwsErrorMessage(),
                           action: UIAlertAction.okAction() { (action) in
                self.routineCreationDelegate?.doneCreatingRoutine()
            })
            return
        }

        routineCreationDelegate?.doneCreatingRoutine()
    }
    
    // MARK: Activities Collection View functions

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workingActivityCollectionViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let activityModel = workingActivityCollectionViewModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activitiesCollectionViewCell", for: indexPath) as! ActivityViewCell
//        cell.addRoundedMyWayyShadow(radius: 3.8)
        cell.activityNameLabel.text = activityModel.activityTemplate.name?.uppercased()
        cell.activityIconImage.image = UIImage(named: activityModel.activityTemplate.icon!)
        cell.activityIconImage.layer.masksToBounds = true
        
        cell.minusButton.tag = indexPath.row
        cell.plusButton.tag  = indexPath.row
        cell.minusButton.addTarget(self, action: #selector(deSelectedActivityAction(sender:)), for: UIControlEvents.touchUpInside)
        cell.plusButton.addTarget(self, action: #selector(selectedActivityAction(sender:)), for: UIControlEvents.touchUpInside)
        
        if let intValue = dict[indexPath.row]{
            if intValue != 0{
                cell.countLabel.isHidden = false
                cell.countLabel.text = String(describing: intValue)
                cell.minusButton.isHidden = false
                cell.plusButton.isHidden = false
                cell.layer.borderWidth = 0
                
            }else{
                cell.countLabel.isHidden = true
                cell.minusButton.isHidden = true
                cell.plusButton.isHidden = true
                activityModel.selected = false
            }
        }
        else{
            cell.countLabel.isHidden = true
            cell.minusButton.isHidden = true
            cell.plusButton.isHidden = true
        }
        
        if activityModel.selected {
            cell.layer.borderWidth = 1
            // hide
        } else {
            cell.layer.borderWidth = 0
            // unhide
        }
        
        return cell
    }
    
    @objc func deSelectedActivityAction(sender: UIButton){
       
        var count_ = 0
        
        if dict[sender.tag]! != 0 {
            count_ =  dict[sender.tag]!
        }
        let cell = workingActivityCollectionViewModels[sender.tag]
        if count_ > 0 {
            count_ = count_ - 1
            dict[sender.tag] = count_
            
            for templateIndex in 0..<rtaSelections.count {
                if rtaSelections[templateIndex].activityTemplateId == cell.activityTemplate.id {
                    rtaSelections.remove(at: templateIndex)
                    updateDurationAndStartTime()
                    numSelectedActivitiesHeaderTitleLabel.text  = "\(rtaSelections.count)"
//                    updateTableView()
                    break
                }
            }
            
        }
        if count_ == 0{
            cell.selected = false
            dictOfCollectionIndex.remove(at: dictOfCollectionIndex.index(of: sender.tag)!)
        }
       activitiesCollectionView.reloadItems(at:[IndexPath(row: sender.tag, section: 0)])
       // updateDurationAndStartTime()
//        updateTableView()
    }
    
    @objc func selectedActivityAction(sender: UIButton){
            var count_ = 0
        if dict[sender.tag]! != 0 {
            count_ =  dict[sender.tag]!
        }
        dict[sender.tag] = count_ + 1
        let cell = workingActivityCollectionViewModels[sender.tag]
        let selection = RtaSelectionModel(routineId: routine?.id,
                                          routineTemplateId: routineTemplate?.id,
                                          activityTemplateId: cell.activityTemplate.id,
                                          activityTemplateDuration: cell.activityTemplate.duration,
                                          activityTemplateVersion: cell.activityTemplate.version)
        addSelection(selection)
        dictOfCollectionIndex.append(sender.tag)
        numSelectedActivitiesHeaderTitleLabel.text = "\(rtaSelections.count)"
        activitiesCollectionView.reloadItems(at:[IndexPath(row: sender.tag, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.activityTileSize(from: view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = workingActivityCollectionViewModels[indexPath.row]
        if !cell.selected {
            cell.selected = true
            dict[indexPath.row] = 1
            let selection = RtaSelectionModel(routineId: routine?.id,
                                              routineTemplateId: routineTemplate?.id,
                                              activityTemplateId: cell.activityTemplate.id,
                                              activityTemplateDuration: cell.activityTemplate.duration,
                                              activityTemplateVersion: cell.activityTemplate.version)
            addSelection(selection)
            dictOfCollectionIndex.append(indexPath.row)
            numSelectedActivitiesHeaderTitleLabel.text = "\(rtaSelections.count)"
            collectionView.reloadItems(at: [indexPath])
           
        }
        
    }
    var showSearch = true
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = kind == UICollectionElementKindSectionHeader  ? String(describing: HeaderCollectionReusableView.self) : "HeaderCollectionReusableView"
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        if let cellHeaderFooter = cell as? HeaderCollectionReusableView
        {
           
            if showSearch == true{
                 cellHeaderFooter.setupSearchBar()
                cellHeaderFooter.searchBar.delegate = self
                showSearch = false
            }
           
        }
        return cell
    }

    func addSelection(_ selection: RtaSelectionModel?) {
        guard let theSelection = selection else {
            logError()
            return
        }
        rtaSelections.append(theSelection)
        selectedActivitiesTableView.reloadData()
        updateDurationAndStartTime()
        //updateTableView()
    }
    
    func updateDurationAndStartTime() {
        totalDurationTime = 0
        for row in 0..<rtaSelections.count {
            totalDurationTime += rtaSelections[row].activityTemplateDuration
        }
        if totalDurationTime == 0 {
            let text = "N/A"
            durationTimeCalculated.text = text
            startTimeCalculated.text = text
            startTimeCalculatedHeader.text = text
            startTimeCalculatedHeader.isHidden = true
            startTimeCalculatedHeaderLabel.isHidden = true
        } else {
            let presenter = ElapsedTimePresenter(seconds: totalDurationTime * Constants.secondsInMinute)
            durationTimeCalculated.text = presenter.stopwatchStringShortWithBiggestUnits

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss" //24 hour format
            let endTimeDate = dateFormatter.date(from: (routineTemplate?.endTime)!)!
            
            let startTime = endTimeDate.addingTimeInterval(Double(-totalDurationTime * Constants.secondsInMinute))
            let startTimeFormatted = DateFormatter.timeFormatter.string(from: startTime)
            startTimeCalculated.text = startTimeFormatted
            startTimeCalculatedHeader.text = startTimeFormatted
            startTimeCalculatedHeader.isHidden = false
            startTimeCalculatedHeaderLabel.isHidden = false
        }
    }
    
    // MARK: SearchBar functions

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            workingActivityCollectionViewModels = masterActivityCollectionViewModels
        } else {
            var newWorkingModels = [ActivityCollectionViewModel]()
            for templateModel in 0..<masterActivityCollectionViewModels.count {
                let templateName = masterActivityCollectionViewModels[templateModel].activityTemplate.name?.lowercased()
                if (templateName!.contains(searchText.lowercased())) ||
                    (templateName!.contains(searchText)) ||
                    (templateName!.contains(searchText)) {
                    newWorkingModels.append(masterActivityCollectionViewModels[templateModel])
                }
            }
            workingActivityCollectionViewModels = newWorkingModels
        }
        activitiesCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // MARK: Tableview functions

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rtaSelections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if activitiesTableViewExpanded {
            return CGFloat(expandedActivitiesTableViewCellHeight)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedActivityTableViewCell") as! SelectedActivityTableViewCell
        guard let activityTemplate = MyWayyService.shared.profile?.getActivityTemplateById(rtaSelections[indexPath.row].activityTemplateId) else {
            return cell
        }
        cell.selectedActivityName.text = activityTemplate.name
        cell.selectedActivityDuration.text = NSLocalizedString("\((activityTemplate.duration)!) MINUTES", comment: "")
        cell.selectedActivityIcon.image = UIImage(named: (activityTemplate.icon)!)
        cell.selectedActivityIconBackground.addRoundedMyWayyShadow(radius: 3)
        cell.selectedActivityIconBackground.layer.cornerRadius = cell.selectedActivityIconBackground.frame.height/2
        cell.selectedActivityIconBackground.layer.borderWidth = 1
        cell.selectedActivityIconBackground.layer.backgroundColor = UIColor.white.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        rtaSelections.insert(rtaSelections.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let button = UIButton(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width - 40 , height: 40))
        button.setTitle("CREATE WAYY", for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.lightTeal
        button.titleLabel?.font = UIFont.heavy(12)
        button.titleLabel?.textColor = UIColor.white
        
        button.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
        customView.addSubview(button)
        return customView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            rtaSelections.remove(at: indexPath.row)
            updateDurationAndStartTime()
            deleteRows(index_: indexPath)
            
        }
    }
    func deleteRows(index_ : IndexPath){
        selectedActivitiesTableView.deleteRows(at: [index_], with: .fade)
        var expandedTableViewHeight = CGFloat(expandedActivitiesTableViewCellHeight * rtaSelections.count + 70)
        if expandedTableViewHeight > maximimSelectedActivitiesTableViewHeight {
            expandedTableViewHeight = maximimSelectedActivitiesTableViewHeight
        }
        selectedActivitiesTableView.frame = selectedActivitiesTableView.frame.offsetBy(dx: 0, dy: expandedTableViewHeight)
        selectedActivitiesTableViewHeight.constant = expandedTableViewHeight
        numSelectedActivitiesHeaderTitleLabel.text = "\(rtaSelections.count)"
        if dictOfCollectionIndex.count > 0{
            let indexx = dictOfCollectionIndex[index_.row]
            dict[indexx] = dict[indexx]!-1
            dictOfCollectionIndex.remove(at: index_.row)
            activitiesCollectionView.reloadItems(at: [IndexPath(row: indexx, section: 0)])
        }
    }
    
    @IBAction func toggleExpandTableView() {
        activitiesTableViewExpanded = !activitiesTableViewExpanded
        updateTableView()
    }
    
    @IBAction func addAc(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomActivityViewController") as? CustomActivityViewController
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    func updateTableView(){
        numSelectedActivitiesHeaderTitleLabel.text = "\(rtaSelections.count)"
      
        selectedActivitiesTableView.beginUpdates()
        var expandedTableViewHeight = CGFloat(expandedActivitiesTableViewCellHeight * rtaSelections.count + 70)
        if expandedTableViewHeight > maximimSelectedActivitiesTableViewHeight {
            expandedTableViewHeight = maximimSelectedActivitiesTableViewHeight
        }
        if shouldUp == true{
            if activitiesTableViewExpanded {
                selectedActivitiesTableView.frame = selectedActivitiesTableView.frame.offsetBy(dx: 0, dy: expandedTableViewHeight)
                selectedActivitiesTableViewHeight.constant = expandedTableViewHeight
                 mainView.addBlurToBackground(view: mainView, blurView: blurView)
                self.mainView.bringSubview(toFront: selectedActivitiesHeaderView)
                self.mainView.bringSubview(toFront: selectedActivitiesTableView)
                
            } else {
                selectedActivitiesTableViewHeight.constant = 0
                selectedActivitiesTableView.frame = selectedActivitiesTableView.frame.offsetBy(dx: 0, dy: -expandedTableViewHeight)
                 mainView.removeBlurToBackground(view: self.view, blurView: blurView)
            }
        }else{
            selectedActivitiesTableViewHeight.constant = 0
             mainView.removeBlurToBackground(view: self.view, blurView: blurView)
            
        }
        
        for row in 0..<rtaSelections.count {
            selectedActivitiesTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
        selectedActivitiesTableView.endUpdates()
    }
}
