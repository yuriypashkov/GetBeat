
import Foundation

// это ужасно но оно работает
struct FilterStateModel {
    
    func setDefaults(controller: FilterViewController) {
        // обнуляем внешний вид
        for button in controller.arrayOfPickerButtons {
            button.setTitle("Выбрать", for: .normal)
        }
        // switchers
        controller.bpmCountSwitch.isOn = false
        controller.newFirstSwitch.isOn = false
        controller.hookSwitch.isOn = false
        controller.bpmCountSwitchTap(controller.bpmCountSwitch)
        controller.bpmCountTextField.text = ""
        // sliders
        controller.coastSlider.value = 0
        controller.tempoSlider.value = 0
        controller.energySlider.value = 0
        controller.coastLabel.text = "Стоимость 0 - 5000 р."
        controller.tempoLabel.text = "Темп 40 - 250 Bpm"
        
        // обнуляем значения
        controller.moodValue = nil
        controller.genreValue = nil
        controller.keyValue = nil
        controller.licenseValue = nil
    }
    
    init(controller: FilterViewController) {
        
        if let temp = controller.filtersState["emotions", default: "none"] {
            if let number = Int(temp) {
                controller.arrayOfPickerButtons[0].setTitle(moodPickerViewData[number - 1], for: .normal)
                controller.moodValue = temp
            }
        }
        
        if let temp = controller.filtersState["ganre", default: "none"] {
            if let number = Int(temp) {
                controller.arrayOfPickerButtons[1].setTitle(genrePickerViewData[number - 1], for: .normal)
                controller.genreValue = temp
            }
        }

        if let temp = controller.filtersState["key", default: "none"] {
            if let number = Int(temp) {
                controller.arrayOfPickerButtons[2].setTitle(keyPickerViewData[number - 1], for: .normal)
                controller.keyValue = temp
            }
        }
        
        if let temp = controller.filtersState["newFirst", default: "none"] {
            switch temp {
            case "true":
                controller.newFirstSwitch.isOn = true
            case "false":
                controller.newFirstSwitch.isOn = false
            default: ()
            }
        }
        
        if let temp = controller.filtersState["hook", default: "none"] {
            switch temp {
            case "true":
                controller.hookSwitch.isOn = true
            case "false":
                controller.hookSwitch.isOn = false
            default: ()
            }
        }
        
        if let temp = controller.filtersState["energy", default: "none"] {
            if let number = Float(temp) {
                controller.energySlider.value = number
            }
        }
        
        if let temp = controller.filtersState["temp", default: "none"] {
            if let number = Float(temp) {
                controller.tempoSlider.value = number
                controller.tempoSliderValueChanged(controller.tempoSlider)
            }
        }
        
        if let temp = controller.filtersState["currBpmStatus", default: "none"] {
            switch temp {
            case "true":
                controller.bpmCountSwitch.isOn = true
            case "false":
                controller.bpmCountSwitch.isOn = false
            default: ()
            }
            controller.bpmCountSwitchTap(controller.bpmCountSwitch)
        }
        
        if let temp = controller.filtersState["currBpm", default: ""] {
            controller.bpmCountTextField.text = temp
        }
        
        if let temp = controller.filtersState["coast", default: "none"] {
            if let number = Float(temp) {
                controller.coastSlider.value = number
                controller.coastSliderValueChanged(controller.coastSlider)
            }
        }
        
        if let temp = controller.filtersState["typeLicense", default: "none"] {
            if let number = Int(temp) {
                controller.arrayOfPickerButtons[3].setTitle(licensePickerViewData[number], for: .normal)
                controller.licenseValue = temp
            }
        }
        
    }
    
}
