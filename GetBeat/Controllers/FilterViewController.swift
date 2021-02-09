
import UIKit

class FilterViewController: UIViewController, PickerDelegate {
    
    let networkModel = NetworkModel()
    let searchActivityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var tempoView: UIView!
    
    // MARK: Sliders outlets and methods - begin
    @IBOutlet weak var energySlider: UISlider!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var coastSlider: UISlider!
    @IBOutlet weak var searchLabel: UILabel!
    
    
    @IBAction func coastSliderValueChanged(_ sender: UISlider) {
        let newValue = sender.value.rounded()
        switch newValue {
        case 0:
            coastLabel.text = "Стоимость 0 - 5000 р."
        case 1:
            coastLabel.text = "Стоимость 0 - 700 р."
        case 2:
            coastLabel.text = "Стоимость 600 - 1300 р."
        case 3:
            coastLabel.text = "Стоимость 1200 - 1800 р."
        case 4:
            coastLabel.text = "Стоимость 1800 - 2600 р."
        case 5:
            coastLabel.text = "Стоимость 2500 - 5000 р."
        default: ()
        }
        coastSlider.setValue(Float(newValue), animated: true)
        getTracksCount()
    }
    
    @IBAction func energySliderValueChanged(_ sender: UISlider) {
        energySlider.setValue(Float(sender.value.rounded()), animated: true)
        getTracksCount()
    }
    
    @IBAction func tempoSliderValueChanged(_ sender: UISlider) {
        let newValue = sender.value.rounded()
        switch newValue {
        case 0:
            tempoLabel.text = "Темп 40 - 250 BPM"
        case 1:
            tempoLabel.text = "Темп 40 - 82 BPM"
        case 2:
            tempoLabel.text = "Темп 82 - 124 Bpm"
        case 3:
            tempoLabel.text = "Темп 124 - 166 BPM"
        case 4:
            tempoLabel.text = "Темп 166 - 208 BPM"
        case 5:
            tempoLabel.text = "Темп 208 - 250 BPM"
        default: ()
        }
        tempoSlider.setValue(Float(newValue), animated: true)
        getTracksCount()
    }
    
    // MARK: Sliders and methods - end
    
    @IBOutlet weak var bpmCountSwitch: UISwitch!
    @IBOutlet weak var hookSwitch: UISwitch!
    @IBOutlet weak var newFirstSwitch: UISwitch!
    @IBOutlet weak var paidTracksSwitch: UISwitch!
    @IBOutlet weak var freeTracksSwitch: UISwitch!
    
    
    @IBAction func switchHookOrNewTap(_ sender: UISwitch) {
        getTracksCount()
    }
    
    @IBAction func freeOrPaidSwitchTap(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            if paidTracksSwitch.isOn { paidTracksSwitch.isOn = false }
        case 1:
            if freeTracksSwitch.isOn { freeTracksSwitch.isOn = false }
        default: ()
        }
        getTracksCount()
    }
    
    
    @IBOutlet weak var bpmCountViewTopConstraint: NSLayoutConstraint!
    
    @IBAction func bpmCountSwitchTap(_ sender: UISwitch) {
        UIView.animate(withDuration: 0.3) {
            self.tempoView.alpha = sender.isOn ? 0 : 1
            self.bpmCountTextField.alpha = sender.isOn ? 1 : 0
        } completion: { _ in
            self.bpmCountViewTopConstraint.constant = sender.isOn ? -60 : 0
        }
    }
    
    @IBOutlet weak var bpmCountTextField: UITextField! {
        didSet {
            bpmCountTextField?.addDoneCancelToolbar()
        }
    }
    
    @IBOutlet var arrayOfPickerButtons: [UIButton]!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var coastLabel: UILabel!
    
    var moodValue: String?
    var genreValue: String?
    var keyValue: String?
    var licenseValue: String?
    
    var delegate: FilterDelegate?

    func pickerValueSelected(value: String, picker: PickerEnum, valueIndex: Int) {
        // назначаем заголовок для нужной кнопки
        arrayOfPickerButtons[picker.rawValue].setTitle(value, for: .normal)
        
        // записываем нужные значения для оптправки дальше потом
        switch picker {
        case .mood:
            moodValue = String(valueIndex)
        case .genre:
            genreValue = String(valueIndex)
        case .key:
            keyValue = String(valueIndex)
        case .license:
            licenseValue = String(valueIndex - 1)
        }
        
        getTracksCount()
    }
    
    // MARK: Установка состояния фильтров после перехода с майн-вью
    var filtersState: [String: String?] = [:]
    
    func setFilters(){
        
        if let temp = filtersState["emotions", default: "none"] {
            if let number = Int(temp) {
                arrayOfPickerButtons[0].setTitle(moodPickerViewData[number - 1], for: .normal)
                moodValue = temp
            }
        }
        
        if let temp = filtersState["ganre", default: "none"] {
            if let number = Int(temp) {
                arrayOfPickerButtons[1].setTitle(genrePickerViewData[number - 1], for: .normal)
                genreValue = temp
            }
        }
        
        if let temp = filtersState["key", default: "none"] {
            if let number = Int(temp) {
                arrayOfPickerButtons[2].setTitle(keyPickerViewData[number - 1], for: .normal)
                keyValue = temp
            }
        }
    }
    
    var filterStateModel: FilterStateModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // imho очень странный момент с моделью установки фильтров, но VC разгрузился
        filterStateModel = FilterStateModel(controller: self)
        // ловим окончание редактирования textfield
        bpmCountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        // set indicator view
        searchActivityIndicator.hidesWhenStopped = true
        searchActivityIndicator.center = searchLabel.center
        searchActivityIndicator.color = .white
        searchActivityIndicator.style = .medium
        view.addSubview(searchActivityIndicator)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //print("DID END EDITING")
        getTracksCount()
    }
    
    // закрыть окно
    @IBAction func closeButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // открываем пикервью с нужными данными
    @IBAction func buttonToPickerTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let pickerViewController = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController else {
            return
        }
        pickerViewController.delegate = self
        
        func setPickerViewController(title: String, data: [String], identifier: PickerEnum) {
            pickerViewController.pickerTitle = title
            pickerViewController.pickerViewData = data
            pickerViewController.pickerIdentifier = identifier
        }
            
        switch sender.tag {
        case 0:
            setPickerViewController(title: "Настроение", data: moodPickerViewData, identifier: .mood)
        case 1:
            setPickerViewController(title: "Жанр", data: genrePickerViewData, identifier: .genre)
        case 2:
            setPickerViewController(title: "Тональность", data: keyPickerViewData, identifier: .key)
        case 3:
            setPickerViewController(title: "Тип лицензии", data: licensePickerViewData, identifier: .license)
        default: ()
        }
        present(pickerViewController, animated: true, completion: nil)
    }
    
    // тап по кнопке Применить
    @IBAction func applyButtonTap(_ sender: UIButton) {
        let filterDictionary = [
            "emotions": moodValue, "ganre": genreValue, "key": keyValue,
            "newFirst": "\(newFirstSwitch.isOn)", "hook": "\(hookSwitch.isOn)",
            "energy": "\(Int(energySlider.value))", "temp": "\(Int(tempoSlider.value))",
            "currBpmStatus": "\(bpmCountSwitch.isOn)", "currBpm": bpmCountTextField.text ?? "0",
            "coast": "\(Int(coastSlider.value))", "typeLicense": licenseValue,
            "getFreeStatus": "\(freeTracksSwitch.isOn)", "getPaidStatus": "\(paidTracksSwitch.isOn)"
        ]

        delegate?.filterValuesSelected(filterDictionary: filterDictionary)
        dismiss(animated: true, completion: nil)
    }
    
    // тап по кнопке Сбросить
    @IBAction func clearFiltersButtonTap(_ sender: UIButton) {
        filterStateModel?.setDefaults(controller: self)
        searchLabel.text = "Найдётся вариантов:"
    }
    
    // метод для получения количества треков после применения какого-то из фильтров на VC
    func getTracksCount() {
        searchActivityIndicator.startAnimating()
        searchLabel.alpha = 0
        let filterDictionary = [
            "emotions": moodValue, "ganre": genreValue, "key": keyValue,
            "newFirst": "\(newFirstSwitch.isOn)", "hook": "\(hookSwitch.isOn)",
            "energy": "\(Int(energySlider.value))", "temp": "\(Int(tempoSlider.value))",
            "currBpmStatus": "\(bpmCountSwitch.isOn)", "currBpm": bpmCountTextField.text ?? "0",
            "coast": "\(Int(coastSlider.value))", "typeLicense": licenseValue,
            "getFreeStatus": "\(freeTracksSwitch.isOn)", "getPaidStatus": "\(paidTracksSwitch.isOn)"
        ]
        var queryItems: [URLQueryItem] = []
        
        for filterAttribute in filterDictionary {
            if let attributeValue = filterAttribute.value {
                queryItems.append(URLQueryItem(name: filterAttribute.key, value: attributeValue))
            }
        }
        
        networkModel.getTracks(queryItems: queryItems) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let tempTuple):
                    if let count = tempTuple.1 {
                        self.searchLabel.text = "Найдётся вариантов: " + count
                    }
                case .failure(let error):
                    print(error)
                }
                self.searchActivityIndicator.stopAnimating()
                self.searchLabel.alpha = 1
            }
        }
        
    }
    
}



