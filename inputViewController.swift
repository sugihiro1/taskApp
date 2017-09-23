//
//  inputViewController.swift
//  taskApp
//
//  Created by 杉山尋美 on 2017/09/15.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class inputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
 {

  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var pickerView: UIPickerView!
  
  var task: Task!

  // Realmインスタンスを生成
  let realm = try! Realm()

  // DB内のCategoryクラスのデータが格納されるリスト
  var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
  
 
  override func viewDidLoad() {
        super.viewDidLoad()    
    // Backボタンを隠す
    navigationItem.setHidesBackButton(true, animated: false)
    
    categoryTextField.text = task.category
    titleTextField.text = task.title
    contentsTextView.text = task.contents
    datePicker.date = task.date as Date
    
    pickerView.delegate = self
    pickerView.dataSource = self

    // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)

  }


  // PickerViewのDataSource
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    // 表示する列数
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    // 表示個数を返す
    return categoryArray.count
  }
  
  // PickerViewのDelegate
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    // 表示する文字列を返す
    return categoryArray[row].categoryName
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // 選択時の処理
    categoryTextField.text = categoryArray[row].categoryName
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  // CategoryViewControllerから戻ってきた時 PickerView を更新する
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    pickerView.reloadAllComponents()
  }
  

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  // 「登録」ボタンがクリックされた
  @IBAction func buttonClicked(_ sender: Any) {
    
    // 入力欄のいずれかが空白の場合、アラートを出しfuncを抜ける
    if self.categoryTextField.text == "" || self.titleTextField.text == "" || self.contentsTextView.text == "" {
      let alertController = UIAlertController(title: "",message: "入力されていない箇所があります", preferredStyle: UIAlertControllerStyle.alert)
 
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
        return
      }
      
      alertController.addAction(okAction)
      present(alertController,animated: true,completion: nil)
    }
    
    // 入力されたdataをDBに書き込む
    try! realm.write {
      self.task.category = self.categoryTextField.text!
      self.task.title = self.titleTextField.text!
      self.task.contents = self.contentsTextView.text
      self.task.date = self.datePicker.date as NSDate
      self.realm.add(self.task, update: true)
    }
    
    setNotification(task: task)
    
    // 前画面に戻る
    self.navigationController?.popViewController(animated: true)
  }

  // 前画面に戻る
  @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
  }
  
  // タスクのローカル通知を登録する
  func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    content.title = task.title
    content.body  = task.contents       // bodyが空だと音しか出ない
    content.sound = UNNotificationSound.default()
    
    // ローカル通知が発動するtrigger（日付マッチ）を作成
    let calendar = NSCalendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
    // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
    let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
    
    // ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
      print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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

  
  func dismissKeyboard(){
    // キーボードを閉じる
    view.endEditing(true)
  }
  

  
}
