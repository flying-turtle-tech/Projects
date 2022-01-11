//
//  ViewController.swift
//  Geofencer
//
//  Created by Jonathan Kovach on 1/8/22.
//

import UIKit
import CoreLocation
import PureLayout
import CoreData

protocol ViewControllerDelegate: AnyObject {
    func saveBuilding(_ address: String, region: CLCircularRegion) -> NSManagedObject?
}

class ViewController: UIViewController {
    
    var fences: [NSManagedObject]
    let addButton = UIButton(type: .roundedRect)
    let removeButton = UIButton(type: .roundedRect)
    let tableView = UITableView()
    weak var delegate: ViewControllerDelegate?

    init(fences: [NSManagedObject]) {
        self.fences = fences
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = fences[indexPath.row].value(forKey: "address") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fences.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        addButton.backgroundColor = UIColor.green
        addButton.setTitleColor(.black, for: .normal)
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(addAddress), for: .touchDown)
        removeButton.backgroundColor = UIColor.red
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.setTitle("Remove", for: .normal)
        removeButton.addTarget(self, action: #selector(editTable), for: .touchDown)
        let title = UILabel()
        title.text = "Geofencer"
        let stack = UIStackView(arrangedSubviews: [title, addButton, removeButton])
        stack.axis = .horizontal
        view.addSubview(stack)
        stack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return view
    }
    
    @objc func editTable() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            removeButton.setTitle("Done", for: .normal)
        } else {
            removeButton.setTitle("Remove", for: .normal)
        }
    }
    
    @objc func addAddress() {
        let alert = UIAlertController(title: "Add Address", message: "Enter a building address to improve the efficiency of it", preferredStyle: .alert)
        alert.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let field = alert.textFields?.first,
                  let address = field.text else {
                return
            }
            GeoDataSource.circleRegionFrom(address: address) { [weak self] circle in
                guard let circle = circle else {
                    print("failed to get circle region")
                    return
                }
                guard let object = self?.delegate?.saveBuilding(address, region: circle) else {
                    return
                }
                self?.fences.append(object)
                self?.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        self.present(alert, animated: true, completion: nil)
    }
}
