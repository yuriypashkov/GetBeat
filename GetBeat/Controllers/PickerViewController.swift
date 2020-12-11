
import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var pickerTitleLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerTitle: String?
    var pickerViewData: [String] = []
    var pickerIdentifier: Int?
    
    var delegate: PickerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pickerTitle = pickerTitle {
            pickerTitleLabel.text = pickerTitle
        }
      
    }

    @IBAction func applyButtonTap(_ sender: UIButton) {
        guard let buttonTag = pickerIdentifier else { return }
        let index = pickerView.selectedRow(inComponent: 0)
        
        // атрибут valueIndex нужен для запроса к бэку, ибо там запрос не по названиям, а по цифровому соответствию
        delegate?.pickerValueSelected(value: pickerViewData[index], buttonTag: buttonTag, valueIndex: index + 1)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    
}

