//
//  Task.swift
//  taskApp
//
//  Created by 杉山尋美 on 2017/09/17.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import RealmSwift

class Task: Object {
  // 管理用 IDプライマリーキー
  dynamic var id = 0
  
  // カテゴリー
  dynamic var category = ""
  
  // タイトル
  dynamic var title = ""
  
  // 内容
  dynamic var contents = ""
  
  /// 日時
  dynamic var date = NSDate()
  
  /**
   id をプライマリーキーとして設定
   */
  override static func primaryKey() -> String? {
    return "id"
  }
}


class Category: Object {
  // 管理用 IDプライマリーキー
  dynamic var id = 0
  
  // カテゴリー名
  dynamic var categoryName = "All"

  /**
   id をプライマリーキーとして設定
   */
  override static func primaryKey() -> String? {
    return "id"
  }

}
