//
//  FeedViewController.swift
//  Instgram
//
//  Created by lxy on 3/16/21.
//

import UIKit
import Parse
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var posts = [PFObject]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author")  //obtain author object instead of just ptr
        query.limit = 20            //get the query
        
        query.findObjectsInBackground{(posts,error) in
            if posts != nil{
                self.posts=posts!       //store the data
                self.tableView.reloadData()         //reload the tableview
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post=posts[indexPath.row]
        let user=post["author"] as! PFUser
        cell.usernameLable.text=user.username
        cell.captionLable.text=post["caption"] as! String
        let imageFile=post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af.setImage(withURL: url)
        return cell
        
    }
  
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
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
