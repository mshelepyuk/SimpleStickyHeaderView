//
//  ViewController.swift
//  SimpleStickyHeaderTests
//
//  Created by Maxim Shelepyuk on 26/4/2562 BE.
//  Copyright © 2562 Maxim Shelepyuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let sampleCellId = "kSampleCellIdentifier"

    private lazy var stickyHeaderView: StickyHeaderView = {
        let stickyView = StickyHeaderView(headerView: headerView, scrollView: tableView)
        stickyView.translatesAutoresizingMaskIntoConstraints = false
        return stickyView
    }()
    
    private lazy var headerView: UIView = {
        let header = UIView()
        header.backgroundColor = .red
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Header"
        label.font = UIFont.systemFont(ofSize: 30.0)
        
        header.addSubview(label)
        label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8.0).isActive = true
        label.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        
        header.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    
        return header
    }()
    
    private lazy var tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: sampleCellId)
        table.dataSource = self
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stickyHeaderView)
        stickyHeaderView.minimumHeaderHeight = 50.0
        stickyHeaderView.delegate = self
        
        NSLayoutConstraint.activate(
            [
                stickyHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
                stickyHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
                stickyHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
                stickyHeaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sampleCellId, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row) Cell"
        return cell
    }
}

extension ViewController: StickyHeaderViewDelegate {
    func stickyHeader(_ stickyHeader: StickyHeaderView, progressDidChanged progress: CGFloat) {
        (headerView.subviews.first as? UILabel)?.font = UIFont.systemFont(ofSize: min(30.0, 17.0 / progress))
    }
}

