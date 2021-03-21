//
//  FeedViewController.swift
//  Instgram
//
//  Created by lxy on 3/16/21.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MessageInputBarDelegate{
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    var selectedPost : PFObject!
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController=main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        let comment=PFObject(className: "Comments")
        comment["text"]=text
        comment["post"]=selectedPost
        comment["author"]=PFUser.current()!
        
        selectedPost.add(comment,forKey:"comments")
        selectedPost.saveInBackground{(success,error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        
        
        // dismiss input bar
        commentBar.inputTextView.text=nil
        showsCommentBar=false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == comments.count+1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
        
        /*comment["text"]="Hello world"
        comment["post"]=post
        comment["author"]=PFUser.current()!
        
        post.add(comment,forKey:"comments")
        post.saveInBackground{(success,error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }*/
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"])  //obtain author object instead of just ptr
        query.limit = 20            //get the query
        
        query.findObjectsInBackground{(posts,error) in
            if posts != nil{
                self.posts=posts!       //store the data
                self.tableView.reloadData()         //reload the tableview
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //if ?? left is null, set it to be  ?? right
        return comments.count+2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let post=posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row==0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user=post["author"] as! PFUser
            cell.usernameLable.text=user.username
            cell.captionLable.text=post["caption"] as? String
            let imageFile=post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
            return cell
            
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text=comment["text"] as? String
            
            let user=comment["author"] as! PFUser
            cell.nameLabel.text=user.username
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        
    }
  
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder="Add a Comment..."
        commentBar.sendButton.title="Post"
        commentBar.delegate=self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.keyboardDismissMode = .interactive            //to dismiss the keyboard by just dragging down the table view
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text=nil
        showsCommentBar=false
        becomeFirstResponder()
    }
    
    // hacking ios framework
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
