//
//  ProgressViewViewController.swift
//  Studysphere2
//
//  Created by Dev on 06/11/24.
//

import UIKit

class ProgressViewViewController: UIViewController {

    @IBOutlet weak var circularPV: ProgressViewCIrcle!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        circularPV.setProgress(value: 0.5)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
