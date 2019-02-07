//
//  Document.swift
//  Document_Emoji
//
//  Created by 无敌帅的yyyyy on 2019/2/6.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class Document: UIDocument {
    var emojiart:emojiArt?
    override func contents(forType typeName: String) throws -> Any {
        return emojiart?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data{
            emojiart = emojiArt(jsondata: json)
        }
    }
}

