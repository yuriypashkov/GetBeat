
import UIKit
import WebKit

class LoginViewController: UIViewController, VKLoginProtocol {

    // MARK: Attributes
    let networkModel = NetworkModel()
    let activityIndicator = UIActivityIndicatorView()
    let defaults = UserDefaults.standard
    let vkLoginClient = VKLoginClient()
    //var currentUser: User?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var loginItemsView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var vkLabel: UILabel!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: IBOutlets Actions
    @IBAction func vkButtonTap(_ sender: UIButton) {
        //vkLoginClient.testQueues()
        vkLoginClient.showPermissions()
        //let controller = vkLoginClient.showPermissions()
        //present(controller, animated: true, completion: nil)
        // можно попробовать релизовать нормально модель: здесь делать видимой вторую кнопку с надписью Войти и уже по тапу на нее вызывать метод из модели, который вернет JSON от гетбит
    }
    
    
    @IBAction func logoutButtonTap(_ sender: UIButton) {
        // разобраться с setupElements
        setupElements(state: false)
        // прячем ненужные элементы и показываем нужные
        vkLabel.alpha = 1
        vkButton.alpha = 1
        usernameTextField.alpha = 1
        passwordTextField.alpha = 1
        loginButton.alpha = 1
        logoutButton.alpha = 0
        welcomeLabel.alpha = 0
        photoImageView.alpha = 0
        // удаляем логин и пароль
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "password")
        // на всякий случай очистим textfields
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func newLoginButtonTap(_ sender: UIButton) {
        errorLabel.alpha = 0
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            errorLabel.alpha = 1
            errorLabel.text = "Ошибка"
            return }
        guard checkInputData(username: username, password: password) else { return }
        
        loginAttemption(username: username, password: password)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        vkLoginClient.delegate = self
        
        // закрытие клавиатуры по тапу на вьюхе
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // constraint warn
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        
        // set indicator view
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // attemption login
       if let username = defaults.string(forKey: "username"), let password = defaults.string(forKey: "password") {
            loginAttemption(username: username, password: password)
       }
        
        // image view rounded
        photoImageView.layer.cornerRadius = photoImageView.frame.width / 2
        //photoImageView.layer.masksToBounds = true
        
    }
    
    
    // MARK: Methods
    @objc func tapOnView() {
        view.endEditing(true)
    }
    
    // метод - прятать элементы на время загрузки
    func setupElements(state: Bool) {
        loginButton.isHidden = state
        passwordTextField.isHidden = state
        usernameTextField.isHidden = state
        vkLabel.isHidden = state
        vkButton.isHidden = state
        //photoImageView.isHidden = state
    }
    
    func loginAttemption(username: String, password: String) {
        activityIndicator.startAnimating()
        setupElements(state: true)
        passwordTextField.text = password
        usernameTextField.text = username

            let queryData = [
                "email": username,
                "pass": password
            ]

            networkModel.login(queryData: queryData) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        if let login = user.login {
                            self.setupAfterLogin(state: login, user: user, username: username, password: password, isEmailLogin: true)
                        }
                    case .failure:
                        self.errorLabel.alpha = 1
                        self.errorLabel.text = "Произошла ошибка"
                    }
                    self.activityIndicator.stopAnimating()
                    self.setupElements(state: false)
                }
            }
    }
    
    func setupAfterLogin(state: Bool, user: User, username: String, password: String, isEmailLogin: Bool) {
        if state {
            //setupElements(state: false)
            // прячем ненужные элементы и показываем нужные
            vkLabel.alpha = 0
            vkButton.alpha = 0
            usernameTextField.alpha = 0
            passwordTextField.alpha = 0
            loginButton.alpha = 0
            logoutButton.alpha = 1
            welcomeLabel.alpha = 1
            
            // в зависимости от типа логина - разные поля заполняются
            if isEmailLogin {
                if let nickname = user.nickname {
                    welcomeLabel.text = "Добро пожаловать, \(nickname)"
                }
                defaults.setValue(username, forKey: "username")
                defaults.setValue(password, forKey: "password")
            } else {
                if let firstname = user.firstName, let lastname = user.lastName, let photoRecUrl = user.photoRec {
                    welcomeLabel.text = "Добро пожаловать, \(firstname) \(lastname)"
                    //photoImageView.image = UIImage(named: "vkIcon200px")
                    photoImageView.alpha = 1
                    photoImageView.lazyDownloadImage(link: photoRecUrl)
                }
            }
        } else {
            errorLabel.alpha = 1
            errorLabel.text = "Неверный логин или пароль"
        }
    }

    func checkInputData(username: String, password: String) -> Bool {
        
        if username.count == 0 || password.count == 0 {
            errorLabel.alpha = 1
            errorLabel.text = "Оба поля должны быть заполнены"
            return false
        }
        if !username.contains("@") {
            errorLabel.alpha = 1
            errorLabel.text = "Поле Username/email заполнено некорректно"
            return false
        }
        if password.count < 8 {
            errorLabel.alpha = 1
            errorLabel.text = "Пароль должен содержать не менее 8 символов"
            return false
        }
        
        return true
    }
}
