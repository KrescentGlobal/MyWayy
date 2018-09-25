//
//  SearchViewController.swift
//  MyWayy
//
//  Created by SpinDance on 11/22/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, BusyOverlayOwner {
    private var topSegment = 0
    private var routinesSegment = 1
    private var profilesSegment = 2
    private var tagsSegment = 3

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profileResultsTableView: UITableView!
    @IBOutlet weak var routineResultsCollectionView: UICollectionView!

    @IBOutlet weak var actionSelector: TabySegmentedControl!
    var profileResults = [Profile]()
    var routineResults = [RoutineTemplate]()
    let overlay = BusyOverlayView.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupProfileResultsTableView()
        setupRoutineResultsCollectionView()
        hideKeyboardWhenTappedAround()
        actionSelector.initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated(notification:)), name: Notification.profileReloadedNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if routineResults.isEmpty && profileResults.isEmpty {
            searchBar.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.profileReloadedNotification, object: nil)
    }

    @objc func profileUpdated(notification: Notification) {
        clearResults()
        search()
    }

    func setupSearchBar() {
        searchBar.delegate = self
        
    }

    func setupProfileResultsTableView() {
        profileResultsTableView.delegate = self
        profileResultsTableView.dataSource = self
        profileResultsTableView.allowsSelection = true
    }

    func setupRoutineResultsCollectionView() {
        routineResultsCollectionView.delegate = self
        routineResultsCollectionView.dataSource = self
        routineResultsCollectionView.allowsSelection = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        view.endEditing(true)

        clearResults()
        search()
    }

    @IBAction func tabValueChanged(_ sender: Any) {
   
        switch actionSelector.selectedSegmentIndex {
        case profilesSegment:
            routineResultsCollectionView.isHidden = true
            profileResultsTableView.isHidden = false
            if profileResults.isEmpty {
                search()
            } else {
                profileResultsTableView.reloadData()
            }
            break
        case routinesSegment:
            profileResultsTableView.isHidden = true
            routineResultsCollectionView.isHidden = false
            if routineResults.isEmpty {
                search()
            } else {
                routineResultsCollectionView.reloadData()
            }
            break
            case topSegment:
                profileResultsTableView.isHidden = true
                routineResultsCollectionView.isHidden = true
                
            break
            case tagsSegment:
                profileResultsTableView.isHidden = true
                routineResultsCollectionView.isHidden = true
            break
        default:
            break
        }
    
    }
   
    func clearResults() {
        profileResults = [Profile]()
        profileResultsTableView.reloadData()
        routineResults = [RoutineTemplate]()
        routineResultsCollectionView.reloadData()
    }

    func search() {
        let searchTerm = "%\(searchBar.text ?? "")%"

        if searchTerm == "%%" {
            return
        }

        switch actionSelector.selectedSegmentIndex {
        case profilesSegment:
            showOverlay()
            MyWayyService.shared.searchProfiles(term: searchTerm, limit: 10, offset: profileResults.count, { (success, results, error) in
                self.hideOverlay()
                guard success, let profiles = results else { return }
                
                self.profileResults = self.profileResults + profiles
                self.profileResultsTableView.reloadData()
            })
        case routinesSegment:
            showOverlay()
            MyWayyService.shared.searchRoutineTemplates(term: searchTerm, limit: 30, offset: routineResults.count, { (success, results, error) in
                self.hideOverlay()
                guard success, let routineTemplates = results else { return }
                
                self.routineResults = self.routineResults + routineTemplates.filter {
                    RoutineHelper.isFullyInitializedRoutineTemplate($0)
                }
                self.routineResultsCollectionView.reloadData()
            })
        default:
            break
        }
    }

    // MARK: Actions
    @IBAction func nextClicked(sender: UIButton) {
        search()
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profileResults.count == 0 {
            return 0
        } else if profileResults.count < 10 {
            return profileResults.count
        } else {
            // the extra row accounts for the "Next" button which will load 10 more records.
            return profileResults.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == profileResults.count {
            return tableView.dequeueReusableCell(withIdentifier: SearchNextTableViewCell.reuseId) as! SearchNextTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchProfileTableViewCell.reuseId) as! SearchProfileTableViewCell
        cell.setup(profileResults[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIViewController.publicProfile as? PublicProfileViewController else {
            return
        }
        vc.userProfile = profileResults[indexPath.row]
        present(vc, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routineResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchRoutineCollectionViewCell.reuseId, for: indexPath) as! SearchRoutineCollectionViewCell
        cell.clipsToBounds = false
        cell.setup(routineResults[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if routineResults.count < 10 {
            return CGSize(width: view.bounds.width, height: CGFloat.leastNormalMagnitude)
        } else {
            return CGSize(width: view.bounds.width, height: 50.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Constants.routineTileSize(from: view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind: String, at indexPath: IndexPath)
        -> UICollectionReusableView {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "SearchRoutineCollectionViewFooter", for: indexPath) as! SearchRoutineFooterCollectionReusableView
            
            return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPublicRoutineScreen(withRoutineTemplate: routineResults[indexPath.row])
    }

}
