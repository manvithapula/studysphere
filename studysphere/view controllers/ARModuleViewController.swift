//
//  ARModuleViewController.swift
//  Studysphere2
//
//  Created by Dev on 06/11/24.
//

import UIKit

class ARModuleViewController: UIViewController {
    
    @IBOutlet weak var progressL: UILabel!
    @IBOutlet weak var circularProgressV: ProgressViewCIrcle!
    @IBOutlet weak var scheduleTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        circularProgressV.setProgress(value: 0.5)

    }
    
    
    



}
import UIKit


extension ARModuleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        
        if let cell = cell as? ARModuleTableViewCell {
            cell.titleL.text = "Question \(indexPath.row + 1)"

        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
}
