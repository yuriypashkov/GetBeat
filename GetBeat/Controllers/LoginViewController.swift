
import UIKit
import WebKit

class LoginViewController: UIViewController, VKLoginProtocol, UITextFieldDelegate {

    // MARK: Attributes
    let networkModel = NetworkModel()
    //let customActivityIndicator = CustomActivityIndicator()
    let activityIndicatorView = UIActivityIndicatorView()
    let defaults = UserDefaults.standard
    let vkLoginClient = VKLoginClient()
    var currentPurchase: [BuyTrack] = []
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var vkLabel: UILabel!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var purchaseButton: UIButton!
    
    // MARK: IBOutlets Actions
    @IBAction func vkButtonTap(_ sender: UIButton) {
        // можно попробовать релизовать нормально модель: здесь делать видимой вторую кнопку с надписью Войти и уже по тапу на нее вызывать метод из модели, который вернет JSON от гетбит
        //setupElements(state: true)
        //logoutButton.alpha = 0
        vkLoginClient.showPermissions()
    }
    
    @IBAction func purchaseButtonTap(_ sender: UIButton) {
        //print("PURCHASE BUTTON TAP")
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let purchaseViewController = storyboard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
        purchaseViewController.purchase = currentPurchase
        present(purchaseViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTap(_ sender: UIButton) {
        // разобраться с setupElements
        setupElements(state: false)
        // удаляем логин и пароль
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "password")
        // на всякий случай очистим textfields
        usernameTextField.text = ""
        passwordTextField.text = ""
        //удаляем токен ВК
        defaults.removeObject(forKey: "vkToken")
        defaults.removeObject(forKey: "userVKid")
    }
    
    @IBAction func newLoginButtonTap(_ sender: UIButton) {
        errorLabel.alpha = 0
        setupElements(state: true)
        logoutButton.alpha = 0
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            errorLabel.alpha = 1
            errorLabel.text = "Ошибка"
            return }
        guard checkInputData(username: username, password: password) else { return }
        
        emailLoginAttemption(username: username, password: password)
    }
    
    // MARK: - ViewController methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
    }
    
    // ПРОДУМАТЬ МОМЕНТ ВОЗВРАЩЕНИЯ IndicatorView
    override func viewWillDisappear(_ animated: Bool) {
        //customActivityIndicator.stopAnimate()
        //customActivityIndicator.removeFromSuperview()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // уберём элементы на момент проверки загрузки
        setupElements(state: true)
        logoutButton.alpha = 0
        
        // set indicator view
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .medium
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        view.addSubview(activityIndicatorView)

        
        vkLoginClient.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        // закрытие клавиатуры по тапу на вьюхе
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // constraint warn
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no

        // attemption login
        if let username = defaults.string(forKey: "username"), let password = defaults.string(forKey: "password") {
            emailLoginAttemption(username: username, password: password)
        } else
            if let token = defaults.value(forKey: "vkToken"), let userID = defaults.value(forKey: "userVKid") {
                vkLoginClient.token = "\(token)"
                vkLoginClient.userVKid = "\(userID)"
                vkLoginAttemption()
            } else {
                //customActivityIndicator.alpha = 0
                activityIndicatorView.stopAnimating()
                setupElements(state: false)
            }
        
        // image view rounded
        photoImageView.layer.cornerRadius = photoImageView.frame.width / 2
    }
    
    
    // MARK: Methods
    @objc func tapOnView() {
        view.endEditing(true)
    }
    
    // метод - прятать элементы на время загрузки
    func setupElements(state: Bool) {
        loginButton.alpha = state ? 0 : 1
        passwordTextField.alpha = state ? 0 : 1
        usernameTextField.alpha = state ? 0 : 1
        vkLabel.alpha = state ? 0 : 1
        vkButton.alpha = state ? 0 : 1
        
        photoImageView.alpha = state ? 1 : 0
        logoutButton.alpha = state ? 1 : 0
        welcomeLabel.alpha = state ? 1 : 0
        purchaseButton.alpha = state ? 1 : 0
        
    }
    
    func vkLoginAttemption() {
        vkLoginClient.getDataFromVK { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.vkLoginClient.getDataFromGetBeat(user: user)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func emailLoginAttemption(username: String, password: String) {
        //customActivityIndicator.alpha = 1.0
        activityIndicatorView.startAnimating()
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
                            //print(user)
                            if login {
                                self.defaults.setValue(username, forKey: "username")
                                self.defaults.setValue(password, forKey: "password")
                            }
                            self.setupAfterLogin(state: login, user: user, isEmailLogin: true)
                        }
                    case .failure:
                        self.setupElements(state: false)
                        self.errorLabel.alpha = 1
                        self.errorLabel.text = "Произошла ошибка"
                    }
                    //self.customActivityIndicator.alpha = 0
                    self.activityIndicatorView.stopAnimating()
                }
            }
    }
    
    func setupAfterLogin(state: Bool, user: VKUser, isEmailLogin: Bool) {
        //customActivityIndicator.alpha = 0
        activityIndicatorView.stopAnimating()
        if state {
            setupElements(state: true)
            ApplicationAuth.isAuth = true
            // в зависимости от типа логина - разные поля заполняются
            if isEmailLogin {
                if let nickname = user.nickname, let firstname = user.firstName, let photoRecURL = user.photoRec {
                    if nickname == "" {
                        welcomeLabel.text = "Добро пожаловать, \(firstname)"
                    } else {
                        welcomeLabel.text = "Добро пожаловать, \(nickname)"
                    }
                    let imgURL = "https://getbeat.ru" + photoRecURL
                    photoImageView.lazyDownloadImage(link: imgURL) // какие-то варны непонятные
                }
            } else {
                // СОЗДАТЬ ОТДЕЛЬНУЮ МОДЕЛЬ ДЛЯ ЮЗЕРА ВОЗВРАЩАЕМОГО БЭКОМ GETBEAT!!!
                if let firstname = user.firstName, let lastname = user.lastName, let photoRecUrl = user.photoRec {
                    welcomeLabel.text = "Добро пожаловать, \(firstname) \(lastname)"
                    photoImageView.lazyDownloadImage(link: photoRecUrl)
                }
            }
            
            // оформим список купленных треков
            if let buyTracks = user.buyTracks {
                currentPurchase = buyTracks
                purchaseButton.setTitle("Покупки (\(buyTracks.count))", for: .normal)
            } else {
                currentPurchase = []
                purchaseButton.setTitle("Покупки (0)", for: .normal)
            }
            
        } else {
            setupElements(state: false)
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
