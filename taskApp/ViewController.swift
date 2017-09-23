//
//  ViewController.swift
//  taskApp
//
//  Created by 杉山尋美 on 2017/09/15.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource
{

  @IBOutlet weak var tableView: UITableView!
//  @IBOutlet weak var pickerView: UIPickerView!


  @IBOutlet weak var categorySelectText: UITextField!
  var pickerView: UIPickerView = UIPickerView()
  
  var categorySelect: String = ""

  // Realmインスタンスを生成
  let realm = try! Realm()
  
  // DB内のCategoryクラスのデータが格納されるリスト
  var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
 
  // DB内のTaskクラスのデータが格納されるリスト
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()

    pickerView.delegate = self
    pickerView.dataSource = self
    makePickerCategoryList()
    categorySelectText.text = categoryList[0]
    
    // カテゴリー選択TextFieldクリックで、PickerViewをポップアップさせる
    categorySelectText.inputView = pickerView
    
/**
    // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
*/
    
    tableView.delegate = self
    tableView.dataSource = self

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  var categoryList = [String]()
  
  // カテゴリーDBから作られたArrayをリストに変換し、頭に"全て"を追加する
  func makePickerCategoryList() {
    categoryList.append("全て")
    for i in 0 ..< categoryArray.count {
      categoryList.append(categoryArray[i].categoryName
      )
    }
  }
  
  
  // MARK: PickerViewのDataSource
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    // 表示する列数
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

    // 表示個数を返す
    return categoryList.count
  }
  
  // PickerViewのDelegate
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

    // 表示する文字列を返す
    return categoryList[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    // Picker選択時の処理
    dismissKeyboard()
    categorySelectText.text = categoryList[row]
  }

  // 「取消」ボタンクリックでPickerを隠す
  @IBAction func cancelButtonClicked(_ sender: Any) {
    dismissKeyboard()
  }
  
  
  // TableView: 選択されたカテゴリーのタスクを表示する
  @IBAction func categorySelectButtonClicked(_ sender: Any) {
   
    categorySelect = categorySelectText.text!
    
    if categorySelect == "全て" {
      taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    } else {
      let predicate = NSPredicate(format: "category = %@", categorySelect)
      taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false).filter(predicate)
    }
    
    tableView.reloadData()
  }
  
  // MARK: UITableViewDataSourceプロトコル
  // データの数（＝セルの数）を返す
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }

  // 各セルの内容を返す
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    // 再利用可能な cell を得る
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    // Cellに値を設定する.
    let task = taskArray[indexPath.row]
    cell.textLabel?.text = task.title + "  <" + task.category + ">"
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    let dateString:String = formatter.string(from: task.date as Date)
    cell.detailTextLabel?.text = dateString

    return cell
  }
  
  // MARK: UITableViewDelegateプロトコル
  // 各セルを選択した時に実行される
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    performSegue(withIdentifier: "cellSegue",sender: nil)
  }
  
  // segue で画面遷移する時に呼ばれる
  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    let inputViewController:inputViewController = segue.destination as! inputViewController
    
    if segue.identifier == "cellSegue" {
      let indexPath = self.tableView.indexPathForSelectedRow
      inputViewController.task = taskArray[indexPath!.row]
    } else {
      let task = Task()
      task.date = NSDate()
      
      if taskArray.count != 0 {
        task.id = taskArray.max(ofProperty: "id")! + 1
      }
      
      inputViewController.task = task
    }
  }
  
  // inputViewControllerから戻るsegue
  @IBAction func unwind (_ segue: UIStoryboardSegue) {
    
  }
  
  // inputViewControllerから戻ってきた時 TableView,PickerView を更新する
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    pickerView.reloadAllComponents()
  }

  
  // セルが削除が可能なことを伝えるメソッド
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  // Delete ボタンが押された時に呼ばれるメソッド
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

  func dismissKeyboard(){
    // キーボードを閉じる
    view.endEditing(true)
  }

}
