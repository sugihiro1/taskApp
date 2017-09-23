//
//  CategoryViewController.swift
//  taskApp
//
//  Created by 杉山尋美 on 2017/09/17.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications


class CategoryViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {


  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var categoryAddedText: UITextField!

//  var category: Category!
  
  // Realmインスタンスを取得する
  let realm = try! Realm()
  
  // DB内のCategoryクラスのデータが格納されるリスト
  var taskArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)

  override func viewDidLoad() {
        super.viewDidLoad()
 
    // Backボタンを隠す
    navigationItem.setHidesBackButton(true, animated: false)

    // Do any additional setup after loading the view.
    tableView.delegate = self
    tableView.dataSource = self
  
  }
  
  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  // MARK: UITableViewDataSourceプロトコルのメソッド
  // データの数（＝セルの数）を返すメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }
  
  // 各セルの内容を返すメソッド
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    // 再利用可能な cell を得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellCategory", for: indexPath)
    
    // Cellに値を設定する.
    let task = taskArray[indexPath.row]
      cell.textLabel?.text = task.categoryName

    return cell
  }

  var category: Category!

  // 新規カテゴリーをDBに追加
  @IBAction func buttonClicked(_ sender: Any) {
   
    print("Add")
    
    self.category = Category()
    
    if taskArray.count != 0 {
      self.category.id = self.taskArray.max(ofProperty: "id")! + 1
    }
    
    try! realm.write {
      self.category.categoryName = self.categoryAddedText.text!
      self.realm.add(self.category, update: true)
    }
    
    tableView.reloadData()
  }

  // 前画面に戻る
  @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
  }
  
  // セルが削除が可能なことを伝える
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  // Delete ボタンが押された時に呼ばれる
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == UITableViewCellEditingStyle.delete {
      
      // 削除されたタスクを取得する
      let task = self.taskArray[indexPath.row]
      
      // ローカル通知をキャンセルする
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
      
      // データベースから削除する
      try! realm.write {
        self.realm.delete(self.taskArray[indexPath.row])
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
      }
      
      // 未通知のローカル通知一覧をログ出力
      center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
        for request in requests {
          print("/---------------")
          print(request)
          print("---------------/")
        }
      }
      
    }
  }

  
}
