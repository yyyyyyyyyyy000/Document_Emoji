//
//  emojiView.swift
//  Drag&Drop
//
//  Created by 无敌帅的yyyyy on 2019/1/25.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class emojiView: UIView,UIDropInteractionDelegate {
    var backgroundimage:UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
   override func draw(_ rect: CGRect) {
        backgroundimage?.draw(in: bounds)
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    private func setup(){
        addInteraction(UIDropInteraction(delegate: self))
    }
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass:NSAttributedString.self, completion: {(provider) in
            let droppoint = session.location(in: self)
            for attributedString in provider as? [NSAttributedString] ?? []{
                self.addlabel(at:droppoint,title: attributedString)
            }
        })
    }
    func addlabel(at droppoint:CGPoint,title:NSAttributedString){
        let label = UILabel()
        label.backgroundColor = .clear
        label.center = droppoint
        label.attributedText = title
        label.sizeToFit()
        self.addSubview(label)
    }
}
