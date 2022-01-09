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
    func saveAddress(_ address: String) -> NSManagedObject?
}

class ViewController: UIViewController {
    
    var fences: [NSManagedObject]
    let addButton = UIButton(type: .roundedRect)
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
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        addButton.backgroundColor = UIColor.red
        addButton.setTitleColor(.white, for: .normal)
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(addAddress), for: .touchDown)
        let title = UILabel()
        title.text = "Geofencer"
        let stack = UIStackView(arrangedSubviews: [title, addButton])
        stack.axis = .horizontal
        view.addSubview(stack)
        stack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return view
    }
    
    @objc func addAddress() {
        let alert = UIAlertController(title: "Add Address", message: "Enter a building address to improve the efficiency of it", preferredStyle: .alert)
        alert.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let field = alert.textFields?.first,
                  let text = field.text else {
                return
            }
            guard let object = self?.delegate?.saveAddress(text) else {
                return
            }
            self?.fences.append(object)
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        self.present(alert, animated: true, completion: nil)
    }
}
