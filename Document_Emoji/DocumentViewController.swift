//
//  DocumentViewController.swift
//  Document_Emoji
//
//  Created by 无敌帅的yyyyy on 2019/2/15.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    var document:Document?{
        didSet{
            updateUI()
        }
    }
    
    
    
    var shortformatter:DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func updateUI(){
        if size != nil, data != nil, let url = document?.fileURL,let attributes = try? FileManager.default.attributesOfItem(atPath: url.path){
            size.text = "\(attributes[.size] ?? 0)"
           let data1 = attributes[.creationDate] as? Date
           data.text = shortformatter.string(from: data1!)
        }
        if imageView != nil, let thumbnail = document?.thumbnail{
            imageView.image = thumbnail
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var data: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func `return`() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
