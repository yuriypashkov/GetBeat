
import Foundation

protocol PickerDelegate {
    func pickerValueSelected(value: String, picker: PickerEnum, valueIndex: Int)
}

protocol FilterDelegate {
    func filterValuesSelected(filterDictionary: [String: String?])
}
