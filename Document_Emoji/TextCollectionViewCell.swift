//
//  TextCollectionViewCell.swift
//  Drag&Drop
//
//  Created by 无敌帅的yyyyy on 2019/1/28.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    
    
    @IBOutlet weak var textfield: UITextField!{
        didSet{
            textfield.delegate = self
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignhandler?()
    }
    var resignhandler:(()->Void)?
}
