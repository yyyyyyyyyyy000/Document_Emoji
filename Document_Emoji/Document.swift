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
    var thumbnail:UIImage?
    override func contents(forType typeName: String) throws -> Any {
        return emojiart?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data{
            emojiart = emojiArt(jsondata: json)
        }
    }
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail{
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
    
}

