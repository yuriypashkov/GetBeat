
import UIKit

class FilterViewController: UIViewController, PickerDelegate {

    @IBOutlet var arrayOfPickerButtons: [UIButton]!
    
    var moodValue: String?
    var genreValue: String?
    
    var delegate: FilterDelegate?

    func pickerValueSelected(value: String, buttonTag: Int, valueIndex: Int) {
        // назначаем заголовок для нужной кнопки
        arrayOfPickerButtons[buttonTag].setTitle(value, for: .normal)
        
        // записываем нужные значения для оптправки дальше потом
        switch buttonTag {
        case 0:
            moodValue = String(valueIndex)
        case 1:
            genreValue = String(valueIndex)
        default: ()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // открываем пикервью с нужными данными
    @IBAction func buttonToPickerTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let pickerViewController = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as? PickerViewController else {
            return
        }
        pickerViewController.delegate = self
            
        switch sender.tag {
        case 0:
            pickerViewController.pickerTitle = "Настроение"
            pickerViewController.pickerViewData = ["Агрессивное", "Расслабленное", "Радостное", "Мрачное", "Осеннее", "Мечтательное", "Грустное", "Позитивное", "Летнее", "Спокойное", "I'm so fresh", "Решительное"]
            pickerViewController.pickerIdentifier = 0
        case 1:
            pickerViewController.pickerTitle = "Жанр"
            pickerViewController.pickerViewData = ["Grime", "Trap", "Old school", "Classic", "Cloud/Trill", "RnB", "Pop", "Soul/Funk", "Club/Deep House", "Jazz Rap", "Underground", "Crunk/Dirty South", "Hardcore", "Experimental", "Dubstep"]
            pickerViewController.pickerIdentifier = 1
        default: ()
        }
        
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func applyButtonTap(_ sender: UIButton) {
        let filterDictionary = ["emotions": moodValue, "ganre": genreValue]
        
        delegate?.filterValuesSelected(filterDictionary: filterDictionary)
        dismiss(animated: true, completion: nil)
    }
}



