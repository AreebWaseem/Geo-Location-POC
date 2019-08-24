//
//  testViewController.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 06/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import M13Checkbox
import DLRadioButton

class testViewController: UIViewController {
    
    
    @IBOutlet weak var stack_view: UIStackView!
    
    @IBOutlet weak var waterButton: DLRadioButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // let checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
       // let checkbox1 = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        let view1 = UIView()
        view1.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view1.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view1.backgroundColor = UIColor.black
        //let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
       // view1.backgroundColor = UIColor.white
        stack_view.addArrangedSubview(view1)
        
        self.waterButton.isMultipleSelectionEnabled = true;
        // set selection states programmatically
        for radioButton in self.waterButton.otherButtons {
            radioButton.isSelected = true;
        }
        
        // programmatically add buttons
        // first button
        let frame = CGRect(x: self.view.frame.size.width / 2 - 131, y: 350, width: 262, height: 17);
        let firstRadioButton = createRadioButton(frame: frame, title: "Red Button", color: UIColor.red);
        
        //other buttons
        let colorNames = ["Brown", "Orange", "Green", "Blue", "Purple"];
        let colors = [UIColor.brown, UIColor.orange, UIColor.green, UIColor.blue, UIColor.purple];
        var i = 0;
        var otherButtons : [DLRadioButton] = [];
        for color in colors {
            let frame = CGRect(x: self.view.frame.size.width / 2 - 131, y: 380 + 30 * CGFloat(i), width: 262, height: 17);
            let radioButton = createRadioButton(frame: frame, title: colorNames[i] + " Button", color: color);
            if (i % 2 == 0) {
                radioButton.isIconSquare = true;
            }
            if (i > 1) {
                // put icon on the right side
                radioButton.isIconOnRight = true;
                radioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right;
            }
            otherButtons.append(radioButton);
            i += 1;
        }
        
        firstRadioButton.otherButtons = otherButtons;
        // set selection state programmatically
        firstRadioButton.otherButtons[1].isSelected = true;
        
        //stack_view.addArrangedSubview(checkbox1)
        //stack_view.layoutSubviews()
        // Do any additional setup after loading the view.
    }
    
    private func createRadioButton(frame : CGRect, title : String, color : UIColor) -> DLRadioButton {
        let radioButton = DLRadioButton(frame: frame);
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 14);
        radioButton.setTitle(title, for: []);
        radioButton.setTitleColor(color, for: []);
        radioButton.iconColor = color;
        radioButton.indicatorColor = color;
        radioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        radioButton.addTarget(self, action: #selector(testViewController.logSelectedButton), for: UIControl.Event.touchUpInside);
        self.view.addSubview(radioButton);
        
        return radioButton;
    }
    
    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        if (radioButton.isMultipleSelectionEnabled) {
            for button in radioButton.selectedButtons() {
                print(String(format: "%@ is selected.\n", button.titleLabel!.text!));
            }
        } else {
            print(String(format: "%@ is selected.\n", radioButton.selected()!.titleLabel!.text!));
        }
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
