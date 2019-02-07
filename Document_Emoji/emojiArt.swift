//
//  emojiArt.swift
//  Drag&Drop
//
//  Created by 无敌帅的yyyyy on 2019/2/4.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import Foundation
struct emojiArt:Codable{
    var url:URL
    var emoji = [EmojiInfo]()
    
    struct EmojiInfo:Codable{
        let x:Int
        let y:Int
        let text:String
        let size:Int
    }
    var json:Data?{
        return try? JSONEncoder().encode(self)
    }
    init?(jsondata:Data){
        if let newValue = try? JSONDecoder().decode(emojiArt.self, from: jsondata){
            self = newValue
        }else{
            return nil
        }
    }
    
    init(url:URL,emojis:[EmojiInfo]){
        self.url = url
        self.emoji = emojis
    }
}
