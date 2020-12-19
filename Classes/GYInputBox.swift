//
//  GYInputBox.swift
//  GYInputBoxDemo
//
//  Created by y g on 2020/12/19.
//

import UIKit
import SnapKit

protocol GYSearchBarDelegate {
    
    /// 返回补全富文本内容
    /// - Parameter index: 下标
    func attributedTextForIndex(index:Int) -> NSAttributedString
}

class GYInputBox: UIView,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    /// 代理
    var delegate:GYSearchBarDelegate?
    
    /// 输入框文本发生改变事件
    var searchTextDidChange:((String) -> ())!
    
    /// 选中某个补全文本事件
    var didSelectIndex:((Int) -> ())!
    
    /// 输入框文本内容
    var text: String {
        get {
            return onEditingText ?? ""
        }
        set {
            searBarField.text = newValue
        }
    }
    
    /// 自动补全的数据源
    var dataSouce:NSArray! = [] {
        didSet{
            self.tableView.reloadData()
            resetConstraint()
        }
    }
    
    
    /// 私有属性
    fileprivate var searBarField:UITextField!
    fileprivate var tableView:UITableView!
    fileprivate var placeholder:String!
    fileprivate var onEditingText:String!//正在编辑的文本
    convenience init(placeholder: String, frame: CGRect) {
        self.init(frame: frame)
        self.placeholder = placeholder
        setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startEditing () {
        searBarField.becomeFirstResponder()
    }
    
    func endEditing () {
        searBarField.resignFirstResponder()
    }
    
    fileprivate func setupViews() {
        searBarField = UITextField()
        searBarField.layer.cornerRadius = 4;
        searBarField.delegate = self
        searBarField.layer.borderColor = UIColor.lightGray.cgColor
        searBarField.layer.borderWidth = 1.0
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 18, height: 0))
        searBarField.leftView = leftView
        searBarField.leftViewMode = .always
        searBarField.clearButtonMode = .whileEditing
        searBarField.placeholder = placeholder
        self.addSubview(searBarField)
        searBarField.snp.makeConstraints({ (make) in
            make.height.equalTo(35)
            make.margins.equalTo(UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2));
        })
        
        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 4;
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1.0
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "id")
        self.addSubview(tableView)
    }
    
    fileprivate func resetConstraint() {
        searBarField.snp.remakeConstraints { (make) in
            make.height.equalTo(35)
            make.left.top.equalTo(2);
            make.right.equalTo(-2);
        }
        let height:CGFloat = 40.0 * CGFloat((dataSouce.count > 4 ? 4 : dataSouce.count))
        tableView.snp.remakeConstraints { (make) in
            make.height.equalTo(height)
            make.top.equalTo(searBarField.snp.bottom).offset(2)
            make.left.equalTo(2);
            make.right.bottom.equalTo(-2);
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        cell.textLabel?.attributedText = delegate?.attributedTextForIndex(index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.didSelectIndex != nil) {
            self.didSelectIndex(indexPath.row)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (self.searchTextDidChange != nil) {
            onEditingText = ""
            self.searchTextDidChange(onEditingText)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if (self.searchTextDidChange != nil) {
            onEditingText = newText
            self.searchTextDidChange(onEditingText)
        }
        return true
    }
}
