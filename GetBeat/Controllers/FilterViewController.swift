
import UIKit

enum PickerEnum: Int {
    case mood
    case genre
    case key
    case license
}

class FilterViewController: UIViewController, PickerDelegate {
    
    @IBOutlet weak var tempoView: UIView!
    
    // MARK: Sliders outlets and methods - begin
    @IBOutlet weak var energySlider: UISlider!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var coastSlider: UISlider!
    
    
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
    }
    
    @IBAction func energySliderValueChanged(_ sender: UISlider) {
        energySlider.setValue(Float(sender.value.rounded()), animated: true)
    }
    
    @IBAction func tempoSliderValueChanged(_ sender: UISlider) {
        let newValue = sender.value.rounded()
        switch newValue {
        case 0:
            tempoLabel.text = "Темп 40 - 250 Bpm"
        case 1:
            tempoLabel.text = "Темп 40 - 82 Bpm"
        case 2:
            tempoLabel.text = "Темп 82 - 124 Bpm"
        case 3:
            tempoLabel.text = "Темп 124 - 166 Bpm"
        case 4:
            tempoLabel.text = "Темп 166 - 208 Bpm"
        case 5:
            tempoLabel.text = "Темп 208 - 250 Bpm"
        default: ()
        }
        tempoSlider.setValue(Float(newValue), animated: true)
    }
    
    // MARK: Sliders and methods - end
    
    @IBOutlet weak var bpmCountSwitch: UISwitch!
    @IBOutlet weak var hookSwitch: UISwitch!
    @IBOutlet weak var newFirstSwitch: UISwitch!
    
    
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
            "coast": "\(Int(coastSlider.value))", "typeLicense": licenseValue
        ]

        delegate?.filterValuesSelected(filterDictionary: filterDictionary)
        dismiss(animated: true, completion: nil)
    }
    
    // тап по кнопке Сбросить
    @IBAction func clearFiltersButtonTap(_ sender: UIButton) {
        filterStateModel?.setDefaults(controller: self)
    }
    
}



