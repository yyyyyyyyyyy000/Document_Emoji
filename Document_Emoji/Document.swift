//
//  Document.swift
//  Document_Emoji
//
//  Created by 无敌帅的yyyyy on 2019/2/6.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

